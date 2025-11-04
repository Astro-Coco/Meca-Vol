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
%%% Conversion de la variable altitude_m en [ft]
altitude_ft = m_convert.f_length(altitude_m, 'm', 'ft');

%%% Calcul du ratio de masse volumique 
if altitude_ft <= 36089.24
    sigma = (1 - 6.8756e-6 .* altitude_ft) .^ 4.25588;
else
    sigma = 0.29708 .* exp(-4.806e-5 .* (altitude_ft - 36089.24));
end
rho_kgpm3=rho0_kgpm3*sigma;

end