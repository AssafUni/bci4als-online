clc; clear; close all;

rng(546351789) % For reproducibility

%% Some parameters (this needs to change according to your system):
addpath 'D:\EEG\eeglab2020_0'
eeglab;                                     % open EEGLAB 

% recordingFolder1 = 'D:\EEG\MI\MI\Record_1\';
% recordingFolder2 = 'D:\EEG\MI\MI\Record_2\';
% recordingFolder3 = 'D:\EEG\MI\MI\Record_3\';
recordingFolder1 = 'D:\EEG\MI\MI2\Sub2\';
recordingFolder2 = 'D:\EEG\MI\MI2\Sub3\';
recordingFolder3 = 'D:\EEG\MI\MI2\Sub3\';
recordingFolder4 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder5 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder6 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder7 = 'D:\EEG\MI\MI2\Sub2\';
recordingFolder8 = 'D:\EEG\MI\MI2\Sub3\';
recordingFolder9 = 'D:\EEG\MI\MI2\Sub3\';
recordingFolder10 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder11 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder12 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder13 = 'D:\EEG\MI\MI2\Sub8\';
recordingFolder14 = 'D:\EEG\MI\MI2\Sub8\';
recordingFolder15 = 'D:\EEG\MI\MI2\Sub5\';
recordingFolder16 = 'D:\EEG\MI\MI2\Sub3\';

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
Features2Select = 8;
Feature2SelectFile = '';
learnModel = 2; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
cv = 1;
saveModel = 1;
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
MI2_Preprocess_Scaffolding(recordingFolder4, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 4 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder5, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 5 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder6, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 6 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder7, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 7 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder8, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 8 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder9, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 9 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder10, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 10 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder11, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 11 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder12, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 12 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder13, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 13 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder14, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 14 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder15, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 15 done...');
if pauseAfterEachPreprocess == 1
    pause;
end
MI2_Preprocess_Scaffolding(recordingFolder16, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
disp('Preprocess 16 done...');
if pauseAfterEachPreprocess == 1
    pause;
end


MI3_SegmentData_Scaffolding(recordingFolder1);
disp('Segmententation 1 done...');
MI3_SegmentData_Scaffolding(recordingFolder2);
disp('Segmententation 2 done...');
MI3_SegmentData_Scaffolding(recordingFolder3);
disp('Segmententation 3 done...');
MI3_SegmentData_Scaffolding(recordingFolder4);
disp('Segmententation 4 done...');
MI3_SegmentData_Scaffolding(recordingFolder5);
disp('Segmententation 5 done...');
MI3_SegmentData_Scaffolding(recordingFolder6);
disp('Segmententation 6 done...');
MI3_SegmentData_Scaffolding(recordingFolder7);
disp('Segmententation 7 done...');
MI3_SegmentData_Scaffolding(recordingFolder8);
disp('Segmententation 8 done...');
MI3_SegmentData_Scaffolding(recordingFolder9);
disp('Segmententation 9 done...');
MI3_SegmentData_Scaffolding(recordingFolder10);
disp('Segmententation 10 done...');
MI3_SegmentData_Scaffolding(recordingFolder11);
disp('Segmententation 11 done...');
MI3_SegmentData_Scaffolding(recordingFolder12);
disp('Segmententation 12 done...');
MI3_SegmentData_Scaffolding(recordingFolder13);
disp('Segmententation 13 done...');
MI3_SegmentData_Scaffolding(recordingFolder14);
disp('Segmententation 14 done...');
MI3_SegmentData_Scaffolding(recordingFolder15);
disp('Segmententation 15 done...');
MI3_SegmentData_Scaffolding(recordingFolder16);
disp('Segmententation 16 done...');


MI4_ExtractFeatures_Scaffolding(recordingFolder1, '', 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder1, learnModel, cv, 0);
disp('Training 1 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder2, recordingFolder1, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder2, learnModel, cv, 0);
disp('Training 2 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder3, recordingFolder2, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder3, learnModel, cv, saveModel);
disp('Training 3 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder4, recordingFolder3, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder4, learnModel, cv, saveModel);
disp('Training 4 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder5, recordingFolder4, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder5, learnModel, cv, saveModel);
disp('Training 5 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder6, recordingFolder5, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder6, learnModel, cv, saveModel);
disp('Training 6 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder7, recordingFolder6, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder7, learnModel, cv, saveModel);
disp('Training 7 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder8, recordingFolder7, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder8, learnModel, cv, saveModel);
disp('Training 8 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder9, recordingFolder8, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder9, learnModel, cv, saveModel);
disp('Training 9 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder10, recordingFolder9, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder10, learnModel, cv, saveModel);
disp('Training 10 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder11, recordingFolder10, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder11, learnModel, cv, saveModel);
disp('Training 11 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder12, recordingFolder11, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder12, learnModel, cv, saveModel);
disp('Training 12 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder13, recordingFolder12, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder13, learnModel, cv, saveModel);
disp('Training 13 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder14, recordingFolder13, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder14, learnModel, cv, saveModel);
disp('Training 14 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder15, recordingFolder14, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder15, learnModel, cv, saveModel);
disp('Training 15 done...');
if pauseAfterEachTrain == 1
    pause;
end
MI4_ExtractFeatures_Scaffolding(recordingFolder16, recordingFolder15, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 2, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
MI5_LearnModel_Scaffolding(recordingFolder16, learnModel, cv, saveModel);
disp('Training 16 done...');
if pauseAfterEachTrain == 1
    pause;
end

close all;