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
qbar_pa = m_atmos.f_pression_dynamique(tas_mps, altitude_m)


%%% Initialisation de alpha, dstab et Fn
alpha_rad = m_convert.f_angle(5, 'deg', 'rad');
dstab_rad = 0;
fn_n = m_convert.f_force(15000, 'lbf', 'N');


%%% Force de portance et coefficient de portance dans le repère body
i_m = avion.geom.i_m;
g0 = 9.81;
s_wb = avion.geom.s_wb;

clb = (masse_kg*g0*cos(alpha_rad)-fn_n*sin(i_m))/(-qbar_pa*swb)
L = qbar_pa*clb*swb*tas_mps^2


%%% D?but de la boucle de convergence
alpha_vect = m_convert.f_angle(-2:1:10, 'deg','rad')
clb_vect = zeros(size(alpha_vect))

for j = 1 : 30
    for i = 1 : length(alpha_vect)
        [cls_temp, cds_tmp, ~] = m_aero.f_coeff_stabilite(...
            alpha_vect(i), 0, 0, tas_mps, mach_nb, qbar_pa, 0, 0, ...
            dstab_rad, fn_n, avion);
        
        [clb_tmp, ~, ~] = m_aero.f_stab2body(cls_tmp, cds_tmp, 0, ...
            alpha_vect(i));
        
        clb_vect(i) = clb_tmp;
    end

    alpha_star = interp1(clb_vect, alpha_vect, clb, 'linear', 'extrap');
    [~, cdb_tmp, ~] = m_aero.f_stab2body(cls_tmp, cds_tmp, 0, ...
            alpha_vect(i));
    cdb = cdb_tmp; 
    fn_star = (masse_kg*g0*sin(i_m) + qbar_pa*swb*cdb)/cos(i_m)
    dstab = ...
    

    alpha_rad = alpha_star
    fn_n = fn_star
    dstab_rad = dstab_star


%%% Recuperation des donnees en croisiere
trim_data.fn_n      = fn_n;
trim_data.alpha_rad = alpha_rad;
trim_data.dstab_rad = dstab_rad;

end