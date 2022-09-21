using DelimitedFiles

include("instance_struct.jl")

function read_instance(instance_address)
    txt_file = readdlm(instance_address)
    num_machines = txt_file[1, 2]
    num_jobs = txt_file[1, 1]
    
    M = Base.OneTo(num_machines)
    M_dist = DiscreteUniform(1, num_machines)

    J = Base.OneTo(num_jobs)
    J_dist = DiscreteUniform(1, num_jobs)

    range_machines_in_txt = range(2, 2*num_machines, step = 2)
    processing_time = copy(Float64.(txt_file[3:(num_jobs + 2), range_machines_in_txt])')
    return InstanceUPMSP(J, J_dist, M, M_dist, processing_time)
end