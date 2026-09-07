clear;
close all;
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% =========================================================
% Lecture des images source et cible
% =========================================================
s_rgb = imread('Images/ronaldo.jpg');

c_rgb = imread('Images/montagne.jpg');

% Affichage
figure('Name','Exercice 3 - Gradients mixtes','Position',[0.05*L,0.1*H,0.9*L,0.8*H]);
subplot(1,3,1);
imagesc(s_rgb);
axis image off;
title('Source s','FontSize',14);

subplot(1,3,2);
imagesc(c_rgb);
axis image off;
title('Cible c','FontSize',14);
drawnow;

% =========================================================
% Selection du polygone p dans s
% =========================================================
subplot(1,3,1);
fprintf('Selectionnez un polygone dans la source, puis tapez Entree.\n');
[xp, yp] = ginput;
xp = [xp; xp(1)];
yp = [yp; yp(1)];
hold on;
plot(xp, yp, 'r-', 'LineWidth', 2);
plot(xp, yp, 'r*', 'MarkerSize', 8);
drawnow;

% =========================================================
% Selection du rectangle r dans c
% =========================================================
subplot(1,3,2);
fprintf('Cliquez sur 2 coins opposes du rectangle dans la cible.\n');
[xr, yr] = ginput(2);
hold on;
plot(xr, yr, 'b*', 'MarkerSize', 10, 'LineWidth', 2);
rectangle('Position',[min(xr),min(yr),abs(diff(xr)),abs(diff(yr))],...
    'EdgeColor','b','LineWidth',2);
drawnow;

% =========================================================
% Transformation affine t : s -> c
% =========================================================
% Rectangle englobant de p
xp_min = min(xp); xp_max = max(xp);
yp_min = min(yp); yp_max = max(yp);
e_width  = xp_max - xp_min;
e_height = yp_max - yp_min;

% Dimensions du rectangle r
r_col1 = round(min(xr)); r_col2 = round(max(xr));
r_lig1 = round(min(yr)); r_lig2 = round(max(yr));
r_width  = r_col2 - r_col1 + 1;
r_height = r_lig2 - r_lig1 + 1;

% Extraction et redimensionnement de s
s_crop = imresize(double(s_rgb), [r_height, r_width]);
c_rgb  = double(c_rgb);
s_crop = max(0, min(255, s_crop));

% Masque du polygone p transforme dans r
xp_norm = (xp - xp_min) / e_width  * (r_width  - 1) + 1;
yp_norm = (yp - yp_min) / e_height * (r_height - 1) + 1;
masque_p = poly2mask(xp_norm, yp_norm, r_height, r_width);

% =========================================================
% Appel collage avec gradients mixtes
% =========================================================

for k = 1:3
    % Moyenne de la cible dans r
    moy_c = mean(mean(double(c_rgb(r_lig1:r_lig2, r_col1:r_col2, k))));
    % Moyenne de la source
    moy_s = mean(mean(s_crop(:,:,k)));
    % Correction
    s_crop(:,:,k) = s_crop(:,:,k) + (moy_c - moy_s);
end
s_crop = max(0, min(255, s_crop));
u = collage_mixte(s_crop, c_rgb, r_lig1, r_lig2, r_col1, r_col2, masque_p);
u = uint8(u);

subplot(1,3,3);
imagesc(u);
axis image off;
title('Resultat gradients mixtes','FontSize',14);
drawnow;

% Sauvegarde
imwrite(u, 'resultat_exercice3.png');
fprintf('Resultat sauvegarde : resultat_exercice3.png\n');