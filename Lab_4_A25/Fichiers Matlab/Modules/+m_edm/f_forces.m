%F_FORCES permet de calculer les composantes totales des forces qui 
%s'appliquent sur l'avion dans le repere body.
%
% Syntax:
%   [fx_n, fz_n, my_nm] = f_forces(clb, cdb, cmb, theta_rad, xcg_perc, ...
%         zcg_m, masse_kg, qbar_pa, fn_n, avion)
%
% Inputs:
%       - clb           : Coefficient de portance dans le body  [-]
%       - cdb           : Coefficient de trainee dans le body   [-]
%       - cmb           : Coefficient de moment dans le body    [-]
%       - theta_rad     : Angle de tangage                      [rad]
%       - xcg_perc      : position du centre de gravite/MAC     [%MAC]
%       - zcg_m         : position du centre gravite selon Zb   [m]
%       - masse_kg      : masse totale de l'avion               [Kg]
%       - qbar_pa       : pression dynamique a l'altitude h     [Pa]
%       - fn_n          : poussee nette totale des moteurs      [N]
%       - avion         : structure contenant les parametres de l'avion
% Outputs:
%       - fx_n          : force totale selon x dans le body        [N]
%       - fz_n          : force totale selon z dans le body        [N]
%       - my_nm         : moment de tangage total dans le body     [N.m]
%
% Example:
%   [fx_n, fz_n, my_nm] = m_edm.f_forces(clb, cdb, cmb, theta_rad, ...
%        xcg_perc, zcg_m, masse_kg, qbar_pa, fn_n, avion)
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

function [fx_n, fz_n, my_nm] = f_forces(clb, cdb, cmb, theta_rad, xcg_perc, ...
    zcg_m, masse_kg, qbar_pa, fn_n, avion)
    
% Definition de la constante de gravitee en m/s^2
g0 = 9.81; 

%%% Données
s_ht = avion.geom.s_ht;
s_wb = avion.geom.s_wb;

% Definition des distances du moteur par rapport au centre de gravite de
% l'avion
xEngine2Cg = avion.geom.x_m + xcg_perc*avion.geom.c_wb;
zEngine2Cg = avion.geom.z_m - zcg_m;

%%% Calcul des forces
% 1 -> inertielles (poids)
Fp_x = -masse_kg*g0*sin(theta_rad) ;
Fp_z = masse_kg*g0*cos(theta_rad) ;
Mp_y = 0 ;

% 2 -> propulsives
Fm_x = fn_n*cos(avion.geom.i_m) ;
Fm_z = -fn_n*sin(avion.geom.i_m) ;
Mm_y = Fm_x*zEngine2Cg - Fm_z*xEngine2Cg ;

% 3 -> aerodynamiques
% Récupérer les variables
s_ht = avion.geom.s_ht;
s_wb = avion.geom.s_wb;

Fa_x = -qbar_pa * avion.geom.s_wb * cdb ;
Fa_z = -qbar_pa * avion.geom.s_wb * clb ;
Ma_y = qbar_pa*avion.geom.s_wb*cmb*avion.geom.c_wb + Fa_x*zcg_m + Fa_z*(0.25*avion.geom.c_wb - xcg_perc*avion.geom.c_wb) ;

%%% Bilan des forces dans le repere avion
fx_n  = Fp_x + Fa_x + Fm_x ;
fz_n  = Fp_z + Fa_z + Fm_z ;
my_nm = Mm_y + Ma_y + Mp_y ;

end