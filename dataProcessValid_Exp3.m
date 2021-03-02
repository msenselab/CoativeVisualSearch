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
          'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,   'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5'} );
  end
  trainMeanSub_RT2 = grpstats(dataIn.train.valid(dataIn.train.valid.RT2 > 0, :), {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT2'});
  if ~isempty(trainMeanSub_RT2)
      trainMeanAllCombine_RT2  = grpstats(trainMeanSub_RT2, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT2'});
      subNumRight = length(unique(trainMeanSub_RT2.NSub) );
      dataOut.forSpss.trainRTRightCombine = dataset({reshape(trainMeanSub_RT2.mean_RT2, subNumRight, []),...
          'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,   'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5'} );
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
       'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6','o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6'} );                     
  elseif ~isempty(testMeanSub_RT1) 
       %combine the left and right participants together
        dataCombine = dataset( {[ trainMeanSub_RT1.New1     trainMeanSub_RT1.NE        trainMeanSub_RT1.NSub       trainMeanSub_RT1.mean_RT1; ...
                                  testMeanSub_RT1.New1       testMeanSub_RT1.NE         testMeanSub_RT1.NSub        testMeanSub_RT1.mean_RT1;], ...
                            'New', 'NE', 'NSub','meanRT'});
          tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});                      
        dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum, []),...
       'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6','o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6'} );
  else
        dataCombine = dataset( {[trainMeanSub_RT2.New2      trainMeanSub_RT2.NE        trainMeanSub_RT2.NSub       trainMeanSub_RT2.mean_RT2; ...
                                  testMeanSub_RT2.New1       testMeanSub_RT2.NE         testMeanSub_RT2.NSub        testMeanSub_RT2.mean_RT2;], ...
                                'New', 'NE', 'NSub','meanRT'});      
       tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});                      
       dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum, []),...
       'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6','o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6'} );
  end

  dataCombineMean = grpstats(dataCombine, {'New','NE'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
  
  %plot all data together
  figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.5 6.83*0.5] );
    errorbar(1:5, dataCombineMean.mean_meanRT(1:5),dataCombineMean.sem_meanRT(1:5), 'k-o');
    errorbar(6, dataCombineMean.mean_meanRT(6),dataCombineMean.sem_meanRT(6), 'k-o');
    
    errorbar(1:5, dataCombineMean.mean_meanRT(7:11),dataCombineMean.sem_meanRT(7:11), 'k-*');
    errorbar(6, dataCombineMean.mean_meanRT(12), dataCombineMean.sem_meanRT(12), 'k-*');
    xlim([0.5 6.5]);
    ylabel('Reaction time (in Secs)');
    xlabel('Epochs');
  hold off;

  
%   nfig = ceil(sqrt(Exp.subNum) );
%   figure(); hold on;
%   for iSub = 1:Exp.subNum
%       train = trainMeanSub(trainMeanSub.NSub == iSub, :);
%       testEp6MeanSubTmp = testEp6MeanSub(testEp6MeanSub.NSub == iSub,:);
%       subplot(nfig,nfig,iSub); hold on;
%       plot(1:6, [train.mean_RT1(1:5); testEp6MeanSubTmp.mean_RT1(1) ]', 'r-o');
%       plot(1:6, [train.mean_RT1(6:10); testEp6MeanSubTmp.mean_RT1(2) ]', 'r-*');
% 
%       plot(1:6, [train.mean_RT2(1:5); testEp6MeanSubTmp.mean_RT2(1) ]', 'b-o');
%       plot(1:6, [train.mean_RT2(6:10); testEp6MeanSubTmp.mean_RT2(2) ]', 'b-*');
%       
%       ylabel('meanRT');
%       xlabel('Epochs');
%       set(gca,'XTick',[1:6]);
%       if iSub == 1
%       legend('oldLeft','newLeft','oldRight','newRight');
%       end
%       hold off
%   end
%   
%   %plot all subjects together, separate left and right participant
%   figure(); hold on;
%       errorbar(1:6, [trainMeanAllCombine.mean_mean_RT1(1:5); testEp6MeanAll.mean_mean_RT1(1) ], ...
%           [trainMeanAllCombine.sem_mean_RT1(1:5); testEp6MeanAll.sem_mean_RT1(1) ], 'r-o');
%       errorbar(1:6, [trainMeanAllCombine.mean_mean_RT1(6:10); testEp6MeanAll.mean_mean_RT1(2) ], ...
%            [trainMeanAllCombine.sem_mean_RT1(6:10); testEp6MeanAll.sem_mean_RT1(2) ],'r-*');
% 
%       errorbar(1:6, [trainMeanAllCombine.mean_mean_RT2(1:5); testEp6MeanAll.mean_mean_RT2(1) ],...
%          [trainMeanAllCombine.sem_mean_RT2(1:5); testEp6MeanAll.sem_mean_RT2(1) ], 'b-o');
%       errorbar(1:6, [trainMeanAllCombine.mean_mean_RT2(6:10); testEp6MeanAll.mean_mean_RT2(2) ], ...
%           [trainMeanAllCombine.sem_mean_RT2(6:10); testEp6MeanAll.sem_mean_RT2(2) ], 'b-*');
%      
%       ylabel('meanRT');
%       xlabel('Epochs');
%       set(gca,'XTick',[1:6]);
%       legend('oldLeft','newLeft','oldRight','newRight');
%   hold off;
%   


catch ME
    disp(ME.message);
end