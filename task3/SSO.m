function [state_estimation_error, attack_error] = SSO(x0, C, A, a_true, lambda, nu, q, n)
    % SSO - Sparse Soft Observer 
    %
    % Inputs:
    %   x0     - Initial state 
    %   C      - Output matrix 
    %   A      - State transition matrix 
    %   a_true - True (constant) sparse attack vector
    %   lambda - Regularization parameter for sparsity
    %   nu     - Step size for gradient descent update
    %   q      - Number of sensors
    %   n      - State dimension
    %
    % Outputs:
    %   state_estimation_error - Normalized state estimation error over time
    %   attack_error           - Support identification error over time
    
    T_max = 10000;
    
    % Initialization
    x_est = zeros(n,1);
    x_true = x0; 
    a_est = zeros(q,1);
    
    state_estimation_error = zeros(1, T_max); 
    attack_error = zeros(1, T_max); 

    state_estimation_error(1) = norm(x_est - x_true, 2) / norm(x_true); 
    attack_error(1) = support_attack_error(a_true, a_est); 

    for k=2:T_max
        % Generate true output under attack
        y_true = C * x_true + a_true;

        % Generate estimated output
        y_est = C * x_est + a_est;

        % Update state  and attack estimate 
        x_est = A * x_est - nu * A * C' * (y_est - y_true);
        a_est = soft_thresholding(a_est - nu * (y_est - y_true), nu * lambda);

        % Propagate true system state
        x_true = A * x_true; 

        % Compute errors at this step
        state_estimation_error(k) = norm(x_est - x_true, 2) / norm(x_true); 
        attack_error(k) = support_attack_error(a_true, a_est); 
    end
end 