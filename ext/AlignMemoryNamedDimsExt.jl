module AlignMemoryNamedDimsExt

using AlignMemory
using NamedDims

AlignMemory.NewArrayOfSameType( old::NamedDimsArray, new_data ) = NamedDimsArray( AlignMemory.NewArrayOfSameType(parent(old), new_data), dimnames(old) )

end
