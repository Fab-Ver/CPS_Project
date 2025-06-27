function analyze_Ag_components(A, B, C, K0, F, c, L, G, N)
    fprintf('=== ANALISI COMPONENTI DI Ag ===\n');
    fprintf('Data: 2025-06-27 13:32:27 UTC\n');
    fprintf('Utente: FabioBrugia\n\n');

    % Step 1: Analizza A0
    A0 = A - B*K0;
    eig_A0 = eig(A0);
    
    fprintf('1. Componente A0 = A-BK0:\n');
    fprintf('   Autovalori di A0:\n');
    for i = 1:length(eig_A0)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_A0(i)), imag(eig_A0(i)));
    end
    
    if all(real(eig_A0) < 0)
        fprintf('   ✓ A0 è stabile\n');
    else
        fprintf('   ❌ A0 NON è stabile! Correggi K0\n');
    end
    
    % Step 2: Analizza il termine c*(L+G)⊗FC
    eig_LG = eig(L + G);
    
    fprintf('\n2. Grafo di comunicazione (L+G):\n');
    fprintf('   Autovalori di (L+G):\n');
    for i = 1:length(eig_LG)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_LG(i)), imag(eig_LG(i)));
    end
    
    if all(real(eig_LG) > 0)
        fprintf('   ✓ (L+G) ha tutti autovalori con parte reale positiva\n');
    else
        fprintf('   ❌ (L+G) ha autovalori con parte reale <= 0!\n');
    end
    
    % Step 3: Analizza A+cFC
    AFC = A + c*F*C;
    eig_AFC = eig(AFC);
    
    fprintf('\n3. Observer dynamics (A+cFC):\n');
    fprintf('   Autovalori di (A+cFC):\n');
    for i = 1:length(eig_AFC)
        fprintf('   λ_%d = %.4f %+.4fi\n', i, real(eig_AFC(i)), imag(eig_AFC(i)));
    end
    
    if all(real(eig_AFC) < 0)
        fprintf('   ✓ (A+cFC) è Hurwitz\n');
    else
        fprintf('   ❌ (A+cFC) NON è Hurwitz! Correggi F o c\n');
    end
    
    % Step 4: Ag finale
    In = eye(N);
    Ag = kron(In, A0) - c * kron(L + G, F*C);
    eig_Ag = eig(Ag);
    
    fprintf('\n4. Matrice globale Ag:\n');
    fprintf('   Dimensione: %dx%d\n', size(Ag,1), size(Ag,2));
    fprintf('   Autovalori critici (con parte reale maggiore):\n');
    
    [~, idx] = sort(real(eig_Ag), 'descend');
    for i = 1:min(6, length(eig_Ag))
        fprintf('   λ_%d = %.6f %+.6fi\n', i, real(eig_Ag(idx(i))), imag(eig_Ag(idx(i))));
    end
    
    if all(real(eig_Ag) < 0)
        fprintf('   ✓ Ag è stabile\n');
        margin = -max(real(eig_Ag));
        fprintf('   Margine stabilità: %.6f\n', margin);
    else
        fprintf('   ❌ Ag NON è stabile! Correzione necessaria\n');
        unstable = sum(real(eig_Ag) >= 0);
        fprintf('   Numero autovalori instabili: %d\n', unstable);
    end
end