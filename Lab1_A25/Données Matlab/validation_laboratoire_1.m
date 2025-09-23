%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
%addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules copy')); 
%% % Debut de vos etudes

%% % Debut de vos etudes

%%% Definition d'un vecteur altitude avec un pas de 1,000 ft
altitude_ft = 0 : 1000 : 60000;

%%% Conversion du vecteur d'altitude en m;
altitude_m = m_convert.f_length(altitude_ft, 'ft', 'm');

%% % Etude sur la temperature

%%% Initialisation d'un vecteur de temperature
temperature_k = zeros(size(altitude_m));

%%% Calcul de la temperature
for i = 1 : length(altitude_m)
    temperature_k(i) = m_atmos.f_temperature(altitude_m(i));
end

%%% Affichage du resultat
figure (1); hold on; grid on; box on;
plot(altitude_ft/1000, temperature_k);
xlabel('Altitude [$\times 1{,}000$ ft]', 'interpreter', 'latex');
ylabel('Temperature [K]', 'interpreter', 'latex');

%% % Etude sur la pression

%%% Initialisation d'un vecteur de pression
pression_pa = zeros(size(altitude_m));

%%% Calcul de la pression
for i = 1 : length(altitude_m)
    pression_pa(i) = m_atmos.f_pression(altitude_m(i));
end

%%% Affichage du resultat
figure (2); hold on; grid on; box on;
plot(altitude_ft/1000, pression_pa);
xlabel('Altitude [$\times 1{,}000$ ft]', 'interpreter', 'latex');
ylabel('Pression statique [Pa]', 'interpreter', 'latex');

%% % Etude sur la masse volumique

%%% Initialisation d'un vecteur de masse volumique
rho_kgpm3 = zeros(size(altitude_m));

%%% Calcul de la masse volumique
for i = 1 : length(altitude_m)
    rho_kgpm3(i) = m_atmos.f_masse_volumique(altitude_m(i));
end

%%% Affichage du resultat
figure (3); hold on; grid on; box on;
plot(altitude_ft/1000, rho_kgpm3);
xlabel('Altitude [$\times 1{,}000$ ft]', 'interpreter', 'latex');
ylabel('Masse volumique [kg/m^3]', 'interpreter', 'latex');

%% % Etude sur la vitesse du son

%%% Initialisation d'un vecteur de vitesse du son
a_mps = zeros(size(altitude_m));

%%% Calcul de la vitesse du son
for i = 1 : length(altitude_m)
    a_mps(i) = m_atmos.f_vitesse_son(altitude_m(i));
end

%%% Affichage du resultat
figure (4); hold on; grid on; box on;
plot(altitude_ft/1000, m_convert.f_velocity(a_mps, 'm/s', 'kts'));
xlabel('Altitude [$\times 1{,}000$ ft]', 'interpreter', 'latex');
ylabel('Vitesse du son [nds]', 'interpreter', 'latex');

%% % Etude sur la pression dynamique et le nombre de mach à 250 nds

%%% Vitesse vraie de l'avion
tas_kts = 250;
tas_mps = m_convert.f_velocity(tas_kts, 'kts', 'm/s');

%%% Initialisation des vecteurs
qbar_pa = zeros(size(altitude_m));
mach_nb = zeros(size(altitude_m));

%%% Calcul de la pression dynamique et du nombre de Mach
for i = 1 : length(altitude_m)
    qbar_pa(i) = m_atmos.f_pression_dynamique(tas_mps, altitude_m(i));
    mach_nb(i) = m_atmos.f_nombre_mach(tas_mps, altitude_m(i));
end

%%% Affichage du résultat avec deux axes Y
figure(5); hold on; grid on; box on;

% Axe de gauche : pression dynamique
yyaxis left
plot(altitude_ft/1000, qbar_pa, 'DisplayName','Pression dynamique');
ylabel('Pression dynamique [Pa]', 'Interpreter','latex');

%%% Axe de droite : Mach
yyaxis right
plot(altitude_ft/1000, mach_nb, 'DisplayName','Nombre de Mach');
ylabel('Nombre de Mach', 'Interpreter','latex');

%%% Axe des X commun
xlabel('Altitude [$\times 1{,}000$ ft]', 'Interpreter','latex');

%%% Légende
legend('Location','northwest');

%% % Etude sur la pression dynamique et le nombre de mach à 20,000 ft

%%% Definition d'un vecteur vitesse
tas_kts = 100 : 1 : 400;

%%% Conversion du vecteur de vitesse en m/s;
tas_mps = m_convert.f_velocity(tas_kts, 'kts', 'm/s');

%%% Altitude de l'avion
altitude_ft = 20000;
altitude_m = m_convert.f_length(altitude_ft, 'ft', 'm');

%%% Initialisation des vecteurs
qbar_pa = zeros(size(tas_mps));
mach_nb = zeros(size(tas_mps));

%%% Calcul de la pression dynamique et du nombre de Mach
for i = 1 : length(tas_mps)
    qbar_pa(i) = m_atmos.f_pression_dynamique(tas_mps(i), altitude_m);
    mach_nb(i) = m_atmos.f_nombre_mach(tas_mps(i), altitude_m);
end

%%% Affichage du résultat avec deux axes Y
figure(6); hold on; grid on; box on;

%%% Axe de gauche : pression dynamique
yyaxis left
plot(tas_kts, qbar_pa, 'DisplayName','Pression dynamique');
ylabel('Pression dynamique [Pa]', 'Interpreter','latex');

%%% Axe de droite : Mach
yyaxis right
plot(tas_kts, mach_nb, 'DisplayName','Nombre de Mach');
ylabel('Nombre de Mach', 'Interpreter','latex');

%%% Axe des X commun
xlabel('Vitesse [nds]', 'Interpreter','latex');

%%% Légende
legend('Location','northwest');



%% 4.2 (Kosma)

%% a)
P_pa = 46565 ;
V_croisiere_kts = 240 ;
V_croisiere_mps = m_convert.f_velocity( V_croisiere_kts, 'kts', 'm/s');

alt_m = linspace(5000,8000,100);

for i = 1 : length(alt_m)
    Pression_pa(i) = m_atmos.f_pression(alt_m(i));
end


alt_est_m = interp1(Pression_pa,alt_m,P_pa);

alt_est_ft = m_convert.f_length(alt_est_m,'m','ft')

%%4.2 b
T_est = m_atmos.f_temperature(alt_est_m)
rho = m_atmos.f_masse_volumique(alt_est_m)

%% 4.2c

%Calcul de sigma selon les masse volumique en kg/m^2
%Valeur de base donnée dans la fonction f_pression
rho0_kgpm3 = 1.2250;

sigma = rho / rho0_kgpm3;

%Vérifier que la vitesse attendue est en mps
Ve = V_croisiere_mps;
Vt = Ve / sigma^0.5

%% 4.2 d
a_son_mps = m_atmos.f_vitesse_son(alt_est_m)
Mach_number = Vt / a_son_mps

%% 4.2 e
T_ISA = T_est;
delta_ISA = 20;
T = T_ISA + delta_ISA;
R_air = 287.058;
rho_reelle = P_pa/(R_air*T);

%% 4.2 f
sigma_reelle = rho_reelle/rho0_kgpm3;
Vt_reelle = Ve/sigma_reelle^0.5
Mach_number_reelle = Vt_reelle/a_son_mps


