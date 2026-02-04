module AlignMemoryAxisKeysExt

using AlignMemory
using AxisKeys

AlignMemory.NewArrayOfSameType( old::KeyedArray, new_data ) = KeyedArray( AlignMemory.NewArrayOfSameType(parent(old), new_data), axiskeys(old) )

end
