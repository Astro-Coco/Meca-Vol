function [clb, cdb, cmb] = f_stab2body(cls, cds, cms, alpha_rad)
%F_STAB2BODY permet de projeter les coefficients aerodynamiques de l'avion
%du repere stabilite vers le repere avion.
%
% Syntax:
%   [clb, cdb, cmb] = f_stab2body(cls, cds, cms, alpha_rad);
%
% Inputs:
%   - cls           : Coefficient de portance dans le stabilite         [-]
%   - cds           : Coefficient de trainee dans le stabilite          [-]
%   - cms           : Coefficient de moment dans le stabilite           [-]
%   - alpha_rad     : Angle d'incidence de l'aile en radian           [rad]
%
% Outputs:
%   - clb           : Coefficient de portance dans le body              [-]
%   - cdb           : Coefficient de trainee dans le body               [-]
%   - cmb           : Coefficient de moment dans le body                [-]
%
% Example:
%   cls = 0.5; cds = 0.02; cms = 0.001;
%   alpha_rad = m_convert.f_angle(10, 'deg', 'rad');
% 
%   [clb, cdb, cmb] = m_aero.f_stab2body(cls, cds, cms, alpha_rad);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by H.bensalah
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$

cdb = cds*cos(alpha_rad) - cls*sin(alpha_rad);
clb = cds*sin(alpha_rad) + cls*cos(alpha_rad);
cmb = cms;


end