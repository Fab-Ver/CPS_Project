function xhatdot = observer(eps, xhat, ytildei)
    global B R P F c A_sta;

    K_net = R^(-1)*B'*P;
    
    xhatdot = A_sta * xhat + B*c*K_net*eps - c*F*ytildei(1);

end