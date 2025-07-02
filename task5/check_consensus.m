function result = check_consensus(Q)
    % Check if matrix Q satisfies spectral condition for consensus
    result = true;

    % Get and sort eigenvalues by absolute value (descending)
    eigenvalues = eig(Q);
    [~, idx] = sort(abs(eigenvalues), 'descend');
    sorted_eigs = eigenvalues(idx);

    % Check Perron-Frobenius condition: λ1 = 1
    if abs(sorted_eigs(1) - 1) > 1e-8
        result = false;
        return;
    end

    % Check that all other eigenvalues are strictly less in magnitude
    for i = 2:length(sorted_eigs)
        if abs(sorted_eigs(i)) >= 1
            result = false;
            break;
        end
    end
end