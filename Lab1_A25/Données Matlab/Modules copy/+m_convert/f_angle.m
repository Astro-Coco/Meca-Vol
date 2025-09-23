function output = f_angle(input, unit_in, unit_out)
%F_ANGLE Convert from angle units to desired angle units.
%   The function "F_ANGLE" is a sub-routine of the convert module. This
%   function convert a angle units (i.e rad or deg) to desired angle unit
%   (i.e deg or rad). 
%
% Syntax:
%   output = m_convert.f_angle(input, unit_in, unit_out);
%
% Inputs:
%   - input      : angle value that the function is to convert,
%   - unit_in    : specified input angle unit as string,
%   - unit_out   : specified output angle unit as string.
% Outputs:
%   - output     : angle value that the function has converted.
%
% Supported unit strings are:
%   'rad'        : Radian
%   'deg'        : Degree
%
% Example:
%   angle_deg = 10;
%   unit_in = 'deg';
%   unit_out = 'rad';
%
%   angle_rad = m_convert.f_angle(angle_deg, unit_in, unit_out);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$

%%% Create conversion table
conversion_table = {[],'deg', 'rad'; ...
    'deg',1, pi/180;...
    'rad', 180/pi, 1};

%%% Find the corresponding unit in the table
for i = 1 : length(conversion_table(:,1))
    if strcmpi(conversion_table{i,1}, unit_in)
        idx_line = i;
    end
end

for i = 1 : length(conversion_table(1,:))
    if strcmpi(conversion_table{1,i}, unit_out)
        idx_column = i;
    end
end

%%% Compute the conversion factor
slope = conversion_table{idx_line, idx_column};

%%% Compute the output
output = input.*slope;

%%% End of the funtion
end