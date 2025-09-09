function a_mps = f_vitesse_son(altitude_m)
%F_VITESSE_SON Calcule la vitesse du son pour une altitude donnee. Le 
%   modele utilise dans cette fonction repose sur le modele ISA
%   (International Standard Atmosphere).
%
% Syntax:
%   a_mps = f_vitesse_son(altitude_m)
%
% Inputs:
%   - altitude_m : altitude de l'avion en metre
% Outputs:
%   - a_mps  : vitesse du son en m/s
%
% Example:
%   altitude_m = m_convert.f_length(10000, 'ft', 'm');
%
%   a_mps = m_atmos.f_vitesse_son(altitude_m);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$
% $ Revision: 2.0 $ $Date: XX/XX/XXXX by "Nom Etudiants"$

%%% Constante des gaz parfait
R_air = 287.058;
gamma_air = 1.4;

end