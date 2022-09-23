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

function solve_instances(resolution_method::ResolutionMethod)
    instance_folder = "instances//soa_ite_instances_1-100//"
    list_of_instances_names = cd(readdir, instance_folder)
    num_instances = length(list_of_instances_names)
    time = zeros(num_instances)
    makespan = zeros(num_instances)
    println("Solving all instances of folder $instance_folder")
    for (i, instance_name) in enumerate(list_of_instances_names)
        instance_address = string(instance_folder, instance_name)
        instance = read_instance(instance_address)
        println(" * Solving $(instance_name[1:end-4]) instance")
        s = resolution_method.method(instance, resolution_method.params)
        
        makespan = s[1].makespan
        time[i] = s[2]
    end
    println("All instances was solved")
    resolution_data = DataFrame(
        Name = list_of_instances_names,
        makespan = makespan,
        times = time
    )
    XLSX.writetable("resolution_data.xlsx", resolution_data)
    return resolution_data
end