clc; clear; close all;

rng(546351789) % For reproducibility

%% Some parameters (this needs to change according to your system):
addpath 'C:\ToolBoxes\eeglab2020_0'
addpath 'C:\ToolBoxes\eeglab2020_0\plugins\xdfimport1.14\xdf-EEGLAB'
eeglab;                                     % open EEGLAB 

raw = 0;
features = 1;
recordings = [
    {'C:\master\bci\recording-28-4\Sub211\', raw}
    {'C:\master\bci\recording-28-4\Sub222\', raw}
    {'C:\master\bci\recording-28-4\Sub233\', raw}
    {'C:\master\bci\recording-28-4\OnlineSub1\', features}
    {'C:\master\bci\recording-28-4\OnlineSub2\', features}
    {'C:\master\bci\recording-28-4\OnlineSub3\', features}
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
learnModel = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
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