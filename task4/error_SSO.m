function error = error_SSO(a, a_est)
    error=0;
    for i=1:size(a,1)
        error = error + abs((a(i) <= 1 && a(i) >= -1) - (a_est(i) <= 1 && a_est(i) >= -1));
    end 
end 