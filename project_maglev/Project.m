clc;
clear all;
close all;

fprintf('=== INITIALIZING SIMULINK PARAMETERS ===\n');
fprintf('Multi-Agent Magnetic Levitation System\n');
fprintf('Cooperative Dynamic Regulator Design\n\n');

% Agents 
A = [0 1; 880.87 0];

B = [0; -9.9453];

C= [708.27 0];

D = zeros(1,2);

%% Leader Node -> Sinusoid 
% w0 = 1;
% R0 = 1;
% K0 = place(A,B,[w0*1i -w0*1i]);
% 
% A0 = A-B*K0;

% 
% x0_0 = [R0 0]';

refernce = 'constant';
switch refernce
    case 'constant'
        % === PARAMETRI PER RIFERIMENTO COSTANTE ===
        constant_R0 = 20;          % Ampiezza del riferimento costante
        K0 = place(A, B,[0, -10]);  % Per steady state
        A0 = A - B*K0;
        x0_0= [constant_R0; 0];
    case 'ramp'
        % === PARAMETRI PER RIFERIMENTO A RAMPA ===
        initial_value = 0;        % Valore iniziale della rampa
        slope = 0.5;              % Pendenza della rampa

        % Ottieni parametri completi per la rampa
        [A_aug, B_aug, K_aug, K0, Ki, A0, B0, x0_0] = setup_ramp_parameters(A, B, C, initial_value, slope);
        B = B0;
        C_aug = [C 0];
        L0 = place(A0', C_aug', [-1, -2, -100])';
    case 'sinusoid'
        % === PARAMETRI PER RIFERIMENTO SINUSOIDALE ===
        sin_amplitude = 1;        % Ampiezza della sinusoide
        sin_frequency = 1;        % Frequenza della sinusoide (rad/s)
        K0 = place(A, B, [sin_frequency*1i, -sin_frequency*1i]);
        A0 = A - B*K0;
        x0_0 = [sin_amplitude; 0];
        
end
L0 = place(A0', C', [-1, -2])';

%% Initial Condition for agent

x0_1 = [12 1]';
x0_2 = [4 1]';
x0_3 = [6 1]';
x0_4 = [6 1]';
x0_5 = [9 1]';
x0_6 = [8 1]';

N = 6;

%% defintion of the Graph matrix
% Star topology for simplicity (can be easily changed)
topology_type = 'star';  % Options: 'star', 'ring', 'complete', 'chain'

[Adj, G] = create_network_topology(N, topology_type);

d_in = sum(Adj, 2);
Deg = diag(d_in);
L = Deg - Adj;

% Compute coupling gain c
eig_LG = eig(L+G);
cmin = 1/2 * (1/min(real(eig_LG)));
c = cmin * 2;

Q = eye(2);
R = 1; % Weighting factor for control input

%Distributed Controller Riccati Equation 
P = are(A0, B*R^(-1)*B', Q);
K = R^(-1)*B'*P;

% Local Observer
P = are(A0', C'*R^-1*C, Q);
F = P * C' * R^(-1);


