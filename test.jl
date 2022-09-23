include("src//load_folders.jl")

instance_address = "instances//soa_ite_instances_1-100//1.txt"
instance = read_instance(instance_address)

s_1 = ils(instance)
solution = s_1[1]

menu_upmsp()