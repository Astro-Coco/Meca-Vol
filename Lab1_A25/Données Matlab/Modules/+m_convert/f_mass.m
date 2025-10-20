function output = f_mass( input, unit_in, unit_out )
%F_MASS Convert from mass units to desired mass units.
%   The function "F_MASS" is a sub-routine of the convert module. This
%   function convert a mass unit (i.e lbm) to desired mass unit (i.e Kg).
%
% Syntax:
%   output = m_convert.f_mass(input, unit_in, unit_out);
%
% Inputs:
%   - input      : mass value that the function is to convert,
%   - unit_in    : specified input mass unit as string,
%   - unit_out   : specified output mass unit as string.
% Outputs:
%   - output     : mass value that the function has converted.
%
% Supported unit strings are:
%   'lbm'        : Pound mass
%   'kg'         : Kilograms
%   'slug'       : slugs
%
% Example:
%   mass_lbm = 32000;
%   unit_in = 'lbm';
%   unit_out = 'kg';
%
%   mass_kg = m_convert.f_mass(mass_lbm, unit_in, unit_out);
%
% Reference(s)
%   NONE
%
% Copyright 2016-2017 LARCASE - Laboratory of Applied Research in Active
% Controls, Avionics and AeroServoElasticity.
% $ Creation by G. Ghazi$
% $ Revision: 1.0 $ $Date: 06/29/2017 by G. Ghazi$

%%% Create conversion table
conversion_table = {[],'lbm','kg','slug';...
    'lbm',1,0.453592370000000,0.0310809502508065;...
    'kg',2.20462262184878,1,0.0685217660314843;...
    'slug',32.1740484744045,14.5939029000000,1};

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

%%% Compute the factor conversion
slope = conversion_table{idx_line, idx_column};

%%% Compute the output
output = input.*slope;

%%% End of function
end