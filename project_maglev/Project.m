clc;
clear all;
close all;

fprintf('=== INITIALIZING SIMULINK PARAMETERS ===\n');
fprintf('Multi-Agent Magnetic Levitation System\n');
fprintf('Cooperative Dynamic Regulator Design\n\n');
%% Project activity (step 1: variable definition)
% x=sym('x',[2 1],'real');
% u=sym('u',[1 1],'real'); 

A = [0 1;
    880.7 0];
B= [0; -9.9453];

C= [708.27, 0];
% D = 0;
K_place = place(A, B, [0, 100]); % oscillanting response
N_agent = 6;
N_agentLeader = 7;

fprintf('System initialized: %d followers + 1 leader\n', N_agent);
fprintf('matrix A :\n');
disp(A);
%% defintion of the Graph matrix
% Star topology for simplicity (can be easily changed)
topology_type = 'star';  % Options: 'star', 'ring', 'complete', 'chain'

[A_adj, G_pinning] = create_network_topology(N_agent, topology_type);

% Display network information
fprintf('\nNetwork Topology: %s\n', topology_type);
fprintf('Adjacency Matrix:\n');
disp(A_adj);
fprintf('Pinning Matrix (diagonal):\n');
disp(diag(G_pinning));
%% System matrixes - Leader
A_l0=A;
B_l0 = zeros(2,1);
C_l0= [1, 1];
D_l0 = 0;

x_init0 = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
%% Laplacian Matrix

%K = place(A, B, [0 -100]); % step response
%K = place(A, B, [-0 0]);  % ramp response
A_star = A-B*K_place;
d_in = sum(A_adj, 2);
D = diag(d_in);
L = D - A_adj;
L_plus_G = L+G_pinning;
% Compute the eigenvalues and eigenvectors of the Laplacian matrix
[lambda_LG] = eig(L_plus_G);
fprintf('\nLaplacian Matrix L:\n');
disp(L);

fprintf('Eigenvalues of (L + G):\n');
disp(lambda_LG);


%% LQR controller desing
Q = eye(2);
R = 1; % Weighting factor for control input
P = are(A,B*R^-1*B',Q);
K = inv(R)*B'*P;
F = P * C'/R;
% fprintf('\nControl gain K (from ARE):\n');
% disp(K);

F = -F;

min_real_eigenvalue = min(real(lambda_LG(lambda_LG > 1e-10))); % Exclude near-zero eigenvalues

c_min = 1 / (2 * min_real_eigenvalue);

c = 2 * c_min;  % Safety factor

fprintf('Minimum coupling gain: %.4f\n', c_min);
fprintf('Selected coupling gain: %.4f\n', c);

%% Simulation Parameters
T_sim = 10;  

% Initial conditions (random around equilibrium)
for i = 1:N_agentLeader
    x_true(:, i, 1) = [0.1*randn; 0.1*randn];  % Small random initial states
    x_hat(:, i, 1) = zeros(N_agent, 1);              % Zero initial estimates
end


