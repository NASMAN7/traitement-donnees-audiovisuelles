clear;
close all;
clc;

taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Lecture et preparation de l'image
u_orig = imread('./Images/Barbara.png');
u_orig = double(u_orig);

if size(u_orig,3) == 1
    u_orig = repmat(u_orig,[1,1,3]);
end

u_orig = u_orig / 255;
[nb_lignes, nb_colonnes, nb_canaux] = size(u_orig);
N = nb_lignes * nb_colonnes;

% Parametres
epsilon  = 0.5;
mu_prime = 70;
gamma    = 3e-5;
nb_iter  = 1000;
pas_aff  = 50;

% Filtre passe-bas Phi dans le domaine frequentiel
eta = 0.05;  % seuil frequentie
[nu_x, nu_y] = meshgrid(1:nb_colonnes, 1:nb_lignes);
nu_x = nu_x/nb_colonnes - 0.5;
nu_y = nu_y/nb_lignes   - 0.5;
Phi = 1 ./ (1 + (nu_x.^2 + nu_y.^2) / eta);

% Construction des matrices Dx et Dy (differences finies)
e  = ones(N,1);
Dx = spdiags([-e, e], [0, nb_lignes], N, N);
Dy = spdiags([-e, e], [0, 1],         N, N);

% Conditions aux bords (derniere colonne/ligne = 0)
% Dx : derniere colonne de blocs
idx_last_col = (nb_colonnes-1)*nb_lignes+1 : nb_colonnes*nb_lignes;
Dx(idx_last_col, :) = 0;
% Dy : derniere ligne de chaque bloc
idx_last_lig = nb_lignes : nb_lignes : N;
Dy(idx_last_lig, :) = 0;

DxT = Dx';
DyT = Dy';

% Initialisation : u = image originale
u = u_orig;

% TF de l'image originale
TF_u_orig = zeros(nb_lignes, nb_colonnes, nb_canaux);
for k = 1:nb_canaux
    TF_u_orig(:,:,k) = fftshift(fft2(u_orig(:,:,k)));
end

% Figure d'affichage
figure('Name','TV-Hilbert : structure + texture', ...
       'Position',[0.05*L, 0.05*H, 0.9*L, 0.8*H]);

% Boucle de descente de gradient
fprintf('Debut des iterations TV-Hilbert...\n');

for iter = 1:nb_iter

    grad_E = zeros(nb_lignes, nb_colonnes, nb_canaux);

    for k = 1:nb_canaux

        uk = u(:,:,k);

        % Terme d'attache aux donnees : TF^{-1}{Phi.[TF(u)-TF(u_orig)]}
        TF_uk     = fftshift(fft2(uk));
        diff_TF   = Phi .* (TF_uk - TF_u_orig(:,:,k));
        attache   = real(ifft2(ifftshift(diff_TF)));

        % Terme de regularisation TV : divergence de grad(u)/|grad(u)|
        uk_vec = uk(:);

        ux  =  Dx  * uk_vec;
        uy  =  Dy  * uk_vec;
        uxx = -DxT * ux;
        uyy = -DyT * uy;
        uxy = -DxT * uy;

        norme2 = ux.^2 + uy.^2 + epsilon;

        div_TV = (uxx .* (uy.^2 + epsilon) + ...
                  uyy .* (ux.^2 + epsilon) - ...
                  2 * ux .* uy .* uxy    ) ./ (norme2.^(3/2));

        div_TV = reshape(div_TV, [nb_lignes, nb_colonnes]);

        % Gradient total de l'energie
        grad_E(:,:,k) = attache - mu_prime * div_TV;
    end

    % Mise a jour de u
    u = u - gamma * grad_E;

    % Affichage toutes les pas_aff iterations
    if mod(iter, pas_aff) == 0
        fprintf('Iteration %d/%d\n', iter, nb_iter);

        subplot(1,3,1);
        imagesc(u_orig);
        axis image off;
        title('Image originale','FontSize',14);

        subplot(1,3,2);
        imagesc(u);
        axis image off;
        title(sprintf('Structure u - iter %d', iter),'FontSize',14);

        subplot(1,3,3);
        texture = u_orig - u;
        imagesc(texture + 0.5);  % +0.5 pour centrer autour du gris
        axis image off;
        title('Texture (u_{orig} - u)','FontSize',14);

        drawnow;
    end
end

fprintf('Iterations terminees.\n');

% Affichage et sauvegarde du resultat final
texture_finale = u_orig - u;

subplot(1,3,1);
imagesc(u_orig);
axis image off;
title('Image originale','FontSize',14);

subplot(1,3,2);
imagesc(u);
axis image off;
title('Structure u','FontSize',14);

subplot(1,3,3);
imagesc(texture_finale + 0.5);
axis image off;
title('Texture (u_{orig} - u)','FontSize',14);
