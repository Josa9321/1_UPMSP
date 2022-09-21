mutable struct SolutionUPMSP{N <: Integer, F <: AbstractFloat}
    job_machine::Vector{N}
    makespan::F
end

