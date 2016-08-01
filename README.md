# VisualMotorIntegration
Brain Science Research at Zhang's Lab
getSpeed.m : A function called by many other scripts, return the calculated speed and others. (see the comments in program)
Plot_Speed_Spike_and_Save.m : Plot speed-spike count bar graph and save the matrix; number each neuron and save it in Neuron_No.mat;
Wilcoxon_SignedRank.m : Using Wilcoxon Signed Rank Test(and do the FDR to adjust the p values) to find significant neurons w.r.t the spike firing frequency in every speed segment.
Plot_resultGraphs.m : Plot Graphs like the paper "Visuomoter", spiking rate as a function of visual and running speed. Other functions are to be added soon.
