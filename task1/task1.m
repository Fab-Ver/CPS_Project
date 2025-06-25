clc; 
clear all;
close all; 

%Parameters
n=15; q=30; h=2; %Dimensions and number of attacks
lambda = 1.5;    %Regularization parameter
delta = 1e-10;   %Convergence Treshold
sigma = 1e-2;     %Measurement noise std
total_runs = 20; 
nu_IJAM = 1; 
max_iterations = 10000; 

state_errors_ISTA_all = zeros(total_runs, max_iterations);
support_errors_ISTA_all = zeros(total_runs, max_iterations);
state_errors_IJAM_all = zeros(total_runs, max_iterations);
support_errors_IJAM_all = zeros(total_runs, max_iterations);
iterations = 1:max_iterations;

for i=1:total_runs
    %Generate Data
    C = normrnd(0,1,[q,n]);
    eta = normrnd(0,sigma^2, [q,1]);
       
    % Generate support set S (which sensor are under attack)
    attack_indices = randperm(q, h);
    
    %Generate Attack Vector a
    a = zeros(q, 1);
    attack_signs = randi([0, 1], h, 1) * 2 - 1;
    attack_values = 4 + rand(h, 1);
    a(attack_indices) = attack_values .* attack_signs;

    %Generate State x 
    x_true = 2 + rand(n, 1); 
    x_signs = randi([0, 1], n, 1) * 2 - 1;
    x_true = x_true .* x_signs;
    
    y = C * x_true + a + eta;

    %ISTA Parameters
    G = [C, eye(q)]; 
    disp(norm(G,2)^2)
    nu_ISTA = 0.99 / norm(G,2)^2;

    %Solve using ISTA 
    [state_errors_ISTA, support_errors_ISTA, iterations_ISTA] = ISTA(y, C, q, n, lambda, nu_ISTA, delta, x_true, a, max_iterations);
    state_errors_ISTA_all(i, :) = state_errors_ISTA;
    support_errors_ISTA_all(i, : ) = support_errors_ISTA; 

    %Solve using IJAM
    [state_errors_IJAM, support_errors_IJAM, iterations_IJAM] = IJAM(y, C, q, n, lambda, nu_IJAM, delta, x_true, a, max_iterations);
    state_errors_IJAM_all(i, :) = state_errors_IJAM;
    support_errors_IJAM_all(i, : ) = support_errors_IJAM; 

end

mean_state_errors_ISTA = mean(state_errors_ISTA_all, 1);
mean_support_errors_ISTA = mean(support_errors_ISTA_all, 1);

mean_state_errors_IJAM = mean(state_errors_IJAM_all, 1);
mean_support_errors_IJAM = mean(support_errors_IJAM_all, 1);

figure;
semilogx(iterations, mean_state_errors_ISTA, '-', 'DisplayName', 'ISTA'); hold on;
%semilogx(iterations, mean_state_errors_IJAM, '-', 'DisplayName', 'IJAM'); hold on;
xlabel('Iterations'); ylabel('State Estimation Error');
legend; title('State Estimation Error'); grid on;
exportgraphics(gcf, 'results/state_estimation_error_N1_ISTA.png', 'Resolution', 300);

figure;
semilogx(iterations, mean_support_errors_ISTA, '-', 'DisplayName', 'ISTA'); hold on;
%semilogx(iterations, mean_support_errors_IJAM, '-', 'DisplayName', 'IJAM'); hold on;
xlabel('Iteration'); ylabel('Support Attack Error');
legend; title('Support Attack Error'); grid on;
exportgraphics(gcf, 'results/support_attack_error_N1_ISTA.png', 'Resolution', 300);