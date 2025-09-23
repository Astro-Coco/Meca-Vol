function rho_kgpm3 = f_masse_volumique(altitude_m)
%F_MASSE_VOLUMIQUE Calcule la masse volumique de l'air pour une altitude
%   donnee. Le modele utilise dans cette fonction repose sur le modele ISA
%   (International Standard Atmosphere).
%
% Syntax:
%   rho_kgpm3 = f_masse_volumique(altitude_m)
%
% Inputs:
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - rho_kgpm3  : masse volumique de l'air en kg/m3
%
% Example:
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   rho_kgpm3 = m_atmos.f_masse_volumique(altitude_m);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Masse volumique de l'air au niveau de la mer (h = 0)
rho0_kgpm3 = 1.2250;
km = altitude_m/1000;

if km <= 11
    ratio = (1-(2.2558e-5)*altitude_m)^5.25588;
    rho_kgpm3 = ratio*rho0_kgpm3;
elseif km > 11 && km <= 20
    ratio = 0.29708*exp((-1.5768e-4)*(altitude_m-11000));
    rho_kgpm3 = ratio*rho0_kgpm3;
else
    rho_kgpm3 = NaN;
    warning('Altitude outisde of supported ranges')



end