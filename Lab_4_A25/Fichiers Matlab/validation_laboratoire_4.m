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
[time,x] = m_edm.f_simuler_avion(x0, 80, 0.2, conditions, avion, []);

% Affichage du resultat de la simulation
figure(); subplot(3, 2, [1 2]);
plot(time, m_convert.f_length(x(:,5), 'm', 'ft')) ; grid on ; box on;
xlabel('Temps [sec]') ; ylabel('Altitude [ft]');
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 80], ...
    'Ylim', [15000 45000]);

subplot(3, 2, 3);
plot(time, m_convert.f_velocity(x(:,1), 'm/s', 'kts')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 80], ...
    'Ylim', [200 450]) ; ylabel('u_b [m/s]');

subplot(3, 2, 4);
plot(time, m_convert.f_velocity(x(:,2), 'm/s', 'kts')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 80], ...
    'Ylim', [20 40]) ; ylabel('w_b [m/s]');

subplot(3, 2, 5); 
plot(time, m_convert.f_angle(x(:,3), 'rad', 'deg')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 80], ...
    'Ylim', [-5 5]); xlabel('Temps [sec]') ; ylabel('q [deg/s]');

subplot(3, 2, 6); 
plot(time, m_convert.f_angle(x(:,4), 'rad', 'deg')) ; grid on ; box on;
set(gca, 'xminorgrid', 'on', 'yminorgrid', 'on', 'Xlim', [0 80], ...
    'Ylim', [0 5]); xlabel('Temps [sec]') ; ylabel('\theta [deg]');



% 
altitudes = m_convert.f_length(10000:2500:35000, 'ft', 'm');
vitesses = m_convert.f_velocity(450:-25:200, 'kts', 'm/s');

results_matrice = zeros(length(altitudes)*length(vitesses), 3);


for i = 1:length(altitudes)
    for j = 1:length(vitesses)
        trim_data = m_trim.f_croisiere(altitudes(i), vitesses(j), ...
            conditions.masse_kg, conditions.xcg_perc, conditions.zcg_m, avion);
        disp(['Altitude: ', num2str(m_convert.f_length(altitudes(i), 'm', 'ft')), ' ft, Vitesse: ', ...
            num2str(m_convert.f_velocity(vitesses(j), 'm/s', 'kts')), ' kts --> alpha (deg): ', ...
            num2str(m_convert.f_angle(trim_data.alpha_rad, 'rad', 'deg')), ...
            ', dstab (deg): ', num2str(m_convert.f_angle(trim_data.dstab_rad, 'rad', 'deg')), ...
            ', fn (N): ', num2str(trim_data.fn_n)]);

        index = (i-1)*length(vitesses) + j;
        results_matrice(index, :) = [trim_data.alpha_rad, trim_data.dstab_rad, trim_data.fn_n];
    end
end

%Graphes des résultats de chaque paramètre en fonction de l'altitude et de la vitesse
%Alpha Graphes
Na = numel(altitudes);
Nv = numel(vitesses);

% results_matrice indexed as (i-1)*Nv + j, donc reshape en Nv x Na puis transpose
alpha_mat = reshape(results_matrice(:,1), Nv, Na)';   % taille [Na x Nv] (lignes=altitudes, colonnes=vitesses)
dstab_mat = reshape(results_matrice(:,2), Nv, Na)';
fn_mat    = reshape(results_matrice(:,3), Nv, Na)';

% grilles X (vitesse) et Y (altitude) de même taille [Na x Nv]
[Vgrid, Hgrid] = meshgrid(vitesses, altitudes);

% conversion unités pour axes et z si souhaité
V_kts = m_convert.f_velocity(Vgrid, 'm/s', 'kts');
H_ft  = m_convert.f_length(Hgrid, 'm', 'ft');
alpha_deg  = m_convert.f_angle(alpha_mat, 'rad', 'deg');
dstab_deg  = m_convert.f_angle(dstab_mat, 'rad', 'deg');

% surface alpha_trim
figure;
surf(V_kts, H_ft, alpha_deg);
shading interp; colorbar;
xlabel('V_T (kts)'); ylabel('Altitude (ft)'); zlabel('\alpha_{trim} (deg)');
title('\alpha_{trim} vs V_T et altitude'); view(45,30);

% surface dstab_trim
figure;
surf(V_kts, H_ft, dstab_deg);
shading interp; colorbar;
xlabel('V_T (kts)'); ylabel('Altitude (ft)'); zlabel('\delta_{stab,trim} (deg)');
title('\delta_{stab,trim} vs V_T et altitude'); view(45,30);

% surface Fn_trim
figure;
surf(V_kts, H_ft, fn_mat);
shading interp; colorbar;
xlabel('V_T (kts)'); ylabel('Altitude (ft)'); zlabel('F_{n,trim} (N)');
title('F_{n,trim} vs V_T et altitude'); view(45,30);


masses = m_convert.f_mass(120000:10000:160000, 'lbm', 'kg');
xcgs = 0:0.05:0.25;

matrices_deux = zeros(length(masses)*length(xcgs), 3);

for i = 1:length(masses)
    for j = 1:length(xcgs)
        trim_data = m_trim.f_croisiere(conditions.altitude_m, conditions.tas_mps, ...
            masses(i), xcgs(j), conditions.zcg_m, avion);
        disp(['Masse: ', num2str(m_convert.f_mass(masses(i), 'kg', 'lbm')), ' lbm, Xcg: ', ...
            num2str(xcgs(j)*100), ' %MAC --> alpha (deg): ', ...
            num2str(m_convert.f_angle(trim_data.alpha_rad, 'rad', 'deg')), ...
            ', dstab (deg): ', num2str(m_convert.f_angle(trim_data.dstab_rad, 'rad', 'deg')), ...
            ', fn (N): ', num2str(trim_data.fn_n)]);
        index = (i-1)*length(xcgs) + j;
        matrices_deux(index, :) = [trim_data.alpha_rad, trim_data.dstab_rad, trim_data.fn_n];
    end
end

mesh = 