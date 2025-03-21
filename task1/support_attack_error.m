function error = support_attack_error(a, a_est)
    error=0;
    for i=1:size(a,1)
        error = error + abs((a(i) ~= 0) - (a_est(i) ~= 0));
    end 
end 