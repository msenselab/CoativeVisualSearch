%Name:                dataProcessValid.m
%
%Autor:               Xuelian Zang
%Description:         process valid data for selected subjects with stable
%performance
%
%Date:                22/09/2015
function dataOut = dataProcessValid_Exp2(dataIn,Exp)
try

  %% for the training session
  trainMeanSub = grpstats(dataIn.train.valid, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1','RT2'});
  trainMeanAllCombine = grpstats(trainMeanSub, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT1','mean_RT2'});
  %o1E1 o1E2 o1E3 o1E4 o1E5    o0E1 o0E2 o0E3 o0E4 o0E5    
  dataOut.forSpss.trainRTLeftCombine = dataset({reshape(trainMeanSub.mean_RT1, Exp.subNum, []),...
      'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,   'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5'} );
  dataOut.forSpss.trainRTRightCombine = dataset({reshape(trainMeanSub.mean_RT2, Exp.subNum, []),...
      'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,   'o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5'} );

  testEp6MeanSub = grpstats(dataIn.test.valid, {'New1','NE','NSub'},{'mean','numel'}, 'datavars',{'RT1', 'RT2'});
  testEp6MeanAll = grpstats(testEp6MeanSub, {'New1','NE'},{'mean','sem','numel'}, 'datavars',{'mean_RT1', 'mean_RT2'});
  dataOut.forSpss.testEp6RTLeft = dataset({reshape(testEp6MeanSub.mean_RT1, Exp.subNum, []),'old','new'});
  dataOut.forSpss.testEp6RTRight = dataset({reshape(testEp6MeanSub.mean_RT2, Exp.subNum, []),'old','new'});
 
  %treat left and right participants as different subjects and combine
  %their data together 
  dataCombine = dataset( {[trainMeanSub.New1    trainMeanSub.NE        trainMeanSub.NSub              trainMeanSub.mean_RT1; ...
                           trainMeanSub.New1    trainMeanSub.NE        trainMeanSub.NSub+Exp.subNum   trainMeanSub.mean_RT2; ...
                           testEp6MeanSub.New1  testEp6MeanSub.NE      testEp6MeanSub.NSub            testEp6MeanSub.mean_RT1; ...
                           testEp6MeanSub.New1  testEp6MeanSub.NE      testEp6MeanSub.NSub+Exp.subNum testEp6MeanSub.mean_RT2;], ...
                            'New', 'NE', 'NSub','meanRT'});
                        
  tmp = grpstats(dataCombine, {'New','NE','NSub'},{'mean','numel'}, 'datavars',{'meanRT'});                      
  dataOut.forSpss.RTAllCombine = dataset({reshape(tmp.mean_meanRT, Exp.subNum*2, []),...
       'o1E1', 'o1E2', 'o1E3', 'o1E4', 'o1E5' ,'o1E6','o0E1', 'o0E2', 'o0E3', 'o0E4', 'o0E5', 'o0E6'} );

  dataCombineMean = grpstats(dataCombine, {'New','NE'},{'mean','sem','numel'}, 'datavars',{'meanRT'});
    
  
  %plot the reaction time of experiemnt 2
  figure(); hold on; set(gcf,'Units','inches','Position',[2 2 6.83*0.5 6.83*0.5] );
   title('Joint condition');
    errorbar(1:5, dataCombineMean.mean_meanRT(1:5),dataCombineMean.sem_meanRT(1:5), 'k-o');
    errorbar(6, dataCombineMean.mean_meanRT(6),dataCombineMean.sem_meanRT(6), 'k-o');
    
    errorbar(1:5, dataCombineMean.mean_meanRT(7:11),dataCombineMean.sem_meanRT(7:11), 'k-*');
    errorbar(6, dataCombineMean.mean_meanRT(12), dataCombineMean.sem_meanRT(12), 'k-*');
    xlim([0.5 6.5]);
    ylabel('Reaction time (in Secs)');
    xlabel('Epochs');
  hold off;

  
 
    

catch ME
    disp(ME.message);
end