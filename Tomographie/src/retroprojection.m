function f = retroprojection(S, theta, n_u, n_lignes, n_colonnes)
% RETROPROJECTION : reconstruction par rétroprojection simple
% S          : sinogramme (n_u x n_theta)
% theta      : vecteur des angles en degrés
% n_u        : nombre de rayons par angle
% n_lignes   : hauteur de l'image reconstruite
% n_colonnes : largeur de l'image reconstruite

n_theta = length(theta);

% Abscisses u discrètes (centrées sur 0)
u_vals = linspace(-(n_u-1)/2, (n_u-1)/2, n_u);

% Coordonnées des pixels (x = colonne, y = -ligne, origine au centre)
[cols, rows] = meshgrid(1:n_colonnes, 1:n_lignes);
x_pix = cols - (n_colonnes+1)/2;   % abscisse x du pixel
y_pix = -rows + (n_lignes+1)/2;    % ordonnée y du pixel (axe inversé)

% Initialisation
f = zeros(n_lignes, n_colonnes);

for k = 1:n_theta

    % Angle en radians
    theta_rad = theta(k) * pi / 180;

    % Projection de chaque pixel sur l'axe u pour cet angle
    u_proj = x_pix * cos(theta_rad) + y_pix * sin(theta_rad);

    % Interpolation de S(:,k) aux abscisses u_proj
    col_sino = interp1(u_vals, S(:,k), u_proj(:), 'linear', 0);

    f = f + reshape(col_sino, n_lignes, n_colonnes);
end

% Normalisation par le nombre d'angles
f = f / n_theta;
end