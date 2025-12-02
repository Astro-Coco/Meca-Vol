%%% Initialisation
clc;
clear;
close all;

%%% Organisation des repertoires
addpath('Aircraft/', 'Modules/');
thisFileDir = fileparts(mfilename('fullpath'));
addpath(fullfile(thisFileDir, 'Aircraft'));
addpath(fullfile(thisFileDir, 'Modules'));
%% Debut de vos etudes
avion = f_loadAircraftData;

open("Fichiers Matlab\AER3640_ctrl_avion_R2015b.slx")