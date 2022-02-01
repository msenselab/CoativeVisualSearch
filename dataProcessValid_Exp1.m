%Name:                dataProcessValid.m
%
%Autor:               Xuelian Zang
%Description:         process valid data for selected subjects with stable
%performance
%
%Date:                22/09/2015
function dataOut = dataProcessValid_Exp1(dataIn,Exp)
try
    % for the training session
    trainMeanSub = grpstats(dataIn.train.valid, {'New','NE','NSub'},{'mean','sem','numel'}, 'datavars','RT');
    trainMeanAllCombine = grpstats(trainMeanSub, {'New','NE'},{'mean','sem','numel'}, 'datavars','mean_RT');
    % o1E1 o1E2 o1E3 o1E4 o1E5    o0E1 o0E2 o0E3 o0E4 o0E5
    dataOut.forSpss.trainCombineCol = dataset({reshape(trainMeanSub.mean_RT, Exp.subNum, []),...
        'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5',    'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5'} );
    
    % precessing transfer data
    testEp6MeanSub = grpstats(dataIn.test.valid(dataIn.test.valid.NE == 6,:), {'New','NE','NSub'},{'mean','sem','numel'}, 'datavars','RT');
    testEp6MeanAll = grpstats(testEp6MeanSub, {'New','NE'},{'mean','sem','numel'}, 'datavars','mean_RT');
    dataOut.forSpss.testEp6 = dataset({reshape(testEp6MeanSub.mean_RT, Exp.subNum, []),'old','new'});
    
    %% plot in published version (between-subject error bar)
    figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
%     title('Solo condition');
    idxOld = (trainMeanAllCombine.New == 0);
    fill([5.5 6.5 6.5 5.5], [1.06 1.06 1.38 1.38], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
    errbar_old = errorbar(1:5, trainMeanAllCombine.mean_mean_RT(idxOld, :), trainMeanAllCombine.sem_mean_RT(idxOld, :), ...
        'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    errorbar(6, testEp6MeanAll.mean_mean_RT(1),testEp6MeanAll.sem_mean_RT(1), ...
        'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    idxNew = (trainMeanAllCombine.New == 1 );
    errbar_new = errorbar(1:5, trainMeanAllCombine.mean_mean_RT(idxNew, :), trainMeanAllCombine.sem_mean_RT(idxNew, :), ...
        'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    errorbar(6, testEp6MeanAll.mean_mean_RT(2),testEp6MeanAll.sem_mean_RT(2), ...
        'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    legend('boxoff');
    legend([errbar_old, errbar_new], 'Repeated', 'Non-repeated', 'location', 'NorthEast');
    xlim([0.5 6.5]);
    ylim([1.05 1.45]);
    set(gca, 'YTick', 1.1:0.1:1.5);
    ylabel('Reaction time (sec)');
    xlabel('Epochs');
    hold off;
    
    %% for error bar within-subject design
    spssRTArrayTrain = reshape(trainMeanSub.mean_RT, Exp.subNum, []);
    spssRTArrayTest = reshape(testEp6MeanSub.mean_RT, Exp.subNum, []);
    spssRTArray = [spssRTArrayTrain(:,1:5) spssRTArrayTest(:,1) spssRTArrayTrain(:,6:10) spssRTArrayTest(:,2)];
    adjustRT = adjustErrorBar(spssRTArray, Exp.subNum);
    [m, e] = grpstats(adjustRT, {[zeros(Exp.subNum*(Exp.nEp+Exp.nEpT),1);ones(Exp.subNum*(Exp.nEp+Exp.nEpT),1)],...
        repmat(reshape(repmat(1:6, Exp.subNum,1),[],1),2,1)}, {'mean', 'sem'});
    
    % plot within-subject error bar
    figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
%     title('Solo condition');
    fill([5.5 6.5 6.5 5.5], [1.06 1.06 1.38 1.38], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
    errbar_old = errorbar(1:5, m(1:5), e(1:5), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    errorbar(6, m(6),e(6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    errbar_new = errorbar(1:5, m(7:11), e(7:11), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    errorbar(6, m(12), e(12), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    legend('boxoff');
    legend([errbar_old, errbar_new], 'Repeated', 'Non-repeated', 'location', 'NorthEast');
    xlim([0.5 6.5]);
    ylim([1.05 1.45]);
    set(gca, 'YTick', 1.1:0.1:1.5);
    ylabel('Reaction time (sec)');
    xlabel('Epochs');
    hold off;
    
    
catch ME
    disp(ME.message);
end