function [state_estimation_error, attack_error] = SSO(x0, C, A, a_true, lambda, nu, q, n)
    x_est = zeros(n,1);
    x_true = x0; 
    a_est = zeros(q,1);
    T_max = 10000;
    state_estimation_error = []; 
    attack_error = []; 
    state_estimation_error(1) = norm(x_est - x_true, 2) / norm(x_true); 
    attack_error(1) = support_attack_error(a_true, a_est); 

    for k=2:T_max
        y_true = C * x_true + a_true;
        y_est = C * x_est + a_est;
        x_est = A * x_est - nu * A * C' * (y_est - y_true);
        a_est = soft_thresholding(a_est - nu * (y_est - y_true), nu * lambda);
        x_true = A * x_true; 
        state_estimation_error(k) = norm(x_est - x_true, 2) / norm(x_true); 
        attack_error(k) = support_attack_error(a_true, a_est); 
    end
end 