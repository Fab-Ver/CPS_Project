clear all
close all
clc

global A B C D Adj G Deg L K R Q P F eig_LG c A_sta

A = [0       1;
     880.87  0];

B = [0; -9.9453];

C = [708.27 0];

D = 0;

% Controllore a poli assegnati
K = place(A, B, [0+i*10, 0-i*10]); % oscillanting response
%K = place(A, B, [0 -100]); % step response
%K = place(A, B, [-0.1 0]);  % ramp response

[Adj, G, Deg] = network("mesh");

L = Deg - Adj;

% Leader node.
%x0 = [0 1];
x0 = [10, 1];

% Follower node.
% x0_1 = [10 1];
% x0_2 = [10 1];
% x0_3 = [10 1];
% x0_4 = [10 1];
% x0_5 = [10 1];
% x0_6 = [10 1];

% x0_1 = [10.01 1];
% x0_2 = [10.02 1];
% x0_3 = [10.03 1];
% x0_4 = [9.99 1];
% x0_5 = [9.98 1];
% x0_6 = [9.97 1];

% x0_1 = [10.3 1];
% x0_2 = [10.2 1];
% x0_3 = [10.1 1];
% x0_4 = [9.9 1];
% x0_5 = [9.8 1];
% x0_6 = [9.7 1];

x0_1 = [12 1];
x0_2 = [4 1];
x0_3 = [6 1];
x0_4 = [6 1];
x0_5 = [9 1];
x0_6 = [8 1];

% x0_1 = [1 1];
% x0_2 = [2 1];
% x0_3 = [3 1];
% x0_4 = [2.5 1];
% x0_5 = [1.5 1];
% x0_6 = [0.8 1];

A_sta = A-B*K;

R = 10;
Q = diag([10, 100]);

P = are(A_sta, B*R^(-1)*B', Q);

Pf = care(A_sta', C', Q, R);
F = Pf * C' / R;

%F2 = R^(-1)*B'*P;

eig_LG = eig(L+G); 
c = 1/2 * (1 / min(real(eig_LG))) + 5;

noise_level = 10000;
noise_freq = 0.1;

% Comment out these for local observer simulation.
F = -F;
output = sim('local_observer_final.slx');

% Comment out these for cooperative observer simulation.
%output = sim('distr_obs_final.slx');

% Picking out relevant signals.
S1_pos = output.x_hats.Data(1,:);
S2_pos = output.x_hats.Data(3,:);
S3_pos = output.x_hats.Data(5,:);
S4_pos = output.x_hats.Data(7,:);
S5_pos = output.x_hats.Data(9,:);
S6_pos = output.x_hats.Data(11,:);
% Reference evolution.
S0_pos = output.x_ref.Data(:,1);

% plotting.
all_pos = [S0_pos, ...
           S1_pos', ...
           S2_pos', ...
           S3_pos', ...
           S4_pos', ...
           S5_pos', ...
           S6_pos'];

errors = [S1_pos' - S0_pos, ...
          S2_pos' - S0_pos, ...
          S3_pos' - S0_pos, ...
          S4_pos' - S0_pos, ...
          S5_pos' - S0_pos, ...
          S6_pos' - S0_pos];

thr = 1e-2;
min_index = find(abs(sum(errors, 2)) < thr, 1, "first");
time2conv = output.tout(min_index);

% figure(1)
% plot(output.tout, all_pos, "LineWidth", 2)
% xlabel("Time [s]"), ylabel("Position")
% title("Evolution of the position w. noise level: " + noise_level)
% legend("ref", "S1", "S2", "S3", "S4", "S5", "S6")
% ylim([9.9, 10.1])

figure(1)
plot(output.tout, all_pos, 'LineWidth', 2)
xlabel('Time [s]', 'FontWeight', 'bold', 'FontSize', 15)
ylabel('Position', 'FontWeight', 'bold', 'FontSize', 15)
title(['Evolution of the position w. noise level: ' num2str(noise_level)], ...
    'FontWeight', 'bold', 'FontSize', 18)
legend('ref', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6', ...
    'FontWeight', 'bold', 'FontSize', 10)
%ylim([0, 11])

% figure(2)
% plot(output.tout, errors)
% title("Evolution of the error w. noise level: " + noise_level)
% %ylim([-9, 1])
% %ylim([-0.5, 1])
% if ~isempty(time2conv)
%     yline(0), xline(time2conv)
% end
% xlabel("Time [s]"), ylabel("Error")

% figure(3)
% plot(output.tout, all_pos(:,1:2))
% title("Comparison of S0 and S1 position.")
% legend("S0 pos", "S1 pos")
% %ylim([-9, 1])
% xlabel("Time [s]"), ylabel("Position")
% 
% figure(4)
% plot(output.tout, errors(:,1))
% title("Evolution of the error in the first node S1.")
% ylim([-9, 1])
% yline(0)
% xlabel("Time [s]"), ylabel("Error")