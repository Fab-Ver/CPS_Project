clear all;
close all; 
clc; 

load("localization_data.mat");

lambda = 10; 
n = 100;            %Number of cells
q = 20;             %Number of sensors 
G = normalize([D eye(q)]);
nu = norm(G,2)^(-2);

[x, a] = ISTA_localization(y, G, lambda, nu, n, q);

supp_x = supp(x')
supp_a = supp(a')
