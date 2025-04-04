function error = support_error(real, est, epsilon)
    error=0;
    for i=1:size(real,1)
        error = error + abs((abs(real(i)) >= epsilon) - (abs(est(i)) >= epsilon));
    end 
end 