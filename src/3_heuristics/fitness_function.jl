include("1_solution_struct.jl")

function fitness_function!(solution::SolutionUPMSP, instance::InstanceUPMSP)
    makespan = 0.0
    makespan_machine_index = 0
    for m in instance.M
        machine_load = 0.0
        for j in instance.J
            if solution.job_machine[j] != m
                continue
            end

            machine_load += instance.processing_time[m, j]
        end
        if makespan < machine_load 
            makespan = machine_load
            makespan_machine_index = m
        end
    end
    solution.makespan = makespan
    solution.makespan_machine_index = makespan_machine_index
    return solution
end