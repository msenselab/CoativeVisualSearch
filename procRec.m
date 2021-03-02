%% process recognition
function  [hitFalseArray, d] = procRec(dataIn)
try
     maxNB = max(dataIn.rec.NB);
     minNB = min(dataIn.rec.NB);
     
     %% put left and right subjects together
     tmpRight = dataIn.rec(dataIn.rec.RP1 == -1 & dataIn.rec.RT1 == -1, 4:end);
     tmpLeft = dataIn.rec(dataIn.rec.RP2 == -1 & dataIn.rec.RT2 == -1, [1:3 7:end]);
     tmpData = dataset({[double(tmpLeft); double(tmpRight)], ...
         'RP','RT','Crr','NT','NB','nConfig','LWhite', 'New1', 'TLoc1', 'RBlack', 'New2', 'TLoc2 ','NSub'});    
    
     recMeanSub = grpstats(tmpData, {'New1','NB','NSub'},{'mean','sem','numel'}, 'datavars',{'Crr'});
     
     hitRates = recMeanSub.mean_Crr(recMeanSub.New1 == 0,:);
     crrReject = recMeanSub.mean_Crr(recMeanSub.New1 == 1,:);

     %if the hit or correct rejection rate equals to 1 or 0,set them to 0.9999
     %and 0.0001
     hitRates(hitRates == 1) = 0.9999;
     crrReject(crrReject == 0) = 0.0001;
     hitRates(hitRates == 0) = 0.0001;
     crrReject(crrReject == 1) = 0.9999;

     
     hitFalseArray = [hitRates  1-crrReject ];

     %% calculate d'
     d = [norminv( hitFalseArray (:,1) ) - norminv( hitFalseArray (:,2) )];
        
%
catch ME
    disp(ME.message);
end