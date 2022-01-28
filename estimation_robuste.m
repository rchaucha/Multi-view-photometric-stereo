function [rho_estime,N_estime] = estimation_robuste(I,S)

I = I';

nb_img = size(I,1);

mu = 0.1;

m_estime = pinv(S'*S)*S'*I;
m_k_moins_1 = zeros(size(m_estime));

e = S*m_estime-I;
w = zeros(nb_img,1);

nb_ite = 0;
while nb_ite < 5 || norm(m_estime-m_k_moins_1)/norm(m_k_moins_1) > 10^-3
    m_k_moins_1 = m_estime;
    
    m_estime = S\(I+e-w/mu);
    e = shrink(S*m_estime-I+w/mu,1/mu);
    w = w + mu*(S*m_estime-I-e);

    nb_ite = nb_ite + 1;
end

rho_estime = vecnorm(m_estime);
N_estime = m_estime ./ rho_estime;

