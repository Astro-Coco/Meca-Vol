%%% Initialisation
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

%% % Initialisation des parametres de croisiere
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

%% % Partie 1
%% Simulation du modèle en conditions de trim
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);

temps_simulation = 300;
sim("AER3640_ctrl_avion_trim", temps_simulation)

figure(1);
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

%% % Partie 2
%% Analyse du phugoide et du short period
% Vecteur de temps
t_sim = 0 : 0.1 : 300;

% Paramètres
V_m = 5;
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
figure(5);
plot(t_sim, delev_deg);
xlabel('Temps [sec]');
ylabel('\delta_{elev} [deg]');
title('Graphique de \delta_{elev} en fonction du temps');
grid on;

delev_deg = m_convert.f_angle(delev_deg, 'deg', 'rad');

% Simulation avec perturbation contrôlée
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_ctrl_avion_elevateur", temps_simulation)

% Affichage de l'altitude en fonction du temps
figure(6);
subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [29900 30100]);

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [395 405]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-20 55]); ylabel('w_b [m/s]');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 8]); xlabel('Temps [sec]'); ylabel('\theta [deg]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-8 10]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

%% Simulation d'un PIO
% Vecteur de temps
t_sim = 0 : 0.1 : 300;

% Paramètres
V_m = 1;
T = 103;
wn_ph = 2*pi/T;

% Initialisation du vecteur V_w
delev_deg = zeros(size(t_sim));

for i = 1:length(t_sim)
    delev_deg(i) = V_m * sin(wn_ph*t_sim(i));
end

% Graphique de l'amplitude de la rafale en fonction du temps
figure(5);
plot(t_sim, delev_deg);
xlabel('Temps [sec]');
ylabel('\delta_{elev} [deg]');
title('Graphique de \delta_{elev} en fonction du temps');
grid on;

delev_deg = m_convert.f_angle(delev_deg, 'deg', 'rad');

% Simulation avec perturbation contrôlée
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_ctrl_avion_elevateur", temps_simulation)

% Sauvegarde des variables de la simu PIO
positions_PIO = positions;
vitesses_PIO = vitesses;
euler_PIO = euler;
pqr_PIO = pqr;

% Affichage de l'altitude en fonction du temps
figure(6);
subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [10000 35000]);

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [0 700]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [0 30]); ylabel('w_b [m/s]');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-55 65]); xlabel('Temps [sec]'); ylabel('\theta [deg]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

%% Conception d'un système de commande de vol

% Linearisation de l'avion autour de la condition de trim
[~, ~, model] = m_mdl.f_stabilite(conditions, avion)

% Interface pour le calcul des gains en longitudinal
%f_compensateur(conditions, avion);

% Vecteur de temps
t_sim = 0 : 0.1 : 300;

% Gains
Kq = -3.7007;
Ki = 13.8363;
Kp = -3.1842;

% Simulation avec perturbation contrôlée
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_ctrl_avion_commande_longitudinale", temps_simulation)

% Sauvegarde des variables de la simu commande
positions_CMD = positions;
vitesses_CMD = vitesses;
euler_CMD = euler;
pqr_CMD = pqr;

% Affichage de l'altitude en fonction du temps
figure(7);
subplot(3, 2, [1 2]); hold on;
plot(positions_PIO.time, positions_PIO.signals(3).values);
plot(positions_CMD.time, positions_CMD.signals(3).values);
box on; grid on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [10000 35000]);
legend('Sans contrôleur', 'Avec contrôleur', 'Location', 'best');

% Affichage de ub ou wb en fonction du temps
subplot(3, 2, 3); hold on;
plot(vitesses_PIO.time, vitesses_PIO.signals(1).values);
plot(vitesses_CMD.time, vitesses_CMD.signals(1).values);
grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [0 700]); ylabel('u_b [m/s]');
legend('Sans contrôleur', 'Avec contrôleur', 'Location', 'best');

subplot(3, 2, 4); hold on;
plot(vitesses_PIO.time, vitesses_PIO.signals(3).values);
plot(vitesses_CMD.time, vitesses_CMD.signals(3).values);
grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [0 30]); ylabel('w_b [m/s]');
legend('Sans contrôleur', 'Avec contrôleur', 'Location', 'best');

% Affichage de theta et q en fonction du temps
subplot(3, 2, 5); hold on;
plot(euler_PIO.time, euler_PIO.signals(2).values);
plot(euler_CMD.time, euler_CMD.signals(2).values);
grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-55 65]); xlabel('Temps [sec]'); ylabel('\theta [deg]');
legend('Sans contrôleur', 'Avec contrôleur', 'Location', 'best');

subplot(3, 2, 6); hold on;
plot(pqr_PIO.time, pqr_PIO.signals(2).values);
plot(pqr_CMD.time, pqr_CMD.signals(2).values);
grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('q [deg/s]');
legend('Sans contrôleur', 'Avec contrôleur', 'Location', 'best');



%% % Partie 3
%% Analyse du roulis Hollandais de l'avion
t_sim = 0:0.1:100;
temps_simulation = 100;
A = 4;    % deg
t0 = 10;  % s
T = 4;    % s

drudder_deg = zeros(size(t_sim)); %Vecteur initialisé à zéro pour le signal
idx = (t_sim >= t0) & (t_sim <= t0+T); %Indexes correspondants à la perturbation
tau = t_sim(idx) - t0; %Temps décalé pour la perturbation
drudder_deg(idx) = A * sin(2*pi*tau/T); %Remplacer les valeurs dans l'intervalle par la perturbation

drudder_rad = m_convert.f_angle(drudder_deg, 'deg', 'rad');

%Figure pour visualiser la perturbation
figure(8);
plot(t_sim, drudder_deg);
xlabel('Temps [sec]');
ylabel('\delta_{rudder} [deg]');
title('Graphique de \delta_{rudder} en fonction du temps');
grid on;

% Trouver les conditions de stabilités comme avant
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
% J'assume le nom du modèle rudder
sim("AER3640_ctrl_avion_commande_longitudinale", temps_simulation)

positions_NR = positions;
vitesses_NR  = vitesses;
euler_NR     = euler;
pqr_NR       = pqr;



%% Conception d'un système de commande de vol latéral
%open("AER3640_ctrl_avion_commande_laterale.slx");


%Changement de noms de gains pour éviter conflit avec longitudinal
% Gains
Kv_lat = -0.0266;
Kp_lat = 2.0893;
Kr_lat = 1.2067;
Kph_lat = 9.5022;
Ki_lat = -7.0334;
Kv1_lat = 0.0087;
Kp1_lat = 0.2904;
Kr1_lat = -2.1597;
Kph1_lat = 0.6675;
Ki1_lat = -0.7286;

% Simulation avec perturbation contrôlée
temps_sim = 0:0.1:100;
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim("AER3640_ctrl_avion_commande_laterale", temps_simulation)

% Sauvegarde des variables de la simu commande contrôlée
positions_CTL = positions;
vitesses_CTL  = vitesses;
euler_CTL     = euler;
pqr_CTL       = pqr;

figure(9)
subplot(3,2,[1 2]); hold on;
plot(positions_NR.time, positions_NR.signals(3).values(:,1));
plot(positions_CTL.time, positions_CTL.signals(3).values(:,1));
grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
legend('Sans compensateur','Avec compensateur','Location','best');

subplot(3,2,3); hold on;
plot(pqr_NR.time, pqr_NR.signals(1).values(:,1));
plot(pqr_CTL.time, pqr_CTL.signals(1).values(:,1));
grid on; box on;
xlabel('Temps [sec]'); ylabel('p [deg/s]');
legend('Sans','Avec','Location','best');

subplot(3,2,4); hold on;
plot(pqr_NR.time, pqr_NR.signals(3).values(:,1));
plot(pqr_CTL.time, pqr_CTL.signals(3).values(:,1));
grid on; box on;
xlabel('Temps [sec]'); ylabel('r [deg/s]');
legend('Sans','Avec','Location','best');

subplot(3,2,5); hold on;
plot(vitesses_NR.time, vitesses_NR.signals(2).values(:,1));
plot(vitesses_CTL.time, vitesses_CTL.signals(2).values(:,1));
grid on; box on;
ylabel('v_b [m/s]');  % ajuste si ton signal est en kts
legend('Sans','Avec','Location','best');

subplot(3,2,6); hold on;
plot(euler_NR.time, euler_NR.signals(1).values(:,1));
plot(euler_CTL.time, euler_CTL.signals(1).values(:,1));
grid on; box on;
xlabel('Temps [sec]'); ylabel('\phi [deg]');
legend('Sans','Avec','Location','best');
