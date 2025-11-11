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

% Aéro 
cl0  = avion.aero.cl0;   
cla  = avion.aero.cla;    
clq  = avion.aero.clq;

cd0  = avion.aero.cd0;    
cdcl = avion.aero.cdcl;   

cm0  = avion.aero.cm0;    
cma  = avion.aero.cma;    
cmq  = avion.aero.cmq;    
cmadot = avion.aero.cmadot;
cmct   = avion.aero.cmct;

% Interpolations
d_cl0_inter = interp1(avion.aero.d_cl0.volet, avion.aero.d_cl0.value, dflaps, 'linear', 'extrap');
r_cla_inter = interp1(avion.aero.r_cla.mach,  avion.aero.r_cla.value,  mach_nb, 'linear', 'extrap');
d_cd0_inter = interp1(avion.aero.d_cd0.mach,  avion.aero.d_cd0.value,  mach_nb, 'linear', 'extrap');
r_cma_inter = interp1(avion.aero.r_cma.mach,  avion.aero.r_cma.value,  mach_nb, 'linear', 'extrap');
d_cm0_inter = interp1(avion.aero.d_cm0.volet, avion.aero.d_cm0.value, dflaps, 'linear', 'extrap');
d_eps_inter = interp1(avion.aero.d_eps.volet,  avion.aero.d_eps.value,  dflaps, 'linear', 'extrap');

% Donnees relatives a l'empennage arriere (ht = horizontal tail)
s_ht = avion.geom.s_ht;
c_ht = avion.geom.c_ht;
x_ht = avion.geom.x_ht;
z_ht = avion.geom.z_ht;

eps0 = avion.aero.eps0;   
epsa = avion.aero.epsa;   

a1 = avion.aero.a1;      
a2 = avion.aero.a2;       

%%% Definitions des parametres additionnels
q_hat     = q_radps*c_wb/(2*tas_mps);
adot_hat  = alpha_dot*c_wb/(2*tas_mps);
ct        = fn_n/(qbar_pa*s_wb);

%%% Conversions de entrees
alpha_deg = m_convert.f_angle(alpha_rad, 'rad', 'deg');


%%% Calcul des coefficients de l'aile
    % Coefficient de portance
clwb = cl0 + d_cl0_inter + r_cla_inter * (cla* alpha_deg) + clq* q_hat;

    % Coefficient de tra?n?e
cdwb = cd0 + d_cd0_inter + cdcl* (clwb ^ 2);

    % Coefficient de moment de tangage
cmwb = cm0 + d_cm0_inter + (cma* r_cma_inter* alpha_deg) + cmq* q_hat + cmadot* adot_hat + cmct* ct;

%%% Calcul du downwash
eps_deg = eps0 + epsa * alpha_deg + d_eps_inter;       
eps_rad = m_convert.f_angle(eps_deg, 'deg', 'rad');     

%%% Calcul de l'angle du stabilisateur
alphah = alpha_rad - eps_rad + dstab_rad + q_radps* (x_ht / tas_mps);

%%% Calculs des volumes de references de la queue
vbar_x = s_ht*x_ht/(s_wb*c_wb);
vbar_z = s_ht*z_ht/(s_wb*c_wb);

%%% Calcul des coefficients de l'empennage arriere
    % Coefficient de portance
clht = s_ht/s_wb*(a1* alphah + a2* delev_rad)*cos(eps_rad); 
    % Coefficient de tra?n?e
cdht = s_ht/s_wb*(a1* alphah + a2* delev_rad)*sin(eps_rad);
    % Coefficient de moment de tangage
cmht = (-vbar_x*cos(alpha_rad-eps_rad) - vbar_z*sin(alpha_rad-eps_rad))*(a1*alphah + a2*delev_rad);

%%% Expression des coefficients totaux dans le repere stab.
cls = clwb + clht;
cds = cdwb + cdht;
cms = cmwb + cmht;

end
