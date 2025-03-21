function z_thresh = soft_thresholding(z, lambda)
    z_thresh = sign(z) .* max(abs(z) - lambda,0);
end