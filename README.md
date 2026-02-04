# AlignMemory

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://NittanyLion.github.io/AlignMemory.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://NittanyLion.github.io/AlignMemory.jl/dev/)
[![Build Status](https://github.com/NittanyLion/AlignMemory.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/NittanyLion/AlignMemory.jl/actions/workflows/CI.yml?query=branch%3Amain)

## Related Packages

There are several other Julia packages that address memory layout and array storage, though with different focuses:

*   [RaggedArrays.jl](https://github.com/mbauman/RaggedArrays.jl): Provides contiguous memory storage specifically for arrays of arrays (jagged/ragged arrays).
*   [BlockArrays.jl](https://github.com/JuliaArrays/BlockArrays.jl): Focuses on partitioning arrays into blocks. The `BlockedArray` type stores the full array contiguously with a block structure overlaid.
*   [Strided.jl](https://github.com/Jutho/Strided.jl): Specialized for efficient strided array views and operations.
*   [UnsafeArrays.jl](https://github.com/JuliaArrays/UnsafeArrays.jl): Provides stack-allocated pointer-based array views.
*   [Buffers.jl](https://github.com/fkfest/Buffers.jl): Manages buffer allocation/deallocation for multidimensional arrays.

**AlignMemory.jl** differs by focusing specifically on physically aligning multiple independent arrays (which may be fields in a struct) into a single contiguous memory block to optimize cache usage, while using `unsafe_wrap` to present them as standard Julia arrays.
