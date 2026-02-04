function AlignMem( s :: AbstractDict )
    D = copy( s )
    AlignMem!( D, keys( D )... )
    return D
end

computesize_deep( :: Any ) = 0
computesize_deep( x :: AbstractArray ) = isbitstype( eltype( x ) ) ? sizeof( eltype( x ) ) * length( x ) : sum( computesize_deep, x )
function computesize_deep( x :: T ) where T
    isbitstype( T ) && return 0
    isstructtype( T ) || return 0
    return sum( computesize_deep( getfield( x, k ) ) for k ∈ fieldnames( T ) )
end

deep_transfer( x :: Any, ▶ :: Ptr, offset :: Ref{Int}, owned :: Ref{Bool} ) = x

function deep_transfer( x :: AbstractArray{T}, ▶ :: Ptr, offset :: Ref{Int}, owned :: Ref{Bool} ) where T
    if isbitstype( T )
         sz = sizeof( T ) * length( x )
         sz == 0 && return x
         ▶now = ▶ + offset[]
         should_own = !owned[]
         flat = unsafe_wrap( Array, Ptr{T}( ▶now ), length( x ); own = should_own )
         if should_own
             owned[] = true
         end
         dest = reshape( flat, size( x ) )
         offset[] += sz
         copyto!( dest, x )
         return NewArrayOfSameType( x, dest )
    else
        return map( el -> deep_transfer( el, ▶, offset, owned ), x )
    end
end

function deep_transfer( x :: T, ▶ :: Ptr, offset :: Ref{Int}, owned :: Ref{Bool} ) where T
    isbitstype( T ) && return x
    if isstructtype( T )
        return T( ( deep_transfer( getfield( x, k ), ▶, offset, owned ) for k ∈ fieldnames( T ) )... )
    end
    return x
end

function DeepAlignMem( x )
    sz = computesize_deep( x )
    sz == 0 && return deepcopy( x )
    ▶ = Base.Libc.malloc( sz )
    offset = Ref( 0 )
    owned = Ref( false )
    return deep_transfer( x, ▶, offset, owned )
end

using DataStructures, StyledStrings
# const Collection = Union{AbstractArray, AbstractDict, AbstractSet, Tuple}

export AlignMem!, ancestor, AlignMem, DeepAlignMem

# const SymbolInt = Union{ Symbol, Int }
computesize( :: Any ) = 0
computesize( x :: AbstractArray ) = isbitstype( eltype( x ) ) ? sizeof( eltype( x ) ) * length( x ) : 0



"""
    NewArrayOfSameType(old, new_data)

Create a new array wrapper of the same type and structure as `old`, but wrapping `new_data`.
This function recursively peels off array wrappers (like `KeyedArray`, `OffsetArray`, `NamedDimsArray`)
to reach the underlying data, replaces it with `new_data`, and then re-wraps it.

# Supported Wrappers
- `KeyedArray`: preserves axis keys.
- `OffsetArray`: preserves offsets.
- `NamedDimsArray`: preserves dimension names.
- `Any`: fallback that returns `new_data` directly (bottom of recursion).
"""
NewArrayOfSameType( ::Any, new_data ) = new_data




transferadvance!( D :: AbstractDict, x, TT, ▶ :: Ptr, :: Ref{Int} ) = nothing


function transferadvance!( D :: AbstractDict, x, TT :: Type{𝒯}, ▶ :: Ptr, offset :: Ref{Int} ) where 𝒯 <: Number
    @assert D[x] isa AbstractArray
    length( D[x] ) == 0 && return nothing
    ▶now = ▶ + offset[]
    flat = unsafe_wrap( Array, Ptr{𝒯}( ▶now ), length( D[x] ); own = offset[] == 0 )
    dest = reshape( flat, size( D[x] ) )
    offset[] += length( D[x] ) * sizeof( 𝒯 )
    copyto!( dest, D[x] )
    D[x] = NewArrayOfSameType( D[x], dest )
    return nothing
end


function transferadvance!( D :: AbstractDict, x, ▶ :: Ptr, offset :: Ref{Int} )
    @assert haskey( D, x )
    D[x] isa AbstractArray || return nothing
    return transferadvance!( D, x, eltype( D[x] ), ▶, offset )
end


"""
    AlignMem!(D::AbstractDict, X...)

Replaces the arrays stored in dictionary `D` at keys `X` with new arrays that are contiguous in memory.

This function:
1. Calculates the total size needed for all arrays in `X`.
2. Allocates a single block of memory using `Libc.malloc` to hold all the data.
3. Recursively copies the data from the old arrays into this new contiguous block.
4. Replaces `D[x]` with a new array wrapper (preserving type, keys, offsets, etc.) that points to the new memory.

# Arguments
- `D`: The dictionary containing the arrays.
- `X...`: A list of symbols (keys in `D`) identifying which arrays to align.

# Notes
- The first array (with offset 0) takes ownership of the `malloc`'d memory (`own=true`).
- Other arrays point to the same block but do not own it.
- This arrangement is safe as long as the first array is kept alive.
"""
function AlignMem!( D :: AbstractDict, X... )
    needed = 0
    for x ∈ X
        @assert haskey( D, x )
        needed += computesize( D[x] )
    end
    ▶ = Base.Libc.malloc( needed )
    offset = Ref(0)
    for x ∈ X
        transferadvance!( D, x, ▶, offset )
    end
    return nothing
end

@info styled"{(fg=white,bg=0x000000),bold:{(fg=0x00ffff):resizing arrays in structs with aligned memory} will {red:break memory contiguity}: it is {(fg=0x08FF08,bg=0x000000):not} otherwise {(fg=0x08FF08,bg=0x000000):unsafe} (examples are using {(fg=0xfff01f,bg=0x000000):push!} or {(fg=0xfff01f,bg=0x000000):append!})}" 


function AlignMem( s :: AbstractArray{T} ) where T
    isbitstype( T ) && return s
    fn = eachindex( s ) 
    D = OrderedDict( k => s[k] for k ∈ fn )
    AlignMem!( D, fn... )
    res = similar(s)
    for k ∈ fn
        res[k] = D[k]
    end
    return res
end

function AlignMem( s :: T ) where T
    isbitstype( T ) && return s 
    if !isstructtype( T ) 
        @warn styled"can only {red:struct types} and {red:array types} at this point" maxlog = 1
        return s 
    end
    fn = fieldnames( T )
    D = OrderedDict( k => getfield( s, k ) for k ∈ fn )
    AlignMem!( D, fn... )
    return T( ( D[k] for k ∈ fn )... )
end




