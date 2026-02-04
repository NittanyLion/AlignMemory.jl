module AlignMemoryOffsetArraysExt

using AlignMemory
using OffsetArrays

AlignMemory.NewArrayOfSameType( old::OffsetArray, new_data ) = OffsetArray( AlignMemory.NewArrayOfSameType(parent(old), new_data), old.offsets... )

end
