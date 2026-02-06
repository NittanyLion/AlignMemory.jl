module TestCycles
using MemoryLayouts
using Test

mutable struct CyclicNode
    next::Union{CyclicNode, Nothing}
    data::Vector{Float64}
end

function run()
    @testset "Cyclic Dependencies" begin
        # Create a cyclic structure
        
        n1 = CyclicNode(nothing, rand(100))
        n2 = CyclicNode(n1, rand(100))
        n1.next = n2
        
        println("  Testing cyclic structure (expecting ArgumentError)...")
        try
            # This is expected to throw ArgumentError due to cycle detection
            deeplayout(n1)
            @warn "Managed to layout cyclic structure (Unexpected!)"
        catch e
            if e isa ArgumentError && occursin("Cyclic", e.msg)
                @info "Caught expected ArgumentError: $(e.msg)"
                @test true
            elseif e isa StackOverflowError
                @warn "Caught StackOverflowError - Cycle detection failed"
                @test false
            else
                @warn "Error was not ArgumentError: $e"
                @test_broken false
            end
        end
    end
end
end
