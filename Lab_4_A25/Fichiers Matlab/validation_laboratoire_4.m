%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules'));
%% % Debut de vos etudes
avion = f_loadAircraftData;

%% % Definition de la condition de vol
% Configuration de l'avion (poids/centrage)
conditions.masse_kg = m_convert.f_mass(130000, 'lbm', 'kg');
conditions.Iyy_kgm2 = avion.inertie.Iyy_kgm2;
conditions.xcg_perc = 0;
conditions.zcg_m = 0;

% Definition de la condition de vol
conditions.tas_mps = m_convert.f_velocity(400, 'kts', 'm/s');
conditions.altitude_m = m_convert.f_length(35000, 'ft', 'm');

%% % Trim de l'avion en col de croisiere
trim_data = m_trim.f_croisiere(conditions.altitude_m, conditions.tas_mps, ...
conditions.masse_kg, conditions.xcg_perc, conditions.zcg_m, avion);

%% % Initialisation des parametres de croisiere
% Configuration des surfaces de controle de l'avion
conditions.dflaps = 0;
conditions.delev_rad = 0;
conditions.dstab_rad = trim_data.dstab_rad;

% Configuration des moteurs
conditions.fn_n = trim_data.fn_n;

% Definition des parametres de vol
conditions.qradps = 0;
conditions.alpha_rad = trim_data.alpha_rad;
conditions.theta_rad = conditions.alpha_rad;

%% % Initialisation du vecteur d'etat
x0 = [conditions.tas_mps*cos(conditions.alpha_rad), ...
    conditions.tas_mps*sin(conditions.alpha_rad), conditions.qradps, ...
    conditions.theta_rad, conditions.altitude_m];

% Lancement d'une simulation
[time,x] = m_edm.f_simuler_avion(x0, 250, 0.2, conditions, avion, []);

% Affichage du resultat de la simulation
figure(); subplot(3, 2, [1 2]);
plot(time, m_convert.f_length(x(:,5), 'm', 'ft')) ; grid on ; box on;
xlabel('Temps [sec]') ; ylabel('Altitude [ft]');
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 250], ...
    'Ylim', [1000 75000]);

subplot(3, 2, 3);
plot(time, m_convert.f_velocity(x(:,1), 'm/s', 'kts')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 250], ...
    'Ylim', [-200 1500]) ; ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(time, m_convert.f_velocity(x(:,2), 'm/s', 'kts')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 250], ...
    'Ylim', [-50 90]) ; ylabel('w_b [m/s]');

subplot(3, 2, 5); 
plot(time, m_convert.f_angle(x(:,3), 'rad', 'deg')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 250], ...
    'Ylim', [-50 50]); xlabel('Temps [sec]') ; ylabel('q [deg/s]');

subplot(3, 2, 6); 
plot(time, m_convert.f_angle(x(:,4), 'rad', 'deg')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 250], ...
    'Ylim', [-50 50]); xlabel('Temps [sec]') ; ylabel('\theta [deg]');