clc; clear; close all;

rng(546351789) % For reproducibility

%% Some parameters (this needs to change according to your system):
addpath 'D:\EEG\eeglab2020_0'
eeglab;                                     % open EEGLAB 

raw = 0;
features = 1;
recordings = [
    {'D:\EEG\Online\bci4als-online\Old\Sub1\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub2\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub3\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub21\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub22\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub23\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub31\', raw}
    {'D:\EEG\Online\bci4als-online\Old\Sub32\', raw}
    {'D:\EEG\Online\bci4als-online\Old\OnlineSub1\', features}
    {'D:\EEG\Online\bci4als-online\Old\OnlineSub2\', features}
];

electrodesToRemove = [8]; % change in online too
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
Features2Select = 6;
Feature2SelectFile = '';
correctWrongOrBoth = 0; % 0 correct 1 wrong 2 both - On features only train, on what to train
learnModel = 2; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
cv = 1;
saveModel = 1;

for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw
        MI2_Preprocess_Scaffolding(folder, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
        disp(['Preprocess ' num2str(i) ' done...']);
        if pauseAfterEachPreprocess == 1
            pause;
        end
    end
end

disp(' ');

for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw
        MI3_SegmentData_Scaffolding(folder);
        disp(['Segmententation ' num2str(i) ' done...']);         
    end
end

disp(' ');

previousFolder = '';
for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw  
        MI4_ExtractFeatures_Scaffolding(folder, previousFolder, 0.2, FeatureSelectMode, Features2Select, Feature2SelectFile, 0, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
        MI5_LearnModel_Scaffolding(folder, learnModel, cv, saveModel);
        disp(['Training ' num2str(i) ' done...']);
        if pauseAfterEachTrain == 1
            pause;
        end        
    else
        ExtractFeatures_FromOnline(folder, correctWrongOrBoth ,previousFolder, Features2Select);
        MI5_LearnModel_Scaffolding(folder, learnModel, cv, saveModel);
        disp(['Training + Features ' num2str(i) ' done...']);
        if pauseAfterEachTrain == 1
            pause;
        end            
    end
    
    previousFolder = folder;
end

close all;