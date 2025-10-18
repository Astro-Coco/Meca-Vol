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

function plot_coeff(alphas, CLb, CDb, CMb)
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
end

function [CLB, CDB, CMB, CLS, CDS, CMS] = coeff_from_flap(alphas, alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap,  delta_it, Fn, avion)
    for i = 1:length(alphas)
        [cls, cds, cms] = m_aero.f_coeff_stabilite(alphas(i), alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap,  delta_it, Fn, avion);
        % Conversion dans le repère géo
        [clb, cdb, cmb] = m_aero.f_stab2body(cls, cds, cms, alphas(i));
        CLB(i) = clb;
        CDB(i) = cdb;
        CMB(i) = cmb;
        CLS(i) = cls;
        CDS(i) = cds;
        CMS(i) = cms;
    end
end


q = 0;
alpha_dot = 0;
delta_e = 0;
delta_it = 0;
Fn = 0;
h_pi = 2000; %ft
Vt = 140; %kts

h_m = m_convert.f_length(h_pi, 'ft', 'm');
V_mps = m_convert.f_velocity(Vt, 'kts', 'm/s');

alphas = linspace(0,20,21);%deg
alpha_rads = m_convert.f_angle(alphas, 'deg', 'rad');

mach = m_atmos.f_nombre_mach(V_mps, h_m);
qbar_pa = m_atmos.f_pression_dynamique(V_mps, h_m);



%3.1 a)
dflap_a = 0;
[CLb, CDb, CMb, CLs, CDs, CMs] = coeff_from_flap(alpha_rads, alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap_a, delta_it, Fn, avion);
plot_coeff(alphas, CLs, CDs, CMs)
% 3.1 b)
dflaps = [0 1 2];

for i = 1:length(dflaps)
    dflap = dflaps(i);
    [CLb, CDb, CMb, CLs, CDs, CMs] = coeff_from_flap(alpha_rads, alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap, delta_it, Fn, avion);
    plot_coeff(alphas, CLs, CDs, CMs)
end
% 3.1 c)
dflap_c = 0;
[CLb, CDb, CMb, CLs, CDs, CMs] = coeff_from_flap(alpha_rads, alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap_c, delta_it, Fn, avion);
plot_coeff(alphas, CLb, CDb, CMb)

%% 3.2 a)

% 3.2 b)

% 3.2 c)

% 3.2 d)

%% 3.3 a)

% 3.3 b)

% 3.3 c)

% 3.3 d)

% 3.3 e)
