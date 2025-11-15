function trim_data = f_croisiere(altitude_m, tas_mps, masse_kg, xcg_perc, ...
    zcg_m, avion)
% F_EQUATIONS_MOUVEMENT permet de d?finir les equations d'etat de l'avion.
%   Cette fonction permet de repr?senter la dynamique du vol d'un avion
%   sous la representation d'etat generale x_dot = f(x, etat, t). Cette
%   forme a ete adaptee pour les besoins du laboratoire de mecanique du vol
%   de l'Ecole Polytechnique Montreal (AER3640).
%
% Syntax:
%   trim_data = f_croisiere(altitude_m, tas_mps, masse_kg, xcg_perc, ...
%    zcg_m, avion)
%
% Inputs:
%       - altitude_m    : altitude de croisiere de l'avion              [m]
%       - tas_mps       : vitesse vraie (TAS) de l'avion              [m/s]
%       - masse_kg      : masse de l'avion                             [Kg]
%       - xcg_perc      : centrage de l'avion en %MAC                   [%]
%       - zcg_m         : centrage vertical de l'avion                  [m]
%       - avion         : structure contenant les donnees de l'avion    [-]
% Outputs:
%       - trim_data     : structure contenant les r?sultats de trim     [-]
%
% Example:
%
%   trim_data = m_trim.f_croisiere(altitude_m, tas_mps, masse_kg, ...
%      xcg_perc, zcg_m, avion);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Code pour la pression dynamique et du nombre de Mach
qbar_pa = m_atmos.f_pression_dynamique(tas_mps, altitude_m);
mach_nb = m_atmos.f_nombre_mach(tas_mps, altitude_m);


%%% Initialisation de alpha, dstab et Fn
alpha_rad = m_convert.f_angle(5, 'deg', 'rad');
dstab_rad = 0;
fn_n = m_convert.f_force(15000, 'lbf', 'N');


%%% Force de portance et coefficient de portance dans le repère body
i_m = avion.geom.i_m;
g0 = 9.81;
s_wb = avion.geom.s_wb;

L = masse_kg*g0*cos(alpha_rad) - fn_n*sin(i_m);
clb = L/(qbar_pa*s_wb);

%OK

%%% D?but de la boucle de convergence
alpha_vect = m_convert.f_angle(-2:1:10, 'deg', 'rad');
dstab_vect = m_convert.f_angle(-2:1:8, 'deg', 'rad');
clb_vect = zeros(size(alpha_vect));
my_vect = zeros(size(dstab_vect));

% Boucle de convergence
for j = 1 : 1000
    % Boucle pour trouver alpha_star
    for i = 1 : length(alpha_vect)
        [cls_tmp, cds_tmp, ~] = m_aero.f_coeff_stabilite(...
            alpha_vect(i), 0, 0, tas_mps, mach_nb, qbar_pa, 0, 0, ...
            dstab_rad, fn_n, avion);
        
        [clb_tmp, ~, ~] = m_aero.f_stab2body(cls_tmp, cds_tmp, 0, ...
            alpha_vect(i));
        
        clb_vect(i) = clb_tmp;
    end

    alpha_star = interp1(clb_vect, alpha_vect, clb, 'linear', 'extrap');

    if mod(j, 50) == 0
        disp(['Iteration de croisiere: ', num2str(j)]);
        alpha_deg = m_convert.f_angle(alpha_star, 'rad', 'deg')
    end

    % Coefficient cdb
    [cls_tmp, cds_tmp, ~] = m_aero.f_coeff_stabilite(alpha_star, 0, 0, ...
    tas_mps, mach_nb, qbar_pa, 0, 0, dstab_rad, fn_n, avion);
    
    [~, cdb_tmp, ~] = m_aero.f_stab2body(cls_tmp, cds_tmp, 0, alpha_star);
    cdb = cdb_tmp;

    % Estimation de fn_star
    fn_star = (masse_kg*g0*sin(alpha_star) + qbar_pa*s_wb*cdb)/cos(i_m);

    % Boucle pour trouver dstab_star
    for i = 1:length(dstab_vect)
        [cls_tmp, cds_tmp, cms_tmp] = m_aero.f_coeff_stabilite( ...
            alpha_star, 0, 0, tas_mps, mach_nb, qbar_pa, ...
            0, 0, dstab_vect(i), fn_star, avion);

        [clb_tmp, cdb_tmp, cmb_tmp] = m_aero.f_stab2body(cls_tmp, cds_tmp, cms_tmp, alpha_star);

        [~, ~, my_nm_tmp] = m_edm.f_forces(clb_tmp, cdb_tmp, cmb_tmp, alpha_star, ...
            xcg_perc, zcg_m, masse_kg, qbar_pa, fn_star, avion);

        my_vect(i) = my_nm_tmp;
    end

    dstab_star = interp1(my_vect, dstab_vect, 0, 'linear', 'extrap');
    

    % Mise à jour des variables
    old_alpha = alpha_rad;
    old_dstab = dstab_rad;

    alpha_rad = alpha_star;
    dstab_rad = dstab_star;
    fn_n = fn_star;

    % Mise à jour de la portance
    L = masse_kg*g0*cos(alpha_rad) - fn_n*sin(i_m);
    clb = L/(qbar_pa*s_wb);

    % Critère de convergence
    if abs(alpha_rad - old_alpha) < 1e-6 && abs(dstab_rad - old_dstab) < 1e-6
        break;
    end

end


%%% Recuperation des donnees en croisiere
trim_data.fn_n      = fn_n;
trim_data.alpha_rad = alpha_rad;
trim_data.dstab_rad = dstab_rad;

end