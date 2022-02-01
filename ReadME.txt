%% Author: Xuelian Zang
%% Contact: zangxuelian@gmail.com, lianlian81821@126.com
%% Date:09th Sep, 2020
%% Descriptions: All the experimental data and the related code for processing data are provided.


Exp1_AllData.mat: Dataset for Experiment 1 (solo-search condition)
Exp2_AllData: Dataset  for Experiment 2 (joint action condition)
Exp3_AllData.mat: Dataset for Experiment 3 (solo-search condition)
Exp2RTTh.mat: Discard thresholds (upper limit, M+2.5*SD) of RTs for each participant in Experiment 2

Note: the data are already preprocessed by combining different participants response together. 
Error trials and invalid trials (RTs of below 200 ms and above 2.5 standard deviations from the mean) 
are separately saved.


For each data set, it includes data for three sessions, namely 'train','test' and 'rec' for the training, test 
and recognition sessions respectively.

Data for each session consist of 'valid','err' and 'dis' for valid trials, error trials, and discarded outliers. When 
put these three parts together, we obtain all the responses for all experimental trials.
For experiment 2, the 'valid' ,'err' and 'dis' datasets were presented as '~Left' and '~Right' datasets, 
indicating the 'RT1' and/or the 'RT2' data was valid.

For each subset data, take AllData.train.valid as an example:
RP:	 participants' actual key press, corresponding to the four response keys. 1=key 1!, 2= key 2@, 3=key 8*, 4= key 0)
RT: 	 participants' response time in seconds
Crr:	 correct trials. >0 1=left response correct; 2= right response correct; -3 = left response wrong; -2=right response wrong
NT:	 number of trials
NB:	 number of blocks
White:	 left target white? 1 = white, 0 = black
New1:  current configuration  related to  left target new? 1= new, 0 = old
TLoc1:  left target's location
OriBlack: right target black? 1= black, 0 =white
New2:   current configuration related to the right target new? 1= new, 0 = old, this column is the same as New1
TLoc2: 	left target's location
Dir1: 	left target's orientation, 1= left, 2=right
Dir2:   right target's orientation, 1= left, 2=right
NE:    	number of epochs
NSub: 	number of subjects

For Experiment 2,
RP1:  actual key press for participant seating on the left
RP2:  actual key press for participant seating on the right
RT1:  response time for participant seating on the left
RT2:  response time for participant seating on the right
Crr1:  correct trials for participant seating on the left
Crr2:  correct trials for participant seating on the right

For all the variable named with 'for Spss', you could copy its data to SPSS and directly use SPSS to run statistical test.