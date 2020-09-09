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
  %o1E1 o1E2 o1E3 o1E4 o1E5    o0E1 o0E2 o0E3 o0E4 o0E5    
  dataOut.forSpss.trainCombineCol = dataset({reshape(trainMeanSub.mean_RT, Exp.subNum, []),...
      'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,   'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5'} );
 
 % precessing transfer data
  testEp6MeanSub = grpstats(dataIn.test.valid, {'New','NE','NSub'},{'mean','sem','numel'}, 'datavars','RT');
  testEp6MeanAll = grpstats(testEp6MeanSub, {'New','NE'},{'mean','sem','numel'}, 'datavars','mean_RT');
  dataOut.forSpss.testEp6 = dataset({reshape(testEp6MeanSub.mean_RT, Exp.subNum, []),'old','new'});

  %plot the reaction time of experiemnt 1
    figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.5 6.83*0.5] );
     title('Solo condition');
     idxNew = (trainMeanAllCombine.New == 1 );
      errorbar(1:Exp.nEp, trainMeanAllCombine.mean_mean_RT(idxNew, :), trainMeanAllCombine.sem_mean_RT(idxNew, :),'k-*');
      idxOld = (trainMeanAllCombine.New == 0);
      errorbar(1:Exp.nEp, trainMeanAllCombine.mean_mean_RT(idxOld, :), trainMeanAllCombine.sem_mean_RT(idxOld, :),'k-o');
      errorbar(Exp.nEp+1, testEp6MeanAll.mean_mean_RT(1),testEp6MeanAll.sem_mean_RT(1),'k-o');
      errorbar(Exp.nEp+1, testEp6MeanAll.mean_mean_RT(2),testEp6MeanAll.sem_mean_RT(2),'k-*');
      xlabel('Epoch');
      ylabel('Reaction time (in Secs)');
      legend('boxoff');
      legend( 'new','old');
      xlim([0.5 6.5]);
  hold off;
  

catch ME
    disp(ME.message);
end