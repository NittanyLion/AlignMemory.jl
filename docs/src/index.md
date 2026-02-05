```@meta
CurrentModule = MemoryLayouts
```

# MemoryLayouts.jl 🧠⚡

**Optimize your memory layout for maximum cache efficiency.**

Documentation for [MemoryLayouts](https://github.com/NittanyLion/MemoryLayouts.jl).

## 🚀 The Problem vs. The Solution

Standard collections in Julia (`Dicts`, `Arrays` of `Arrays`, `structs`) often scatter data across memory, causing frequent **cache misses**. `MemoryLayouts.jl` packs this data into contiguous blocks.

### 🔮 How it works

| Function | Description | Analogy |
| :--- | :--- | :--- |
| **`alignmem(x)`** | Aligns immediate fields of `x` | Like `copy(x)` but packed |
| **`deepalignmem(x)`** | Recursively aligns nested structures | Like `deepcopy(x)` but packed |

## Usage

The package provides two exported functions: `alignmem` and `deepalignmem`. The distinction is that `alignmem` only applies to top level objects, whereas `deepalignmem` applies to objects at all levels. The two examples below demonstrate their use.

### Example for `alignmem`

The example below demonstrates how to use `alignmem`.

```@example
using MemoryLayouts, BenchmarkTools, StyledStrings

function original( A = 10_000, L = 100, S = 5000)
    x = Vector{Vector{Float64}}(undef, A)
    s = Vector{Vector{Float64}}(undef, A)
    for i ∈ 1:A
        x[i] = rand( L )
        s[i] = rand( S )
    end
    return x
end

function computeme( X )
    Σ = 0.0
    for x ∈ X 
        Σ += x[5] 
    end
    return Σ
end

print( styled"{(fg=0xff9999):original}: " ); @btime computeme( X ) setup=(X = original();)
print( styled"{(fg=0x99ff99):alignmem}: " ); @btime computeme( X ) setup=(X = alignmem( original());)
;
```

### Example for `deepalignmem`

The example below illustrates the use of `deepalignmem`.

```@example
using MemoryLayouts, BenchmarkTools, StyledStrings


struct 𝒮{X,Y,Z}
    x :: X
    y :: Y 
    z :: Z
end


function original( A = 10_000, L = 100, S = 5000)
    x = Vector{Vector{Float64}}(undef, A)
    s = Vector{Vector{Float64}}(undef, A)
    for i ∈ 1:A
        x[i] = rand( L )
        s[i] = rand( S )
    end
    return 𝒮( [x[i] for i ∈ 1:div(A,3)], [ x[i] for i ∈ div(A,3)+1:div(2*A,3)], [x[i] for i ∈ div(2*A,3)+1:A ] )
end

function computeme( X )
    Σ = 0.0
    for x ∈ X.x  
        Σ += x[5] 
    end
    for y ∈ X.y 
        Σ += y[37]
    end
    for z ∈ X.z 
        Σ += z[5] 
    end
    return Σ
end

print( styled"{(fg=0xff9999):original}: " ); @btime computeme( X ) setup=(X = original();)
print( styled"{(fg=0x99ff99):alignmem}: " ); @btime computeme( X ) setup=(X = alignmem( original());)
print( styled"{(fg=0x9999ff):deepalignmem}: " ); @btime computeme( X ) setup=(X = deepalignmem( original());)
;
```

## 🔌 Compatibility & Extensions

* `MemoryLayouts.jl` is further compatible with 
  - [`AxisKeys`](https://github.com/mcabbott/AxisKeys.jl)
  - [`InlineStrings`](https://github.com/JuliaStrings/InlineStrings.jl)
  - [`NamedDimsArrays`](https://github.com/invenia/NamedDims.jl) 
  - [`OffsetArrays`](https://github.com/JuliaArrays/OffsetArrays.jl)
* this assumes that those packages are loaded by the user

## Function documentation

```@docs
alignmem
deepalignmem
```



## ⚠️ Critical Usage Note

!!! warning "Memory Contiguity"
    1. Aligned arrays share a single contiguous memory block.
    2. **Resizing** aligned arrays (`push!`, `append!`) will cause them to be reallocated elsewhere, breaking memory contiguity.
    3. Any arrays that you may wish to reassign or resize at a later point in time should be specified in the optional `exclude` argument.
    
    *Implementation Note:* The code allocates a single chunk of memory (`Vector{UInt8}`) to hold all the data. This memory is kept alive by the aligned arrays.

