using Pkg
Pkg.activate("examples")
Pkg.develop(path=joinpath(@__DIR__, ".."))  # MemoryLayouts.jl
Pkg.add("BorrowChecker") # Use registry version instead of local dev

using MemoryLayouts
using BorrowChecker

println("Environment setup complete.")
println("MemoryLayouts version: ", Pkg.project().dependencies["MemoryLayouts"])
println("BorrowChecker version: ", Pkg.project().dependencies["BorrowChecker"])

# --- Unsafe Scenario (Baseline) ---

# We will simulate the behavior of MemoryLayouts where an 'Owner' holds the actual data,
# and a 'Borrower' (View) holds a pointer or reference to it.

mutable struct UnsafeOwner
    data::Vector{Int}
end

struct UnsafeBorrower
    view::SubArray
end

function get_borrower(owner::UnsafeOwner)
    # In reality this would be more complex, but here we just take a view
    return UnsafeBorrower(view(owner.data, 1:length(owner.data)))
end

function unsafe_demo()
    println("\n--- Unsafe Demo (Pure Julia) ---")
    owner = UnsafeOwner([1, 2, 3, 4, 5])
    borrower = get_borrower(owner)
    
    println("Borrower view before drop: ", borrower.view)
    
    # In pure Julia, setting owner = nothing doesn't immediately free memory due to GC.
    # However, if UnsafeOwner managed manual memory (Libc.malloc), this would be a segfault.
    # We simulate the 'hazard' by simply nulling the reference.
    
    owner = nothing 
    GC.gc() # Encourage cleanup (though borrower still holds a reference so it won't actually free)
    
    println("Borrower view after drop (unsafe but valid in GC languages): ", borrower.view)
    println("In a manual memory context, this would be Use-After-Free.")
end

unsafe_demo()

# --- BorrowChecker Integration (Safety) ---

# We now use `BorrowChecker.@safe` to enforce ownership rules.
# We will define a function that attempts the same pattern but is checked by BorrowChecker.

# In the BorrowChecker model:
# 1. 'Owner' objects should be treated as resources that can be moved or borrowed.
# 2. Creating a 'Borrower' (View) constitutes a borrow.
# 3. If we drop (move away or end lifetime of) the Owner, the Borrower should be invalid.

# Note: BorrowChecker.jl is experimental. The `@safe` macro analyzes the function body.

@safe function safe_demo_attempt()
    println("\n--- Safe Demo (BorrowChecker Enforced) ---")
    
    # Create an owner (simulating a unique resource)
    # We use a Ref to simulate a mutable heap resource that we want to track
    # @own needs to wrap the variable name in an assignment, e.g. @own x = ...
    @own owner = [1, 2, 3, 4, 5]
    
    # Borrow from it
    # @ref requires a lifetime scope. We create one with @lifetime.
    # The macro expects a Symbol name, not ~l syntax in the definition.
    @lifetime l begin
        # Create a reference 'borrower' valid for lifetime ~l
        # Syntax: @ref ~lifetime variable_to_borrow
        # It seems @ref expects ~l to be an expression like `~l` and owner to be an expression.
        # But `owner` is a Symbol. The macro might require it to be wrapped or assigned.
        # Let's try assigning it: @ref ~l borrower = owner
        @ref ~l borrower = owner
        
        println("Borrower created: ", borrower)
        
        # Now we simulate the "Use-After-Free" pattern:
        # We "move" the owner away (effectively destroying it or invalidating it in this scope)
        # The macro `@move` explicitly consumes the value.
        # This SHOULD FAIL because 'borrower' is still live in this scope and borrows 'owner'.
        # @move also seems to expect an assignment expression or similar, not just a Symbol.
        # Let's try explicit assignment: moved_owner = @move owner
        @move moved_owner = owner
        
        # Now we try to use the borrower
        println("Borrower access attempt: ", borrower) 
        
        # To silence unused warning for moved_owner
        println("Owner moved to: ", moved_owner)
    end
end

println("\nAttempting to run safe_demo_attempt()...")
try
    safe_demo_attempt()
catch e
    println("Caught expected error: ", e)
end
