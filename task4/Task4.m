clc
clear all
close all

load('tracking_data.mat')

lambda = 10; 

q=15;   
n=36;
G = normalize([D eye(q)]);
nu_SSO = norm(G,2)^(-2);
%% SSO
[err_SSO, att_err_SSO] = SSO(xtrue0, G, A, atrue, lambda, nu_SSO, q, n,T,y);
 %%
   iterations = 1:T;
 figure;
 loglog(iterations, err_SSO, '-', 'DisplayName', 'SSO'); hold on;
 legend; title('State Estimation Error'); grid on;
 figure;
 semilogx(iterations, att_err_SSO, '-', 'DisplayName', 'SSO'); hold on;
 legend; title('Support Attack Error'); grid on;
