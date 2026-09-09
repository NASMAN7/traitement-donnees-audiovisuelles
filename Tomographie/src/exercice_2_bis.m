clear;
close all;
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

load donnees;

figure('Name','Tomographie : rétroprojection filtrée','Position',[0.2*L,0,0.8*L,0.5*H]);

% Affichage de l'image originale :
subplot(1,3,1);
imagesc(I);
colormap gray;
axis off;
axis equal;
title('Image d''origine','FontSize',20);

% Filtrage du sinogramme (Ram-Lak) :
S_filtre = filtrage_sinogramme(S, n_u);

% Affichage du sinogramme filtré :
subplot(1,3,2);
imagesc(S_filtre);
colormap gray;
axis off;
axis equal;
title('Sinogramme filtré','FontSize',20);
drawnow;

% Rétroprojection sur le sinogramme filtré :
f = retroprojection(S_filtre, theta, n_u, n_lignes, n_colonnes);

% Affichage du résultat :
subplot(1,3,3);
imagesc(f);
colormap gray;
axis off;
axis equal;
title('Rétroprojection filtrée (Ram-Lak)','FontSize',20);
