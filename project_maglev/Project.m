clc;
clear all;
close all;

fprintf('Multi-Agent Magnetic Levitation System\n');

noise_level = 0;
noise_freq = 0.1;

T_sim = 100; 

% Agents 
N = 6;
A = [0 1; 880.87 0];
B = [0; -9.9453];
C= [708.27 0];
D = zeros(1,2);
 
reference = 'sin'; % 'const' % 'ramp' % 'sin'

switch reference
    case 'const'
        R0 = 1;
        x0_0 = [R0 0]';
        K0 = place(A, B, [0, -20]);
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

perturb = @(v) 0.5 * randn(size(v));

x0_1 = perturb(x0_0);
x0_2 = perturb(x0_0);
x0_3 = perturb(x0_0);
x0_4 = perturb(x0_0);
x0_5 = perturb(x0_0);
x0_6 = perturb(x0_0);

x0_hat = [0 ; 0]; 

% x0_1 = [0 ; 0];
% x0_2 = [0 ; 0];
% x0_3 = [0 ; 0];
% x0_4 = [0 ; 0];
% x0_5 = [0 ; 0];
% x0_6 = [0 ; 0];

% Network Topology Definition
% Options: 'star', 'star_s0', 'star_s0_complete', 'ring', 'complete', 'tree', 'chain'

topology_type = 'chain';  
[Adj, G, L] = create_network_topology(N, topology_type);

% Compute coupling gain c
eig_LG = eig(L+G);
cmin = 1/2 * (1/min(real(eig_LG)));
c = cmin;

R = 1; % Weighting factor for control input
Q = eye(2);

%Distributed Controller Riccati Equation 
Pc = are(A0, B * R^(-1) * B', Q);
K = R^(-1) * B' *Pc;

% Cooperative Observer F
P = are(A0', C' *R^(-1) * C, Q);
F_c = P * C' * R^(-1);

% Local Observer F
F_l = find_hurwitz_F(A0, C, c);

% Check if Ao is Hurwitz for the Cooperative Observer
Ao_coop = kron(eye(N), A0) - c * kron(L + G, F_c*C);
eigvals_Ao_coop = eig(Ao_coop);

if any(real(eigvals_Ao_coop) >= 0)
    error('Ao Cooperative NOT Hurwitz: at least one eigenvalue has a real part greater than or equal to 0.');
end

% Check if Ao is Hurwitz for the Local Observer
Ao_local = A0 + c * F_l * C;
eigvals_Ao_local = eig(Ao_local);

if any(real(eigvals_Ao_local) >= 0)
    error('Ao Local NOT Hurwitz: at least one eigenvalue has a real part greater than or equal to 0.');
end

%Uncomment if you want to analyze Ao components
%analyze_Ao_components(A, B, C, K0, F_c, F_l, c, L, G, N);

% --- Cooperative Observer Results ---
results_cooperative = sim('cooperative_observer.slx');

x_hat_all = results_cooperative.x_hat_all.Data;   % [12 x 1 x N]
x_ref_col = results_cooperative.x_ref_col.Data;   % [12 x 1 x N]
t = results_cooperative.tout;                     % [N x 1]

% Plot State Estimation vs Reference for each Agent
plot_agent_states_vs_ref(x_hat_all, x_ref_col, t, 'Cooperative');

% Plot Estimation Error for each Agent
plot_estimation_errors_by_state(x_hat_all, x_ref_col, t, 'Cooperative');


% --- Local Observer Results ---
results_local = sim('local_observer.slx');

x_hat_all = results_local.x_hat_all.Data;   % [12 x 1 x N]
x_ref_col = results_local.x_ref_col.Data;   % [12 x 1 x N]
t = results_local.tout;                     % [N x 1]

% Plot State Estimation vs Reference for each Agent
plot_agent_states_vs_ref(x_hat_all, x_ref_col, t, 'Local');

% Plot Estimation Error for each Agent
plot_estimation_errors_by_state(x_hat_all, x_ref_col, t, 'Local');



% --- Compute convergence time ---
state_estimation_error = abs(squeeze(x_ref_col - x_hat_all)); % [12 x T]
threshold = 1e-5;
window_duration = 2.0;

[t_conv_thresh, t_conv_deriv] = check_convergence(state_estimation_error, t, threshold, window_duration);



% --- Remove NaNs for statistics ---
valid_thresh = ~isnan(t_conv_thresh);
valid_deriv = ~isnan(t_conv_deriv);

% --- Compute statistics ---
mean_t_conv_thresh = mean(t_conv_thresh(valid_thresh));
median_t_conv_thresh = median(t_conv_thresh(valid_thresh));

mean_t_conv_deriv = mean(t_conv_deriv(valid_deriv));
median_t_conv_deriv = median(t_conv_deriv(valid_deriv));

% --- Display results ---
fprintf('\n--- Convergence Analysis ---\n');

fprintf('Threshold-based convergence:\n');
disp(t_conv_thresh');
fprintf('  Average convergence time: %.4f s\n', mean_t_conv_thresh);
fprintf('  Median convergence time:  %.4f s\n', median_t_conv_thresh);

fprintf('\nDerivative-based convergence:\n');
disp(t_conv_deriv');
fprintf('  Average convergence time: %.4f s\n', mean_t_conv_deriv);
fprintf('  Median convergence time:  %.4f s\n', median_t_conv_deriv);