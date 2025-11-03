%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
%addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules'));
%% % Debut de vos etudes
avion = f_loadAircraftData;

%%% Conditions de vol pour validation
h_pi = 20000;
h_m = m_convert.f_length(h_pi, 'ft', 'm');
masse_kg = 100000;
zcg_m = 0;
alpha_deg = 5;
alpha_rad = m_convert.f_angle(alpha_deg, 'deg', 'rad');
alpha_dot = 0;
theta_deg = 5;
theta_rad = m_convert.f_angle(theta_deg, 'deg', 'rad');
V_mps = 240;
tas_mps = m_convert.f_velocity(V_mps, 'kts', 'm/s');
fn_n = 15000;
xcg_perc = 0.1;
q_radps = 0;
delta_e = 0;
delev_rad = 0;
dflaps = 0;
dstab_rad = 0;
qbar_pa = m_atmos.f_pression_dynamique(V_mps, h_m);
mach_nb = m_atmos.f_nombre_mach(tas_mps, h_m);


%%% Coefficients dans le repère stabilité
[cls, cds, cms] = m_aero.f_coeff_stabilite(alpha_rad, alpha_dot, ...
    q_radps, tas_mps, mach_nb, qbar_pa, delta_e, dflaps, dstab_rad, ...
    fn_n, avion);

%%% Coefficients dans le repère body
[clb, cdb, cmb] = m_aero.f_stab2body(cls, cds, cms, alpha_rad)


%%% Forces et moment
[fx_n, fz_n, my_nm] = f_forces(clb, cdb, cmb, theta_rad, xcg_perc, ...
    zcg_m, masse_kg, qbar_pa, fn_n, avion, alpha_rad, alpha_dot, ...
    q_radps, tas_mps, mach_nb, delev_rad, dflaps, dstab_rad)
