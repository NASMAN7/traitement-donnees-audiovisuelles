function [u_k,D] = rapiecage(bornes_V_p,bornes_V_q_chapeau,u_k,D)

i_p_min = bornes_V_p(1);
j_p_min = bornes_V_p(2);
i_p_max = bornes_V_p(3);
j_p_max = bornes_V_p(4);

i_q_min = bornes_V_q_chapeau(1);
j_q_min = bornes_V_q_chapeau(2);
i_q_max = bornes_V_q_chapeau(3);
j_q_max = bornes_V_q_chapeau(4);

D_patch = D(i_p_min:i_p_max , j_p_min:j_p_max);

nb_canaux = size(u_k, 3);
    for c = 1:nb_canaux
        source = u_k(i_q_min:i_q_max, j_q_min:j_q_max, c);
        cible  = u_k(i_p_min:i_p_max, j_p_min:j_p_max, c);

        cible(D_patch) = source(D_patch);
        u_k(i_p_min:i_p_max, j_p_min:j_p_max, c) = cible;
    end   

    D(i_p_min:i_p_max, j_p_min:j_p_max) = 0;