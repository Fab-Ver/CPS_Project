clc
clear all
close all

load('tracking_data.mat')

lambda = 10; 
q=15;   
n=36;
G = normalize([D eye(q)]);
nu = norm(G,2)^(-2);
epsilon = 1; 

%% SSO
[support_state_error, support_attack_error] = SSO(xtrue0, G, A, atrue, lambda, nu, q, n, T, y, epsilon);

time_step = 1:T;

figure;
plot(time_step, support_state_error, '-'); hold on;
xlabel('Time Step'); ylabel('Support State Error');
legend; title('Support State Error'); grid on;
exportgraphics(gcf, 'results/support_state_error.png', 'Resolution', 300);

figure;
plot(time_step, support_attack_error, '-'); hold on;
xlabel('Time Step'); ylabel('Support Attack Error');
legend; title('Support Attack Error'); grid on;
exportgraphics(gcf, 'results/support_attack_error.png', 'Resolution', 300);
