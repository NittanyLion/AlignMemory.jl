module MemoryLayoutsInlineStringsExt

using MemoryLayouts
using InlineStrings

function MemoryLayouts.transferadvance( x, TT :: Type{𝒯}, ■ :: Vector{UInt8}, offset :: Ref{Int}, alignment :: Int ) where 𝒯 <: InlineString
    x isa AbstractArray || return x
    length( x ) == 0 && return x
    ▶ = pointer( ■ ) + offset[]
    flat = unsafe_wrap( Array, Ptr{𝒯}( ▶ ), length( x ); own = false )
    finalizer( _ -> ( ■; nothing ), flat )
    dest = reshape( flat, size( x ) )
    offset[] += MemoryLayouts.alignup( length( x ) * sizeof( 𝒯 ), alignment )
    copyto!( dest, x )
    return MemoryLayouts.newarrayofsametype( x, dest )
end

end
