module AlignMemoryInlineStringsExt

using AlignMemory
using InlineStrings

function AlignMemory.transferadvance( x, TT :: Type{𝒯}, ■ :: Vector{UInt8}, offset :: Ref{Int} ) where 𝒯 <: InlineString
    x isa AbstractArray || return x
    length( x ) == 0 && return x
    ▶ = pointer(■) + offset[]
    flat = unsafe_wrap( Array, Ptr{𝒯}( ▶ ), length( x ); own = false )
    finalizer(_ -> ( ■; nothing ), flat)
    dest = reshape( flat, size( x ) )
    offset[] += length( x ) * sizeof( 𝒯 )
    copyto!( dest, x )
    return AlignMemory.newarrayofsametype( x, dest )
end

end
