function [existe_q,bornes_V_p,bornes_V_q_chapeau] = d_min(i_p,j_p,u_k,D,t,T)

    [nb_lignes, nb_colonnes, ~] = size(u_k);

    i_p_min = max(1,i_p-t);
    i_p_max = min(nb_lignes,i_p+t);
    j_p_min = max(1,j_p-t);
    j_p_max = min(nb_colonnes,j_p+t);

    bornes_V_p = [i_p_min, j_p_min, i_p_max, j_p_max];
    D_p = D(i_p_min:i_p_max, j_p_min:j_p_max);

    R_p = sum(~D_p(:));
    i_F_min = max(1 + t, i_p - T);
    i_F_max = min(nb_lignes - t, i_p + T);
    j_F_min = max(1 + t, j_p - T);
    j_F_max = min(nb_colonnes - t, j_p + T);

    existe_q = false;
    bornes_V_q_chapeau = [];
    d_min_val = inf;

    u_p = u_k(i_p_min:i_p_max, j_p_min:j_p_max,:);
    for i_q = i_F_min : i_F_max
        for j_q = j_F_min : j_F_max
            i_q_min = i_q-t;
            i_q_max = i_q+t;
            j_q_min = j_q-t;
            j_q_max = j_q+t;
            D_q = D(i_q_min : i_q_max, j_q_min : j_q_max);
            if sum(D_q(:)) == 0 
                existe_q = true;
                u_q = u_k(i_q_min : i_q_max, j_q_min : j_q_max,:);

                s = (~D_p) .* sum((u_p - u_q).^2, 3);
                s = sum(s(:));
                d = s / R_p;

                if d < d_min_val
                    d_min_val = d;
                    bornes_V_q_chapeau = [i_q_min,j_q_min, i_q_max,j_q_max];
                end
            end
        end
    end


    
    

