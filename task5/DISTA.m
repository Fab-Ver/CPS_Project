function DISTA(Q, nu, lambda, G, y, n, tol)
    % Ensure y is a column vector
    y = y(:);  
    
    % Size of the problem
    [q, ~] = size(G);  % q: number of nodes, n+q: dimension of each z_i
    
    % Initialize local variables
    z = zeros(q, n + q);  % z has q rows, each of size (n+q)

    % Iterative update
    while true 
        z_old = z; 
        for i = 1:q
            % Local consensus: sum over neighbors
            sum_val = Q(i,:) * z_old;  % 1 x (n+q)

            % Local gradient computation
            grad_i = G(i,:)' * (y(i) - G(i,:) * z_old(i,:)');  % (n+q) x 1
            grad_i = grad_i';  % Transpose to 1 x (n+q)

            % Proximal gradient update with soft thresholding
            z(i,:) = soft_thresholding(sum_val + nu * grad_i, nu * lambda);  % 1 x (n+q)
        end

        % Check for convergence
        if norm(z - z_old, 'fro')^2 < tol
            break
        end 
    end 

    % Final estimate: average across all nodes
    z_final = mean(z,1)';  % (n+q) x 1
    x_est = z_final(1:n);           % Estimated signal x
    a_est = z_final(n+1:end);       % Estimated attack a

    % Threshold small values in a_est
    a_est(abs(a_est) < 1) = 0;

    % Updated support detection
    [~, ind_x] = max(x_est');         % Index of max value in x_est
    supp_a = find(abs(a_est) >= 0.1); % Support of a

    % Print results (only index of max x shown as supp(x))
    fprintf('DISTA: supp(x) = {%d}, supp(a) = {%s}\n', ...
        ind_x, num2str(supp_a', '%d '));
end