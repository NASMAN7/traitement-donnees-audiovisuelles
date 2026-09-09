function f = kaczmarz(s, W, n_boucles)
% KACZMARZ : résolution de W*f = s par l'algorithme de Kaczmarz
% s        : vecteur du sinogramme
% W        : matrice sparse des longueurs d'intersection
% n_boucles: nombre de parcours complets des équations

[NS, NF] = size(W);

% Précalcul hors boucle 
Wt         = W';                        % transposée de W
normes2    = full(sum(W.^2, 2));        % norme au carré de chaque ligne

% Initialisation
f = zeros(NF, 1);

nb_iter = n_boucles * NS;

for k = 0 : nb_iter - 1

    % Indice de la ligne courante (modulo NS, base 1)
    i = mod(k, NS) + 1;

    % Si la norme est nulle, on ne fait rien
    if normes2(i) == 0
        continue;
    end

    % Itération de Kaczmarz :
    % f = f + (s_i - w_i * f) / ||w_i||^2 * w_i'
    wi  = Wt(:, i);             % colonne de Wt = ligne i de W
    res = s(i) - wi' * f;       % résidu scalaire
    f   = f + (res / normes2(i)) * wi;
end
end
