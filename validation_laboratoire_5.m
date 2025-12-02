%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
addpath('Aircraft/', 'Modules/');

%%%Chargement des données de l'avion

avion = f_loadAircraftData;


%% Definition de la condition de vol
% Configuration de l'avion (poids/centrage)
conditions.masse_kg = m_convert.f_mass(130000, 'lbm', 'kg');
conditions.Iyy_kgm2 = avion.inertie.Iyy_kgm2;
conditions.xcg_perc = 0.2;
conditions.zcg_m = 0;

% Definition de la condition de vol
conditions.tas_mps = m_convert.f_velocity(400, 'kts', 'm/s');
conditions.altitude_m = m_convert.f_length(30000, 'ft', 'm');

% Trim de l'avion en vol de croisiere
trim_data = m_trim.f_croisiere(conditions.altitude_m, conditions.tas_mps,conditions.masse_kg, conditions.xcg_perc, conditions.zcg_m, avion);


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
%%
%Calcul analytiquedes w et zeta
alpha_vect = m_convert.f_angle(-2:1:10, 'deg', 'rad');
            cmb_vect = zeros(size(alpha_vect));
            
            % Pour toutes les valeurs de alpha, on trouve le clb
            for i = 1 : length(alpha_vect)
                [cls_tmp, cds_tmp, cms_tmp] = m_aero.f_coeff_stabilite(alpha_vect(i), 0, conditions.q_radps, conditions.tas_mps, m_atmos.f_nombre_mach(conditions.tas_mps, conditions.altitude_m),m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m), conditions.delev_rad, conditions.dflaps, conditions.dstab_rad, conditions.fn_n, avion);            
                cmb_vect(i) = cms_tmp;
            end
delta_alpha = alpha_vect(1)-alpha_vect(end);
cm_alpha = (cmb_vect(1) - cmb_vect(end))/(delta_alpha);
wnsp = sqrt(-m_atmos.f_pression_dynamique(conditions.tas_mps,conditions.altitude_m)*avion.geom.s_wb*avion.geom.c_wb*cm_alpha/avion.inertie.Iyy_kgm2);
zetasp = -m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m)*avion.geom.s_wb*avion.geom.c_wb*avion.geom.c_wb*(avion.aero.cma/m_convert.f_angle(1, 'deg', 'rad') + avion.aero.cmq)/(4*wnsp*conditions.tas_mps*avion.inertie.Iyy_kgm2);
[cls, cds, cms] = m_aero.f_coeff_stabilite(conditions.alpha_rad, 0, conditions.q_radps, conditions.tas_mps, m_atmos.f_nombre_mach(conditions.tas_mps, conditions.altitude_m),m_atmos.f_pression_dynamique(conditions.tas_mps, conditions.altitude_m), conditions.delev_rad, conditions.dflaps, conditions.dstab_rad, conditions.fn_n, avion);           
[clb,  ~,  ~] = m_aero.f_stab2body(cls, cds, cms, conditions.alpha_rad);
wnph = sqrt(m_atmos.f_masse_volumique(conditions.altitude_m)*avion.geom.s_wb*clb*9.81/conditions.masse_kg);
zetaph = cds/cls;
%%
%%% Initialisation du vecteur d'etat
x0 = [conditions.tas_mps*cos(conditions.alpha_rad), ...
      conditions.tas_mps*sin(conditions.alpha_rad), conditions.q_radps, ...
      conditions.theta_rad, conditions.altitude_m];
% Lancement d'une simulation
[time, x] = m_edm.f_simuler_avion(x0, 50, 1.0, conditions, avion, []);

% Affichage du resultat de la simulation
figure(); subplot(3, 2, [1 2]);
plot(time, m_convert.f_length(x(:, 5), 'm', 'ft')); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 50], ...
    'Ylim', [15000 25000]);

subplot(3, 2, 3);
plot(time, m_convert.f_velocity(x(:, 1), 'm/s', 'kts')); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 50], ...
    'Ylim', [200 300]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(time, m_convert.f_velocity(x(:, 2), 'm/s', 'kts')); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 50], ...
    'Ylim', [20 40]); ylabel('w_b [m/s]');

subplot(3, 2, 5);
plot(time, m_convert.f_angle(x(:, 3), 'rad', 'deg')); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 50], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

subplot(3, 2, 6);
plot(time, m_convert.f_angle(x(:, 4), 'rad', 'deg')); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 50], ...
    'Ylim', [-10 10]); xlabel('Temps [sec]'); ylabel('theta [deg]');

%% Preparation de la simulation
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim('m_mdl/AER3640_2207935_2207248_SIMULINK',300);
figure(); subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [25000 40000]);

subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [300 500]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [10 30]); ylabel('w_b [m/s]');

subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-20 25]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('theta [deg]');

%% Simulation du modele
% Time vector
t_sim = 0:0.1:300;   

% Parameters
Vm = 50;          
t_init = 50;      
t_pert = 10;      

% Initialize V_w vector
V_w = zeros(size(t_sim));

for i = 1:length(t_sim)
    if t_sim(i) <= t_init
        V_w(i) = 0;
    elseif t_sim(i) > t_init && t_sim(i) < t_init + t_pert
        V_w(i) = Vm / 2 * (1 - cos(pi * (t_sim(i) - t_init) / t_pert));
    else
        V_w(i) = Vm;
    end
end


% Plot the result to visualize
plot(t_sim, V_w);
xlabel('Time (t)');
ylabel('V_w(t)');
title('Plot of V_w(t) as a function of time');
grid on;

% Parameters
Vm = 10;          
t_init = 10;      
t_pert = 4;     

% Time vector
t_sim = 0:0.1:300;    

% Initialize V_w vector
V_w_delev = zeros(size(t_sim));

for i = 1:length(t_sim)
    if t_sim(i) <= t_init
        V_w_delev(i) = 0;
    elseif t_sim(i) > t_init && t_sim(i) < t_init + t_pert
        V_w_delev(i) = m_convert.f_angle(Vm * sin(pi/2 * t_sim(i) + pi), 'deg', 'rad');
    else
        V_w_delev(i) = 0;
    end
end
% plot(t_sim, V_w_delev);
% xlabel('Time (t)');
% ylabel('V_w_delev(t)');
% title('Plot of V_w_delev(t) as a function of time');
% grid on;
%%
[wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
sim('m_mdl/AER3640_2207935_2207248_SIMULINK',300);
%%

figure(); subplot(3, 2, [1 2]);
plot(positions.time, positions.signals(3).values); grid on; box on;
xlabel('Temps [sec]'); ylabel('Altitude [ft]');
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [29800 30200]);

subplot(3, 2, 3);
plot(vitesses.time, vitesses.signals(1).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [300 500]); ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(vitesses.time, vitesses.signals(3).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 20], ...
    'Ylim', [0 40]); ylabel('w_b [m/s]');

subplot(3, 2, 5);
plot(euler.time, euler.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-20 25]); xlabel('Temps [sec]'); ylabel('q [deg/s]');

subplot(3, 2, 6);
plot(pqr.time, pqr.signals(2).values); grid on; box on;
set(gca, 'xminortick', 'on', 'yminortick', 'on', 'Xlim', [0 300], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]'); ylabel('theta [deg]');
figure(10)
plot(vitesses.signals(3).values, vitesses.signals(1).values);
xlabel('wb');
ylabel('ub');
title('Graphique de ub en fonction de wb');
grid on;
%%
% Definition des altitudes :
altitude = 10000:5000:35000; % Altitudes from 10,000 to 35,000 feet

% Definition des vitesses :
vitesse = 200:40:400; % Speeds from 200 to 400 knots
mass_kg = m_convert.f_mass(130000, 'lbm', 'kg');
xcg_perc = 0.2;
zcg_m = 0;
% Initialize data storage
results = zeros(length(altitude), length(vitesse));
w_n_mat_sp = zeros(length(altitude), length(vitesse));
zeta_mat_sp = zeros(length(altitude), length(vitesse));
w_n_mat_phu = zeros(length(altitude), length(vitesse));
zeta_mat_phu = zeros(length(altitude), length(vitesse));

for i = 1 : length(altitude)
    for j = 1 : length(vitesse)
        conditions.tas_mps = m_convert.f_velocity(vitesse(j), 'kts', 'm/s');
        conditions.altitude_m = m_convert.f_length(altitude(i), 'ft', 'm');
        conditions.masse_kg = m_convert.f_mass(130000, 'lbm', 'kg');
        conditions.Iyy_kgm2 = avion.inertie.Iyy_kgm2;
        conditions.xcg_perc = 0.2;
        conditions.zcg_m = 0;
        trim_data = m_trim.f_croisiere(conditions.altitude_m, conditions.tas_mps,conditions.masse_kg, conditions.xcg_perc, conditions.zcg_m, avion);
        conditions.dflaps = 0;
        conditions.delev_rad = 0;
        conditions.dstab_rad = trim_data.dstab_rad;
        conditions.fn_n = trim_data.fn_n;
        conditions.q_radps = 0;
        conditions.alpha_rad = trim_data.alpha_rad;
        conditions.theta_rad = conditions.alpha_rad;
        % 2 - Utilisez la fonction f_stabilite (Example usage of f_stabilite function)
        [wn, zeta, model] = m_mdl.f_stabilite(conditions, avion);
        
        % 3 - Stockage des donnees (Store data in results matrix)
        w_n_mat_sp(j, i) = wn(2);
        zeta_mat_sp(j, i) = zeta(2);
        w_n_mat_phu(j, i) = wn(1);
        zeta_mat_phu(j, i) = zeta(1);
        
    end
end
%%

% Plot wn sp
figure;
surf(altitude,vitesse, w_n_mat_sp); 
xlabel('Altitude [ft]');
ylabel('True Airspeed [knots]');
zlabel('wn sp');
title('wn vs Altitude and True Airspeed for a short period');

% Plot zeta sp
figure;
surf(altitude,vitesse, zeta_mat_sp);  
xlabel('Altitude [ft]');
ylabel('True Airspeed [knots]');
zlabel('zeta sp');
title('zeta vs Altitude and True Airspeed for a short period');

figure;
surf(altitude,vitesse,w_n_mat_phu); 
xlabel('Altitude [ft]');
ylabel('True Airspeed [knots]');
zlabel('wn phu');
title('wn vs Altitude and True Airspeed for a phugoid');

% Plot zeta sp
figure;
surf(altitude,vitesse, zeta_mat_phu);  
xlabel('Altitude [ft]');
ylabel('True Airspeed [knots]');
zlabel('zeta phu');
title('zeta vs Altitude and True Airspeed for a phugoid');
