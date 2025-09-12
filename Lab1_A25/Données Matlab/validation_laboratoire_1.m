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

%%% Definition d'un vecteur altitude avec un pas de 1,000ft 
altitude_ft = 0 : 1000 : 60000;

%%% Conversion du vecteur d'altitude en m
altitude_m = m_convert.f_length(altitude_ft, 'ft', 'm');

%%% Initialisation d'un vecteur de temperature
temperature_k = zeros(size(altitude_m));

%%% Calcul de la temperature
for i = 1 : length(altitude_m);
    % Calcul de la temperature;
    temperature_k(i) = m_atmos.f_temperature(altitude_m(i));
end

%%% Affichage des resultats
figure(1); hold on; grid on; box on;
plot(altitude_m, temperature_k, '-x');
xlabel('Altitude [$\times$ 1{,}000 ft]', 'Interpreter', 'latex');
ylabel('Temperature [K]', 'interpreter', 'latex');



%% 4.2 (Kosma)

%% a)
P_pa = 46565 ;
V_croisiere_kts = 240 ;
V_croisiere_mps = m_convert.f_velocity( V_croisiere_kts, 'kts', 'm/s');




alt_m = linspace(5000,8000,100);

for i = 1 : length(alt_m)
    Pression_pa(i) = m_atmos.f_pression(alt_m(i));
end


alt_est_m = interp1(Pression_pa,alt_m,P_pa)