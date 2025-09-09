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

km = altitude_m/1000;

if km <= 11
    P_pa = ((1-2.2558e-5*altitude_m)^5.25588)*P0_pa;
    delta = P_pa/P0_pa;
elseif km > 11 
    P_pa = (0.22336*exp(-1.5768e-4*(altitude_m-11000)))*P0_pa;
    delta = P_pa/P0_pa;
end