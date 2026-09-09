function S_filtre = filtrage_sinogramme(S, n_u)
% FILTRAGE_SINOGRAMME : filtre Ram-Lak appliqué aux colonnes du sinogramme
% S     : sinogramme (n_u x n_theta)
% n_u   : nombre de rayons par angle

% Fréquences du filtre Ram-Lak : |nu|
nu = linspace(-0.5, 0.5, n_u)';
ram_lak = abs(nu);               % filtre Ram-Lak 1D

% Application colonne par colonne dans le domaine de Fourier
S_filtre = zeros(size(S));

for k = 1:size(S, 2)
    col_fft    = fftshift(fft(S(:,k)));      % TF de la colonne
    col_filtre = col_fft .* ram_lak;         % filtrage
    S_filtre(:,k) = real(ifft(ifftshift(col_filtre)));  % TF inverse
end
end