module TestLargeStruct
using MemoryLayouts
using Test

struct TreeNode
    children::Vector{TreeNode}
    payload::Vector{Float64}
end

function run()
    @testset "Deeply Nested Large Struct" begin
        # Create a deep tree
        
        depth = 10
        fanout = 2
        
        function make_tree(d)
            if d == 0
                return TreeNode(TreeNode[], rand(10))
            else
                return TreeNode([make_tree(d-1) for _ in 1:fanout], rand(10))
            end
        end
        
        println("  Building tree (depth=$depth, fanout=$fanout)...")
        root = make_tree(depth)
        
        println("  Deep layout execution...")
        
        @time l_root = deeplayout(root)
        
        # Verify integrity of a leaf
        # We need to traverse down to find a leaf.
        function get_leaf(node)
            if isempty(node.children)
                return node
            else
                return get_leaf(node.children[1])
            end
        end
        
        leaf_orig = get_leaf(root)
        leaf_layout = get_leaf(l_root)
        
        @test leaf_orig.payload == leaf_layout.payload
        @test pointer(leaf_orig.payload) != pointer(leaf_layout.payload)
        
        p_root = pointer(l_root.payload)
        p_leaf = pointer(leaf_layout.payload)
        
        println("  Root ptr: $p_root")
        println("  Leaf ptr: $p_leaf")
        
        # They should be relatively close (within total size)
        diff = abs(Int(p_leaf) - Int(p_root))
        println("  Diff: $diff bytes")
        
        # Calculate total size expected
        stats = deeplayoutstats(root)
        println("  Stats: $stats")
        
        @test diff < stats.summary.bytes + 1000 # Margin
    end
end
end
