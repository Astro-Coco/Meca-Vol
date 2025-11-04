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




%% Configuration de l'avion (centrage)
conditions.masse_kg  = m_convert.f_mass(13000, 'lbm', 'kg');
conditions.Iyy_kgm2  = avion.inertie.Iyy_kgm2;
conditions.xcg_perc  = 0;
conditions.zcg_m     = 0;

%% Définition de la condition de vol
conditions.tas_mps   = m_convert.f_velocity(250, 'kts', 'm/s');
conditions.altitude_m= m_convert.f_length(20000, 'ft', 'm');

%% Configuration des volets (position croisière) et des surfaces de contrôle
conditions.dflaps    = 0;
conditions.dstab_rad = m_convert.f_angle(-6.6171, 'deg', 'rad');
conditions.delev_rad = m_convert.f_angle(-0.5905, 'deg', 'rad');

%% Définition des paramètres de vol
conditions.q_radps   = 0;
alpha_dot = 0;
conditions.alpha_rad = m_convert.f_angle(7.4108, 'deg', 'rad');
conditions.theta_rad = conditions.alpha_rad;   % vol symétrique: θ ≈ α en palier

%% Configuration des moteurs
conditions.fn_n      = 3.3320e+04;   % [N]

mach_nb = m_atmos.f_nombre_mach(conditions.tas_mps, conditions.altitude_m);
qbar_pa = m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m);
%%% Coefficients dans le repère stabilité
[cls, cds, cms] = m_aero.f_coeff_stabilite( ...
    conditions.alpha_rad, alpha_dot, conditions.q_radps, ...
    conditions.tas_mps, mach_nb, qbar_pa, ...
    conditions.delev_rad, conditions.dflaps, conditions.dstab_rad, ...
    conditions.fn_n, avion);

%%% Coefficients dans le repère body
[clb, cdb, cmb] = m_aero.f_stab2body(cls, cds, cms, conditions.alpha_rad);


%%% Forces et moment
[fx_n, fz_n, my_nm] = m_edm.f_forces(clb, cdb, cmb, conditions.theta_rad, ...
    conditions.xcg_perc, conditions.zcg_m, conditions.masse_kg, ...
    qbar_pa, conditions.fn_n, avion, conditions.alpha_rad, alpha_dot, ...
    conditions.q_radps, conditions.tas_mps, mach_nb, ...
    conditions.delev_rad, conditions.dflaps, conditions.dstab_rad);


ub0   = conditions.tas_mps * cos(conditions.alpha_rad);
wb0   = conditions.tas_mps * sin(conditions.alpha_rad);
q0    = conditions.q_radps;        % = 0 à l’init (page 10)
theta0= conditions.theta_rad;      % = alpha_rad à l’init (palier)
h0    = conditions.altitude_m;

x0 = [ub0; wb0; q0; theta0; h0];

[time, x] = m_edm.f_simuler_avion(x0, 50, 1.0, conditions, avion, []);

% time = t;  x = X;

% Affichage du résultat de la simulation
figure;
subplot(3, 2, [1 2]);
plot(time, m_convert.f_length(x(:, 5), 'm', 'ft')); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Xlim', [0 50], ...
         'Ylim', [15000 25000]);

subplot(3, 2, 3);
plot(time, m_convert.f_velocity(x(:, 1), 'm/s', 'kts')); grid on; box on;
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Xlim', [0 50], ...
         'Ylim', [200 300]);
ylabel('u_b [kts]');

subplot(3, 2, 4);
plot(time, m_convert.f_velocity(x(:, 2), 'm/s', 'kts')); grid on; box on;
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Xlim', [0 50], ...
         'Ylim', [200 401]);
ylabel('w_b [kts]');

subplot(3, 2, 5);
plot(time, m_convert.f_angle(x(:, 3), 'rad', 'deg')); grid on; box on;
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Xlim', [0 50], ...
         'Ylim', [-5 5]);
xlabel('Temps [sec]'); ylabel('q [deg/s]');

subplot(3, 2, 6);
plot(time, m_convert.f_angle(x(:, 4), 'rad', 'deg')); grid on; box on;
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Xlim', [0 50], ...
         'Ylim', [0 10]);
xlabel('Temps [sec]'); ylabel('\theta [deg]');