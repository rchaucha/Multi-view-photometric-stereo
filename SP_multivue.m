function [rho_estime, N_estime, a_garder] = SP_multivue_synthese(I, X, Y, Z, K, R, t, S)
% I : (l,c,nb_img) uint8
% X, Y, Z : 3 * (nb_pts,1) coord des points 3D
% K : (3,3) matrice de calibrage
% R : (3,3,nb_img) matrices de rotations des caméras
% t : (3,nb_img) matrices de translation des caméras
% S : (3,nb_img) matrices d'éclairage
%
% rho_estime : (nb_pts_conservés,1) albédo estimé
% N_estime : (3,nb_pts_conservés) normales estimées 

nb_pts = numel(X);
[l,c,nb_img] = size(I);

% Vecteur 4 x 10000 de points 3D en coord homogènes
Q = [X(:)' ; Y(:)' ; Z(:)' ; ones(1,nb_pts)];

a_retirer = [];
q_proj_tot = zeros(2,nb_pts,nb_img);

for k=1:nb_img
    % Projection des points Q sur l'image k
    q_proj = [R(:,:,k) t(:,k)] * Q;
    q_proj = round((K * q_proj) ./ q_proj(3,:));

    % On supprime les points qui ne sont pas dans l'image
    [~,a_retirer1] = find(q_proj(1:2,:) < 1);
    [~,a_retirer2] = find(q_proj(2,:) > l);
    [~,a_retirer3] = find(q_proj(1,:) > c);
    a_retirer = union(union(union(a_retirer,a_retirer1'),a_retirer2),a_retirer3);

    % On rajoute les points projetés
    q_proj_tot(:,:,k) = q_proj(2:-1:1,:);
end

% On détermine les points qui sont dans toutes les images
a_garder = setdiff(1:nb_pts,a_retirer);

q_proj_tot(:,a_retirer,:) = [];

% On retire les autres points
nb_pts_retenus = length(a_garder);

clear row col i_a_garder j_a_garder a_garder_complete masque;


% On crée des "images" à partir des points retenus de chaque image pour faire la SP
I_selection = zeros(nb_pts_retenus,nb_img);
for k=1:nb_img
    I_selection(:,k) = I(sub2ind(size(I),q_proj_tot(1,:,k),q_proj_tot(2,:,k),k*ones(1,size(q_proj_tot,2))));
end


% SP robuste vis-à-vis des écarts à la loi de Lambert
[rho_estime,N_estime] = estimation_robuste(I_selection,S);



