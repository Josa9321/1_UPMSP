using TerminalMenus, XLSX, DataFrames

function select_option(;message = "Select the desired option:", 
    options = ["""Generate ".xlsx" empty file to feed times of jobs;""", 
                "Generate a solution for the problem;", 
                "Exit."])
    menu = RadioMenu(options, pagesize=3)
    choice = request(message, menu)
    return choice
end

function menu_upmsp()
    println("\nScheduling program\n\n")
    num_option = select_option()
    println()
    if num_option == 1
        generate_spreadsheet()
    elseif num_option == 2
        run_procedure()
    end
    return nothing
end

function generate_spreadsheet()
    data = generate_data_matrix()
    address = "xlsx_instances//instance.xlsx"
    if isfile(address)
        println("The file $(address) already exist. Therefore, confirm the data from the worksheet and, if you want generate another with this generator, then removal from the folder or rename it.")
    else
        XLSX.writetable(address, data)
        println("The file was generated with success in $address")
    end
    return nothing
end

function generate_data_matrix()
    num_jobs = 10
    J = Base.OneTo(num_jobs)

    name_jobs = ["Job_$(j)" for j in J]
    times = zeros(num_jobs)

    data = DataFrame(Jobs = name_jobs,
        Machine_1 = times,
        Machine_2 = times,
        Machine_3 = times,
        Machine_4 = times,
        Machine_5 = times
    )
    return data
end

function run_procedure()
    # For now, data assumes 
    instance_address = "xlsx_instances//instance.xlsx"
    if !isfile(instance_address)
        println("The $(instance_address) file is not in the program folder. Please place the $(instance_address) file in the folder xlsx_instances where the program is so it could read the job's data.")
        return nothing
    end
    instance = nothing
    try 
        instance = read_xlsx_instance(instance_address)
    catch y
        println(y, "\nIt wasn't possible to read the instance.")
        return nothing
    end
    s_1 = ils(instance)
    println("The solution was found after $(round(s_1[2], digits = 5))s")
    solution = s_1[1]
    save_in_xlsx_solution(solution, instance)
    return nothing
end

function save_in_xlsx_solution(solution, instance)
    machine_jobs = ["" for m in instance.M]
    for (j, m) in enumerate(solution.job_machine)
        machine_jobs[m] = string(machine_jobs[m], "$(j) ")
    end
    machines_load = calculate_machines_load(solution, instance)
    solution_data = DataFrame(Machine = collect(instance.M),
        Jobs = machine_jobs,
        Machine_Load = machines_load
    )
    address = "xlsx_instances//solution.xlsx"
    if isfile(address)
        select_option(message = """Before continuing, rename the "$(address)" file or remove it from the folder if you want to keep it.\nAfter that or if you don't want to keep it, select "Continue".""", options = ["Continue"])
        rm(address, force = true)
    end
    XLSX.writetable(address, solution_data)
end

function read_xlsx_instance(instance_address)
    data = DataFrame(XLSX.readtable(instance_address, "Sheet1"))
    num_jobs, num_machines = size(data)
    num_machines -= 1
    M = Base.OneTo(num_machines)
    M_dist = DiscreteUniform(1, num_machines)

    J = Base.OneTo(num_jobs)
    J_dist = DiscreteUniform(1, num_jobs)

    processing_time = zeros(num_machines, num_jobs)
    println(M)
    println(J)
    for m in M
        for j in J
            # println("m = $m, j = $j")
            processing_time[m, j] = data[m+1][j]
        end
    end
    return InstanceUPMSP(J, J_dist, M, M_dist, processing_time)
end