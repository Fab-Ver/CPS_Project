function [state_estimation_error, attack_error] = SSO(x0, G, A, a_true, lambda, nu, q, n,T,y, epsilon)
    xa_est = zeros(n+q,1);
    x_true = x0; 
    state_estimation_error = []; 
    attack_error = []; 
    x_est = xa_est(1:n);
    a_est = xa_est(n+1:end);
    state_estimation_error(1) = support_error(x_true, x_est, epsilon);
    attack_error(1) = support_error(a_true, a_est, epsilon); 

    for k=2:T
        xa_est = soft_thresholding(xa_est - nu * G' * (G * xa_est - y(:,k)), nu * lambda);
        x_est = xa_est(1:n);
        a_est = xa_est(n+1:end);
        x_true = A * x_true; 
        state_estimation_error(k) = support_error(x_true, x_est, epsilon); 
        attack_error(k) = support_error(a_true, a_est, epsilon); 
    end
end 