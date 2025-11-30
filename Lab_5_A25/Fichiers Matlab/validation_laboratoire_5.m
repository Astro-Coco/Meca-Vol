%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules'));
%% Debut de vos etudes
avion = f_loadAircraftData;

%% Definition de la condition de vol
% Definition de la condition de vol
conditions.tas_mps = m_convert.f_velocity(400, 'kts', 'm/s');
conditions.altitude_m = m_convert.f_length(30000, 'ft', 'm');
g0 = 9.81;

% Configuration de l'avion (poids/centrage)
conditions.masse_kg = m_convert.f_mass(130000, 'lbm', 'kg');
conditions.Iyy_kgm2 = avion.inertie.Iyy_kgm2;
conditions.xcg_perc = 0.2;
conditions.zcg_m = 0;

%% Trim de l'avion en col de croisiere
trim_data = m_trim.f_croisiere(conditions.altitude_m, conditions.tas_mps, ...
conditions.masse_kg, conditions.xcg_perc, conditions.zcg_m, avion)

%% Initialisation des parametres de croisiere
% Configuration des surfaces de controle de l'avion
conditions.dflaps = 0;
conditions.delev_rad = 0;
conditions.dstab_rad = trim_data.dstab_rad;

% Configuration des moteurs
conditions.fn_n = trim_data.fn_n;

% Definition des parametres de vol
conditions.q_radps = 0;
conditions.alpha_rad = trim_data.alpha_rad;
conditions.theta_rad = conditions.alpha_rad;

%% Analyse des modes à partir des équations
% a)
alpha_vect = m_convert.f_angle(-2:1:10, 'deg', 'rad');
cmb_vect = zeros(size(alpha_vect));
            for i = 1 : length(alpha_vect)
                [cls_tmp, cds_tmp, cms_tmp] = m_aero.f_coeff_stabilite(alpha_vect(i), 0, conditions.q_radps, conditions.tas_mps, m_atmos.f_nombre_mach(conditions.tas_mps, conditions.altitude_m),m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m), conditions.delev_rad, conditions.dflaps, conditions.dstab_rad, conditions.fn_n, avion);            
                cmb_vect(i) = cms_tmp;
            end
cm_alpha = (cmb_vect(1) - cmb_vect(end))/(alpha_vect(1)-alpha_vect(end));

wsp = sqrt(-m_atmos.f_pression_dynamique(conditions.tas_mps,conditions.altitude_m)*avion.geom.s_wb*avion.geom.c_wb*cm_alpha/avion.inertie.Iyy_kgm2)
zetasp = -m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m)*avion.geom.s_wb*avion.geom.c_wb^2*(avion.aero.cma/m_convert.f_angle(1, 'deg', 'rad') + avion.aero.cmq)/(4*conditions.tas_mps*avion.inertie.Iyy_kgm2*wsp)

% b)
[cls, cds, cms] = m_aero.f_coeff_stabilite(conditions.alpha_rad, 0, conditions.q_radps, conditions.tas_mps, m_atmos.f_nombre_mach(conditions.tas_mps, conditions.altitude_m),m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m), conditions.delev_rad, conditions.dflaps, conditions.dstab_rad, conditions.fn_n, avion);           
[clb,  ~,  ~] = m_aero.f_stab2body(cls, cds, cms, conditions.alpha_rad);

wph = sqrt(m_atmos.f_masse_volumique(conditions.altitude_m)*avion.geom.s_wb*g0*clb/conditions.masse_kg)
zetaph = cds/cls

%% Préparation de la simulation
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);

%% Simulation du modele
temps_simulation = 50;
sim("AER3640_avion_trim", temps_simulation)
