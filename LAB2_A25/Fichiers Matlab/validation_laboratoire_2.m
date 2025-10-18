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


alphas = linspace(-5,18, 25);
delta_s = 0;

function cls = sweep(alphas, delta_s)
    cl0 = 0.1;
    cl_a = 0.1;
    for i = 1:length(alphas)
        cl_stall = 0.5*(1- tanh(0.7*(alphas(i) - 14 - delta_s))) + 0.25 * ( 1 + tanh(0.7*(alphas(i) - 14.5 - delta_s)));
        cls(i) = cl0 + (cl_a*cl_stall)*alphas(i);
    end
end

cls = sweep(alphas, delta_s);
figure;
subplot(1,1,1);
plot(alphas, cls, '-o', 'LineWidth', 1.2);
xlabel('Angle of attack \alpha (deg)');
ylabel('CL_stall');
grid on;
title('C_l vs \alpha');
% 3.2 b)
[cl_max, idx_max] = max(cls);   % idx_max is index of first maximum automatically
alpha_at_clmax = alphas(idx_max);

% 3.2 c)
deltas_s = [0, 3, 5];
n = numel(deltas_s);
cl_matrix = zeros(n, numel(alphas));
for k = 1:n
    cl_matrix(k, :) = sweep(alphas, deltas_s(k));
end

figure;
plot(alphas, cl_matrix.', '-o', 'LineWidth', 1.2); % each row -> one curve
xlabel('Angle of attack \alpha (deg)');
ylabel('CL_{stall}');
grid on;
legend(arrayfun(@(d) sprintf('\\delta_s=%g', d), deltas_s, 'UniformOutput', false), 'Location', 'best');
title('CL_{stall} vs \alpha for different \delta_s');

% 3.2 d)


%% 3.3 a)
m = 45000;
h_ft = 20000;
h_m = m_convert.f_length(h_ft, 'ft', 'm');
V_kts = 400;
V_mps = m_convert.f_velocity(V_kts, 'kts', 'm/s');

Fn = 0;
alpha_dot = 0;
q = 0;
g = 9.81;

delta_f = 0;
delta_e = 0;
delta_it = linspace(-6, 2, 20);

gamma_deg = -3;
gamma = m_convert.f_angle(gamma_deg, 'deg', 'rad');

Q = m_atmos.f_pression_dynamique(V_mps, h_m);
CLs = m*g*cos(gamma)/(avion.geom.s_wb*Q);
CMs = 0;

% 3.3 b)
% 3.3 b) sweep du stabilisateur, et alpha, graphs en fonctions de alpha, voir Cl et Cm
dflap = 0;                        
alphas = linspace(-5,18,25);   
alpha_rads = m_convert.f_angle(alphas,'deg','rad');

delta_it_deg = linspace(-6,2,20);           % Positions des stab
delta_it_rad = m_convert.f_angle(delta_it_deg,'deg','rad');

% Construction des matrices de CLS et CMS
%Longueur
nD = numel(delta_it_deg);
nA = numel(alphas);
%Matrices
CLS_mat = zeros(nD, nA);
CMS_mat = zeros(nD, nA);

for j = 1:nD
    dstab = delta_it_rad(j);
    [~,~,~, CLS_row, ~, CMS_row] = coeff_from_flap(alpha_rads, alpha_dot, q, V_mps, mach, qbar_pa, delta_e, dflap, dstab, Fn, avion);
    CLS_mat(j,:) = CLS_row;
    CMS_mat(j,:) = CMS_row;
end

% Plot CLS and CMS overlays
figure;
subplot(2,1,1);
plot(alphas, CLS_mat.', 'LineWidth', 1.2); hold on;
yline(CLs, '--k', 'LineWidth',1.2); 
xlabel('alpha (deg)'); ylabel('C_{L_s}');
grid on;
legend_entries = arrayfun(@(d) sprintf('\\delta_{it}=%g°', d), delta_it_deg, 'UniformOutput', false);
legend([legend_entries, {'C_{L,req}'}], 'Location','best');
title('C_{L_s} vs \alpha pour différents It');

subplot(2,1,2);
plot(alphas, CMS_mat.', 'LineWidth', 1.2);
xlabel('alpha (deg)'); ylabel('C_{M_s}');
grid on;
legend(legend_entries, 'Location','best');
title('C_{M_s} vs \alpha pour différents It');


%TODOOOOOOOOOOOO
% 3.3 c)

% 3.3 d)

% 3.3 e)
