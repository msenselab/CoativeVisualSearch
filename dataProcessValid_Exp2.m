% Name:                dataProcessValid.m
%
% Autor:               Xuelian Zang
% Description:         process valid data for selected subjects with stable
% performance
%
% Date:                22/09/2015
function dataOut = dataProcessValid_Exp2(dataIn,Exp)
try
    %% for the training session
    trainSubLeft = grpstats(dataIn.train.validLeft, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    trainSubRight = grpstats(dataIn.train.validRight, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    % o1E1 o1E2 o1E3 o1E4 o1E5    o0E1 o0E2 o0E3 o0E4 o0E5
    dataOut.forSpss.trainRTLeftCombine = dataset({reshape(trainSubLeft.mean_RT1, Exp.subNum, []),...
        'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5',    'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5'} );
    dataOut.forSpss.trainRTRightCombine = dataset({reshape(trainSubRight.mean_RT2, Exp.subNum, []),...
        'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5',    'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5'} );
    
    testSubLeft = grpstats(dataIn.test.validLeft, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    testSubRight = grpstats(dataIn.test.validRight, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    dataOut.forSpss.testEp6RTLeft = dataset({reshape(testSubLeft.mean_RT1, Exp.subNum, []),'old','new'});
    dataOut.forSpss.testEp6RTRight = dataset({reshape(testSubRight.mean_RT2, Exp.subNum, []),'old','new'});
    
    % treat left and right participants as different subjects and combine their data together
    dataCombine = dataset( {[trainSubLeft.New1     trainSubLeft.NE    trainSubLeft.NSub     trainSubLeft.mean_RT1; ...
        trainSubRight.New1   trainSubRight.NE  trainSubRight.NSub+Exp.subNum  trainSubRight.mean_RT2; ...
        testSubLeft.New1        testSubLeft.NE      testSubLeft.NSub                                testSubLeft.mean_RT1; ...
        testSubRight.New1     testSubRight.NE   testSubRight.NSub+Exp.subNum     testSubRight.mean_RT2;], ...
        'New', 'NE', 'NSub','meanRT'});
    
    tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});
    dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum*2, []),...
        'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6',     'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6'} );
    %     dataCombineMean = grpstats(dataCombine, {'New','NE'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
    %     plotFig1(dataCombineMean.mean_meanRT, dataCombineMean.sem_meanRT);
    
    % adjust RT for within-subject error bar
    spssRTArray = reshape(tmp.mean_meanRT, Exp.subNum*2, []);
    adjustRT = adjustErrorBar(spssRTArray, Exp.subNum*2);
    [m, e] = grpstats(adjustRT, {tmp.New, tmp.NE}, {'mean', 'sem'});
    plotFig1(m,e); % plot within-subject error bar
    
	%% check if faster actor acquired contextual memory because of an extra exposure time after response
    %% Way 1: classified into faster and slower group by Faster-Rate Difference (FRD)
	% Step1: descriptive information of Faster-Rate Difference (FRD)
    % a) filter out invalid data for both participants in each pair, and
    % save only trials in which responses for both partcipants are valid (paired RT data)
    load('Exp2RTTh.mat'); % RT discard threshold (M+2.5*SD) for each pair
    trainTmp = dataIn.train.validLeft(dataIn.train.validLeft.Crr2>0,:);
    for i = 1:Exp.subNum
        trainTmp(trainTmp.NSub == i & (trainTmp.RT2 > th4Par(i,2) | trainTmp.RT2 < 0.2),:) = [];
        trainTmp(trainTmp.NSub == i & (trainTmp.RT1 > th4Par(i,1) | trainTmp.RT1 < 0.2),:) = [];
    end
    
    % b) mark the faster participant for each trial
    trainTmp.deltaRT = trainTmp.RT1 - trainTmp.RT2;
    trainTmp.leftSlowTrial = zeros(size(trainTmp.deltaRT));
    trainTmp.leftSlowTrial(trainTmp.deltaRT>0) = 1; % 1 = left-slow pair, 0 = left-fast pair
    
    % c) calculate the probability of left participants being slow & FRD
    meanRT = grpstats(trainTmp, {'NSub'}, 'mean', 'dataVars', 'leftSlowTrial');
    FastRateDiff = abs(meanRT.mean_leftSlowTrial-(1-meanRT.mean_leftSlowTrial))*100;
    sortrows([1-meanRT.mean_leftSlowTrial, meanRT.mean_leftSlowTrial, FastRateDiff],3)
    
    % d) plot FRD
    figure(); set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] ); hold on;
    bar(1:16, FastRateDiff); % difference between proportions of faster-response trials in a pair
    plot(0:17,7.5*ones(1,18),'k-');
    ylabel('Faster-Rate Difference (%)');
    xlabel('Participant pairs');
    xticks(1:16);
    xlim([0,17]);
    hold off;
    
    % Step2: classified participants into frequently vs. less frequently faster groups (criteria: Faster Rate>50%)
    % a) filter out the left- and right-faster participants
    leftFasterpairIdx = meanRT.NSub(meanRT.mean_leftSlowTrial<0.5); % left-faster
    rightFasterpairIdx = meanRT.NSub(meanRT.mean_leftSlowTrial>0.5); % right-faster
    
    trainTmp.leftFasterPair = zeros(size(trainTmp.RP1));
    trainTmp.leftFasterPair(ismember(trainTmp.NSub, leftFasterpairIdx)) = 1; % 1 - left-faster pair, 0 - left-slower
    trainTmp.rightFasterPair = zeros(size(trainTmp.RP1));
    trainTmp.rightFasterPair(ismember(trainTmp.NSub, rightFasterpairIdx)) = 1; % 1 - right-faster pair, 0 - right-slower
    
    testLeft = dataIn.test.validLeft;
    testLeft.fasterSub = zeros(size(testLeft.RP1));
    testLeft.fasterSub(ismember(testLeft.NSub, leftFasterpairIdx)) = 1;
    testRight = dataIn.test.validRight;
    testRight.fasterSub = zeros(size(testRight.RP1));
    testRight.fasterSub(ismember(testRight.NSub, rightFasterpairIdx)) = 1;
    
    % b) calculate the stats for left and right participants
    trainS1 = grpstats(trainTmp, {'leftFasterPair','New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    trainS2 = grpstats(trainTmp, {'rightFasterPair','New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    testS1 = grpstats(testLeft, {'fasterSub','New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    testS2 = grpstats(testRight, {'fasterSub','New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    
    % c) combine the stats for left and right participants
    dataCombinePrp = dataset( {[trainS1.leftFasterPair    trainS1.New1   trainS1.NE   trainS1.NSub     trainS1.mean_RT1; ...
        trainS2.rightFasterPair  trainS2.New1    trainS2.NE    trainS2.NSub+Exp.subNum   trainS2.mean_RT2; ...
        testS1.fasterSub             testS1.New1     testS1.NE      testS1.NSub                              testS1.mean_RT1; ...
        testS2.fasterSub             testS2.New1     testS2.NE      testS2.NSub+Exp.subNum     testS2.mean_RT2;], ...
        'fasterSub','New', 'NE', 'NSub','meanRT'});
    
    % d) plot CC for faster and slower group
    spssCCFRDgrpTmp = grpstats(dataCombinePrp, {'New','fasterSub','NE','NSub'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
    spssCCFRDgrpTmpRt = reshape(spssCCFRDgrpTmp.mean_meanRT, Exp.subNum, []);
    spssCCFRDgrp = ( spssCCFRDgrpTmpRt(:,13:24) - spssCCFRDgrpTmpRt(:,1:12) ).*1000;
    dataOut.forSpss.CCFRDSubAll = dataset({[[zeros(Exp.subNum,1); ones(Exp.subNum,1)], [spssCCFRDgrp(:,1:6); spssCCFRDgrp(:,7:12)]], ...
        'faster', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6'} );
    cc4plot = [mean(spssCCFRDgrp,1); std(spssCCFRDgrp,1)/sqrt(Exp.subNum)];
    plotFig3FastSlowCC(cc4plot,1);
    
    %%  Way 2: classified into faster and slower group by mean RT
    % Step1: find the faster participant in each pair and mark them
    meanRT1 = grpstats(trainSubLeft, {'NSub'},{'mean','numel'}, 'datavars',{'mean_RT1'});
    meanRT2 = grpstats(trainSubRight, {'NSub'},{'mean','numel'}, 'datavars',{'mean_RT2'});
    deltaRT = meanRT1.mean_mean_RT1 - meanRT2.mean_mean_RT2;
    leftFasterIdx = find(deltaRT<0); % left-faster pair
    rightFasterIdx = find(deltaRT>0)+Exp.subNum; % right-faster pair
    tmp.fasterSub = zeros(size(tmp.New));
    tmp.fasterSub(ismember(tmp.NSub, leftFasterIdx)) = 1;
    tmp.fasterSub(ismember(tmp.NSub, rightFasterIdx)) = 1;
    
    % Step2: calculate CC for faster and slower groups
    spssRtGrpSub = grpstats(tmp, {'New','fasterSub','NE','NSub'},{'mean','sem','numel'}, 'datavars',{'mean_meanRT'});
    spssRtGrpSubAll = reshape(spssRtGrpSub.mean_mean_meanRT, Exp.subNum, []);
    % o0f0:e1~e6    o0f1:e1~e6
    % o1f0:e1~e6	o1f1:e1~e6
    spssCCArray = ( spssRtGrpSubAll(:,13:24) - spssRtGrpSubAll(:,1:12) ).*1000;
    dataOut.forSpss.CCmRTSubAll = dataset({[[zeros(Exp.subNum,1); ones(Exp.subNum,1)], [spssCCArray(:,1:6); spssCCArray(:,7:12)]], ...
        'faster', 'E1', 'E2', 'E3', 'E4', 'E5', 'E6'} );
%     cc4plot = [mean(spssCCArray,1); std(spssCCArray,1)/sqrt(Exp.subNum)];
%     plotFig3FastSlowCC(cc4plot,2);
    
    % adjust RT for within-subject error bar
    spssRtSlowGrp = [spssRtGrpSubAll(:,1:6), spssRtGrpSubAll(:,13:18)];
    spssRtFastGrp = [spssRtGrpSubAll(:,7:12), spssRtGrpSubAll(:,19:24)];
    adjustSlowGrp = reshape(adjustErrorBar(spssRtSlowGrp, Exp.subNum), Exp.subNum, []);
    adjustFastGrp = reshape(adjustErrorBar(spssRtFastGrp, Exp.subNum), Exp.subNum, []);
    adjustRtCombine = [adjustSlowGrp(:,1:6), adjustFastGrp(:,1:6), adjustSlowGrp(:,7:12), adjustFastGrp(:,7:12)];
    adjustCCArray = ( adjustRtCombine(:,13:24) - adjustRtCombine(:,1:12) ).*1000;
    adjustCC4plot = [mean(adjustCCArray,1); std(adjustCCArray,1)/sqrt(Exp.subNum)];
    plotFig3FastSlowCC(adjustCC4plot,2); % plot within-subject error bar
    
catch ME
    disp(ME.message);
end
end

function plotFig1(m, e)
figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
%     title('Joint condition');
fill([5.5 6.5 6.5 5.5], [1.11 1.11 1.43 1.43], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
errbar_old = errorbar(1:5, m(1:5), e(1:5), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errorbar(6, m(6),e(6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errbar_new = errorbar(1:5, m(7:11), e(7:11), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
errorbar(6, m(12), e(12), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
legend('boxoff');
legend([errbar_old, errbar_new], 'Repeated', 'Non-repeated', 'location', 'NorthEast');
xlim([0.5 6.5]);
ylim([1.1 1.5]);
set(gca, 'YTick', 1.1:0.1:1.5);
ylabel('Reaction time (sec)');
xlabel('Epochs');
hold off;
end


function plotFig3FastSlowCC(cc4plot, groupingMethod)
yAxisBelow = -40;
yAxisUp = 160;
% plot CC for each condition
figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83 6.83*0.7] );
bar([1:5, 6.5], transpose([cc4plot(1,[1:6]);cc4plot(1,7:12)]));
% slower participants
errorbar([1:5]-0.15, cc4plot(1,1:5), cc4plot(2,1:5),...
    'ko', 'MarkerSize', 0.1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errorbar(5.85+0.5, cc4plot(1,6), cc4plot(2,6), ...
    'ko', 'MarkerSize', 0.1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
% faster participants
errorbar([1:5]+0.15, cc4plot(1,[1:5]+6),cc4plot(2,[1:5]+6), ...
    'ko', 'MarkerSize', 0.1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
errorbar(6.15+0.5, cc4plot(1,6+6),cc4plot(2,6+6), ...
    'ko', 'MarkerSize', 0.1, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
plot(5.75*ones(2,1), [yAxisBelow, yAxisUp], 'k--');
legend('boxoff');
switch groupingMethod
    case 1 % classified participants into faster vs. slower groups by FRD
        legend('less freqently faster group', 'frequently faster group', 'location', 'NorthWest');
    case 2 % classified into faster and slower group by mean RT
        legend('slower group', 'faster group', 'location', 'NorthWest');
end
xlim([0.5 7]);
ylim([yAxisBelow, yAxisUp]);
set(gca, 'YTick', yAxisBelow:20:yAxisUp);
xticks([1:5, 6.5]);
xticklabels([1:6]);
ylabel('Contextual Cueing Effect (ms)');
xlabel('Epochs');
hold off;
end