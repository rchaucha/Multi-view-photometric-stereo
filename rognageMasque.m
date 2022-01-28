function [masque, taille_finale] = rognageMasque(masque_entree)
% Rogne masque_entree jusqu'à n'obtenir que des 1
% masque_entree : matrice booleene
% 
% masque : matrice booleenne avec 1 sur les éléments de masque_entree que l'on garde
% taille_finale : taille du masque après rognage

masque = ones(size(masque_entree),'logical');

taille_finale = size(masque_entree);

i = 0;
while ~all(masque_entree(masque))
    it = fix(i/4);

    if mod(i,4) == 0
        masque(it+1,:) = 0;
        taille_finale(1) = taille_finale(1) - 1;
    elseif mod(i,4) == 1
        masque(:,end-it) = 0;
        taille_finale(2) = taille_finale(2) - 1;
    elseif mod(i,4) == 2
        masque(end-it,:) = 0;
        taille_finale(1) = taille_finale(1) - 1;
    else
        masque(:,it+1) = 0;
        taille_finale(2) = taille_finale(2) - 1;
    end

    i = i + 1;
end
