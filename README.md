# VisualMotorIntegration
Brain Science Research at Zhang's Lab
Code Explaination
========
* getSpeed.m : A function called by many other scripts, return the calculated speed and others. (see the comments in program)
* Plot_Speed_Spike_and_Save.m : Plot speed-spike count bar graph and save the matrix; number each neuron and save it in Neuron_No.mat;
* Wilcoxon_SignedRank.m : Using Wilcoxon Signed Rank Test(and do the FDR to adjust the p values) to find significant neurons w.r.t the spike firing frequency in every speed segment.
    * Need to have the result from Plot_Speed_Spike_and_Save.m 
* Plot_resultGraphs.m : Plot Graphs like the paper "Visuomoter", spiking rate as a function of visual and running speed. Other functions are to be added soon.
* Translate_Xlsx_New.m etc : Read Excel file and save the data into a .mat file

Raw Data Storage
========
* speed and spike data are saved separately in directory 'SPEED DATA/' and 'SPIKE DATA/'. Those two directories should be put in the same path as other MATLAB programs. MATLAB programs load them by the following command:
    * speedname = dir('SPEED DATA/*.mat');
    * spikename = dir('SPIKE DATA/*.mat');
* raw data in mat format are save in my Baidu Cloud

Attachment
========
* the 'Temporary Result' folder contains some result graph recently produced
