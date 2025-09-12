function mach_nb = f_nombre_mach(tas_mps, altitude_m)
%F_NOMBRE_MACH Calcule le nombre de Mach de l'avion a partir de l'altitude
%   et de la vitesse vraie de l'avion. Le modele utilise dans cette 
%   fonction repose sur le modele ISA (International Standard Atmosphere).
%
% Syntax:
%   mach_nb = f_nombre_mach(tas_mps, altitude_m)
%
% Inputs:
%   - tas_mps    : vitesse vraie de l'avion en m/s
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - mach_nb    : nombre de Mach de l'avion
%
% Example:
%   tas_mps = m_convert.f_velocity(250, 'kts', 'm/s');
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   mach_nb = m_atmos.f_nombre_mach(tas_mps, altitude_m);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$


mach_nb = tas_mps/m_atmos.f_vitesse_son(altitude_m);

end