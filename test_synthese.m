clear
close all
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Définition des fonctions
mu = [0.2 0.4];
sigma = [0.7 0.6];
zFunc = @(X,Y) 1/(sigma(1)*sigma(2)*sqrt(2*pi)).*exp(-1/2*((X-mu(1)).^2/sigma(1)^2 + (Y-mu(2)).^2/sigma(2)^2));
normalsFunc = @(X,Y) [-(2^(1/2).*exp(-(mu(1) - X).^2/(2*sigma(1)^2) - (mu(2)-Y).^2/(2*sigma(2)^2)).*(2*mu(1) - 2*X))/(4*pi^(1/2)*sigma(1)^4);
    -(2^(1/2).*exp(- (mu(1) - X).^2/(2*sigma(1)^2) - (mu(2) - Y).^2/(2*sigma(2)^2)).*(2*mu(2) - 2*Y))/(4*pi^(1/2)*sigma(1)^2*sigma(2)^2);
    ones(1,size(X,2))];

data_path = 'data/Gaussienne/';

load(append(data_path, 'data_gt.mat'))

%Chargement des images
nb_img = 0;
for file = dir(append(data_path, '*.png'))'
    nb_img = nb_img+1;
    I(:,:,nb_img) = imread(append(data_path, file.name));
end
clear file data_path;

Z = zFunc(X,Y);

[rho_estime, N_estime, a_garder] = SP_multivue(I, X, Y, Z, K, RCamTab, tCamTab, lightSourceTab');

[l,c] = size(rho_estime);

% Calcul des normales des points conservés
N = normalsFunc(X(a_garder)',Y(a_garder)');

rho = ones(l,c);

% Integration du champ de normales :
N_estime = normalize(N_estime,1,'norm');
N_estime(3,find(abs(N_estime(3,:))<0.1)) = Inf;		% Les pentes trop fortes sont tronquees
p_estime = reshape(-N_estime(1,:)./N_estime(3,:),l,c);
q_estime = reshape(N_estime(2,:)./N_estime(3,:),l,c);
z_estime = integration_SCS(q_estime,p_estime);

% Ambiguïté concave/convexe :
if (z_estime(floor(l/2),floor(c/2)) < z_estime(1,1))
	z_estime = -z_estime;
end

% Integration du champ de normales réelles :
N = normalize(N,1,'norm');
N(3,find(abs(N(3,:))<0.1)) = Inf;		% Les pentes trop fortes sont tronquees
p_estime = reshape(-N(1,:)./N(3,:),l,c);
q_estime = reshape(N(2,:)./N(3,:),l,c);
z = integration_SCS(q_estime,p_estime);

% Ambiguïté concave/convexe :
if (z(floor(l/2),floor(c/2))<z(1,1))
	z = -z;
end

figure('Name','Carte des normales')
subplot(1,2,1)
N_estime_rgb = reshape(N_estime', size(z_estime,1), size(z_estime,2),3);
N_estime_rgb = ((N_estime_rgb+1)./2).*255;
imshow(uint8(N_estime_rgb));
title('Carte des normales réelles','FontSize',15);

subplot(1,2,2)
N_rgb = reshape(N', size(z_estime,1), size(z_estime,2),3);
N_rgb = ((N_rgb+1)./2).*255;
imshow(uint8(N_rgb));
title('Carte des normales estimées','FontSize',15);

figure('Name','Albedo et relief reel','Position',[0.1*L,0,0.2*L,0.7*H])
affichage_albedo_relief(rho,z,'reel');

figure('Name','Albedo et relief estime','Position',[0.3*L,0,0.2*L,0.7*H]);
affichage_albedo_relief(rho_estime,z_estime,'estime');

% Calcul des différences entre les angles en degré
diff_angles = rad2deg(acos(dot(N,N_estime) ./ (vecnorm(N).*vecnorm(N_estime))));

disp(['Ecart angulaire moyen sur les normales : ' num2str(mean(diff_angles(:)),'%.2f') ' degres']);

hmf = figure('Name','Heatmap');
set(hmf, 'Position', get(hmf,'Position').*[0 0 1 1] + [0.51*L 0.2*H 0 0])
% Affichage de la heatmap
angles_heatmap = reshape(diff_angles,l,c);
colormap('hot')
imagesc(angles_heatmap)
c = colorbar;
c.Label.String = 'Ecart angulaire en degrés';
