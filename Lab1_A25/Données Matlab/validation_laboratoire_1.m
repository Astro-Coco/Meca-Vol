%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
addpath('Aircraft/', 'Modules/');

%% % Debut de vos etudes

%%% Definition d'un vecteur altitude avec un pas de 1,000ft 
altitude_ft = 0 : 1000 : 60000;

%%% Conversion du vecteur d'altitude en m
altitude_m = m_convert.f_length(altitude_ft, 'ft', 'm');

%%% Initialisation d'un vecteur de temperature
temperature_k = zeros(size(altitude_m));

%%% Calcul de la temperature
for i = 0 : length(altitude_m);
    % Calcul de la temperature;
    temperature_k(i) = m_atmos.f_temperature(altitude_m(i));
end

%%% Affichage des resultats
figure(1); hold on; grid on; box on;
plot(altitude_m, temperature_k, '-x');
xlabel("Altitude [$$\times$$1,000ft]", 'interpreter','latex');
ylabel('Temperature [K]', 'interpretrer', 'latex');