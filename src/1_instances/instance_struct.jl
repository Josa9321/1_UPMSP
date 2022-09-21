struct InstanceUPMSP{F <: AbstractFloat, R <: AbstractRange}
    J::R
    M::R
    processing_time::Matrix{F}
end