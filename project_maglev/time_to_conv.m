function [t_conv, t_idx] = time_to_conv(error_data, time_vector, threshold)
% time_to_conv - Computes the convergence time for estimation error
%
%
% Inputs:
%   error_data   - [N×T] matrix of error signals (N states, T time steps)
%   time_vector  - [T×1] vector of time points
%   threshold    - Scalar threshold below which all errors must remain
%
% Output:
%   t_conv       - Time at which all error signals stay below threshold

    abs_error = abs(error_data);  % [N×T]
    is_below_thresh = all(abs_error < threshold, 1);  % [1×T]

    idx = find(is_below_thresh, 1);  % First istant

    if isempty(idx)
        t_conv = NaN;
        t_idx = NaN;
        warning('Convergence not reached within simulation time.');
    else
        t_conv = time_vector(idx);
        t_idx = idx;
    end
end
