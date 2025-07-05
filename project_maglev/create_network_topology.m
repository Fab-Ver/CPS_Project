function [Adj, G, L] = create_network_topology(N, topology_type)
    % Create different network topologies
    Adj = zeros(N, N);
    G = zeros(N, N);
    
    switch topology_type
        case 'star'
            % Star topology: node 1 connected to all others
            % Only node 1 is pinned to leader
            Adj(2:N, 1) = 1;  % All nodes receive info from node 1
            Adj(1, 2:N) = 1;  % Node 1 receives info from all
            G(1, 1) = 1;  % Only node 1 is pinned
        case 'star_s0'
            %Star Topology: node 0 pinned to all others, no follower
            %connection
            for i=1:N
                G(i, i) = 1;
            end
        case 'star_s0_complete'
            %Star Topology: node 0 pinned to all others, each node i
            %connected with i+1
            for i=1:N-1
                Adj(i+1, i) = 1;
            end
            Adj(1,N) = 1; 
            for i=1:N
                G(i, i) = 1;
            end
        case 'ring'
            % Ring topology: each node connected to next
            for i = 1:N-1
                Adj(i+1, i) = 1;
            end
            Adj(1, N) = 1;  % Close the ring
            G(1, 1) = 1;  % Node 1 pinned to leader
            
        case 'complete'
            % Complete graph: all nodes connected to all
            Adj = ones(N, N) - eye(N);
            G(1, 1) = 1;  % Node 1 pinned to leader
        case 'tree'
            % Tree: the leader is connected to a subset of nodes, other
            % node are connected in chain to the nodes pinned to the leader
            Adj(2,1) = 1; 
            Adj(3,2) = 1;
            Adj(5,4) = 1;
            Adj(6,5) = 1;
            G(1,1) = 1; %Node 1 pinned to leader 
            G(4,4) = 1; %Node 4 pinned to leader 
        case 'chain'
            % Chain Topology: linear connection
            for i = 1:N-1
                Adj(i+1, i) = 1;
            end
            G(1, 1) = 1; % First node pinned to leader
    end
    % Compute the in-degree of node i and the matrix D
    d_in = sum(Adj, 2);
    Deg = diag(d_in);

    %Laplacian Matrx of G, L = D - A
    L = Deg - Adj;
    
    %Visualize Network Topology 
    visualize_network(Adj, G, N, topology_type);
end