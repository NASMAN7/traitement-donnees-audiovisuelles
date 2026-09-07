function u = collage(r,s,interieur)

[nb_lignes_r,nb_colonnes_r,nb_canaux] = size(r);
N = nb_lignes_r * nb_colonnes_r; 
e = ones(N,1);
Dx = spdiags([-e e],[0 nb_lignes_r],N,N);
Dx(end-nb_lignes_r+1:end,:) = 0;
Dy = spdiags([-e e],[0 1],N,N);
Dy(nb_lignes_r:nb_lignes_r:end,:) = 0;

A = -Dx'*Dx - Dy'*Dy;

r = double(r);
s = double(s);

masque_r = true(nb_lignes_r,nb_colonnes_r);
masque_r(2:end-1,2:end-1) = false;
indices_bord_r = find(masque_r);
n_bord_r = length(indices_bord_r);

A(indices_bord_r,:) = sparse(1:n_bord_r,indices_bord_r,ones(n_bord_r,1),n_bord_r,N);
u = zeros(nb_lignes_r, nb_colonnes_r, nb_canaux);
for i = 1:nb_canaux
    s_i = s(:,:,i);
    s_i = s_i(:);
    r_i = r(:,:,i);
    r_i = r_i(:);


    grad_xs = Dx * s_i;
    grad_ys = Dy * s_i;

    grad_xr = Dx * r_i;
    grad_yr = Dy * r_i;

    g_x = grad_xr;
    g_x(interieur) = grad_xs(interieur);

    g_y = grad_yr;
    g_y(interieur) = grad_ys(interieur);

    b_i = -Dx'*g_x - Dy'*g_y;
    b_i(indices_bord_r) = r_i(indices_bord_r);
    u_i = A \ b_i ; 

    u_i = reshape(u_i,nb_lignes_r, nb_colonnes_r);
    
    u(:,:,i) = u_i;
end

