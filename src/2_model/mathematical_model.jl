using JuMP, CPLEX

function declare_model(instance::InstanceUPMSP, model_params::ModelParams = initialize_model_params())
    
    upmsp_model = Model(
        optimizer_with_attributes(
            model_params.optimizer, 
            "CPX_PARAM_SCRIND" => model_params.log, 
            "CPXPARAM_MIP_Tolerances_MIPGap" => model_params.relative_gap, 
            "CPX_PARAM_THREADS" => model_params.threads
        )
    ) 

    @variables upmsp_model begin
        x[instance.M, instance.J], Bin
        Cmax >= 0
    end

    @objective(upmsp_model, Min, Cmax)

    @constraints upmsp_model begin
        c2[m in instance.M],
            sum(instance.processing_time[m, j] * x[m, j] for j in instance.J) <= Cmax

        c3[j in instance.J],
            sum(x[m, j] for m in instance.M) == 1
    end
    return upmsp_model
end

function solve_instance_by_milp(instance::InstanceUPMSP, model_params::ModelParams = initialize_model_params())
    upmsp_model = declare_model(instance, model_params)
    optimize!(upmsp_model)
    return upmsp_model
end