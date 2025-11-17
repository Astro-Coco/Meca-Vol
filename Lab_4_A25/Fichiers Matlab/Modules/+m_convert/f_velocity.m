function output = f_velocity( input, unit_in, unit_out)
%F_VELOCITY Convert from velocity units to desired velocity units.
%   The function "F_VELOCITY" is a sub-routine of the convert module. This
%   function convert a velocity unit (i.e m/s or kts) to desired velocity
%   unit (i.e km/h or mph).
%
% Syntax:
%   output = m_convert.f_velocity(input, unit_in, unit_out);
%
% Inputs:
%   - input      : velocity value that the function is to convert,
%   - unit_in    : specified input velocity unit as string,
%   - unit_out   : specified output velocity unit as string.
% Outputs:
%   - output     : velocity value that the function has converted.
%
% Supported unit strings are:
%   'ft/s'       : feet per second
%   'm/s'        : meters per second
%   'km/s'       : kilometers per second
%   'in/s'       : inches per second
%   'km/h'       : kilometers per hour
%   'mph'        : miles per hour
%   'kts'        : knots
%   'ft/min'     : feet per minute
%
% Example:
%   velocity_kts = 100;
%   unit_in = 'kts';
%   unit_out = 'm/s';
%
%   velocity_mps = m_convert.f_velocity(velocity_kts, unit_in, unit_out);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$

%%% Create conversion table
conversion_table = {[] 'ft/s' 'm/s' 'km/s' 'in/s' 'km/h' 'mph' 'kts' 'ft/min';
    'ft/s' 1 0.304800000000000 0.000304800000000000 12.0000000000000 1.09727999999991 0.681818181818182 0.592483801296408 60;
    'm/s' 3.28083989501312 1 0.00100000000000000 39.3700787401575 3.59999999999971 2.23693629205440 1.94384449244228 196.850393700787;
    'km/s' 3280.83989501312 1000 1 39370.0787401575 3599.99999999971 2236.93629205440 1943.84449244228 196850.393700787;
    'in/s' 0.0833333333333333 0.0254000000000000 2.54000000000000e-05 1 0.0914399999999927 0.0568181818181818 0.0493736501080340 5.00000000000000;
    'km/h' 0.911344415281496 0.277777777777800 0.000277777777777800 10.9361329833780 1 0.621371192237384 0.539956803456233 54.6806649168898;
    'mph' 1.46666666666667 0.447040000000000 0.000447040000000000 17.6000000000000 1.60934399999987 1 0.868976241901399 88;
    'kts' 1.68780985709974 0.514444444444000 0.000514444444444000 20.2537182851969 1.85199999999825 1.15077944802255 1 101.268591425984;
    'ft/min' 0.0166666666666667 0.00508000000000000 5.08000000000000e-06 0.200000000000000 0.0182879999999985 0.0113636363636364 0.00987473002160681 1};

% Find the corresponding unit in the table
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

%%% Compute the factor conversion
slope = conversion_table{idx_line, idx_column};

%%% Compute the output
output = input.*slope;

%%% End of function
end
