%initialisation
clc;
clear;
close all;

%%% Organisation des répertoires
addpath('Aircraft/','Modules/');

%%% Chargement des données de l'avion
avion = f_loadAircraftData;

%%%Analyse des coefficients aérodynamiques
%Données
q=0;
alpha_dot=0;
delta_e=0;
delta_it=0;
Fn=0;
h=2000;
altitude_m=m_convert.f_length(h, 'ft', 'm');
Vt=140;
tas_mps=m_convert.f_velocity( Vt, 'kts', 'm/s');
alpha = linspace(0, 20, 100);

%Initialisation des vecteurs
cls0 = zeros(size(alpha));
cds0 = zeros(size(alpha));
cms0 = zeros(size(alpha));
cls1 = zeros(size(alpha));
cds1 = zeros(size(alpha));
cms1 = zeros(size(alpha));
cls2 = zeros(size(alpha));
cds2 = zeros(size(alpha));
cms2 = zeros(size(alpha));

%Calcul des coefficients pour toutes les positions de volet
for i = 1:length(alpha)
    [cls0(i), cds0(i), cms0(i)] = m_aero.f_coeff_stabilite(m_convert.f_angle(alpha(i), 'deg', 'rad'), alpha_dot, q, tas_mps, m_atmos.f_nombre_mach(tas_mps, altitude_m),m_atmos.f_pression_dynamique(tas_mps, altitude_m),delta_e, 0, delta_it, Fn, avion);
end
for i = 1:length(alpha)
    [cls1(i), cds1(i), cms1(i)] = m_aero.f_coeff_stabilite(m_convert.f_angle(alpha(i), 'deg', 'rad'), alpha_dot, q, tas_mps, m_atmos.f_nombre_mach(tas_mps, altitude_m),m_atmos.f_pression_dynamique(tas_mps, altitude_m),delta_e, 1, delta_it, Fn, avion);
end
for i = 1:length(alpha)
    [cls2(i), cds2(i), cms2(i)] = m_aero.f_coeff_stabilite(m_convert.f_angle(alpha(i), 'deg', 'rad'), alpha_dot, q, tas_mps, m_atmos.f_nombre_mach(tas_mps, altitude_m),m_atmos.f_pression_dynamique(tas_mps, altitude_m),delta_e, 2, delta_it, Fn, avion);
end

%Trace les graphiques
figure;

sgtitle('Évolution des coefficients aérodynamiques en fonction de l''angle d''attaque avec différentes positions de volets');
subplot(1,3,1);
plot(alpha, cls0, 'r-', 'LineWidth', 1.5); hold on;
plot(alpha, cls1, 'b--', 'LineWidth', 1.5);
plot(alpha, cls2, 'g-.', 'LineWidth', 1.5);
grid on;
xlabel('\alpha (deg)');
ylabel('C_L_s');
legend('volet=0', 'volet=1', 'volet=2');


subplot(1,3,2);
plot(alpha, cds0, 'r-', 'LineWidth', 1.5); hold on;
plot(alpha, cds1, 'b--', 'LineWidth', 1.5);
plot(alpha, cds2, 'g-.', 'LineWidth', 1.5);
grid on;
xlabel('\alpha (deg)');
ylabel('C_D_s');
legend('volet=0', 'volet=1', 'volet=2');


subplot(1,3,3);
plot(alpha, cms0, 'r-', 'LineWidth', 1.5); hold on;
plot(alpha, cms1, 'b--', 'LineWidth', 1.5);
plot(alpha, cms2, 'g-.', 'LineWidth', 1.5);
grid on;
xlabel('\alpha (deg)');
ylabel('C_M_s');
legend('volet=0', 'volet=1', 'volet=2');

clb0 = zeros(size(alpha));
cdb0 = zeros(size(alpha));
cmb0 = zeros(size(alpha));

%Transfert au repère de l'avion
for i = 1:length(alpha)
    [clb0(i),cdb0(i),cmb0(i)]=m_aero.f_stab2body(cls0(i),cds0(i),cms0(i),m_convert.f_angle(alpha(i), 'deg', 'rad'));
end
%Trace la figure
figure;

sgtitle('Évolution des coefficients aérodynamiques en fonction de l''angle d''attaque dans le repère de l''avion');
plot(alpha, clb0, 'r-', 'LineWidth', 1.5); hold on;
plot(alpha, cdb0, 'b--', 'LineWidth', 1.5);
plot(alpha, cmb0, 'g-.', 'LineWidth', 1.5);
grid on;
xlabel('\alpha (deg)');
ylabel('Coefficients aérodynamiques');
legend('C_L_b', 'C_D_b', 'C_M_b');


%%%Deuxième étude:Analyse du décrochage d'un avion
%Données
alpha_deg = linspace(-5, 18, 100);
ds=0;
cl0=0.1;
cla=0.1;
cl= zeros(size(alpha_deg));

%Coefficient de portance 
for i = 1:length(alpha_deg)
    clstall=0.5*(1-tanh(0.7*(alpha_deg(i)-14-ds)))+0.25*(1+tanh(0.7*(alpha_deg(i)-14.5-ds)));
    cl(i)=cl0+(cla*clstall)*alpha_deg(i);
end

%Trace le graphique
figure;

sgtitle('Évolution du coefficient de portance en fonction de l''angle d''attaque pour étudier le décrochage');
plot(alpha_deg, cl, 'r-', 'LineWidth', 1.5); hold on;
grid on;
xlabel('\alpha (deg)');
ylabel('C_L');

%Calcul du Clmax
clmax = max(cl);
clmax_deg = alpha_deg(cl == clmax);
disp(clmax);
disp(clmax_deg)

%Variation du delta_s
cl3 = zeros(size(alpha_deg));
cl5 = zeros(size(alpha_deg));

ds3=3;
ds5=5;

%Calcul des cl pour des ds différents
for i = 1:length(alpha_deg)
    clstall=0.5*(1-tanh(0.7*(alpha_deg(i)-14-ds3)))+0.25*(1+tanh(0.7*(alpha_deg(i)-14.5-ds3)));
    cl3(i)=cl0+(cla*clstall)*alpha_deg(i);
end
for i = 1:length(alpha_deg)
    clstall=0.5*(1-tanh(0.7*(alpha_deg(i)-14-ds5)))+0.25*(1+tanh(0.7*(alpha_deg(i)-14.5-ds5)));
    cl5(i)=cl0+(cla*clstall)*alpha_deg(i);
end

%Trace le graphique
figure;

sgtitle('Évolution du coefficient de portance en fonction de l''angle d''attaque avec différentes positions de volets de bord d''attaque');
plot(alpha_deg, cl, 'r-', 'LineWidth', 1.5); hold on;
plot(alpha_deg, cl3, 'b--', 'LineWidth', 1.5);
plot(alpha_deg, cl5, 'g-.', 'LineWidth', 1.5);
grid on;
xlabel('\alpha (deg)');
ylabel('C_L');
legend('volet=0°', 'volet=3°', 'volet=5°');

%%%Troisième étude:Équilibrage d'un avion en descente
%Données
gamma=-3;
gamma_rad=m_convert.f_angle(gamma, 'deg', 'rad');
fn=0;
m=45000;
h=20000;
Vt=400;
tas_mps=m_convert.f_velocity( Vt, 'kts', 'm/s');
q=0;
alpha_dot=0;
df=0;
de=0;
dit=linspace(-6, 2, 100);
altitude_m=m_convert.f_length(h, 'ft', 'm');
Q = m_atmos.f_pression_dynamique(tas_mps, altitude_m);
g=9.81;
s_wb=avion.geom.s_wb;
mach_nb = m_atmos.f_nombre_mach(tas_mps, altitude_m);

%Calcul de clstrim
clstrim=m*g*cos(gamma_rad)/(Q*s_wb);
disp(clstrim)

%Variation des paramètres
alpha_deg = linspace(0, 10, 100);  
delta_it = -4:1:2;             

%Création des vecteurs vides
CL = zeros(length(alpha_deg), length(delta_it));
CD = zeros(length(alpha_deg), length(delta_it));
CM = zeros(length(alpha_deg), length(delta_it));

% Itérations pour les coefficients
for j = 1:length(delta_it)               % boucle sur δ_it
    for i = 1:length(alpha_deg)              % boucle sur α
        
        [CL(i,j), CD(i,j), CM(i,j)] = m_aero.f_coeff_stabilite(m_convert.f_angle(alpha_deg(i), 'deg', 'rad'),alpha_dot,q,tas_mps, mach_nb,Q,de,0,m_convert.f_angle(delta_it(j), 'deg', 'rad'), Fn, avion);
    end
end

%Trace les graphiques
figure;
subplot(1,2,1);
hold on; grid on;
for j = 1:length(delta_it)
    plot(alpha_deg, CL(:,j), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('\\delta_{it} = %d°', delta_it(j)));
end
xlabel('\alpha (deg)');
ylabel('C_L');


subplot(1,2,2);
hold on; grid on;
for j = 1:length(delta_it)
    plot(alpha_deg, CM(:,j), 'LineWidth', 1.5, ...
         'DisplayName', sprintf('\\delta_{it} = %d°', delta_it(j)));
end
xlabel('\alpha (deg)');
ylabel('C_M');
legend show;

sgtitle('Évolution des coefficients C_L_s et C_M_s en fonction de \alpha et \delta_{it}')

%Calcul de la plage de alpha
alpha_max = interp1(CL(:, 1), alpha_deg, clstrim, 'linear');
alpha_min = interp1(CL(:, 7), alpha_deg, clstrim, 'linear');
disp(alpha_min)
disp(alpha_max)
alpha_eq = interp1(CM(:,4), alpha_deg, 0, 'linear');
disp(alpha_eq)


