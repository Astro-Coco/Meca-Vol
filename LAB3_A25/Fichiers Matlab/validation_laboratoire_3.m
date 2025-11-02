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
masse_kg = 100000;
zcg_m = 0;
alpha = 5;
alpha_rad = m_convert.f_angle(alpha, 'deg', 'rad');
alpha_dot = 0;
theta_deg = 5;
theta_rad = m_convert.f_angle(theta_deg, 'deg', 'rad');
tas_mps = 240;
fn_n = 15000;
xcg_perc = 0.1;

h_m = m_convert.f_length(h_pi, 'ft', 'm');
V_mps = m_convert.f_velocity(Vt, 'kts', 'm/s');
qbar_pa = m_atmos.f_pression_dynamique(V_mps, h_m);
mach_nb = m_atmos.f_nombre_mach(V_mps, h_m);
q_radps = 0;
delta_e = 0;
dflaps = 0:
dstab_rad = 0;

% dflaps, dstab_rad


%%% Coefficients dans le repère stabilité
[cls, cds, cms] = f_coeff_stabilite(alpha_rad, alpha_dot, ...
    q_radps, tas_mps, mach_nb, qbar_pa, delta_e, dflaps, dstab_rad, ...
    fn_n, avion)

%%% Coefficients dans le repère body
[clb, cdb, cmb] = f_stab2body(cls, cds, cms, alpha_rad)


[fx_n, fz_n, my_nm] = f_forces(clb, cdb, cmb, theta_rad, xcg_perc, ...
    zcg_m, masse_kg, qbar_pa, fn_n, avion)