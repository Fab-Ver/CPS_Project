function F = find_hurwitz_F(A, C, c)
% FIND_HURWITZ_F Find matrix F such that (A + c*F*C) is Hurwitz
%
% Syntax:
%   F = find_hurwitz_F(A, C, c)
%
% Inputs:
%   A - System matrix (n x n)
%   C - Output matrix (p x n) 
%   c - Scalar multiplier
%
% Output:
%   F - Feedback matrix (n x p) such that (A + c*F*C) is Hurwitz
%

% Get dimensions
[n, ~] = size(A);
[p, ~] = size(C);

fprintf('=== Finding F to make (A + c*F*C) Hurwitz ===\n');

% Check if C is square and full rank for direct LQR approach
if p == n && rank(C) == n
    % Method 1: Direct LQR approach
    fprintf('Using Method 1: Direct LQR approach\n');
    
    B = c * eye(n);
    Q = eye(n);     % State weighting matrix
    R = eye(p);     % Control weighting matrix
    try
        K = lqr(A, B, Q, R);
        F = K / C;  % F = K * inv(C)
        fprintf('LQR solution found successfully\n');
    catch ME
        fprintf('LQR failed: %s\n', ME.message);
        fprintf('Falling back to optimization method...\n');
        F = optimize_F_for_hurwitz(A, C, c);
    end
else
    % Method 2: Optimization approach for general case
    fprintf('Using Method 2: Optimization approach\n');
    F = optimize_F_for_hurwitz(A, C, c);
end

% Verify the result
H = A + c * F * C;
eigenvals = eig(H);

fprintf('Found F matrix (%dx%d):\n', size(F,1), size(F,2));
disp(F);

if all(real(eigenvals) < 0)
    fprintf('SUCCESS! Matrix (A + c*F*C) is Hurwitz.\n');
    disp(real(eigenvals)')
else
    fprintf('WARNING! Result may not be Hurwitz.\n');
    disp(real(eigenvals)')
end

end

% Local function for optimization approach
function F = optimize_F_for_hurwitz(A, C, c)
    [n, ~] = size(A);
    [p, ~] = size(C);
    
    % Initial guess for F
    F0 = randn(n, p);
    
    % Optimization options
    options = optimoptions('fminunc', 'Display', 'off', 'MaxIterations', 1000, ...
                          'Algorithm', 'quasi-newton');
    
    % Cost function - minimize the maximum real part of eigenvalues
    objective = @(F_vec) hurwitz_cost(reshape(F_vec, n, p), A, C, c);
    
    % Optimize
    try
        fprintf('Running optimization...\n');
        [F_opt, ~, ~] = fminunc(objective, F0(:), options);
        F = reshape(F_opt, n, p);
        fprintf('Optimization completed\n');
    catch ME
        % If optimization fails, try a different initial guess
        F0 = -abs(randn(n, p));  % Try negative initial guess
        [F_opt, ~, ~] = fminunc(objective, F0(:), options);
        F = reshape(F_opt, n, p);
    end
end

% Cost function for Hurwitz stability
function cost = hurwitz_cost(F, A, C, c)
    H = A + c * F * C;
    
    try
        eigenvals = eig(H);
        
        % Primary objective: minimize the maximum real part
        max_real_part = max(real(eigenvals));
        cost = max_real_part;
        
        % Add large penalty if any eigenvalue has non-negative real part
        if max_real_part >= 0
            cost = cost + 1000 * (1 + max_real_part);
        end
        
        % Add small regularization term to prevent F from becoming too large
        cost = cost + 0.01 * norm(F, 'fro')^2;
        
    catch
        % If eigenvalue computation fails, return large cost
        cost = 1e6;
    end
end