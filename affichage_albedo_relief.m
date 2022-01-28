function affichage_albedo_relief(rho_estime,z_estime,type)

% Affichage de l'albédo estimé :
subplot(2,1,1);
imagesc(rho_estime);
title(append('Albedo ',type),'FontSize',15);
axis image;
axis off;

% Affichage du relief estimé :
subplot(2,1,2);
h = surfl(fliplr(z_estime));
title(append('Relief ',type),'FontSize',15);
zdir = [1 0 0];
rotate(h,zdir,90);
zdir = [0 1 0];
rotate(h,zdir,180);
zdir = [1 0 0];
rotate(h,zdir,-90);
shading flat;
colormap gray;
axis equal;
axis off;

view(0,90);				% Direction d'éclairage
hc = camlight('headlight','infinite');
view(-44,42);				% Direction d'observation
rotate3d;
