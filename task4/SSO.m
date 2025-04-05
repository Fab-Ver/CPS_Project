function [state_estimation_error, attack_error] = SSO(x0, G, A, a_true, lambda, nu, q, n, T, y, epsilon)
    x_true = x0; 
    x_est = zeros(n, 1);
    a_est = zeros(q, 1);
    xa_est = [x_est; a_est];
    
    %Perfomance Metrics
    state_estimation_error = zeros(1, T); 
    attack_error = zeros(1, T);
    state_estimation_error(1) = support_error(x_true, x_est, epsilon);
    attack_error(1) = support_error(a_true, a_est, epsilon); 

    for k=2:T
        y_k = y(:,k);
        xa_est = soft_thresholding(xa_est - nu * G' * (G * xa_est - y_k), nu * lambda);

        x_est = xa_est(1:n);
        a_est = xa_est(n+1:end);
        
        x_true = A * x_true;
        next_x = A * x_est;

        xa_est = [next_x; a_est];
        state_estimation_error(k) = support_error(x_true, x_est, epsilon); 
        attack_error(k) = support_error(a_true, a_est, epsilon); 
    end
end 