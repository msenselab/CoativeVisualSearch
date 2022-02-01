%% Name:         adjustErrorBar.m
%% Description:  adjust the error bar to fit within subject design, make
%% the error bar smaller
function tempOut = adjustErrorBar(spssRTArray, subNum)         
try
         %% for error bar within subject design
         temp = mean(spssRTArray,2) - mean( mean(spssRTArray));
         for i = 1:subNum
             tempOut(i,:) = spssRTArray(i,:) - temp(i);
         end
         
         tempOut = reshape(tempOut,1,[])';
catch Me
    disp(Me.message);
end