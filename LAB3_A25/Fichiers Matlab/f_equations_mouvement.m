function x_dot = f_equations_mouvement(t, x, conditions, avion, ...
    mode, dt)
% F_EQUATIONS_MOUVEMENT permet de d?finir les equations d'etat de l'avion.
%   Cette fonction permet de repr?senter la dynamique du vol d'un avion
%   sous la representation d'etat generale x_dot = f(x, etat, t). Cette
%   forme a ete adaptee pour les besoins du laboratoire de mecanique du vol
%   de l'Ecole Polytechnique Montreal (AER3640).
%
% Syntax:
%   x_dot = f_equations_mouvement(t, x, conditions, avion, mode, dt)
%
% Inputs:
%       - t             : temps de la simulation qui s'ecoule         [sec]
%       - x             : vecteur d'etat de l'avion                   [-]
%       - conditions    : structure contenant les conditions de vol   [-]
%       - avion         : structure contenant les donnees de l'avion  [-]
%       - mode          : 'short period' ou 'phugoid' ou 'normal'
%       - dt            : pas de la simualtion                        [sec]
% Outputs:
%       - x_dot         : variation du vecteur d'?tat de l'avion      [-]
%
% Example:
%
%   x_dot = m_edm.f_equations_mouvement(t, x, conditions, avion, mode, dt)
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%%% Initialisation du vecteur de sortie
x_dot = zeros(5,1); 

%%%% Recupreraton des donnees actuelles
ub_mps     = x(1);        % Vitesse longitudinale de l'avion (dans le body)
wb_mps     = x(2);        % Vitesse verticale de l'avion (dans le body)
q_radps    = x(3);        % Vitesse de tangage de l'avion (dans le body)
theta_rad  = x(4);        % Angle de tangage de l'avion
altitude_m = x(5);        % Altitude de l'avion

%%% Recuperation de la condition de vol actuelle
xcg_perc   = conditions.xcg_perc;
zcg_m      = conditions.zcg_m;
masse_kg   = conditions.masse_kg;
Iyy_Kgm2   = conditions.Iyy_kgm2;

delev_rad  = conditions.delev_rad;
dflaps     = conditions.dflaps;
dstab_rad  = conditions.dstab_rad;
fn_n       = conditions.fn_n;

%%%% Mise en scene des analyses dynamiques (voir laboratoire 5)
if strcmpi(mode, 'short period')
    % Preparation pour le mode short period
    % voir laboratoire 5
elseif strcmpi(mode, 'phugoid')
    % Preparation pour le mode phugoid
    % voir laboratoire 5
end

%%% NE PAS TOUCHER CETTE PARTIE
if ~exist('uv_mps', 'var')
	% Composantes du vent dans le repère avion
    uv_mps = 0;
    wv_mps = 0;
end

%%% Calcul des composantes de la vitese vraie
ua_mps =  % fonction de ub et uv
wa_mps =  % fonction de wb et wv

tas_mps = 

%%% Calcul de l'angle alpha


%%% Hypothese alpha_dot = 0 (NE PAS RETIRER !)
alpha_dot = 0;

%%% Calcul des donnees atmospheriques
% Nombre de Mach

% Pression dynamique

%%% Calcul des coefficients
% Dans le repere de stabilite

% Dans le repere de l'avion

%%% Calcul des forces qui s'applique sur l'avion


%%% Calcul des acceleration de l'avion
% Calcul de u_dot = x_dot(1) et w_dot = x_dot(2)
x_dot(1) = 
x_dot(2) = 

% Calcul q_dot = x_dot(3)
x_dot(3) = 

% Calcul de theta_dot = x_dot(4)
x_dot(4) = 

% Calcul de h_dot = x_dot(5)
x_dot(5) = 

end