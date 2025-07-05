function [t_conv_thresh, t_conv_deriv] = check_convergence(error, t, threshold, window_duration)
%CHECK_CONVERGENCE_CONDITIONS Computes convergence time for each agent's state.
%
% INPUTS:
%   error           : matrix of estimation errors (2 states × 6 agents)
%   t               : time vector
%   threshold       : scalar threshold for convergence condition
%   window_duration : duration (in seconds) the condition must hold
%
% OUTPUTS:
%   t_conv_thresh : time of convergence using threshold-based method
%   t_conv_deriv  : time of convergence using derivative-based method

    [num_states, ~] = size(error);
    dt = mean(diff(t));
    window_size = round(window_duration / dt);

    t_conv_thresh = NaN(num_states, 1);
    t_conv_deriv = NaN(num_states, 1);

    for i = 1:num_states
        e = error(i, :);

        %% 1. Threshold-based: error < threshold for window_duration
        is_below = e < threshold;
        % Cumulative window check
        below_count = movsum(is_below, [window_size-1, 0]);
        idx_thresh = find(below_count >= window_size, 1, 'first');
        if ~isempty(idx_thresh)
            t_conv_thresh(i) = t(idx_thresh);
        end

        %% 2. Derivative-based: derivative ~ 0 for window_duration
        de = abs([0, diff(e)]);  % time derivative
        is_flat = de < threshold;
        flat_count = movsum(is_flat, [window_size-1, 0]);
        idx_deriv = find(flat_count >= window_size, 1, 'first');
        if ~isempty(idx_deriv)
            t_conv_deriv(i) = t(idx_deriv);
        end
    end
end
