using AlignMemory
using AxisKeys



struct S{X,Y}
    x :: X 
    y :: Y 
end

x = [randn(10,3), 0, KeyedArray( randn(13,4); rw = 1:13, cl = [:a,:b,:c,:d] )]
z = zeros( 100_000_000 )
y = randn(7,8)

s = S( x, y )

println( div( abs( Int(pointer( s.x[3].data.data )) - Int(pointer( s.y )) ), 1 ) )
println( div( abs( Int(pointer( s.x[3].data.data )) - Int(pointer( z )) ), 1 ) )

s2 = DeepAlignMem( s )

println( div( abs( Int(pointer( s2.x[3].data.data )) - Int(pointer( s2.y )) ), 1 ) )
println( div( abs( Int(pointer( s2.x[3].data.data )) - Int(pointer( z )) ), 1 ) )

