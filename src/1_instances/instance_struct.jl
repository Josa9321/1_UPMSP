struct Job{F <: AbstractFloat}
    data_de_entrega::F
#     tempo_de_processamento::F
end

struct InstanceUPMSP{F <: AbstractFloat, R <: AbstractRange, R2 <: AbstractRange, O}
    N::R
    N_0::R2
    M::R2
    setup::Array{F}
    processing_time::Matrix{F}
    jobs::Vector{O}
end

struct DistribuicoesInstancia
    n
    m
    setup
    tempo_de_processamento
    data_de_entrega
end