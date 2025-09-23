function aircraft = f_loadAircraftData()

%%% Donn?es g?om?triques de l'avion
% Donn?es de l'aile
aircraft.geo.Swb = 122.401;                                % [m?]
aircraft.geo.cwb = 4.1935;                                 % [m]
aircraft.geo.iwb = conversion(0, 'deg', 'rad');            % [rad]
% Donn?es de l'empennage arri?re
aircraft.geo.Sht = 31;                                     % [m?]
aircraft.geo.cht = 2.7;                                    % [m]
aircraft.geo.iht = conversion(0, 'deg', 'rad');            % [rad]
aircraft.geo.xh = 17.59;                                   % [m]
aircraft.geo.zh = 1.26;                                    % [m]
% Donn?es du moteur
aircraft.geo.xm = conversion(9.8, 'ft', 'm');              % [m]
aircraft.geo.zm = conversion(5.0, 'ft', 'm');              % [m]
aircraft.geo.im  = conversion(2.0, 'deg', 'rad');          % [rad]

%%% Coefficients aerodynamiques de l'avion
% Coefficients statiques
aircraft.aero.CL0  = 0.23;                                % [-]
aircraft.aero.CLa  = 0.09;                                % [1/deg]

aircraft.aero.CD0  = 0.020;                              % [-]
aircraft.aero.CDCL = 0.0379;                             % [-]

aircraft.aero.Cm0  = -0.11;                               % [-]
aircraft.aero.Cma  = 0.013;                               % [1/deg]
aircraft.aero.Cmt  = 0.25;                                % [-]

aircraft.aero.eps0 = 1.18;                               % [deg]
aircraft.aero.epsa = 0.37;                               % [-]

aircraft.aero.a1   = 3.08;                                 % [1/rad]
aircraft.aero.a2   = 1.73;                                 % [1/rad]

% Coefficients dynamiques
aircraft.aero.CLq    = 8.1;                                 % [1/rad]
aircraft.aero.Cmq    = -24.0;                               % [1/rad]
aircraft.aero.Cmadot = -1.4;                             % [1/rad]

% Variations dues aux volets et nombre de Mach
aircraft.aero.dCL0.value = [0 0.45 1.01];
aircraft.aero.dCL0.dFlap = [0 1 2];

aircraft.aero.rCLa.value = [1.0 1.0 1.05 1.19 1.25 1.34 1.34];
aircraft.aero.rCLa.Mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

aircraft.aero.dCD0.value = [0  0 0.0025 0.0035 0.0045 0.0055 0.013];
aircraft.aero.dCD0.Mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

aircraft.aero.dCm0.value = [0 -0.17 -0.34];
aircraft.aero.dCm0.dFlap = [0 1 2];

aircraft.aero.rCma.value = [1.0 1.0 1.0 0.97 0.93 0.80 0.43];
aircraft.aero.rCma.Mach  = [0 0.2 0.6 0.7 0.75 0.80 0.85];

aircraft.aero.dEps.value = [0 2.36 3.55];
aircraft.aero.dEps.dFlap = [0 1 2];

%%% Donn?es massiques (inertie Iyy) de L'avion
aircraft.inertie.Iyy = conversion(1.766e10, 'lb.in2', 'kg.m2');
