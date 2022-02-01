% Name:            compareExp2v3.m
% Description:    compare data of participants from Exp3 and
%                       data of matched participants from Exp2. 
% Autor:             Jiao Wu
% Date:              Jan. 1, 2022

function dataOut = compareExp2v3
try
    close all;
    clc;
    clear;
    
    % load datasets from Exp 2 and 3
    load('Exp2_AllData.mat');
    dataExp2 = AllData;
    load('Exp3_AllData.mat');
    dataExp3 = AllData;
    
    % parameters
    Exp2.subPair = 16;
    Exp3.subEachSide = 8;
    subNum = 16; % subNum after combined Exp2 and 3
    
    % acquire datasets for experiment 2 and 3
    dataCombine2 = dataCombine(generateOriginalDataset(dataExp2, 'Exp2'), Exp2.subPair);
    dataCombine3 = dataCombine(generateOriginalDataset(dataExp3, 'Exp3'), 0); % subIdx need no change
    
    %% paired participants from Exp2 & Exp3 for a comparable mean RT on Epoch 1
    % calculate mean RT on Epoch 1 for each participants in Exp2 and Exp3
    trainLeft2_ep = grpstats(dataExp2.train.validLeft, {'NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    trainRight2_ep = grpstats(dataExp2.train.validRight, {'NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    Rt2_ep1 = [trainLeft2_ep.mean_RT1(1:Exp2.subPair); trainRight2_ep.mean_RT2(1:Exp2.subPair)];
    [rt2, idx2] = sort(Rt2_ep1);
    
    trainLeft3_ep = grpstats(dataExp3.train.valid(dataExp3.train.valid.RT1 > 0, :), ...
        {'NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    trainRight3_ep = grpstats(dataExp3.train.valid(dataExp3.train.valid.RT2 > 0, :), ...
        {'NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    Rt3_ep1 = [trainLeft3_ep.mean_RT1(1:Exp3.subEachSide); trainRight3_ep.mean_RT2(1:Exp3.subEachSide)];
    [rt3, idx3] = sort(Rt3_ep1);
    
    % plot mean RT on Epoch 1, and match participants from Exp2 and Exp3
    figure; hold on;
%     plot(sort(Rt2_ep1), 'k-*');
    plot(sort(Rt3_ep1), 'b-^');
    % find index of participants from Exp2 whose mean RT in Epoch 1 was
    % comparable to that from Exp3 (match manually)
    pairedExp2subIdx = [2,3,4,6,9,11,12,16,17,18,19,21,23,25,26,32]; 
    Rt2_ep1_selected = Rt2_ep1(pairedExp2subIdx);
    Rt2_selected = sort(Rt2_ep1_selected);
    plot(sort(Rt2_selected), 'r-*');
    hold off;
    
    % get the stats for only matched participants from Exp2
    statsExp2MatchedPar =  grpstats(dataCombine2(ismember(dataCombine2.NSub, pairedExp2subIdx),:), ...
        {'New','NE','NSub','Exp'},{'mean','numel'}, 'datavars',{'meanRT'});
    
    % compare Exp2 and 3
    [meanRT4plot, semRT4plot, spssMatchedPar] = ...
        compareExp2n3(statsExp2MatchedPar, dataCombine3, subNum, 'wth');
    dataOut.forSpss.MatchedPar2vsAllPar3 =dataset({[ [2*ones(subNum,1), spssMatchedPar(:, 1:12)]; ... % Exp2
        [3*ones(subNum,1), spssMatchedPar(:, (1:12)+12)] ], ... % Exp3;
        'Exp', 'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6',     'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6'} );
    
    % plot mean RT for data from Exp2 and 3
    plotFig(meanRT4plot, semRT4plot, [1.05, 1.45]);
    
catch ME
    disp(ME.message);
end
end

function [meanRT4plot, semRT4plot, spssArray] = compareExp2n3(statsExp2, dataCombine3, subNum, withinSub)
%% combine data from Exp 2 and 3
statsExp2n3 = dataset( {[statsExp2.New  statsExp2.NE   statsExp2.NSub   statsExp2.mean_meanRT   statsExp2.Exp; ...
    dataCombine3.New  dataCombine3.NE  dataCombine3.NSub  dataCombine3.meanRT  dataCombine3.Exp], ...
    'New', 'NE', 'NSub','meanRT', 'Exp'});

%% compare RT and CC for Exp 2 & 3
% mean RT for each participant
meanRT = grpstats(statsExp2n3, {'Exp', 'New','NE','NSub'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
% Exp2: o0e1-6  o1e1-6
% Exp3: o0e1-6  o1e1-6
spssArray = reshape(meanRT.mean_meanRT, subNum, []);

switch withinSub
    case 'btw' % plot between-subject error bars
        % mean RT for each condition
        meanRTAll = grpstats(statsExp2n3, {'Exp', 'New','NE'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
        % Exp2: o0e1-6  o1e1-6
        % Exp3: o0e1-6  o1e1-6
        meanRT4plot = transpose([meanRTAll.mean_meanRT(1:12), meanRTAll.mean_meanRT(13:24)]);
        semRT4plot = transpose([meanRTAll.sem_meanRT(1:12), meanRTAll.sem_meanRT(13:24)]);
    case 'wth' % plot with within-subject error bar
        adjustRT = adjustErrorBar(spssArray(:,1:12), subNum);
        adjustRT = [adjustRT; adjustErrorBar(spssArray(:,13:24), subNum)];
        [mRTFP, eRTFP] = grpstats(adjustRT, {meanRT.Exp, meanRT.New, meanRT.NE}, {'mean', 'sem'});
        meanRT4plot = transpose(reshape(mRTFP, [], 2));
        semRT4plot = transpose(reshape(eRTFP, [], 2));
end

end

function dataOut = dataCombine(data, subPair)
% acquire and combine dataset
trainLeft = grpstats(data.trainLeft, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
trainRight = grpstats(data.trainRight, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
testLeft = grpstats(data.testLeft, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
testRight = grpstats(data.testRight, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
combinedMatrix = [trainLeft.New1     trainLeft.NE    trainLeft.NSub   trainLeft.mean_RT1; ...
    trainRight.New1   trainRight.NE     trainRight.NSub+subPair    trainRight.mean_RT2; ...
    testLeft.New1      testLeft.NE        testLeft.NSub                    testLeft.mean_RT1; ...
    testRight.New1    testRight.NE      testRight.NSub+subPair      testRight.mean_RT2];
dataOut = dataset( {[combinedMatrix, data.expNo*ones(size(combinedMatrix,1),1)], ...
    'New', 'NE', 'NSub','meanRT','Exp'});
end

function dataOut = generateOriginalDataset(data, expName)
% generate original dataset for specific experiments
switch expName
    case 'Exp2'
        dataOut.trainLeft = data.train.validLeft;
        dataOut.trainRight = data.train.validRight;
        dataOut.testLeft = data.test.validLeft;
        dataOut.testRight = data.test.validRight;
        dataOut.expNo = 2;
    case 'Exp3'
        dataOut.trainLeft = data.train.valid(data.train.valid.RT1 > 0, :);
        dataOut.trainRight = data.train.valid(data.train.valid.RT2 > 0, :);
        dataOut.testLeft = data.test.valid(data.test.valid.RT1 > 0, :);
        dataOut.testRight = data.test.valid(data.test.valid.RT2 > 0, :);
        dataOut.expNo = 3;
end
end

function plotFig(meanRT4plot, semRT4plot, yAxisLim)
% plot RT for Exp2 and 3 respectively
figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
fill([5.5 6.5 6.5 5.5], [yAxisLim(1)+0.01, yAxisLim(1)+0.01, yAxisLim(2)-0.14, yAxisLim(2)-0.14], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
% Exp2
errbar_old_e2 = errorbar([1:5]-0.1, meanRT4plot(1,[1:5]),semRT4plot(1,[1:5]), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errorbar(5.75, meanRT4plot(1,6),semRT4plot(1,6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errbar_new_e2 = errorbar([1:5]-0.1, meanRT4plot(1,[1:5]+6),semRT4plot(1,[1:5]+6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
errorbar(5.9, meanRT4plot(1,6+6),semRT4plot(1,6+6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
% Exp3
errbar_old_e3 = errorbar([1:5]+0.1, meanRT4plot(2,[1:5]),semRT4plot(2,[1:5]), 'b-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
errorbar(6.15, meanRT4plot(2,6),semRT4plot(2,6), 'b-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b');
errbar_new_e3 = errorbar([1:5]+0.1, meanRT4plot(2,[1:5]+6),semRT4plot(2,[1:5]+6), 'b-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'w');
errorbar(6.3, meanRT4plot(2,6+6),semRT4plot(2,6+6), 'b-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'w');
legend('boxoff');
legend([errbar_old_e2, errbar_new_e2, errbar_old_e3, errbar_new_e3], ...
    'Repeated, Exp2', 'Non-repeated, Exp2',...
    'Repeated, Exp3', 'Non-repeated, Exp3', 'location', 'NorthEast');
xlim([0.5 6.5]);
ylim([yAxisLim(1), yAxisLim(2)]);
set(gca, 'YTick', yAxisLim(1)+0.05:0.1:yAxisLim(2)-0.1);
ylabel('Reaction time (sec)');
xlabel('Epochs');
hold off;
end