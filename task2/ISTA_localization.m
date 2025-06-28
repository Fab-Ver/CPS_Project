function [x_est, a_est] = ISTA_localization(y, G, lambda, nu, n, q)
    % ISTA_localization estimates the position x and the attack vector a
    % Inputs:
    % - y: RSS measurement vector 
    % - G: normalized dictionary + identity matrix
    % - lambda: regularization term
    % - nu: step size
    % - n: number of location cells
    % - q: number of sensors
    % Output:
    % - x_est: estimated location vector
    % - a_est: estimated attack vector

    xa_est = zeros(n+q,1);
    max_iteration = 10000;

    for i=1:max_iteration
        % Gradient step + soft thresholding
        xa_est = soft_thresholding(xa_est - nu * G' * (G * xa_est - y), nu * lambda);
    end 
    
    % Separate final estimate into position and attack
    x_est = xa_est(1:n);
    a_est = xa_est(n+1:end);
end 