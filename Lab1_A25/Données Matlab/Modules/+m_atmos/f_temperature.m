function T_k  = f_temperature(altitude_m)
%F_TEMPERATURE Calcule la temperature statique de l'air pour une altitude
%   donnee. Le modele utilise dans cette fonction repose sur le modele ISA
%   (International Standard Atmosphere).
%
% Syntax:
%   T_k  = f_temperature(altitude_m)
%
% Inputs:
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - T_k        : temperature statique de l'air en K
%
% Example:
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   T_k = m_atmos.f_temperature(altitude_m);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Temperature au niveau de la mer (h=0 m)
T0_k = 288.15;
km = altitude_m/1000;

if km <= 11
    T_k = (1-2.2558e-5 * altitude_m)*T0_k;
elseif km > 11 
    T_k = 0.75187*T0_k;


end