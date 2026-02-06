module TestAliasing
using MemoryLayouts
using Test

struct AliasContainer
    a::Vector{Float64}
    b::Vector{Float64}
end

function run()
    @testset "Aliasing / Shared Data" begin
        
        data = rand(100)
        # Both fields point to the same array
        c = AliasContainer(data, data)
        
        @test c.a === c.b
        
        println("  Layout on aliased fields...")
        c_aligned = @test_logs (:warn, r"Shared reference detected") layout(c)
        
        # Check that aliasing is lost
        # This is an "advising users" finding: aliasing is not preserved.
        @test c_aligned.a !== c_aligned.b
        @test c_aligned.a == c_aligned.b # Content is same
        
        # Verify they are in the same block but distinct regions
        pa = pointer(c_aligned.a)
        pb = pointer(c_aligned.b)
        
        # They should be offset by size
        dist = abs(Int(pb) - Int(pa))
        @test dist >= sizeof(c_aligned.a)
    end
end
end
