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

%% Simulation en condition d'équilibre
temps_simulation = 300;
sim("AER3640_avion_trim", temps_simulation)

figure(1); clf;
% Affichage de l'altitude en fonction du temps
subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [25000 40000]);

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [350 450]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [10 25]); ylabel('w_b [m/s]');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [0 5]); xlabel('Temps [sec]'); ylabel('\theta [deg]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

%% Étude d'une perturbation atmosphérique
% Vecteur de temps
t_sim = 0 : 0.1 : 300;

% Paramètres
V_m = 50;
t_init = 50;
t_pert = 10;

% Initialisation du vecteur V_w
V_w = zeros(size(t_sim));

for i = 1 : length(t_sim)
    if t_sim(i) <= t_init
        V_w(i) = 0;
    elseif t_sim(i) > t_init && t_sim(i) < t_init + t_pert
        V_w(i) = V_m/2 * (1-cos(pi*(t_sim(i)-t_init)/t_pert));
    else
        V_w(i) = V_m;
    end
end

% Graphique de l'amplitude de la rafale en fonction du temps
figure (2); clf;
plot(t_sim, V_w);
xlabel('Temps (t)');
ylabel('V_w(t)');
title('Graphique de V_w(t) en fonction du temps');
grid on;

% Simulation avec perturbation atmosphérique
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_avion_wind", temps_simulation)

% Affichage de l'altitude en fonction du temps
figure(3); clf;
subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [25000 40000]);

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [300 500]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [10 25]); ylabel('w_b [m/s]');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-20 25]); xlabel('Temps [sec]'); ylabel('\theta [deg]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

% Évolution u_b en fonction de w_b
figure(4); clf; 
plot(vitesses.signals(3).values, vitesses.signals(1).values);
xlabel('w_b');
ylabel('u_b');
title('Graphique de u_b en fonction de w_b');
grid on;

%% Étude d'une perturbation contrôlée
% Vecteur de temps
t_sim = 0 : 0.1 : 300;

% Paramètres
V_m = 10;
t_init = 10;
t_pert = 4;

% Initialisation du vecteur V_w
delev_deg = zeros(size(t_sim));

for i = 1:length(t_sim)
    if t_sim(i) <= t_init
        delev_deg(i) = 0;
    elseif t_sim(i) > t_init && t_sim(i) < t_init + t_pert
        delev_deg(i) = V_m * sin((pi*t_sim(i))/2 + pi);
    else
        delev_deg(i) = 0;
    end
end

% Graphique de l'amplitude de la rafale en fonction du temps
figure(5); clf;
plot(0:0.1:20, delev_deg(1:201));
xlabel('Temps [sec]');
ylabel('\delta_{elev} [deg]');
title('Graphique de \delta_{elev} en fonction du temps');
grid on;

delev_deg = m_convert.f_angle(delev_deg, 'deg', 'rad');

% Simulation avec perturbation contrôlée
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_avion_elevateur", temps_simulation)

% Affichage de l'altitude en fonction du temps
figure(6); clf;
subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [25000 35000]);

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [350 450]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-30 90]); ylabel('w_b [m/s]');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-15 15]); xlabel('Temps [sec]'); ylabel('\theta [deg]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-15 15]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

%% Problème : etude du comportement dynamique