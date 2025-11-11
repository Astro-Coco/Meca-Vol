function P_pa = f_pression(altitude_m)
%F_PRESSION Calcule la pression statique de l'air pour une altitude
%   donnee. Le modele utilise dans cette fonction repose sur le modele ISA
%   (International Standard Atmosphere).
%
% Syntax:
%   P_pa = f_pression(altitude_m)
%
% Inputs:
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - P_pa       : pression statique de l'air en Pascal
%
% Example:
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   P_pa = m_atmos.f_pression(altitude_m);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Pression au niveau de la mer (h = 0)
P0_pa = 101325;

% %%% Conversion de la variable altitude_m en [ft]
altitude_ft = m_convert.f_length(altitude_m, 'm', 'ft');

%%% Calcul du ratio de temperature (theta)
if altitude_ft <= 36089.24
    delta = (1-altitude_ft*6.8756*1e-6)^5.25588;
else
    delta = (0.2233*exp(-4.806*1e-5*(altitude_ft-36089.24)));
end

%%% Calcul de la temperature
P_pa = delta*P0_pa;

end