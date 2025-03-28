%ISTA Algorithm
function [state_errors_ISTA, support_errors_ISTA, iterations] = ISTA(y, C, q, n, lambda, nu, delta, x_true, a, max_iterations)
    x_est = zeros(n,1);
    a_est = zeros(q,1);
    t=1;
    state_errors_ISTA = [];
    support_errors_ISTA = [];
    iterations = [];
    state_errors_ISTA(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
    support_errors_ISTA(t) = support_attack_error(a, a_est);
    iterations(t) = t;
    while true
        t=t+1;
        x_prev = x_est;
        a_prev = a_est;
        x_est = x_prev - nu * C' * (C * x_prev + a_prev - y);
        a_est = soft_thresholding(a_prev - nu * (C * x_prev + a_prev - y), nu * lambda);
        state_errors_ISTA(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
        support_errors_ISTA(t) = support_attack_error(a, a_est);
        iterations(t) = t; 
        if norm(x_est - x_prev,2)^2 < delta && t >= max_iterations
            break;
        end 
    end 
end 