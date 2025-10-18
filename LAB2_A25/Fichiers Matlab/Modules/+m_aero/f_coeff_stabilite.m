function [cls, cds, cms] = f_coeff_stabilite(alpha_rad, alpha_dot, ...
    q_radps, tas_mps, mach_nb, qbar_pa, delev_rad, dflaps, dstab_rad, ...
    fn_n, avion)
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
%   - alpha         : angle d'attaque / d'incidence                   [rad]
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

%%% Calculs des volumes de references de la queue
vbar_x = s_ht*x_ht/(s_wb*c_wb);
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
    cla = cla * interp1(avion.aero.r_cla.mach, avion.aero.r_cla.value, mach_nb, 'linear', 'extrap');

    % J'assume ici une valeur de 0, 1, 2 pour dflaps, possible interp1
    % Maybe faire interp avec d_cl0.volet et d_cl0.value!
    delta_cl0 = avion.aero.d_cl0.value(dflaps + 1);

    cl_wb = cl0 + delta_clo0 + cla*alpha

    % Contribution de la vitesse de tangage Q sur la portance 
    % Contribution négligeable de Q sur alpha, mais pas sur alpha H, voir autre section

    % Coefficient de tra?n?e

    % Coefficient de moment de tangage

%%% Calcul du downwash

%%% Calcul de l'angle du stabilisateur

%%% Calcul des coefficients de l'empennage arriere
    % Coefficient de portance
    %Formule du downwash selon alpha et coeff données
    epsilon_deg = avion.aero.eps0 + avion.aero.epsa * alpha_deg;
    epsilon = m_convert.f_angle(epsilon_deg, 'deg', 'rad');
    % Angle d'attaque du stabilisateur
    alpha_h = alpha + dstab_rad + epsilon;

    %Existe aussi une formule combinée voir p21 chap 4, mais semble équivalent
    %Coefficient de portance de l'empennage, selon alpha_h et deflection stab
    clh = avion.aero.a1*alpha_h + avion.aero.a2*delev_rad;

    %Contribution de la vitese de tangage Q
    % Possible correction à faire ici, l_h semble entre donnée par rapport au centre de masse
    l_h = x_ht; %Distance entre les quarts de cordes aile / empennnage
    V = tas_mps; % Vitesse vraie
    Q = q_radps; % Vitesse de tangage

    delta_clah = Q*l_h/V;

    % Coefficient de tra?n?e

    % Coefficient de moment de tangage

%%% Expression des coefficients totaux dans le repere stab.
% Clh normalisé par la surface de l'aile sh/s
cls = cl_wb + (s_ht/s)*cl_h;
cds = cd_wb + %... ;
cms = cm_wb + %... ;

end
