function u_kp1 = debruitage(b,u_k,lambda,Dx,Dy,epsilon) 
nb_pixels = size(u_k,1);

grad_x = Dx * u_k;
grad_y = Dy * u_k;

norm_grad_sq = sum(grad_x.^2 + grad_y.^2, 2);

W = 1 ./sqrt(norm_grad_sq + epsilon);
W = spdiags(W, 0, nb_pixels, nb_pixels);

A = speye(nb_pixels) - lambda*(-Dx'*W*Dx - Dy'*W*Dy);

u_kp1 = A \ b;
end