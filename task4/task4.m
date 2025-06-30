clc
clear all
close all

% Load system data from the provided MAT file
data = load('tracking_data.mat');
A = data.A;            % System state matrix
D = data.D;            % Output matrix
y = data.y;            % Output measurements over time
xtrue0 = data.xtrue0;  % Initial true state
atrue = data.atrue;    % True attack vector
T = data.T;

% Algorithm parameters
lambda = 10; 
q=15;   
n=36;
epsilon = 1; 

% Check observability of the system (A, D)
O = obsv(A, D);
observable = rank(O) == n; % Check if observability matrix is full rank

if observable
    disp('The system (A, D) is observable.');
else
    disp('The system (A, D) is NOT observable.');
end

% Check observability of the augmented system 
A_aug = blkdiag(A, eye(q));
D_aug = [D, eye(q)];
O_aug = obsv(A_aug, D_aug);
rank_O_aug = rank(O_aug);
is_aug_observable = (rank_O_aug == size(A_aug, 1));

if is_aug_observable
    disp('The augmented system is observable.');
else
    disp('The augmented system is NOT observable.');
end

% Construct normalized augmented output matrix G = [D I]
G = normalize([D eye(q)]);

% Step size
nu = norm(G,2)^(-2);

%Run SSO (modified) to track the target and identify the sensors under attack
[support_state_error, support_attack_error] = SSO_tracking(xtrue0, G, A, atrue, lambda, nu, q, n, T, y, epsilon);

time_step = 1:T;

figure;
plot(time_step, support_state_error, '-'); hold on;
xlabel('Time Step'); ylabel('Support State Error');
title('Support State Error'); grid on;
exportgraphics(gcf, 'results/support_state_error_tracking.png', 'Resolution', 300);

figure;
plot(time_step, support_attack_error, '-'); hold on;
xlabel('Time Step'); ylabel('Support Attack Error');
title('Support Attack Error'); grid on;
exportgraphics(gcf, 'results/support_attack_error_tracking.png', 'Resolution', 300);
