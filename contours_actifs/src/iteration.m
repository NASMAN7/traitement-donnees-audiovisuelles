function [x,y] = iteration(x,y,Fx,Fy,gamma,A) 


    [nb_lignes, nb_colonnes] = size(Fx);
    xx = max(1, min(round(x), nb_colonnes));
    yy = max(1, min(round(y), nb_lignes));
    
    indices = sub2ind([nb_lignes, nb_colonnes], yy, xx);
    
    Fx_contour = Fx(indices);
    Fy_contour = Fy(indices);
    
    Bx = -gamma * Fx_contour(:);
    By = -gamma * Fy_contour(:);
    
    x = A * x + Bx;
    y = A * y + By;
end

