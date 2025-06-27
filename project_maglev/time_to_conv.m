function t_conv = time_to_conv(error_data, time_vector, threshold)
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

    abs_error = abs(error_data);  

    is_below_thresh = all(abs_error < threshold, 1);  % [1×T]

    % Find the first time index where all errors stay below threshold
    % and remain below for the rest of the simulation
    for k = 1:length(is_below_thresh)
        if all(is_below_thresh(k:end))
            t_conv = time_vector(k);
            return;
        end
    end

    % If convergence never achieved
    t_conv = NaN;
    warning('Convergence not reached within simulation time.');
end
