function save_solution(solution::SolutionUPMSP, folder_address::String)
    job_machine_string = ""
    for m in solution.job_machine
        job_machine_string = string(job_machine_string, "$m ")
    end
    job_machine_string = string(job_machine_string, "\n$(solution.makespan)\n$(solution.makespan_machine_index)")
    solution_file_name = "$(folder_address)solution.txt"

    if isfile(solution_file_name)
        select_option(message = """Before continuing, rename the "$(solution_file_name)" file or remove it from the folder if you want to keep it.\nAfter that or if you don't want to keep it, select "Continue".""", options = ["Continue"])
    end

    open(solution_file_name, "w") do file
        write(file, job_machine_string)
    end
    return nothing
end

function load_solution(solution_address::String)
    txt_file = readdlm(solution_address)
    solution = generate_zero_solution(size(txt_file, 2))
    for j in eachindex(solution.job_machine)
        solution.job_machine[j] = txt_file[1, j]
    end
    solution.makespan = txt_file[2, 1]
    solution.makespan_machine_index = txt_file[3, 1]
    return solution
end