clear all;
close all; 
clc; 

load("localization_data.mat");

lambda = 10; 
n = 100;            %Number of cells
q = 20;             %Number of sensors 

G = normalize([D eye(q)]); % Concatenate and normalize columns
nu = norm(G,2)^(-2);

[x, a] = ISTA_localization(y, G, lambda, nu, n, q);

[~, ind_x] = max(x'); % Consider only the state with the higher value
supp_a = supp(a');    % Sensor indices detected as attacked

fprintf('Estimated target position index: %d\n', ind_x);
fprintf('Estimated attacked sensor indices: [%s]\n', num2str(supp_a));
