using DataFrames, XLSX

struct ResolutionMethod{M, P}
    method::M
    params::P
end

function initialize_ils_method(;max_iteration::Int64 = 50, time_limit::Float64 = 100.0, perturbation_num_operations::Int64 = 2, same_makespan_tolerance_ls::Int64 = 5)
    method = ils
    params = initialize_ils_params(max_iteration, time_limit, perturbation_num_operations, same_makespan_tolerance_ls)
    return ResolutionMethod(method, params)
end

struct HeuristicDataTest{M <: AbstractMatrix, V <: AbstractVector, S <: AbstractString, N <: Integer}
    instance_folder::S
    list_of_instances_names::V
    num_instances::N
    num_executions::N
    time::M
    makespan::M
end
function initialize_heuristic_data_test(num_executions, instance_folder = "instances//soa_ite_instances_1-100//")
    list_of_instances_names = cd(readdir, instance_folder)
    num_instances = length(list_of_instances_names)
    time = zeros(num_instances, num_executions + 1)
    makespan = zeros(num_instances, num_executions + 1)
    
    heuristic_data_test = HeuristicDataTest(
        instance_folder, 
        list_of_instances_names, 
        num_instances,
        num_executions,
        time,
        makespan
    )

    return heuristic_data_test
end

function generate_heuristic_test_data(resolution_method::ResolutionMethod, num_executions = 10; instance_folder = "instances//soa_ite_instances_1-100//")
    heuristic_data_test = initialize_heuristic_data_test(num_executions, instance_folder)
    
    loop_load_instances_to_solve!(heuristic_data_test, resolution_method)#makespan, time, resolution_method, list_of_instances_names, instance_folder)
    
    save_heuristic_data(heuristic_data_test)#list_of_instances_names, makespan, time, num_executions)
    return nothing
end

function loop_load_instances_to_solve!(heuristic_data_test::HeuristicDataTest, resolution_method::ResolutionMethod)
    #(makespan, time, resolution_method, list_of_instances_names, instance_folder)
    println("Solving all instances of folder $(heuristic_data_test.instance_folder)")
    for (i, instance_name) in enumerate(heuristic_data_test.list_of_instances_names)
        instance_address = string(heuristic_data_test.instance_folder, instance_name)
        instance = read_instance(instance_address)
        println(" * Solving instance $(instance_name)")
        loop_solve_instance!(heuristic_data_test, resolution_method, instance, i)
    end
    println("All instances was solved")
    return nothing
end

function loop_solve_instance!(heuristic_data_test::HeuristicDataTest, resolution_method::ResolutionMethod, instance, i)

    mean_index = heuristic_data_test.num_executions + 1
    for j in Base.OneTo(heuristic_data_test.num_executions)
        s = resolution_method.method(instance, resolution_method.params)
        println("   - Execution $j")
        heuristic_data_test.makespan[i, j] = s[1].makespan
        heuristic_data_test.makespan[i, mean_index] += s[1].makespan
        
        heuristic_data_test.time[i, j] = s[2]
        heuristic_data_test.time[i, mean_index] += s[2]
    end
    heuristic_data_test.makespan[i, mean_index] /= heuristic_data_test.num_executions
    heuristic_data_test.time[i, mean_index] /= heuristic_data_test.num_executions
    return nothing
end

function save_heuristic_data(heuristic_data_test)
    col_names = define_columns_names(heuristic_data_test.num_executions)

    data_makespan = hcat(heuristic_data_test.list_of_instances_names, 
        heuristic_data_test.makespan)
    df_makespan = convert_heuristic_data_to_dataframe(data_makespan, col_names)

    data_time = hcat(heuristic_data_test.list_of_instances_names, 
        heuristic_data_test.time)
    df_time = convert_heuristic_data_to_dataframe(data_time, col_names)

    if isfile("resolution_data.xlsx")
        rm("resolution_data.xlsx")
    end
    XLSX.writetable("resolution_data.xlsx", "Makespan" => df_makespan, "Time" => df_time)
    return nothing
end

function convert_heuristic_data_to_dataframe(data_matrix, col_names)
    data_df = convert(DataFrame, data_matrix)
    DataFrames.rename!(data_df, col_names)
    return data_df
end

function define_columns_names(num_executions)
    executions_col_names = ["Execution $(j)" for j in Base.OneTo(num_executions)]
    vector_col_names = ["Instance_name"; executions_col_names; "Mean"]
    return vector_col_names
end