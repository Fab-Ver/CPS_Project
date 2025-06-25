function [Adj, G, Deg] = mesh_net()

    % Adjacency matrix.
    Adj = [0     3     1     1     1     1;
           1     0     1     1     1     1;
           1     1     0     4     1     1;
           1     1     1     0     1     1;
           1     1     2     1     0     1;
           1     2     1     1     1     0];

    % Pinning matrix.
    G = diag([1,3,1,2,2,1]);
    
    % Degree matrix.
    Deg = diag([7,5,8,5,6,6]);      

end

