function xdot = maglev_dyn(x,eps,zita)
    global B R P c A_sta

    K_net = R^(-1)*B'*P;

    xdot = A_sta * x + B*c*K_net*eps;

end