function [A_adj, G_pinning] = create_network_topology(N, topology_type)
    % Create different network topologies
    A_adj = zeros(N, N);
    G_pinning = zeros(N, N);
    
    switch topology_type
        case 'star'
            % Star topology: node 1 connected to all others
            % Only node 1 is pinned to leader
            A_adj(2:N, 1) = 1;  % All nodes receive info from node 1
            A_adj(1, 2:N) = 1;  % Node 1 receives info from all
            G_pinning(1, 1) = 1;  % Only node 1 is pinned
            
        case 'ring'
            % Ring topology: each node connected to next
            for i = 1:N-1
                A_adj(i+1, i) = 1;
            end
            A_adj(1, N) = 1;  % Close the ring
            G_pinning(1, 1) = 1;  % Node 1 pinned to leader
            
        case 'complete'
            % Complete graph: all nodes connected to all
            A_adj = ones(N, N) - eye(N);
            G_pinning(1, 1) = 1;  % Node 1 pinned to leader
            
        case 'chain'
            % Chain topology: linear connection
            for i = 1:N-1
                A_adj(i+1, i) = 1;
            end
            G_pinning(1, 1) = 1;  % First node pinned to leader
    end
end