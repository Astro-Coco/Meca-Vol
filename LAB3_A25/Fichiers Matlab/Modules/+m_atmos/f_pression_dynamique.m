function qbar_pa = f_pression_dynamique(tas_mps, altitude_m)
%F_PRESSION_DYNAMIQUE Calcule la pression dynamique de l'avion pour une
%   vitesse et une altitude donnee. Cette fonction utilise la fonction
%   f_masse_volumique du module atmos pour calculer la masse volumique de
%   l'air a l'altitude donne.
%
% Syntax:
%   qbar_pa = f_pression_dynamique(tas_mps, altitude_m)
%
% Inputs:
%   - tas_mps    : vitesse vraie de l'avion en m/s
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - qbar_pa    : pression dynamique en Pascal
%
% Example:
%   tas_mps = m_convert.f_velocity(250, 'kts', 'm/s');
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   qbar_pa = m_atmos.f_pression_dynamique(tas_mps, altitude_m)
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

qbar_pa = 0.5*m_atmos.f_masse_volumique(altitude_m)*tas_mps^2;

end