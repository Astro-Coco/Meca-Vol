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
masse_kg = 100000
zcg_m = 0
alpha = 5
theta_deg = 5;
theta_deg = m_convert.f_angle(alpha_deg, 'deg', 'rad');
Vt = 240
fn_n = 15000
xcg_perc = 0.1



function [fx_n, fz_n, my_nm] = f_forces(clb, cdb, cmb, theta_rad, xcg_perc, ...
    zcg_m, masse_kg, qbar_pa, fn_n, avion)

    