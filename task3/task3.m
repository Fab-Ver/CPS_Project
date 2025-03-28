clear all; 
close all; 
clc; 

q = 30; %Number of sensors
h = 3;  %Number of sensor under attack 
n = 15; %State dimension 
T_max = 10000;

load("dynamic_CPS_data.mat");

lambda = 0.1; 
nu_DSSO = 0.7;
G = [C eye(q)];
nu_SSO = 0.99 / (norm(G,2)^2); 

[state_estimation_error_SSO, attack_error_SSO] = SSO(x0, C, A, a, lambda, nu_SSO, q, n); 
[state_estimation_error_DSSO, attack_error_DSSO] = DSSO(x0, C, A, a, lambda, nu_DSSO, q, n); 

iterations = 1:T_max;

figure;
loglog(iterations, state_estimation_error_SSO, '-', 'DisplayName', 'SSO'); hold on;
loglog(iterations, state_estimation_error_DSSO, '-', 'DisplayName', 'DSSO'); hold on;
xlabel('Iterations'); ylabel('State Estimation Error');
legend; title('State Estimation Error'); grid on;
exportgraphics(gcf, 'results/state_estimation_error.png', 'Resolution', 300);

figure;
semilogx(iterations, attack_error_SSO, '-', 'DisplayName', 'SSO'); hold on;
semilogx(iterations, attack_error_DSSO, '-', 'DisplayName', 'DSSO'); hold on;
xlabel('Iterations'); ylabel('Support Attack Error');
legend; title('Support Attack Error'); grid on;
exportgraphics(gcf, 'results/support_attack_error.png', 'Resolution', 300);

