%% calError.m
%% Description: calculate the error rates, discard rates the ANOVA of error array
%% Date: 04/12/2014
%% Contact: zangxuelian@gmail.com
function dataOut = calError(dataIn, Exp)

    %% calculate discard rate array       
%         %% Array: o1e1  o1e2  o1e3  o1e4   o1e5   o1e6   o2e1   o2e2  o2e3
%         %% o2e4  o2e5  o2e6
%         %% disArray.p1...
    numOfEP = Exp.nEp + Exp.nEpT;
    dataTemp = [dataIn.train.err;  dataIn.test.err; dataIn.train.dis;  dataIn.test.dis];
    errArray = zeros(Exp.subNum, 2*(Exp.nEp + Exp.nEpT ));
    for j = 1 : Exp.subNum % for each subject
            for t = 0:1 % for old and new
                for m = 1:(numOfEP) % for EP 1:6
                    temp = dataTemp(dataTemp.NSub == j & dataTemp.New1 == t & dataTemp.NE == m,:);
                        if ~isempty(temp)
                             numOfAllTrial = Exp.nTrl * Exp.numOfBlock.TrainEpoch/2 ;
                             errArray(j, t*numOfEP+m) = 100*length(temp.NE)/numOfAllTrial;
                        else
                           errArray(j, t*numOfEP+m) = 0;
                        end
                end
            end
    end

   dataOut.errSpssArray = errArray;
    
    
    %% discard trial
    dataTemp = [dataIn.train.dis;  dataIn.test.dis];
    disArray = zeros(Exp.subNum, 2*(Exp.nEp + Exp.nEpT ));
    for j = 1 : Exp.subNum % for each subject
%         for iLeftRight = 1:2
            for t = 0:1 % for old and new
                for m = 1:(numOfEP) % for EP 1:6
                    temp = dataTemp(dataTemp.NSub == j & dataTemp.New1 == t & dataTemp.NE == m,:);
                    
%                     if iLeftRight == 1% left
                        if ~isempty(temp)
                             numOfAllTrial = Exp.nTrl * Exp.numOfBlock.TrainEpoch/2 ;
                             disArrayLeft(j, t*numOfEP+m) = 100*length(temp.NE)/numOfAllTrial;
                        else
                           disArrayLeft(j, t*numOfEP+m) = 0;
                        end
%                     else
%                         temp = temp(temp.Crr2 == -2,:);
%                         if ~isempty(temp)
%                              numOfAllTrial = Exp.nTrl * Exp.numOfBlock.TrainEpoch/2 ;
%                              disArrayRight(j, t*numOfEP+m) = 100*length(temp.NE)/numOfAllTrial;
%                         else
%                            disArrayRight(j, t*numOfEP+m) = 0;
%                         end
%                     end
                end

            end
%         end
    end
    
    dataOut.disSpssArray = disArray;
    
end