clc; 
clear all;
close all; 

%Parameters
n=15; q=30; h=2; %Dimensions and number of attacks
lambda = 0.1;    %Regularization parameter
delta = 1e-10;   %Convergence Treshold
sigma = 1e-2;     %Measurement noise std
total_runs = 20; 
nu_IJAM = 0.7; 

state_errors_ISTA_all = [];
support_errors_ISTA_all = [];
state_errors_IJAM_all = [];
support_errors_IJAM_all = [];

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
    nu_ISTA = 0.99 / norm(G,2)^2;

    %Solve using ISTA 
    [state_errors_ISTA, support_errors_ISTA, iterations_ISTA] = ISTA(y, C, q, n, lambda, nu_ISTA, delta, x_true, a);

    %Solve using IJAM
    [state_errors_IJAM, support_errors_IJAM, iterations_IJAM] = IJAM(y, C, q, n, lambda, nu_IJAM, delta, x_true, a);

end
