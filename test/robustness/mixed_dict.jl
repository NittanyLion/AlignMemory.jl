module TestMixedDict
using MemoryLayouts
using Test

function run()
    @testset "Mixed Dict Types" begin
        # Dict with mixed value types
        d = Dict{Symbol, Any}(
            :a => rand(100),         # Float64
            :b => rand(Int, 100),    # Int
            :c => "Not an array",    # String
            :d => ["String", "Arr"], # Array of strings (not bitstype)
            :e => rand(Float32, 50)  # Float32
        )
        
        println("  Layout mixed dict...")
        d_l = layout(d)
        
        # Bitstype arrays should be moved
        p_a = pointer(d_l[:a])
        p_b = pointer(d_l[:b])
        p_e = pointer(d_l[:e])
        
        # Non-bitstype should be same (or deepcopied? layout copies the structure)
        
        @test d_l[:c] == d[:c] # Strings are immutable/value equal
        @test d_l[:d] == d[:d]
        
        # Check if :d array was moved. Element is String (not bitstype).
        # Should NOT be moved, but the array object itself might be the same?
        # Layout copies the dict, then iterates and replaces.
        # If transferadvance returns x, then d_l[:d] is the exact same array object as d[:d] (if d was shallow copied) 
        # OR d_l[:d] is the copy of d[:d] if layout(dict) does deepcopy?
        # Source says: layout(s::AbstractDict) = layout!(copy(s)...)
        # copy(dict) shallow copies. So keys point to same values.
        # So if transferadvance returns x, d_l[:d] === d[:d].
        
        @test d_l[:d] === d[:d] 
        
        # Bitstype arrays should be NEW arrays (wrappers)
        @test d_l[:a] !== d[:a]
        @test d_l[:b] !== d[:b]
        
        # Check they are in the block
        diff_ab = abs(Int(p_a) - Int(p_b))
        @test diff_ab > 0
        
        # They should be packed together. 
        # Check bounds.
        stats = layoutstats(d)
        # Verify stats matches reality roughly
        println("  Stats: $stats")
        
        # Check that :a, :b, :e are in the range minaddr..maxaddr
        # Note: the stats are computed on the ORIGINAL object 'd'.
        # The new object d_l will have new addresses.
        
        min_ptr = min(UInt(p_a), UInt(p_b), UInt(p_e))
        max_ptr = max(UInt(p_a), UInt(p_b), UInt(p_e))
        span = max_ptr - min_ptr
        
        println("  Span: $span")
        # Span should be <= sum of sizes + padding
        
        total_size = sizeof(d_l[:a]) + sizeof(d_l[:b]) + sizeof(d_l[:e])
        # Allow padding
        @test span >= sizeof(d_l[:a]) # At least one object size
        @test span < total_size * 2 # Shouldn't be wildly apart
    end
end
end
