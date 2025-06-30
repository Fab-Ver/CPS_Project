function [state_estimation_error, attack_error] = SSO_tracking(x0, G, A, a_true, lambda, nu, q, n, T, y, epsilon)
    % SSO_tracking implements the SSO algorithm for target tracking under sparse sensor attacks
    %
    % Inputs:
    %   x0     - initial true state
    %   G      - normalized measurement matrix [D I]
    %   A      - system dynamics matrix
    %   a_true - true attack vector
    %   lambda - regularization parameter
    %   nu     - step size 
    %   q      - number of sensors
    %   n      - number of cells
    %   T      - number of time steps
    %   y      - measured output 
    %   epsilon - threshold to compute support error
    %
    % Outputs:
    %   state_estimation_error - support error of state estimate at each time step
    %   attack_error           - support error of attack estimate at each time step
    
    % Initialize true state at time 0
    x_true = x0; 
    
    % Initialize estimated state and attack vectors to zero
    x_est = zeros(n, 1);
    a_est = zeros(q, 1);

    % Concatenate into one estimation vector [x_est; a_est]
    xa_est = [x_est; a_est];
    
    %Perfomance Metrics
    state_estimation_error = zeros(1, T); 
    attack_error = zeros(1, T);

    state_estimation_error(1) = support_error(x_true, x_est, epsilon);
    attack_error(1) = support_error(a_true, a_est, epsilon); 

    for k=2:T
        % Get current measurement vector
        y_k = y(:,k);

        % Gradient descent + soft thresholding step 
        xa_est = soft_thresholding(xa_est - nu * G' * (G * xa_est - y_k), nu * lambda);
        
        % Split estimate back into state and attack vectors
        x_est = xa_est(1:n);
        a_est = xa_est(n+1:end);
        
        % Propagate the true state and predicted state using system dynamics
        x_true = A * x_true;
        next_x = A * x_est;
        
        xa_est = [next_x; a_est];

        state_estimation_error(k) = support_error(x_true, x_est, epsilon); 
        attack_error(k) = support_error(a_true, a_est, epsilon); 
    end
end 