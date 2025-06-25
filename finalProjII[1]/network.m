function [Adj, G, Deg] = network(name)
    
    if name == "star"
        [Adj, G, Deg] = star_net();        
    elseif name == "chain"
        [Adj, G, Deg] = chain_net();
    elseif name == "mesh"
        [Adj, G, Deg] = mesh_net();
    end

end

