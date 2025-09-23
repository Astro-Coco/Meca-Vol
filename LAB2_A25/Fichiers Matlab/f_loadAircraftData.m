function avion = f_loadAircraftData()

%%% Donnees geometriques de l'avion
% Donnees relatives a l'aile de l'avion
avion.geom.s_wb = 122.401;                                  % [m2]
avion.geom.c_wb = 4.1935;                                   % [m]

% Donnees relatives a l'empennage arriere
avion.geom.s_ht = 31;                                       % [m2]
avion.geom.c_ht = 2.7;                                      % [m]
avion.geom.x_ht = 17.59;                                    % [m]
avion.geom.z_ht = 1.26;                                     % [m]

% Donnees relatives aux moteurs
avion.geom.x_m = m_convert.f_length(9.8, 'ft', 'm');        % [m]
avion.geom.z_m = m_convert.f_length(5.0, 'ft', 'm');        % [m]
avion.geom.i_m = m_convert.f_angle(2.0, 'deg', 'rad');      % [rad]

%%% Coefficients aerodynamiques de l'avion
% Coefficients statiques de l'aile et l'empennage arriere
avion.aero.cl0  = 0.23;                                     % [-]
avion.aero.cla  = 0.09;                                     % [1/deg]

avion.aero.cd0  = 0.020;                                    % [-]
avion.aero.cdcl = 0.0379;                                   % [-]

avion.aero.cm0  = -0.11;                                    % [-]
avion.aero.cma  = 0.013;                                    % [1/deg]
avion.aero.cmct = 0.25;                                     % [-]

avion.aero.eps0 = 1.18;                                     % [deg]
avion.aero.epsa = 0.37;                                     % [-]

avion.aero.a1   = 3.08;                                     % [1/rad]
avion.aero.a2   = 1.73;                                     % [1/rad]

% Coefficients dynamiques de l'aile
avion.aero.clq    = 8.1;                                    % [1/rad]
avion.aero.cmq    = -24.0;                                  % [1/rad]
avion.aero.cmadot = -1.4;                                   % [1/rad]

%%% Table de variations dues aux volets et au nombre de Mach
avion.aero.d_cl0.value = [0 0.45 1.01];
avion.aero.d_cl0.volet = [0 1 2];

avion.aero.r_cla.value = [1.0 1.0 1.05 1.19 1.25 1.34 1.34];
avion.aero.r_cla.mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

avion.aero.d_cd0.value = [0  0 0.0025 0.0035 0.0045 0.0055 0.013];
avion.aero.d_cd0.mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

avion.aero.d_cm0.value = [0 -0.17 -0.34];
avion.aero.d_cm0.volet = [0 1 2];

avion.aero.r_cma.value = [1.0 1.0 1.0 0.97 0.93 0.80 0.43];
avion.aero.r_cma.mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

avion.aero.d_eps.value = [0 2.36 3.55];
avion.aero.d_eps.volet = [0 1 2];

%%% Moment d'inertie de l'avion autour de l'axe y
avion.inertie.Iyy_kgm2 = m_convert.f_mass(1.766e10, 'lbm', 'kg');
avion.inertie.Iyy_kgm2 = m_convert.f_length(avion.inertie.Iyy_kgm2, 'in', 'm');
avion.inertie.Iyy_kgm2 = m_convert.f_length(avion.inertie.Iyy_kgm2, 'in', 'm');
