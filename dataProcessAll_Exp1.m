%% xuelian zang
%% 10/05/2013
%% analyse all the data
%% 
function dataProcessAll_Exp1()

try
    close all
    clc
    clear all
    Exp.nEp = 5;
    Exp.nEpT = 1;
    Exp.nTB = 5;
    Exp.nTrl = 24;
    Exp.nB = 25;
    Exp.subNum = 16; 


    load('Exp1_AllData.mat');
    data = AllData;
    
    %generate a data set for SPSS Statistics
    dataOutAll = dataProcessValid_Exp1(data,  Exp);   
      
catch ME
    disp(ME.message);
end