clc;
clear all;
close all;

fprintf('Multi-Agent Magnetic Levitation System\n');

% RUN both local and cooperative observers for a single run on the choosen
% parameters. 

% Agents
N = 6;
A = [0 1; 880.87 0];
B = [0; -9.9453];
C = [708.27 0];
D = zeros(1, 2);

% Parameters Definition
rng(42)                 % Set random seed
T_sim = 250;            % Simulation Time 
topology_type = 'star'; % Possible values: chain, star, tree, complete
reference = 'const';    % Possible values: const, ramp, sin
noise_level = 0;        % Tested Values: 200, 2500, 10000
noise_sample_time = 1;
R = 1;
Q = eye(2);
threshold = 2e-4;       % Threshold for convergence time computation

% Create Network Topology
[Adj, G, L] = create_network_topology(N, topology_type);

% --- Reference-dependent setup ---
switch reference
    case 'const'
        R0 = 1;
        x0_0 = [R0; 0];
        K0 = place(A, B, [0, -20]);
    case 'ramp'
        slope = 0.5;
        K0 = acker(A, B, [0 0]);
        x0_0 = [0; slope];
    case 'sin'
        w0 = 1;
        Amp = 1;
        K0 = place(A, B, [w0*1i, -w0*1i]);
        x0_0 = [Amp; 0];
end

%Leader’s closed-loop dynamics
A0 = A - B * K0;
L0 = place(A0', C', [-10, -20])';

%Set initial conditions
perturb = @(v) 0.5 * randn(size(v));
x0_1 = perturb(x0_0);
x0_2 = perturb(x0_0);
x0_3 = perturb(x0_0);
x0_4 = perturb(x0_0);
x0_5 = perturb(x0_0);
x0_6 = perturb(x0_0);
        
x0_hat = [0; 0];
        
% Compute coupling gain c
eig_LG = eig(L + G);
cmin = 1/2 * (1 / min(real(eig_LG)));
c = cmin;
        
% Distributed Controller Riccati Equation
Pc = are(A0, B * R^(-1) * B', Q);
K = R^(-1) * B' * Pc;
        
% Cooperative Observer F
P = are(A0', C' * R^(-1) * C, Q);
F_c = P * C' * R^(-1);
        
% Local Observer F
F_l = find_hurwitz_F(A0, C, c);
        
% Check if Ao is Hurwitz for the Cooperative Observer
Ao_coop = kron(eye(N), A0) - c * kron(L + G, F_c * C);
eigvals_Ao_coop = eig(Ao_coop);
if any(real(eigvals_Ao_coop) >= 0)
    error('Ao Cooperative NOT Hurwitz: at least one eigenvalue has a real part >= 0.');
end
        
% Check if Ao is Hurwitz for the Local Observer
Ao_local = A0 + c * F_l * C;
eigvals_Ao_local = eig(Ao_local);
if any(real(eigvals_Ao_local) >= 0)
    error('Ao Local NOT Hurwitz: at least one eigenvalue has a real part >= 0.');
end
        
% Cooperative Observer Results
results_cooperative = sim('sim/cooperative_observer.slx');
x_hat_all = results_cooperative.x_hat_all.Data;  % [12 x 1 x N]
x_ref_col = results_cooperative.x_ref_col.Data;  % [12 x 1 x N]
t = results_cooperative.tout;                    % [Nx1]

%Compute SEE and Convergence Time
state_estimation_error_cooperative = abs(squeeze(x_ref_col - x_hat_all));
[t_conv_cooperative, idx_c] = time_to_conv(state_estimation_error_cooperative, t, threshold);

% Plot Obtained Results
plot_agent_states_vs_ref(x_hat_all, x_ref_col, t, 'Cooperative');
plot_estimation_errors_by_state(x_hat_all, x_ref_col, t, 'Cooperative');

% Local Observer Results
results_local = sim('sim/local_observer.slx');
x_hat_all = results_local.x_hat_all.Data;
x_ref_col = results_local.x_ref_col.Data;
t = results_local.tout;

%Compute SEE and Convergence Time
state_estimation_error_local = abs(squeeze(x_ref_col - x_hat_all));
[t_conv_local, idx_l] = time_to_conv(state_estimation_error_local, t, threshold);
        
% Plot Obtained Results
plot_agent_states_vs_ref(x_hat_all, x_ref_col, t,'Local');
plot_estimation_errors_by_state(x_hat_all, x_ref_col, t, 'Local');

run.topology_type = topology_type;
run.reference = reference;
run.R = R;
run.Q = Q;
run.c = c;
run.noise_level = noise_level;
run.F_c = F_c;
run.F_l = F_l;
        
if ~isnan(idx_c)
    run.see_coop = max(state_estimation_error_cooperative(:,idx_c));
else
    run.see_coop = max(state_estimation_error_cooperative(:,end));
end
        
if ~isnan(idx_l)
    run.see_local = max(state_estimation_error_local(:,idx_l));
else
    run.see_local = max(state_estimation_error_local(:,end));
end
        
run.t_coop = t_conv_cooperative;
run.t_local = t_conv_local;
        
disp(run);