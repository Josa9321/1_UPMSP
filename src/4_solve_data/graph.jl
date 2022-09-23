using DataFrames, Gadfly, VegaLite

function generate_graph(solution, instance)
    job_start_stop = calculate_job_start_stop_time(solution, instance)
    
    machines_load = calculate_machines_load(solution, instance)
    machine_makespan = DataFrame(y = collect(instance.M),
        Machine = collect(instance.M[end:-1:1]),
        start = zeros(instance.M),
        stop = [machines_load[m] for m in instance.M[end:-1:1]],
        type = collect(instance.M)
    )

    # jobs = DataFrame(y = collect(instance.J),
    #     Machine = solution.job_machine,
    #     start = job_start_stop[:, 1],
    #     stop = job_start_stop[:, 2],
    #     type = collect(instance.J)
    # )

    machine_makespan |> @vlplot(
        :bar,
        y="Machine:n",
        x=:start,
        x2=:stop,
        color={
            :type, 
            scale={range=["#EA98D2", "#659CCA", "#000000"]}
        }
    )
end

function calculate_job_start_stop_time(solution, instance)
    job_start_stop = zeros(instance.J.stop, 2)
    machines_load = zeros(instance.M.stop)
    for (j, m) in enumerate(solution.job_machine)
        job_start_stop[j, 1] = machines_load[m]
        machines_load[m] += instance.processing_time[m, j]
        job_start_stop[j, 2] = machines_load[m]
    end
    return job_start_stop
end

function calculate_machines_load(solution, instance)
    machines_load = zeros(instance.M.stop)
    for (j, m) in enumerate(solution.job_machine)
        machines_load[m] += instance.processing_time[m, j]
    end
    return machines_load
end