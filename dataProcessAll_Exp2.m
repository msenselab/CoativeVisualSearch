%% xuelian zang
%% 10/05/2013
%% analyse all the data
%% 
function dataProcessAll_Exp2

try
    close all;
    clc;
    clear all;
    Exp.nEp = 5;
    Exp.nEpT = 1;
    Exp.nTB = 5;
    Exp.nB = 25;
    Exp.nTrl = 24;

    Exp.subNum = 16;
    
    load('Exp2_AllData.mat');
    data = AllData;
    dataOutAll = dataProcessValid(data,  Exp);


catch ME
    disp(ME.message);
end