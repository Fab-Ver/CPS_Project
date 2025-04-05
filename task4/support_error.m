function error = support_error(real, est, epsilon)
    error = sum(abs((abs(real) >= epsilon) - (abs(est) >= epsilon)));
end 