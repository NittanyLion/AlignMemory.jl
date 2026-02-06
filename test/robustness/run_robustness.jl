using Pkg
Pkg.activate(".")
using Test
using MemoryLayouts

# Include all test modules
include("cycles.jl")
include("aliasing.jl")
include("memory_leak.jl")
include("alignment.jl")
include("large_struct.jl")
include("mixed_dict.jl")

println("================================================================")
println("Running Robustness Tests for MemoryLayouts.jl")
println("================================================================")

# Run them
try
    TestCycles.run()
catch e
    println("TestCycles failed with error: $e")
end

println("\n----------------------------------------------------------------\n")

try
    TestAliasing.run()
catch e
    println("TestAliasing failed with error: $e")
end

println("\n----------------------------------------------------------------\n")

try
    TestMemoryLeak.run()
catch e
    println("TestMemoryLeak failed with error: $e")
end

println("\n----------------------------------------------------------------\n")

try
    TestAlignment.run()
catch e
    println("TestAlignment failed with error: $e")
end

println("\n----------------------------------------------------------------\n")

try
    TestLargeStruct.run()
catch e
    println("TestLargeStruct failed with error: $e")
end

println("\n----------------------------------------------------------------\n")

try
    TestMixedDict.run()
catch e
    println("TestMixedDict failed with error: $e")
end

println("\n================================================================")
println("Done.")
