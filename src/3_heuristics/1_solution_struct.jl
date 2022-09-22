mutable struct SolutionUPMSP{N <: Integer, F <: AbstractFloat}
    job_machine::Vector{N}
    makespan::F
    makespan_machine_index::N
end

function copy_solution(solution::SolutionUPMSP, instance)
    new_solution = generate_zero_solution(instance)
    return copy_solution!(new_solution, solution)
end

function copy_solution!(new_solution::SolutionUPMSP, solution::SolutionUPMSP)
    for i in eachindex(new_solution.job_machine)
        new_solution.job_machine[i] = solution.job_machine[i]
    end
    new_solution.makespan = solution.makespan
    new_solution.makespan_machine_index = solution.makespan_machine_index
    return new_solution
end