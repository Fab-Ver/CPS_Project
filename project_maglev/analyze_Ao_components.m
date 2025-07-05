function analyze_Ao_components(A, B, C, K0, F_c, F_l, c, L, G, N)
    fprintf('=== ANALISI COMPONENTI DI Ao ===\n');
    fprintf('Data: 2025-06-27 13:32:27 UTC\n');
    fprintf('Utente: FabioBrugia\n\n');

    %% === 1. Componente A0 ===
    A0 = A - B*K0;
    eig_A0 = eig(A0);
    
    fprintf('1. Dinamica A0 = A - B*K0:\n');
    fprintf('   Autovalori di A0:\n');
    for i = 1:length(eig_A0)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_A0(i)), imag(eig_A0(i)));
    end
    
    if all(real(eig_A0) < 0)
        fprintf('   [OK] A0 è stabile\n');
    else
        fprintf('   [X] A0 NON è stabile! Correggi K0\n');
    end

    %% === 2. Analisi grafo di comunicazione (L + G) ===
    eig_LG = eig(L + G);
    
    fprintf('\n2. Grafo di comunicazione (L + G):\n');
    fprintf('   Autovalori di (L + G):\n');
    for i = 1:length(eig_LG)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_LG(i)), imag(eig_LG(i)));
    end
    
    if all(real(eig_LG) > 0)
        fprintf('   [OK] (L + G) ha tutti autovalori con parte reale positiva\n');
    else
        fprintf('   [X] (L + G) ha autovalori con parte reale <= 0!\n');
    end

    %% === 3. Dinamica osservatore locale: A + c * F_l * C ===
    A_local = A0 + c * F_l * C;
    eig_A_local = eig(A_local);
    
    fprintf('\n3. Dinamica osservatore locale (A + c * F_l * C):\n');
    fprintf('   Autovalori di A + cFC:\n');
    for i = 1:length(eig_A_local)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_A_local(i)), imag(eig_A_local(i)));
    end
    
    if all(real(eig_A_local) < 0)
        fprintf('   [OK] (A + cFC) è Hurwitz\n');
    else
        fprintf('   [X] (A + cFC) NON è Hurwitz! Correggi F_l o c\n');
    end

    %% === 4. Dinamica globale distribuita: Ao ===
    In = eye(N);
    Ao = kron(In, A0) - c * kron(L + G, F_c * C);
    eig_Ao = eig(Ao);
    
    fprintf('\n4. Dinamica globale Ao:\n');
    fprintf('   Dimensione matrice Ao: %dx%d\n', size(Ao,1), size(Ao,2));
    fprintf('   Autovalori principali (quelli con parte reale maggiore):\n');
    
    [~, idx] = sort(real(eig_Ao), 'descend');
    for i = 1:min(6, length(eig_Ao))
        fprintf('   λ_%d = %.6f %+.6fi\n', i, real(eig_Ao(idx(i))), imag(eig_Ao(idx(i))));
    end
    
    if all(real(eig_Ao) < 0)
        fprintf('   [OK] Ao è stabile\n');
        margin = -max(real(eig_Ao));
        fprintf('   Margine di stabilità: %.6f\n', margin);
    else
        fprintf('   [X] Ao NON è stabile! Correzione necessaria\n');
        unstable = sum(real(eig_Ao) >= 0);
        fprintf('   Numero di autovalori instabili: %d\n', unstable);
    end
end