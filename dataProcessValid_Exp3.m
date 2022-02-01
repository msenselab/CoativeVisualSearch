%Name:                dataProcessValid.m
%
%Autor:               Xuelian Zang
%Description:         process valid data for selected subjects with stable
%performance
%
%Date:                22/09/2015
function dataOut = dataProcessValid(dataIn,Exp)
try
    
    %plot black and white together
    trainMeanSub_RT1 = grpstats(dataIn.train.valid(dataIn.train.valid.RT1 > 0, :), {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    if ~isempty(trainMeanSub_RT1)
        trainMeanAllCombine_RT1 = grpstats(trainMeanSub_RT1, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT1'});
        %o1E1 o1E2 o1E3 o1E4 o1E5    o0E1 o0E2 o0E3 o0E4 o0E5
        subNumLeft = length(unique(trainMeanSub_RT1.NSub) );
        dataOut.forSpss.trainRTLeftCombine = dataset({reshape(trainMeanSub_RT1.mean_RT1, subNumLeft, []),...
            'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5',     'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5'} );
    end
    trainMeanSub_RT2 = grpstats(dataIn.train.valid(dataIn.train.valid.RT2 > 0, :), {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    if ~isempty(trainMeanSub_RT2)
        trainMeanAllCombine_RT2  = grpstats(trainMeanSub_RT2, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT2'});
        subNumRight = length(unique(trainMeanSub_RT2.NSub) );
        dataOut.forSpss.trainRTRightCombine = dataset({reshape(trainMeanSub_RT2.mean_RT2, subNumRight, []),...
            'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5',     'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5'} );
    end
    
    %% test session, all color instruction reversed
    testMeanSub_RT1 = grpstats(dataIn.test.valid(dataIn.test.valid.RT1 > 0, :), {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1'});
    if ~isempty(testMeanSub_RT1)
        testMeanAllCombine_RT1 = grpstats(testMeanSub_RT1, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT1'});
        dataOut.forSpss.testRTLeft = dataset({reshape(testMeanSub_RT1.mean_RT1, subNumLeft, []),'old','new'});
    end
    testMeanSub_RT2 = grpstats(dataIn.test.valid(dataIn.test.valid.RT2 > 0, :), {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
    if ~isempty(testMeanSub_RT2)
        testMeanAllCombine_RT2 = grpstats(testMeanSub_RT2, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT2'});
        dataOut.forSpss.testRTRight = dataset({reshape(testMeanSub_RT2.mean_RT2, subNumRight, []),'old','new'});
    end
    
    if ~isempty(testMeanSub_RT1) &&  ~isempty(testMeanSub_RT2)
        %combine the left and right participants together
        dataCombine = dataset( {[ trainMeanSub_RT1.New1     trainMeanSub_RT1.NE        trainMeanSub_RT1.NSub       trainMeanSub_RT1.mean_RT1; ...
            trainMeanSub_RT2.New1      trainMeanSub_RT2.NE        trainMeanSub_RT2.NSub       trainMeanSub_RT2.mean_RT2; ...
            testMeanSub_RT1.New1       testMeanSub_RT1.NE         testMeanSub_RT1.NSub        testMeanSub_RT1.mean_RT1; ...
            testMeanSub_RT2.New1       testMeanSub_RT2.NE         testMeanSub_RT2.NSub        testMeanSub_RT2.mean_RT2;], ...
            'New', 'NE', 'NSub','meanRT'});
        tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});
        dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum, []),...
            'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6',    'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6'} );
    elseif ~isempty(testMeanSub_RT1)
        %combine the left and right participants together
        dataCombine = dataset( {[ trainMeanSub_RT1.New1     trainMeanSub_RT1.NE        trainMeanSub_RT1.NSub       trainMeanSub_RT1.mean_RT1; ...
            testMeanSub_RT1.New1       testMeanSub_RT1.NE         testMeanSub_RT1.NSub        testMeanSub_RT1.mean_RT1;], ...
            'New', 'NE', 'NSub','meanRT'});
        tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});
        dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum, []),...
            'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6',      'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6'} );
    else
        dataCombine = dataset( {[trainMeanSub_RT2.New2      trainMeanSub_RT2.NE        trainMeanSub_RT2.NSub       trainMeanSub_RT2.mean_RT2; ...
            testMeanSub_RT2.New1       testMeanSub_RT2.NE         testMeanSub_RT2.NSub        testMeanSub_RT2.mean_RT2;], ...
            'New', 'NE', 'NSub','meanRT'});
        tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});
        dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum, []),...
            'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6',      'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6'} );
    end
    
%     dataCombineMean = grpstats(dataCombine, {'New','NE'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
    
    %% plot in published version (between-subject error bar)
%     figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
%     title('Solo condition');
%     fill([5.5 6.5 6.5 5.5], [1.01 1.01 1.43 1.43], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
%     errbar_old = errorbar(1:5, dataCombineMean.mean_meanRT(1:5),dataCombineMean.sem_meanRT(1:5), ...
%         'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
%     errorbar(6, dataCombineMean.mean_meanRT(6),dataCombineMean.sem_meanRT(6), ...
%         'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
%     errbar_new = errorbar(1:5, dataCombineMean.mean_meanRT(7:11),dataCombineMean.sem_meanRT(7:11), ...
%         'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
%     errorbar(6, dataCombineMean.mean_meanRT(12), dataCombineMean.sem_meanRT(12), ...
%         'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
%     legend('boxoff');
%     legend([errbar_old, errbar_new], 'Repeated', 'Non-repeated', 'location', 'NorthEast');
%     xlim([0.5 6.5]);
%     ylim([1 1.5]);
%     set(gca, 'YTick', 1.1:0.1:1.5);
%     ylabel('Reaction time (sec)');
%     xlabel('Epochs');
%     hold off;

    %% for error bar within-subject design
    spssRTArray = reshape(tmp.mean_meanRT, Exp.subNum, []);
    adjustRT = adjustErrorBar(spssRTArray, Exp.subNum);
    [m, e] = grpstats(adjustRT, {tmp.New, tmp.NE}, {'mean', 'sem'});
    
    % plot within-subject error bar
    figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.7 6.83*0.7] );
    %     title('Solo condition');
    fill([5.5 6.5 6.5 5.5], [1.01 1.01 1.43 1.43], [0.92 0.92 0.92], 'EdgeColor', [0.92 0.92 0.92]);
    errbar_old = errorbar(1:5, m(1:5), e(1:5), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    errorbar(6, m(6),e(6), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k');
    errbar_new = errorbar(1:5, m(7:11), e(7:11), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    errorbar(6, m(12), e(12), 'k-o', 'MarkerSize', 8, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w');
    legend('boxoff');
    legend([errbar_old, errbar_new], 'Repeated', 'Non-repeated', 'location', 'NorthEast');
    xlim([0.5 6.5]);
    ylim([1 1.5]);
    set(gca, 'YTick', 1.1:0.1:1.5);
    ylabel('Reaction time (sec)');
    xlabel('Epochs');
    hold off;
    
    
catch ME
    disp(ME.message);
end