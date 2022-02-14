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
clc; clear; close all;
addpath Common\

rng(Configuration.RNG_CONST) % For reproducibility

eeglab;                                     % open EEGLAB 

raw = 0;
features = 1;
recordings = [
    {'NewHeadsetRecordingsOmri\Test2\', raw}
    {'NewHeadsetRecordingsOmri\Test3\', raw}
    {'NewHeadsetRecordingsOmri\Test4\', raw}
];

% Preprocess raw recordings
for i=1 : size(recordings, 1)
    folder = cell2mat(recordings(i, 1));
    rawOrFeatures = cell2mat(recordings(i, 2));
    if rawOrFeatures == raw
        MI2_Preprocess(folder);
        disp(['Preprocess ' num2str(i) ' done...']);
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
        MI4_ExtractFeatures(folder, previousFolder);
        MI5_LearnModel(folder, Configuration.CLASSIFIER_TYPE, Configuration.CLASSIFIER_SAVE);
        disp(['Training ' num2str(i) ' done...']);
    else
        ExtractFeatures_FromOnline(folder, Configuration.ONLINE_COLEARN_MODEcorrectWrongOrBoth,...
            previousFolder, Configuration.FE_N, m);
        MI5_LearnModel(folder, learnModel, saveModel);
        disp(['Training + Features ' num2str(i) ' done...']);
    end
    
    previousFolder = folder;
end

close all;