function u_k1 = inpainting(b,u_k,lambda,Dx,Dy,epsilon, D)
n = size(Dx,1);
coeff  = 1 ./ sqrt(sum((Dx * u_k).^2 + (Dy * u_k).^2, 2) + epsilon);
W_k = spdiags(coeff,[0],n,n);
W_D = spdiags(1 - D(:),[0],n,n);
A = W_D - lambda * (-Dx' * W_k * Dx - Dy' * W_k * Dy);

u_k1 = A \ (W_D * b) ;