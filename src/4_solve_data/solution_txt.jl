function save_solution(solution::SolutionUPMSP, folder_address::String)
    job_machine_string = ""
    for m in solution.job_machine
        job_machine_string = string(job_machine_string, "$m ")
    end
    job_machine_string = string(job_machine_string, "\n$(solution.makespan)\n$(solution.makespan_machine_index)")
    solution_file_name = "$(folder_address)solution"
    list_of_solutions = Int64[]
    last_number = 0
    if isfile("$(solution_file_name)$(last_number).txt")
        list_of_files = cd(readdir, folder_address)
        files_is_solutions = occursin.(Ref("solution"), list_of_files)

        for (j, file_is_solution) in enumerate(files_is_solutions)
            if file_is_solution
                number_of_solution = parse(Int64, list_of_files[j][9:(end-4)])
                if last_number == number_of_solution
                    last_number = number_of_solution+1
                end
            end
        end
    end

    open("$(solution_file_name)$(last_number).txt", "w") do file
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