clc;
clear all;
close all;

global A_star B c Kf F; 

fprintf('=== INITIALIZING SIMULINK PARAMETERS ===\n');
fprintf('Multi-Agent Magnetic Levitation System\n');
fprintf('Cooperative Dynamic Regulator Design\n\n');

A = [0 1;
    880.87 0];
B= [0; -9.9453];

C= [708.27 0];
D = 0;

%K = place(A, B, [0+i*10, 0-i*10]); 
K = place(A, B, [0, -2500]); %ramp 

N_agent = 6;
N_agentLeader = 7;

fprintf('System initialized: %d followers + 1 leader\n', N_agent);
fprintf('matrix A :\n');
disp(A);
%% defintion of the Graph matrix
% Star topology for simplicity (can be easily changed)
topology_type = 'star';  % Options: 'star', 'ring', 'complete', 'chain'

[Adj, G] = create_network_topology(N_agent, topology_type);

d_in = sum(Adj, 2);
Deg = diag(d_in);
L = Deg - Adj;

x0 = [10, 1];

x0_1 = [12 1];
x0_2 = [4 1];
x0_3 = [6 1];
x0_4 = [6 1];
x0_5 = [9 1];
x0_6 = [8 1];

% Compute A_star
A_star = A - B * K;

Q = eye(2);
R = 1; % Weighting factor for control input

P = are(A_star,B*R^(-1)*B', Q);
K = inv(R)*B'*P;
F = P * C'/R;

eig_LG = eig(L+G);



% Compute coupling gain c
c = 1/2 * (1/min(real(eig_LG)));

% Flip sign of F
F = -F;

% Compute follower gain Kf
Kf = inv(R) * B' * P;
