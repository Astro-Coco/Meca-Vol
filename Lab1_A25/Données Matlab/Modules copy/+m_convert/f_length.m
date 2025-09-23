function output = f_length(input, unit_in, unit_out)
%F_LENGTH Convert from length units to desired length units.
%   The function "F_LENGTH" is a sub-routine of the convert module. This
%   function convert a length units (i.e ft or m) to desired length unit
%   (i.e ft or m). 
%
% Syntax:
%   output = m_convert.f_length(input, unit_in, unit_out);
%
% Inputs:
%   - input      : length value that the function is to convert,
%   - unit_in    : specified input length unit as string,
%   - unit_out   : specified output length unit as string.
% Outputs:
%   - output     : length value that the function has converted.
%
% Supported unit strings are:
%   'ft'         : feet
%   'm'          : meters
%   'km'         : kilometers
%   'in'         : inches
%   'mi'         : miles
%   'naut mi'    : nautical miles
%
% Example:
%   length_ft = 1000;
%   unit_in = 'ft';
%   unit_out = 'm';
%
%   length_m = m_convert.f_length(length_ft, unit_in, unit_out);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active 
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$

%%% Create conversion table
conversion_table = {[], 'ft', 'm', 'km', 'in', 'mi', 'naut mi' ; ...
    'ft',1,0.304800000000000,0.000304800000000000,12,0.000189393939393939,0.000164578833693305; ...
    'm',3.28083989501312,1,0.00100000000000000,39.3700787401575,0.000621371192237334,0.000539956803455724; ...
    'km',3280.83989501312,1000,1,39370.0787401575,0.621371192237334,0.539956803455724; ...
    'in',0.0833333333333333,0.0254000000000000,2.54000000000000e-05,1,1.57828282828283e-05,1.37149028077754e-05; ...
    'mi',5280,1609.34400000000,1.60934400000000,63360,1,0.868976241900648; ...
    'naut mi',6076.11548556430,1852,1.85200000000000,72913.3858267717,1.15077944802354,1};

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

%%% End of function
end