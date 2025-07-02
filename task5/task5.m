clear all; 
close all; 
clc; 

% Load data
data = load("localization_data.mat");
Q_ring_data = load("Q_ring.mat");
Q_star_data = load("Q_star.mat");

D = data.D;
y = data.y;

Q_ring = Q_ring_data.Q;
q_ring = Q_ring_data.q;
d_ring = Q_ring_data.d;

if check_consensus(Q_ring)
   disp("Consensus is guaranteed for Q ring");
else
   disp("Consensus is NOT guaranteed for Q ring");
end


Q_star = Q_star_data.Q;
q_star = Q_star_data.q; 

if check_consensus(Q_star)
   disp("Consensus is guaranteed for Q star");
else
   disp("Consensus is NOT guaranteed for Q star");
end

G = normalize([D eye(q_ring)]);

%Parameters
lambda = 1; 
nu = 0.01 * norm(G,2)^(-2);
n = 100; 
tol = 1e-8;

%figure;
%plot(digraph(Q_ring)); hold on;
%exportgraphics(gcf, 'results/ring_network.png', 'Resolution', 300);

% Run the DISTA algorithm on the ring topology
DISTA(Q_ring, nu, lambda, G, y, n, tol);


%figure;
%plot(digraph(Q_star)); hold on;
%exportgraphics(gcf, 'results/star_network.png', 'Resolution', 300);

% Run the DISTA algorithm on the star topology
DISTA_star(Q_star, nu, lambda, G, y, n, tol)



