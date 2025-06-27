function F = design_local_observer_gain(A, B, C, K0, Q_obs, R_obs)
% DESIGN_LOCAL_OBSERVER_GAIN Progetta la matrice di guadagno F per il local observer
%
% Inputs:
%   A, B, C - Matrici del sistema
%   K0 - Guadagno del controllore di riferimento  
%   Q_obs, R_obs - Matrici di peso per il progetto dell'observer
%
% Output:
%   F - Matrice di guadagno del local observer

    fprintf('=== PROGETTAZIONE LOCAL OBSERVER ===\n');
    
    % Step 1: Calcola la matrice del sistema in anello chiuso
    A0 = A - B*K0;
    fprintf('A0 (sistema in anello chiuso) calcolata\n');
    
    % Step 2: Verifica l'osservabilità del sistema (A0, C)
    Obs_matrix = obsv(A0, C);
    rank_obs = rank(Obs_matrix);
    n = size(A0, 1);
    
    if rank_obs < n
        warning('Il sistema (A0, C) non è completamente osservabile!');
        fprintf('Rank della matrice di osservabilità: %d (dovrebbe essere %d)\n', rank_obs, n);
    else
        fprintf('✓ Sistema completamente osservabile\n');
    end
    
    % Step 3: Progetta F usando l'equazione di Riccati algebrica (ARE)
    % Per il problema duale: A0' * P + P * A0 - P * C' * R_obs^(-1) * C * P + Q_obs = 0
    
    try
        P = are(A0', C' * inv(R_obs) * C, Q_obs);
        F = P * C' * inv(R_obs);
        
        fprintf('✓ Matrice P (soluzione ARE) calcolata con successo\n');
        fprintf('✓ Guadagno F dell''observer calcolato\n');
        
    catch ME
        fprintf('❌ Errore nel calcolo ARE: %s\n', ME.message);
        % Metodo alternativo: pole placement
        fprintf('Usando pole placement come metodo alternativo...\n');
        
        % Scegli poli per l'observer (più veloci del sistema)
        desired_poles = [-10, -20]; % Esempio per sistema 2x2
        if length(desired_poles) ~= n
            desired_poles = linspace(-10, -20, n);
        end
        
        F = place(A0', C', desired_poles)';
        fprintf('✓ Guadagno F calcolato tramite pole placement\n');
    end
    
    % Step 4: Verifica stabilità dell'observer
    A_obs = A0 - F*C;  % Matrice dinamica dell'observer
    eigenvals_obs = eig(A_obs);
    
    fprintf('\nVerifica stabilità observer:\n');
    fprintf('Autovalori di (A0 - FC):\n');
    for i = 1:length(eigenvals_obs)
        if imag(eigenvals_obs(i)) == 0
            fprintf('  λ_%d = %.4f\n', i, real(eigenvals_obs(i)));
        else
            fprintf('  λ_%d = %.4f %+.4fi\n', i, real(eigenvals_obs(i)), imag(eigenvals_obs(i)));
        end
    end
    
    if all(real(eigenvals_obs) < 0)
        fprintf('✓ Observer stabile (tutti gli autovalori hanno parte reale negativa)\n');
    else
        fprintf('❌ Observer instabile!\n');
    end
    
    % Step 5: Mostra la matrice F risultante
    fprintf('\nMatrice F del local observer:\n');
    disp(F);
    
    % Step 6: Informazioni aggiuntive per il debug
    fprintf('\nInformazioni aggiuntive:\n');
    fprintf('Condizionamento di P: %.2e\n', cond(P));
    fprintf('Norma di F: %.4f\n', norm(F));
    
end

