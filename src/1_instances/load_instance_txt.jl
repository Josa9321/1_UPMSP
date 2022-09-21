using DelimitedFiles

# function read_instance_before(instance_address)
#     txt_file = readdlm(instance_address)
#     num_machines = txt_file[1, 1]
#     num_jobs = txt_file[1, 2]
#     M = 1:num_machines
#     J = 1:num_jobs
#     range_jobs_in_txt = range(2, 2*num_jobs, step = 2)
#     processing_time = Float64.(txt_file[2:(num_machines+1), range_jobs_in_txt])
#     return InstanceUPMSP(J, M, processing_time)
# end

function read_instance(instance_address)
    txt_file = readdlm(instance_address)
    num_machines = txt_file[1, 2]
    num_jobs = txt_file[1, 1]
    M = 1:num_machines
    J = 1:num_jobs
    range_machines_in_txt = range(2, 2*num_machines, step = 2)
    processing_time = copy(Float64.(txt_file[3:(num_jobs + 2), range_machines_in_txt])')
    return InstanceUPMSP(J, M, processing_time)
end