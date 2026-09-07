clear;
close all;
clc;

taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Lecture de l'image de base
I = imread('Images/rose.jpg');

% 1. Initialisation de la source s et de la cible c au format LAB
s = rgb2lab(I);
c = s;
% Annulation des canaux chromatiques de c pour la rendre en niveaux de gris
c(:,:,2) = 0; 
c(:,:,3) = 0;

% Affichage de l'image source (reconvertie en RGB pour l'affichage)
figure('Name','Décoloration partielle','Position',[0.1*L,0.1*H,0.9*L,0.7*H]);
subplot(1,2,1);
imagesc(lab2rgb(s));
axis image off;
title('Image originale','FontSize',20);
hold on;

% 2. Sélection du polygone p
disp('Détourez grossièrement la rose (double-clic pour valider)');
[p, x_p, y_p] = roipoly;
plot([x_p; x_p(1)], [y_p; y_p(1)], 'r', 'LineWidth', 2);

[nb_lignes, nb_colonnes, ~] = size(s);
i_p = min(max(round(y_p),1), nb_lignes);
j_p = min(max(round(x_p),1), nb_colonnes);

i_min = min(i_p(:));
i_max = max(i_p(:));
j_min = min(j_p(:));
j_max = max(j_p(:));


% 4. Extraction des sous-matrices
s_sub = s(i_min:i_max, j_min:j_max, :);
c_sub = c(i_min:i_max, j_min:j_max, :);
p_sub = p(i_min:i_max, j_min:j_max);

% 5. Traitement via l'équation de Poisson
interieur = find(p_sub > 0);

u_sub = collage(c_sub, s_sub, interieur);

% 6. Reconstruction de l'image finale
u = c; % Le fond est l'image décolorée
u(i_min:i_max, j_min:j_max, :) = u_sub; % On insère le résultat du collage

% Affichage du résultat final (converti en RGB)
subplot(1,2,2);
imagesc(lab2rgb(u));
axis image off;
title('Résultat (Décoloration partielle)','FontSize',20);
