%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
%addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules'));
%% % Debut de vos etudes
avion = f_loadAircraftData;

h = 20000
m = 100000
zcg_m = 0
alpha = 5
theta_deg = 5;
theta_deg = m_convert.f_angle(alpha_deg, 'deg', 'rad');
Vt = 240
fn_n = 15000
xcg_perc = 0.1