function [cls, cds, cms] = f_coeff_stabilite(alpha_rad, alpha_dot, ...
    q_radps, tas_mps, mach_nb, qbar_pa, delev_rad, dflaps, dstab_rad, ...
    fn_n, avion, delta_e)
%F_COEFF_STABILITE permet de calculer les coefficients aerodynamiques de
%l'avion au complet, exprime dans le repere de stabilite de l'aile. Le
%calcul du moment est effectue au centre aerodynamique de l'aile, soit a
%25% de la MAC.
%
% Syntax:
%   [cls, cds, cms] = f_coeff_stabilite(alpha_rad, alpha_dot, ...
%    q_radps, tas_mps, mach_nb, qbar_pa, delev_rad, dflaps, dstab_rad, ...
%    fn_n, avion)
%
% Inputs:
%   - alpha_rad     : angle d'attaque / d'incidence                   [rad]
%   - alpha_dot     : variation de l'angle d'attaque                [rad/s]
%   - q_radps       : vitesse de tangage                            [rad/s]
%   - tas_mps       : vitesse vraie de l'avion                        [m/s]
%   - mach_nb       : nombre de Mach de l'avion                         [-]
%   - qbar_pa       : pression dynamique                               [Pa]
%   - delev_rad     : deflexion moyenne des elevateurs                [rad]
%   - dflaps        : position des volets                               [-]
%   - dstab_rad     : position du stabilisateur horizontal            [rad]
%   - fn_n          : poussee net des deux moteurs                      [N]
%   - avion         : structure contenant les donnees de l'avion
%
% Outputs:
%   - cls           : Coefficient de portance dans le stabilite         [-]
%   - cds           : Coefficient de trainee dans le stabilite          [-]
%   - cms           : Coefficient de moment dans le stabilite           [-]
%
% Example:
%   voir section syntax.
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Recuperations de donnees geometriques de l'avion
% Donnees relative a l'aile (wb = wing + body)
s_wb = avion.geom.s_wb;
c_wb = avion.geom.c_wb;

% Donnees relatives a l'empennage arriere (ht = horizontal tail)
s_ht = avion.geom.s_ht;
c_ht = avion.geom.c_ht;

x_ht = avion.geom.x_ht;
z_ht = avion.geom.z_ht;

a1 = avion.aero.a1;
a2 = avion.aero.a2;

%%% Calculs des volumes de references de la queue
vbar_x = s_ht*x_ht/(s_wb*c_wb);

% Possible erreur de c, aurait du etre c_ht pour être utilisée pour calculer Cmh
vbar_z = s_ht*z_ht/(s_wb*c_wb);

%%% Conversions de entrees
alpha_deg = m_convert.f_angle(alpha_rad, 'rad', 'deg');

%%% Definitions des parametres additionnels
q_hat     = q_radps*c_wb/(2*tas_mps); 
adot_hat  = alpha_dot*c_wb/(2*tas_mps);
ct        = fn_n/(qbar_pa*s_wb);

%%% Calcul des coefficients de l'aile
    % Coefficient de portance
    cl0 = avion.aero.cl0;
    cla = avion.aero.cla;

    % Effet du nombre de Mach sur le coefficient de portance (Ratio par interpolation)
    % Effet Clu, effets aéroélastiques
    cla = cla * interp1(avion.aero.r_cla.mach, avion.aero.r_cla.value, mach_nb, 'linear', 'extrap');

    % J'assume ici une valeur de 0, 1, 2 pour dflaps, possible interp1
    delta_cl0_flaps = avion.aero.d_cl0.value(dflaps + 1);

    cl_wb = cl0 + delta_cl0_flaps + cla*alpha_rad;

    % Contribution de la vitesse de tangage Q sur la portance 
    clq = avion.aero.clq;
    %Clq * Q = delta_clq
    delta_clq = clq * q_hat;

    cl_wb = cl_wb + delta_clq;
   
   
    % Coefficient de tra?n?e
    cd0 = avion.aero.cd0;
    cdcl = avion.aero.cdcl;


    delta_cd0 = interp1(avion.aero.d_cd0.mach, avion.aero.d_cd0.value, mach_nb, 'linear', 'extrap');
    cd_wb = cd0 + delta_cd0 + cdcl*cl_wb^2;


    % Coefficient de moment de tangage
    cm0 = avion.aero.cm0;
    cma = avion.aero.cma;

    % Effet du nombre de Mach sur le coefficient de moment (Ratio par interpolation)
    cma = cma * interp1(avion.aero.r_cma.mach, avion.aero.r_cma.value, mach_nb, 'linear', 'extrap');

    % Contribution de la vitesse de tangage Q
    delta_cmq = avion.aero.cmq*q_hat;

    % Contribution de la vitesse de variation de l'angle d'attaque
    delta_cmadot = avion.aero.cmadot*adot_hat;

    % Contribution des volets sur cm0
    delta_cm0 = avion.aero.d_cm0.value(dflaps + 1);

    %Contribution des moteurs sur cm0
    delta_cm_mot = avion.aero.cmct * ct;

    cm_wb = cm0 + delta_cm0 + cma*alpha_rad + delta_cmq + delta_cmadot + delta_cm_mot;

    
%%% Calcul du downwash
    epsilon_deg = avion.aero.eps0 + avion.aero.epsa * alpha_deg;

    % Correction du downwash selon la deflection des volets
    delta_eps_downwash = avion.aero.d_eps.value(dflaps + 1);
    epsilon_deg = epsilon_deg + delta_eps_downwash;
    eps_rad = m_convert.f_angle(epsilon_deg, 'deg', 'rad');

%%% Calcul de l'angle du stabilisateur
    %Formule du downwash selon alpha et coeff données
    % Angle d'attaque du stabilisateur 
alpha_ht = alpha_rad - eps_rad + dstab_rad + q_radps*(x_ht/tas_mps);


%Coefficient de trainée de l'empennage est nul parce qu'il s'agit %d'un mvt longitudinal
cdht = 0;

% Coefficient de moment de tangage est nul
cmht = 0;

% Coefficient de portance de l'empennage
delta_e = 0;
clht = s_ht/s_wb*(a1*alpha_ht+a2*delta_e)*cos(eps_rad);

%%% On ne tient pas compte du fait que eps est petit

% Coefficients de portance pour l'empennage  CL_H
CL_H = s_ht/s_wb*(clht*cos(eps_rad) - cdht*sin(eps_rad));


% Coefficients de trainée CD_H pour l'empennage
CD_H = s_ht/s_wb*(cdht*cos(eps_rad) + clht*sin(eps_rad));


% Coefficients de moment CM_H pour l'empennage 
CM_H = s_ht*c_ht/(s_wb*c_wb)*cmht - vbar_x*(clht*cos(alpha_rad-eps_rad)...
       + cdht*sin(alpha_rad-eps_rad)) +...
       vbar_z*(cdht*cos(alpha_rad-eps_rad) - clht*sin(alpha_rad-eps_rad));


%% % Expression des coefficients totaux dans le repère stab.
cls = cl_wb + CL_H ;
cds = cd_wb + CD_H ;
cms = cm_wb + CM_H ;

end