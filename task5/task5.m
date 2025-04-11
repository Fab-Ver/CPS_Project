clear all; 
close all; 
clc; 

data = load("localization_data.mat");
Q_ring_data = load("Q_ring.mat");
Q_star_data = load("Q_star.mat");

D = data.D;
y = data.y;

Q_ring = Q_ring_data.Q;
q_ring = Q_ring_data.q;
d_ring = Q_ring_data.d;

Q_star = Q_star_data.Q;
q_star = Q_star_data.q; 

G = normalize([D eye(q_ring)]);
lambda = 1; 
nu = 0.01 * norm(G,2)^(-2);
n = 100; 
tol = 1e-8;

figure
plot(digraph(Q_ring));
DISTA(Q_ring, nu, lambda, G, y, n, tol)

figure
plot(digraph(Q_star));
DISTA_star(Q_star, nu, lambda, G, y, n, tol)



