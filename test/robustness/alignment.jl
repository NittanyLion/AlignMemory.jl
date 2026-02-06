module TestAlignment
using MemoryLayouts
using Test

struct Mix
    a::Vector{Int8}   # 1 byte elements
    b::Vector{Int64}  # 8 byte elements
end

function run()
    @testset "Alignment Stress Test" begin
        
        # weird alignments
        alignments = [1, 2, 4, 8, 16, 32, 64, 128]
        
        for align in alignments
            println("  Testing alignment: $align")
            m = Mix(rand(Int8, 11), rand(Int64, 11))
            
            m_l = layout(m, alignment=align)
            
            pa = pointer(m_l.a)
            pb = pointer(m_l.b)
            
            # Check alignment of start of array 'a'
            # Note: The block itself is aligned, but 'a' is at offset 0 (probably).
            @test mod(UInt(pa), align) == 0
            
            # Check alignment of start of array 'b'
            @test mod(UInt(pb), align) == 0
            
            # Check padding calculation
            # Size of a is 11 bytes.
            # Next start must be aligned to 'align' (layout rule) AND sizeof(eltype(b)) (hardware rule).
            
            nominal_end = MemoryLayouts.alignup(sizeof(m_l.a), align)
            expected_offset = MemoryLayouts.alignup(nominal_end, sizeof(eltype(m.b)))
            
            actual_offset = Int(pb) - Int(pa)
            
            @test actual_offset == expected_offset
        end
    end
end
end
