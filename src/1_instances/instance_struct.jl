using Distributions
DiscreteUniform(1, 5)
struct InstanceUPMSP{F <: AbstractFloat, R <: AbstractRange, D}
    J::R
    J_dist::D

    M::R
    M_dist::D
    
    processing_time::Matrix{F}
end