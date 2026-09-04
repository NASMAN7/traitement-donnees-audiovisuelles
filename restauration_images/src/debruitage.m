function u_k1 = debruitage(b,u_k,lambda,Dx,Dy,epsilon)
n = size(Dx,1);
coeff  = 1 ./ sqrt((Dx*u_k).^2 + (Dy*u_k).^2 + epsilon);
W_k = spdiags(coeff,[0],n,n);

A = speye(n) - lambda * (-Dx' * W_k * Dx - Dy' * W_k * Dy);

u_k1 = A \ b ;