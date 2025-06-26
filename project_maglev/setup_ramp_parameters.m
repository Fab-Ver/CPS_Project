function [A_aug, B_aug, K_aug, K0, Ki, A0, B0, x0_0] = setup_ramp_parameters(A, B, C, initial_value, slope)
    % SETUP_RAMP - Imposta i parametri per un riferimento a rampa in Simulink
    %
    % Input:
    %   A, B, C - Matrici del sistema
    %   initial_value - Valore iniziale della rampa
    %   slope - Pendenza della rampa (unità/secondo)
    %
    % Output:
    %   A_aug - Matrice A del sistema aumentato
    %   B_aug - Matrice B del sistema aumentato
    %   K_aug - Guadagno completo del regolatore [K0 Ki]
    %   K0 - Guadagno proporzionale
    %   Ki - Guadagno integrale
    %   A0 - Matrice A del sistema a ciclo chiuso
    %   B0 - Matrice B del sistema a ciclo chiuso
    %   x0_0 - Stato iniziale del leader [posizione; velocità; stato integratore]
    
    % Crea sistema aumentato per la rampa
    A_aug = [A, zeros(2,1); 
             -C, 0];
    B_aug = [B; 
             0];
    
    % Calcolo del guadagno del regolatore
    poles = [-2, -3, -4];  % Poli desiderati (modificabili)
    K_aug = place(A_aug, B_aug, poles);
    
    % Estrai i guadagni
    K0 = K_aug(1:2);       % Guadagno proporzionale
    Ki = K_aug(3);         % Guadagno integrale
    
    % Matrici del sistema a ciclo chiuso
    A0 = [A - B*K0, -B*Ki;
          -C, 0];
    B0 = [zeros(2,1); 
          1];
    
    % Stato iniziale del leader
    x0_0 = [initial_value; slope; 0];  % [posizione; velocità; stato integratore]
end