% This is a script to automate training a model. The steps to follow are:
% 1. Record using the MI1_Training function raw recordings using as many recording as
% needed. (Run function file to record, not this script).
% 2. Change the eeglab path in line 17
% 3. Alter the recordings array in line 23. Each element of the array
% specifies if to aggregate raw recording or feautes extracted fron an
% online session.
% 4. Alter parameters as needed.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% VERY IMPORTANT- The parameters should be kept in sync with the online
%% parameters.

clc; clear; close all;

rng(546351789) % For reproducibility

addpath utils\
% addpath 'C:\ToolBoxes\eeglab2020_0\plugins\xdfimport1.14\xdf-EEGLAB'
eeglab;                                     % open EEGLAB 

raw = 0;
features = 1;
recordings = [
    {'NewHeadsetRecordingsOmri\Test2\', raw}
    {'NewHeadsetRecordingsOmri\Test3\', raw}
    {'NewHeadsetRecordingsOmri\Test4\', raw}
];

% Alter parameters
electrodesToRemove = []; % don't forget to change in online too
plotLowPassHighPassFreqResp = 0; % during preprocess, plot freq resp
plotScroll = 0; % during preprocess plot scroll 
plotSpectraMaps = 0; % during preprocess plot spectre maps
plotSpectrom = 0; % plot spectorm
plotSpectogram = 0; % plot spectogram
plotBins = 0; % plot bins of all features
plotBinsFeaturesSelected = 0; % plot bins of only selected featues
useLowPassHighPass = 1; % 0- don't use filter 1- use low-high-pass fiter
useNotchHighPass = 1; % 0- don't use filter 1- use notch filter
resampleFsHz = 125; % resample rate
automaticNoiseRejection = 0; % Problamatic to keep in consistency with trainingVec- could alter training and keep data in events
automaticAverageReReference = 0; % 0- don't use average re-reference 1- use average re-reference.
pauseAfterEachPreprocess = 0; % 0- don't pause 1- pause after each preprocess
pauseAfterEachTrain = 0; % 0- don't pause 1- pause after each train
FeatureSelectMode = 0; % feature 2 select mode, see extractFeatures for more info.
Features2Select = 6; % the number of features to select
Feature2SelectFile = ''; % the file path of a pre-determined feature selection
onlyPowerBands = 0; % whether to use or not to use only power bands features
% When training on online data(from features only in the recording array),
% you can train on correct labled trials, wrong, or both.
correctWrongOrBoth = 2; % 0 correct 1 wrong 2 both - On features only train, on what to train
% which model to train
learnModel = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
% Whether to save or not to save the model
saveModel = 1; % 0-don't save 1- save

% Preprocess raw recordings
for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw
        MI2_Preprocess(folder, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference);
        disp(['Preprocess ' num2str(i) ' done...']);
        if pauseAfterEachPreprocess == 1
            pause;
        end
    end
end

disp(' ');

% Segment preprocessed data
for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw
        MI3_SegmentData(folder);
        disp(['Segmententation ' num2str(i) ' done...']);         
    end
end

disp(' ');

% Extract features and train model
previousFolder = '';
for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if i == 1
        m = 0;
    else 
        m = 1;
    end
    if rawOrFeatures == raw  
        MI4_ExtractFeatures(folder, previousFolder, FeatureSelectMode, Features2Select, Feature2SelectFile, m, onlyPowerBands, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected);
        MI5_LearnModel(folder, learnModel, saveModel);
        disp(['Training ' num2str(i) ' done...']);
        if pauseAfterEachTrain == 1
            pause;
        end        
    else
        ExtractFeatures_FromOnline(folder, correctWrongOrBoth ,previousFolder, Features2Select, m);
        MI5_LearnModel(folder, learnModel, saveModel);
        disp(['Training + Features ' num2str(i) ' done...']);
        if pauseAfterEachTrain == 1
            pause;
        end            
    end
    
    previousFolder = folder;
end

close all;