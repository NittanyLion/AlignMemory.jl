# objectives

* add a version of `AlignMem` that operates on `AbstractDict`
* create `DeepAlignMem` versions of `AlignMem`

# requirements

## AlignMem

* same as the other versions of `AlignMem` but it should work on any `AbstractDict`

## DeepAlignMem

* `DeepAlignMem` should be to `AlignMem` what `deepcopy` is to `copy` in the sense described below
* `DeepAlignMem` should align the memory of elements at the top level, like `AlignMem`, but should also align it with any elements further down in the hierarchy
* consider the following example
    ```julia
        struct S{X,Y}
            x :: X
            y :: Y
        end

        s = S( [ randn(3,4), 0, [rand(1:2,20) for i ∈ 1:3] ], randn(8,3) )
        s2 = DeepAlignMem( s )
    ```
* so the five numerical arrays in `s2` should be contiguous in memory
  

# tasks

* make it so, Dr. Spock

