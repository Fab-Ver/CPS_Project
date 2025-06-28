%IJAM Algorithm
function [state_errors_IJAM, support_errors_IJAM, iterations] = IJAM(y, C, q, n, lambda, nu, delta, x_true, a, max_iterations)
    x_est = zeros(n,1);
    a_est = zeros(q,1);
    t=1;

    state_errors_IJAM = [];
    support_errors_IJAM = [];
    iterations = [];

    state_errors_IJAM(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
    support_errors_IJAM(t) = support_attack_error(a, a_est);
    iterations(t) = t; 

    % Precompute pseudo-inverse of C
    C_pinv = pinv(C);

    while true
        t=t+1;
        x_prev = x_est;
        a_prev = a_est;

        x_est = C_pinv * (y - a_prev);
        a_est = soft_thresholding(a_prev - nu * (C * x_prev + a_prev - y), nu * lambda);

        state_errors_IJAM(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
        support_errors_IJAM(t) = support_attack_error(a, a_est);
        iterations(t) = t; 
        
        %if norm(x_est - x_prev,2)^2 < delta %Use this check for a single run (comment other IF)
        if t >= max_iterations % Use this check for multiple run (comment other IF) 
            break;
        end
    end 
end 