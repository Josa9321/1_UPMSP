include("1_solution_struct.jl")

function fitness_function!(solution::SolutionUPMSP, instance::InstanceUPMSP)
    makespan = 0.0
    for m in instance.M
        machine_load = 0.0
        for j in instance.J
            if solution.job_machine[j] != m
                continue
            end

            machine_load += instance.processing_time[m, j]
        end
        makespan < machine_load ? makespan = machine_load : nothing
    end
    solution.makespan = makespan
    return solution
end