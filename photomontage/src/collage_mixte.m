function u = collage_mixte(s, c, r_lig1, r_lig2, ...
                           r_col1, r_col2, masque_p)
% COLLAGE_MIXTE
% Photomontage par gradients mixtes de Perez et al. (2003).
%
% Pour chaque arete entre deux pixels voisins, on conserve le gradient
% le plus fort entre la source et la cible.
%
% Dans R\P, l'image cible reste strictement inchangee.
%
% ENTREES
%   s        : source redimensionnee a la taille du rectangle R
%   c        : image cible complete
%   masque_p : masque du polygone P dans le rectangle R
%
% SORTIE
%   u        : resultat du photomontage

%% Préparation

s = double(s);
c = double(c);
masque_p = masque_p > 0.5;

nr = r_lig2 - r_lig1 + 1;
nc = r_col2 - r_col1 + 1;

if size(s,1) ~= nr || size(s,2) ~= nc
    error('La source doit avoir la meme taille que le rectangle R.');
end

if size(masque_p,1) ~= nr || size(masque_p,2) ~= nc
    error('Le masque P doit avoir la meme taille que le rectangle R.');
end

nb_canaux = size(c,3);

if size(s,3) ~= nb_canaux
    error('La source et la cible doivent avoir le meme nombre de canaux.');
end

% Résultat initial : copie exacte de la cible
u = c;

%% Indexation des pixels appartenant à P

indices_P = find(masque_p);
nb_inconnues = length(indices_P);

if nb_inconnues == 0
    return;
end

% Associe chaque pixel de P à une inconnue du système
index_inconnue = zeros(nr, nc);
index_inconnue(indices_P) = 1:nb_inconnues;

% Voisinage à quatre pixels
voisins = [
    -1,  0;
     1,  0;
     0, -1;
     0,  1
];

%% Préallocation du système

% Chaque pixel possède au maximum cinq coefficients :
% le coefficient diagonal et quatre voisins
I = zeros(5 * nb_inconnues, 1);
J = zeros(5 * nb_inconnues, 1);
V = zeros(5 * nb_inconnues, 1);

position = 0;

% Un second membre pour chaque canal
b = zeros(nb_inconnues, nb_canaux);

%% Construction de A et b

for indice = 1:nb_inconnues

    % Coordonnées locales du pixel p dans R
    [i, j] = ind2sub([nr, nc], indices_P(indice));

    % Coordonnées globales du pixel p dans la cible
    i_global = r_lig1 + i - 1;
    j_global = r_col1 + j - 1;

    source_p = reshape( ...
        s(i, j, 1:nb_canaux), ...
        1, nb_canaux);

    cible_p = reshape( ...
        c(i_global, j_global, 1:nb_canaux), ...
        1, nb_canaux);

    degre = 0;

    for voisin = 1:4

        di = voisins(voisin,1);
        dj = voisins(voisin,2);

        % Coordonnées locales du voisin q
        ni = i + di;
        nj = j + dj;

        % Coordonnées globales du voisin q
        ni_global = i_global + di;
        nj_global = j_global + dj;

        % Ignore les voisins hors de l'image cible
        if ni_global < 1 || ni_global > size(c,1) || ...
           nj_global < 1 || nj_global > size(c,2)
            continue;
        end

        degre = degre + 1;

        cible_q = reshape( ...
            c(ni_global, nj_global, 1:nb_canaux), ...
            1, nb_canaux);

        % Gradient cible sur l'arête p-q
        gradient_cible = cible_p - cible_q;

        voisin_dans_R = ...
            ni >= 1 && ni <= nr && ...
            nj >= 1 && nj <= nc;

        if voisin_dans_R

            source_q = reshape( ...
                s(ni, nj, 1:nb_canaux), ...
                1, nb_canaux);

            % Gradient source sur l'arête p-q
            gradient_source = source_p - source_q;

            % Choix du gradient ayant la plus grande norme RGB
            if norm(gradient_source) >= norm(gradient_cible)
                gradient_choisi = gradient_source;
            else
                gradient_choisi = gradient_cible;
            end

        else

            % Si le voisin n'existe pas dans la source,
            % on conserve le gradient cible
            gradient_choisi = gradient_cible;
        end

        % Contribution du champ de gradients
        b(indice,:) = b(indice,:) + gradient_choisi;

        if voisin_dans_R && masque_p(ni,nj)

            % q appartient à P : sa valeur est inconnue
            position = position + 1;

            I(position) = indice;
            J(position) = index_inconnue(ni,nj);
            V(position) = -1;

        else

            % q est hors de P : condition au bord donnée par la cible
            b(indice,:) = b(indice,:) + cible_q;
        end
    end

    % Coefficient diagonal du Laplacien
    position = position + 1;

    I(position) = indice;
    J(position) = indice;
    V(position) = degre;
end

%% Matrice laplacienne creuse

A = sparse( ...
    I(1:position), ...
    J(1:position), ...
    V(1:position), ...
    nb_inconnues, ...
    nb_inconnues);

%% Résolution de l'équation de Poisson

valeurs_P = A \ b;

%% Limitation des valeurs

if max(c(:)) <= 1
    valeurs_P = max(0, min(1, valeurs_P));
else
    valeurs_P = max(0, min(255, valeurs_P));
end

%% Insertion du résultat dans la cible

region_resultat = ...
    c(r_lig1:r_lig2, r_col1:r_col2, :);

for k = 1:nb_canaux

    canal_resultat = region_resultat(:,:,k);

    % Modification uniquement des pixels appartenant à P
    canal_resultat(masque_p) = valeurs_P(:,k);

    region_resultat(:,:,k) = canal_resultat;
end

% La région R\P reste exactement égale à la cible
u(r_lig1:r_lig2, r_col1:r_col2, :) = region_resultat;

end