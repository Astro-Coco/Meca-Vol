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

%% 1.1 a)

% 1.1 b)

% 1.1 c) PAS À FAIRE

% 1.1 d)

% 1.2 a)

% 1.2 b)

%% 1.3 a)

% 1.3 b)

% 1.4 a)

% 1.4 b)

% 1.4 c)

%% 2.0.1

% 2.0.2

% 2.0.3

% 2.0.4

%% 2.1

% 2.2

% 2.3

%% 3.1 a)

q = 0;
alpha_dot = 0;
delta_e = 0;
delta_it = 0;
Fn = 0;
h_pi = 2000; %ft
Vt = 140; %kts

h_m = m_convert.f_length(h_pi, 'ft', 'm');
V_mps = m_convert.f_velocity(Vt, 'kts', 'm/s');

alphas = linspace(0,20,21)%deg
alpha_rads = m_convert.f_angle(alphas, 'deg', 'rad');

mach = m_atmos.f_nombre_mach(V_mps, h_m);
qbar_pa = m_atmos.f_pression_dynamique(V_mps, h_m);
dflap = 0;

for i = 1:length(alpha_rads)
    [cls, cds, cms] = m_aero.f_coeff_stabilite(alpha_rads(i), alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap,  delta_it, Fn, avion);
    % Conversion dans le repère géo
    [clb, cdb, cmb] = m_aero.f_stab2body(cls, cds, cms, alpha_rads(i));
    CLb(i) = clb;
    CDb(i) = cdb;
    CMb(i) = cmb;
end

%Plotting coefficiens vs alpha in degrees
figure;
subplot(3,1,1);
plot(alphas, CLb, '-o', 'LineWidth', 1.2);
xlabel('Angle of attack \alpha (deg)');
ylabel('C_L');
grid on;
title('C_L vs \alpha');

subplot(3,1,2);
plot(alphas, CDb, '-o', 'LineWidth', 1.2);
xlabel('Angle of attack \alpha (deg)');
ylabel('C_D');
grid on;
title('C_D vs \alpha');

subplot(3,1,3);
plot(alphas, CMb, '-o', 'LineWidth', 1.2);
xlabel('Angle of attack \alpha (deg)');
ylabel('C_M');
grid on;
title('C_M vs \alpha');

% 3.1 b)

% 3.1 c)

%% 3.2 a)

% 3.2 b)

% 3.2 c)

% 3.2 d)

%% 3.3 a)

% 3.3 b)

% 3.3 c)

% 3.3 d)

% 3.3 e)
