function [x_est, a_est] = ISTA_localization(y, G, lambda, nu, n, q)
    xa_est = zeros(n+q,1);
    max_iteration = 10000;

    for i=1:max_iteration
        xa_est = soft_thresholding(xa_est - nu * G' * (G * xa_est - y), nu * lambda);
    end 

    x_est = xa_est(1:n);
    a_est = xa_est(n+1:end);
end 