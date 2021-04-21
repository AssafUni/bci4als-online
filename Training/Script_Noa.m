clc; clear; close all;

rng(546351789) % For reproducibility

%% Some parameters (this needs to change according to your system):
addpath 'C:\ToolBoxes\eeglab2020_0'
addpath 'C:\ToolBoxes\eeglab2020_0\plugins\xdfimport1.14\xdf-EEGLAB'
eeglab;  


electrodesToRemove = [];
plotLowPassHighPassFreqResp = 0;
plotScroll = 0;
plotSpectraMaps = 0;
plotSpectrom = 0;
plotSpectogram = 0;
plotBins = 0;
plotBinsFeaturesSelected = 0;
useLowPassHighPass = 1;
useNotchHighPass = 1;
resampleFsHz = 120;
automaticNoiseRejection = 0; % Problamatic to keep in consistency with trainingVec- could alter training and keep data in events
automaticAverageReReference = 0;
pauseAfterEachPreprocess = 0;
pauseAfterEachTrain = 0;
FeatureSelectMode = 0;
Features2Select = 5;
Feature2SelectFile = '';
learnModel = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
cv = 1;
saveModel = 1;
% Maybe extract more parameters out of the functions

recordingFolder1 = 'C:\master\bci\recording-21-4\Sub1\';
recordingFolder2 = 'C:\master\bci\recording-21-4\Sub2\';
recordingFolder3 = 'C:\master\bci\recording-21-4\Sub3\';

MI2_Preprocess_Scaffolding(recordingFolder1, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 1 done...');
MI2_Preprocess_Scaffolding(recordingFolder2, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 2 done...');
MI2_Preprocess_Scaffolding(recordingFolder3, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 3 done...');

MI3_SegmentData_Scaffolding(recordingFolder1);
MI3_SegmentData_Scaffolding(recordingFolder2);
MI3_SegmentData_Scaffolding(recordingFolder3);

MI4_ExtractFeatures_Scaffolding(recordingFolder1, '', 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder1, learnModel, cv, saveModel);
MI4_ExtractFeatures_Scaffolding(recordingFolder2, recordingFolder1, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder2, learnModel, cv, saveModel);
MI4_ExtractFeatures_Scaffolding(recordingFolder3, recordingFolder2, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder3, learnModel, cv, saveModel);

close all;