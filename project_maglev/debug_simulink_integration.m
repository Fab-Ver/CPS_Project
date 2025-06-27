function debug_simulink_integration(A,B,C,K0,R,Q,c,F,P)
% DEBUG_SIMULINK_INTEGRATION Diagnostica problemi di integrazione in Simulink
%
% Questa funzione identifica i problemi più comuni che impediscono
% l'integrazione in sistemi di local observer

    fprintf('=== DIAGNOSI PROBLEMI INTEGRAZIONE SIMULINK ===\n');
    fprintf('Data: %s\n', datestr(now));
    fprintf('Utente: FabioBrugia\n\n');
    
    % Carica i tuoi parametri
 
    N = 6;
    
    % Parametri dal tuo codice
 
    A0 = A - B*K0;
    
 
    
    % === DIAGNOSI 1: STABILITÀ MATRICI ===
    fprintf('\n=== DIAGNOSI 1: STABILITÀ MATRICI ===\n');
    
    % Verifica A0
    eig_A0 = eig(A0);
    fprintf('Autovalori di A0 (A-BK0):\n');
    for i = 1:length(eig_A0)
        fprintf('  λ_%d = %.6f %+.6fi (Re=%.6f)\n', i, real(eig_A0(i)), imag(eig_A0(i)), real(eig_A0(i)));
    end
    
    if any(real(eig_A0) >= -1e-10)
        fprintf('❌ PROBLEMA: A0 ha autovalori con parte reale >= 0\n');
        fprintf('   Questo può causare instabilità nell''integrazione\n');
    else
        fprintf('✓ A0 è stabile\n');
    end
    
    % Verifica observer dynamics
    A_obs = A0 - F*C;
    eig_obs = eig(A_obs);
    fprintf('\nAutovalori dell''observer (A0 - FC):\n');
    for i = 1:length(eig_obs)
        fprintf('  λ_%d = %.6f %+.6fi (Re=%.6f)\n', i, real(eig_obs(i)), imag(eig_obs(i)), real(eig_obs(i)));
    end
    
    if any(real(eig_obs) >= -1e-10)
        fprintf('❌ PROBLEMA: Observer ha autovalori con parte reale >= 0\n');
    else
        fprintf('✓ Observer è stabile\n');
    end
    
    % === DIAGNOSI 2: CONDIZIONAMENTO NUMERICO ===
    fprintf('\n=== DIAGNOSI 2: CONDIZIONAMENTO NUMERICO ===\n');
    
    cond_A0 = cond(A0);
    cond_F = cond(F);
    cond_P = cond(P);
    
    fprintf('Numero di condizione A0: %.2e\n', cond_A0);
    fprintf('Numero di condizione F: %.2e\n', cond_F);
    fprintf('Numero di condizione P: %.2e\n', cond_P);
    
    if cond_A0 > 1e12
        fprintf('❌ PROBLEMA: A0 è mal condizionata\n');
    end
    if cond_F > 1e12
        fprintf('❌ PROBLEMA: F è mal condizionata\n');
    end
    if cond_P > 1e12
        fprintf('❌ PROBLEMA: P è mal condizionata\n');
    end
    
    % === DIAGNOSI 3: MAGNITUDE DEI GUADAGNI ===
    fprintf('\n=== DIAGNOSI 3: MAGNITUDE DEI GUADAGNI ===\n');
    
    norm_F = norm(F);
    norm_K0 = norm(K0);
    
    fprintf('Norma di F: %.6f\n', norm_F);
    fprintf('Norma di K0: %.6f\n', norm_K0);
    fprintf('Coupling gain c: %.6f\n', c);
    fprintf('Prodotto c*||F||: %.6f\n', c * norm_F);
    
    if norm_F > 1e6
        fprintf('❌ PROBLEMA: F ha guadagni molto alti (possibili oscillazioni numeriche)\n');
    end
    if c * norm_F > 1e6
        fprintf('❌ PROBLEMA: c*F ha guadagni molto alti\n');
    end
    
    % === DIAGNOSI 4: OSSERVABILITÀ ===
    fprintf('\n=== DIAGNOSI 4: OSSERVABILITÀ ===\n');
    
    Obs_matrix = obsv(A0, C);
    rank_obs = rank(Obs_matrix);
    cond_obs = cond(Obs_matrix);
    
    fprintf('Rank matrice osservabilità: %d (dimensione: %d)\n', rank_obs, size(A0,1));
    fprintf('Condizionamento matrice osservabilità: %.2e\n', cond_obs);
    
    if rank_obs < size(A0,1)
        fprintf('❌ PROBLEMA: Sistema non completamente osservabile\n');
    end
    if cond_obs > 1e12
        fprintf('❌ PROBLEMA: Matrice osservabilità mal condizionata\n');
    end
    
    % === DIAGNOSI 5: STEP SIZE E SOLVER ===
    fprintf('\n=== DIAGNOSI 5: STEP SIZE E SOLVER ===\n');
    
    % Calcola time constants
    if all(real(eig_obs) < 0)
        tau_obs = -1./real(eig_obs);
        tau_min = min(tau_obs);
        fprintf('Costante di tempo minima observer: %.6f s\n', tau_min);
        
        suggested_step = tau_min / 50;  % Rule of thumb
        fprintf('Step size suggerito: %.2e s\n', suggested_step);
        
        if suggested_step < 1e-6
            fprintf('❌ PROBLEMA: Dinamiche molto veloci richiedono step molto piccoli\n');
            fprintf('   Considera di ridurre i guadagni o usare solver stiff\n');
        end
    end
    
    % === DIAGNOSI 6: ALGEBRAIC LOOPS ===
    fprintf('\n=== DIAGNOSI 6: POSSIBILI ALGEBRAIC LOOPS ===\n');
    
    % Verifica se D è non-zero
    D = zeros(size(C,1), size(B,2));
    if any(D(:) ~= 0)
        fprintf('❌ PROBLEMA: Matrice D non-zero può causare algebraic loops\n');
    else
        fprintf('✓ Matrice D è zero (nessun feedthrough diretto)\n');
    end
    
    % === SUGGERIMENTI SPECIFICI ===
    fprintf('\n=== SUGGERIMENTI PER SIMULINK ===\n');
    fprintf('1. Solver settings:\n');
    fprintf('   - Usa ode15s (solver stiff) se hai dinamiche veloci\n');
    fprintf('   - Max step size: %.2e\n', min(0.01, suggested_step*10));
    fprintf('   - Relative tolerance: 1e-6 o meno\n\n');
    
    fprintf('2. Verifica nel modello Simulink:\n');
    fprintf('   - Controlla che non ci siano algebraic loops\n');
    fprintf('   - Verifica le condizioni iniziali degli integratori\n');
    fprintf('   - Assicurati che tutte le matrici siano definite nel workspace\n\n');
    
    fprintf('3. Se il problema persiste:\n');
    fprintf('   - Riduci il coupling gain c\n');
    fprintf('   - Usa solver con tolleranze più strette\n');
    fprintf('   - Aggiungi small delay negli anelli di feedback\n');
    
end

% Funzione per creare topologia di rete (se non esiste già)
function [Adj, G] = create_network_topology(N, type)
    switch type
        case 'star'
            Adj = zeros(N);
            % Node 1 è il centro, connesso a tutti gli altri
            for i = 2:N
                Adj(1,i) = 1;
                Adj(i,1) = 1;
            end
            G = zeros(N);
            G(1,1) = 1;  % Solo il nodo centrale ha accesso al riferimento
        otherwise
            error('Topologia non implementata');
    end
end

% Funzione per testare il sistema in open loop
function test_open_loop_stability()
    fprintf('\n=== TEST STABILITÀ OPEN LOOP ===\n');
    
    A = [0 1; 880.87 0];
    B = [0; -9.9453];
    C = [708.27 0];
    
    eig_A = eig(A);
    fprintf('Autovalori sistema originale A:\n');
    for i = 1:length(eig_A)
        fprintf('  λ_%d = %.6f %+.6fi\n', i, real(eig_A(i)), imag(eig_A(i)));
    end
    
    if any(real(eig_A) >= 0)
        fprintf('⚠️  Sistema originale instabile (normale per levitazione magnetica)\n');
    end
    
    % Test osservabilità sistema originale
    Obs_orig = obsv(A, C);
    rank_orig = rank(Obs_orig);
    fprintf('Osservabilità sistema originale: %d/%d\n', rank_orig, size(A,1));
    
    if rank_orig < size(A,1)
        fprintf('❌ PROBLEMA FONDAMENTALE: Sistema originale non osservabile\n');
    end
end
