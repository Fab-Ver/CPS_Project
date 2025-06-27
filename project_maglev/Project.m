clc;
clear all;
close all;

fprintf('=== INITIALIZING SIMULINK PARAMETERS ===\n');
fprintf('Multi-Agent Magnetic Levitation System\n');
fprintf('Cooperative Dynamic Regulator Design\n\n');

noise_level = 10000;
noise_freq = 0.1;

T_sim = 50; 

% Agents 
A = [0 1; 880.87 0];

B = [0; -9.9453];

C= [708.27 0];

D = zeros(1,2);
 
reference = 'ramp'; % 'const' % 'ramp' % 'sin'

switch reference
    case 'const'
        R0 = 1;
        x0_0 = [R0 0]';
        K0 = place(A, B, [0, -10]);
    case 'ramp'
        slope = 1;
        K0 = acker(A, B, [0 0]);
        x0_0 = [0 slope]';
    case 'sin'
        w0 = 1;
        Amp = 1; 
        K0 = place(A, B, [w0*1i -w0*1i]);
        x0_0 = [Amp 0]';
end

A0 = A-B*K0;

L0 = place(A0', C', [-10, -20])';

% perturb = @(v) v + 0.02 * randn(size(v));
% 
% x0_1 = perturb(x0_0);
% x0_2 = perturb(x0_0);
% x0_3 = perturb(x0_0);
% x0_4 = perturb(x0_0);
% x0_5 = perturb(x0_0);
% x0_6 = perturb(x0_0);

range = 1.5;

x0_1 = 2 * range * rand(2,1) - range;
x0_2 = 2 * range * rand(2,1) - range;
x0_3 = 2 * range * rand(2,1) - range;
x0_4 = 2 * range * rand(2,1) - range;
x0_5 = 2 * range * rand(2,1) - range;
x0_6 = 2 * range * rand(2,1) - range;

N = 6;

%% defintion of the Graph matrix
% Star topology for simplicity (can be easily changed)
topology_type = 'star';  % Options: 'star', 'ring', 'complete', 'chain'

[Adj, G] = create_network_topology(N, topology_type);

d_in = sum(Adj, 2);
Deg = diag(d_in);
L = Deg - Adj;

% Compute coupling gain c
eig_LG = eig(L+G);
cmin = 1/2 * (1/min(real(eig_LG)));
c = cmin * 2;

R = 1; % Weighting factor for control input
Q = eye(2);

%Distributed Controller Riccati Equation 
Pc = are(A0, B * R^(-1) * B', Q);
K = R^(-1) * B' *Pc;

% Local Observer
P = are(A0', C' *R^(-1) * C, Q);
F = P * C' * R^(-1);


In = eye(N);
Ag = kron(In, A0) - c * kron(L + G, F*C);
eigvals = eig(Ag);

if any(real(eigvals) >= 0)
    error('At least one eigenvalue has a real part greater than or equal to 0. The system may be unstable.');
end

results = sim('cooperative_observer.slx');

x_ref_col = results.x_ref_col.Data;
x_hat_all = results.x_hat_all.Data; 

state_estimation_error = abs(squeeze(x_ref_col - x_hat_all));
t = results.tout;
threshold = 1e-8; 
t_conv = time_to_conv(state_estimation_error, t, threshold);
fprintf('Convergence time: %.4f s\n', t_conv);

plot(results.tout, state_estimation_error);
grid on;
legend('show');
xlabel('Time [s]');
ylabel('Estimation Error');
title('Estimation Error of All States Over Time');