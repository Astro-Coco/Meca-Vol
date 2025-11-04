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


%%% Initialisation de alpha, dstab et Fn


%%% D?but de la boucle de convergence


%%% Recuperation des donnees en croisiere
trim_data.fn_n      = ;
trim_data.alpha_rad = ;
trim_data.dstab_rad = ;

end