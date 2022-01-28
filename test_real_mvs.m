clear
close all
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

data_path = 'data/Real_data/';

load append(data_path, 'data_cam_real.mat') K R T pathToPictures C_complete
I1 = imread(pathToPictures{1});
[l, c, can] = size(I1);
nb_img_tot = 4;
I = zeros(l,c,nb_img_tot,'uint8');

load(append(data_path, 'mvs/normal_verts.mat'))
load(append(data_path, 'mvs/sommets.mat'))

sommets_MVS = sommets;

%Chargement des images
nb_img = 0;
for file = dir(append(data_path, 'flash/*.JPG'))'
    nb_img = nb_img+1;
    if (nb_img > nb_img_tot)
        break;
    end
    I(:,:,nb_img) = im2gray(imread(append(data_path, file.name)));
end
clear file data_path sommets;

X = sommets_MVS(:,1);
Y = sommets_MVS(:,2);
Z = sommets_MVS(:,3);

nb_pts = numel(X);

S = C_complete(:,1:nb_img_tot)';
S = normalize(S,1,'norm');

[rho_estime, N_estime, a_garder] = SP_multivue(I, X, Y, Z, K, R, T, S);
N_estime = normalize(N_estime,1,'norm');

N = normal_verts(a_garder,:)';

a_retirer = any(isnan(N), 1);

N_estime(:,a_retirer) = [];
N(:,a_retirer) = [];
a_garder(a_retirer) = [];
rho_estime(a_retirer) = [];

% Calcul des différences entre les angles en degré
diff_angles = rad2deg(acos(dot(N,N_estime) ./ (vecnorm(N).*vecnorm(N_estime))));

a_retirer = isnan(diff_angles) | diff_angles > 140;
diff_angles(a_retirer) = [];
rho_estime(a_retirer) = [];
a_garder(a_retirer) = [];

disp(['Ecart angulaire moyen sur les normales : ' num2str(mean(diff_angles(:)),'%.2f') ' degres']);
disp(['Ecart angulaire médian sur les normales : ' num2str(median(diff_angles(:)),'%.2f') ' degres']);


%%%% HEATMAP %%%%
hmf = figure('Name','Heatmap');
cmap = jet(256);
v = rescale(diff_angles, 1, 256);
numValues = length(diff_angles);
markerColors = zeros(numValues, 3);
% Now assign marker colors according to the value of the data.
for k = 1 : numValues
    row = round(v(k));
    markerColors(k, :) = cmap(row, :);
end

% Create the scatter plot.
scatter3(X(a_garder), Y(a_garder), Z(a_garder), [], markerColors, '.');
c = colorbar;
c.Label.String = 'Ecart angulaire en degrés';
caxis([min(diff_angles) max(diff_angles)]);


%%%% ALBEDO %%%%
figure('Name','Albedo estimé');
colormap gray

% Create the scatter plot.
scatter3(X(a_garder), Y(a_garder), Z(a_garder), [], rho_estime, '.');