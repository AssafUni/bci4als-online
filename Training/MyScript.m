clc; clear; close all;

rng(546351789) % For reproducibility

%% Some parameters (this needs to change according to your system):
addpath 'D:\EEG\eeglab2020_0'
eeglab;                                     % open EEGLAB 

% recordingFolder1 = 'D:\EEG\recordings\Sub2\';
% recordingFolder2 = 'D:\EEG\recordings\Sub3\';
% recordingFolder3 = 'D:\EEG\recordings\Sub4\';
% recordingFolder4 = 'D:\EEG\recordings\Sub5\';
% recordingFolder5 = 'D:\EEG\recordings\Sub6\';
recordingFolder1 = 'D:\EEG\MI\MI\Record_1\';
recordingFolder2 = 'D:\EEG\MI\MI\Record_2\';
recordingFolder3 = 'D:\EEG\MI\MI\Record_3\';
electrodesToRemove = [];
plotLowPassHighPassFreqResp = 0;
plotScroll = 0;
plotSpectraMaps = 0;
plotSpectrom = 0;
plotSpectogram = 0;
plotBins = 0;
plotBinsFeaturesSelected = 0;
useLowPassHighPass = 0;
useNotchHighPass = 1;
resampleFsHz = 120;
automaticNoiseRejection = 0; % Problamatic to keep in consistency with trainingVec- could alter training and keep data in events
automaticAverageReReference = 1;
pauseAfterEachPreprocess = 0;
pauseAfterEachTrain = 0;
FeatureSelectMode = 0;
Features2Select = 5;
Feature2SelectFile = '';
learnModel = 1; % 0 - lda 1 - svm rbf
cv = 1;
% Maybe extract more parameters out of the functions

MI2_Preprocess_Scaffolding(recordingFolder1, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 1 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder2, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 2 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder3, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 3 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
% MI2_Preprocess_Scaffolding(recordingFolder4, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
% disp('Preprocess 4 done...');
% if pauseAfterEachPreprocess == 1
%     pause;
% end
% MI2_Preprocess_Scaffolding(recordingFolder5, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
% disp('Preprocess 5 done...');
% if pauseAfterEachPreprocess == 1
%     pause;
% end

MI3_SegmentData_Scaffolding(recordingFolder1);
disp('Segmententation 1 done...');
MI3_SegmentData_Scaffolding(recordingFolder2);
disp('Segmententation 2 done...');
MI3_SegmentData_Scaffolding(recordingFolder3);
disp('Segmententation 3 done...');
% MI3_SegmentData_Scaffolding(recordingFolder4);
% disp('Segmententation 4 done...');
% MI3_SegmentData_Scaffolding(recordingFolder5);
% disp('Segmententation 5 done...');

MI4_ExtractFeatures_Scaffolding(recordingFolder1, '', 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder1, learnModel, cv);
disp('Training 1 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder2, recordingFolder1, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder2, learnModel, cv);
disp('Training 2 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder3, recordingFolder2, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder3, learnModel, cv);
disp('Training 3 done...');
if pauseAfterEachTrain == 1
    pause;
end
% MI4_ExtractFeatures_Scaffolding(recordingFolder4, recordingFolder3, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
% MI5_LearnModel_Scaffolding(recordingFolder4);
% disp('Training 4 done...');
% if pauseAfterEachTrain == 1
%     pause;
% end
% MI4_ExtractFeatures_Scaffolding(recordingFolder5, recordingFolder4, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
% MI5_LearnModel_Scaffolding(recordingFolder5);
% disp('Training 5 done...');
% if pauseAfterEachTrain == 1
%     pause;
% end

close all;