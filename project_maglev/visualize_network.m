function visualize_network(Adj, G, N, topology_type)

    % Augmented matrix to include also the connection with the leader node
    A_ext = zeros(N+1, N+1);           
    A_ext(2:end, 2:end) = Adj;

    % Insert pinning from G
    for i = 1:N
        if G(i,i) > 0
            A_ext(i+1, 1) = G(i,i);   % leader v₀ → follower v_i
        end
    end

    % Create digraph
    G_aug = digraph(A_ext');

    %Labels
    node_names = ["S_0", arrayfun(@(i) sprintf("S_%d", i), 1:N, 'UniformOutput', false)];

    % Plot
    figure; 
    plot(G_aug, ...
    'NodeLabel', node_names, ...
    'Layout', 'layered', 'Direction', 'right', ...
    'MarkerSize', 10, ...
    'NodeFontSize', 10, ...
    'NodeFontWeight', 'bold');

    filename = sprintf("topology/%s_network.png", topology_type);
    exportgraphics(gcf, filename, 'Resolution', 300);
end