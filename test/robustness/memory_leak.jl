module TestMemoryLeak
using MemoryLayouts
using Test

struct BigStruct
    x::Vector{Float64}
    y::Vector{Int}
end

function run()
    @testset "Memory Leak Check" begin
        
        function allocate_and_drop()
            s = BigStruct(rand(1024*1024), rand(Int, 1024*1024)) # ~16MB
            l = layout(s)
            return nothing
        end
        
        println("  Warming up GC...")
        allocate_and_drop()
        GC.gc()
        
        initial_mem = Base.gc_live_bytes()
        println("  Initial memory: $(initial_mem / 1024^2) MB")
        
        println("  Running 50 iterations of allocation (~800MB processed)...")
        for i in 1:50
            allocate_and_drop()
            if i % 10 == 0
                GC.gc()
            end
        end
        GC.gc()
        GC.gc() # Double GC to be sure
        
        final_mem = Base.gc_live_bytes()
        println("  Final memory: $(final_mem / 1024^2) MB")
        
        # Check for growth. 
        # 16MB * 50 = 800MB. If leaked, it would be massive.
        # We allow small overhead/fluctuation (e.g. 50MB).
        growth = final_mem - initial_mem
        @test growth < 50 * 1024 * 1024 
        if growth > 50 * 1024 * 1024 
            @warn "Possible memory leak detected: growth of $(growth/1024^2) MB"
        end
    end
end
end
