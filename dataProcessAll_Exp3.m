%% xuelian zang
%% 10/05/2013
%% analyse all the data
%%
function dataProcessAll_Exp3()

try
    close all;
    clc;
    clear;
    Exp.nEp = 5;
    Exp.nEpT = 1;
    Exp.nTB = 5;
    Exp.nB = 25;
    Exp.nTrl = 24;
    Exp.numOfBlock.TrainEpoch = 5;
    Exp.numOfBlock.TransferEpoch = 5;
    
    
    RTTh.low = 0.2;
    RTTh.ratio = 2.5;
    RTTh.high_RT1 = 0; % 0: discard with ratio
    RTTh.high_RT2 = 0;
    
    numOfDisTrials = 0;
    
    %% for all subjects
    Exp.subNum = 16; %% 12 with positive cueing, 3 with negative cueing
    
    %% load Exp3 behavior data  
    load('Exp3_AllData.mat');
    data = AllData;
    
    dataOutAll = dataProcessValid_Exp3(data,  Exp);
    
    %%error and miss together
    errData1 = calError(data, Exp);
    mErrRates = mean(mean(errData1.errSpssArray,2))
    
    mErrRatesTrain = mean(mean(errData1.errSpssArray(:,[1:5 7:11]),2))
    mErrRatesTransfer = mean(mean(errData1.errSpssArray(:,[6 12]),2))
    
    mDisRates = mean(mean(errData1.disSpssArray,2))
    
    %% hitFalseArray1: hitLeftSub, FALeft, hitRight, FARight
    %% d: leftSub RightSub
    [hitFalseArray, d] = procRec(data);
    
catch ME
    disp(ME.message);
end