function visualize_network(A_adj, G_pinning, topology_type)
    % Simple network visualization
    N = size(A_adj, 1);
    
    % Create node positions based on topology
    switch topology_type
        case 'star'
            % Central node at origin, others in circle
            angles = linspace(0, 2*pi, N+1);
            pos = [0.5*cos(angles(1:N))' + 0.5, 0.5*sin(angles(1:N))' + 0.5];
            pos(1,:) = [0.5, 0.5];  % Center node
            
        case 'ring'
            angles = linspace(0, 2*pi, N+1);
            pos = [0.4*cos(angles(1:N))' + 0.5, 0.4*sin(angles(1:N))' + 0.5];
            
        otherwise
            % Random positions for other topologies
            pos = rand(N, 2);
    end
    
    % Draw edges
    for i = 1:N
        for j = 1:N
            if A_adj(i,j) > 0
                plot([pos(i,1), pos(j,1)], [pos(i,2), pos(j,2)], 'b-', 'LineWidth', 1);
                hold on;
            end
        end
    end
    
    % Draw nodes
    for i = 1:N
        if G_pinning(i,i) > 0
            % Pinned node (red)
            plot(pos(i,1), pos(i,2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red');
        else
            % Regular node (blue)
            plot(pos(i,1), pos(i,2), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'blue');
        end
        text(pos(i,1)+0.05, pos(i,2)+0.05, sprintf('%d', i), 'FontSize', 8);
        hold on;
    end
    
    % Leader node
    plot(0.1, 0.9, 'ks', 'MarkerSize', 12, 'MarkerFaceColor', 'black');
    text(0.15, 0.9, 'L', 'FontSize', 10, 'Color', 'white', 'FontWeight', 'bold');
    
    axis equal;
    axis([0 1 0 1]);
    axis off;
end