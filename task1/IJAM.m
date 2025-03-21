%IJAM Algorithm
function [state_errors_IJAM, support_errors_IJAM, iterations] = IJAM(y, C, q, n, lambda, nu, delta, x_true, a)
    x_est = zeros(n,1);
    a_est = zeros(q,1);
    t=1;
    state_errors_IJAM = [];
    support_errors_IJAM = [];
    iterations = [];
    state_errors_IJAM(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
    support_errors_IJAM(t) = support_attack_error(a, a_est);
    iterations(t) = t; 
    while true
        t=t+1;
        x_prev = x_est;
        a_prev = a_est;
        
        x_est = pinv(C) * (y - a_prev);
        a_est = soft_thresholding(a_prev - nu * (C * x_prev + a_prev - y), lambda);
        state_errors_IJAM(t) = norm(x_est - x_true, 2) / norm(x_true, 2);
        support_errors_IJAM(t) = support_attack_error(a, a_est);
        iterations(t) = t; 
        if norm(x_est - x_prev,2)^2 < delta
            break;
        end
    end 
    figure;
    semilogx(iterations, state_errors_IJAM, '-', 'DisplayName', 'IJAM'); hold on;
    xlabel('Iterations'); ylabel('State Estimation Error');
    legend; title('State Estimation Error'); grid on;

    figure;
    semilogx(iterations, support_errors_IJAM, '-', 'DisplayName', 'IJAM'); hold on;
    xlabel('Iteration'); ylabel('Support Attack Error');
    legend; title('Support Attack Error'); grid on;
    %disp(t)
end 