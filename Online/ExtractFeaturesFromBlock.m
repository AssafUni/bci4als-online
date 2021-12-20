function [EEG_Features, AllDataInFeatures] = ExtractFeaturesFromBlock(recordingFolder)
%% This function extracts features for the machine learning process.
% It loads a preprocessed chunk, the selected features indexes from
% the offline phase, and extracts the same features to be selected
% using these indexes.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.


% Loads channels numbering
load(strcat(recordingFolder,'EEG_chans.mat'));
% Loads preprocessed chunk
load(strcat(recordingFolder,'MIData.mat'));
% Loads the features that were selected in the offline phase
load(strcat(recordingFolder,'SelectedIdx.mat'));

% Parameters as in the offline phase- should be the same
numTargets = 3;
Fs = 120; 
onlyPowerBands = 1;
trials = size(MIData,1);
[R, C] = size(EEG_chans);
chanLocs = reshape(EEG_chans',[1, R*C]);
numChans = size(MIData,2);

motorDataChan = {};
welch = {};
idxTarget = {};
lg={};

freq.low = 0.5;
freq.high = 60;
freq.Jump = 0.1; 
f = freq.low:freq.Jump:freq.high;
trailT = length(MIData);
window = [];
noverlap = [];

for i = 1:numChans
    motorDataChan{i} = squeeze(MIData(:,i,:))';                     % convert the data to a 2D matrix fillers by channel
    motorDataChan{i} = reshape(motorDataChan{i}, size(motorDataChan{i}, 2), []);
    welch{i} = pwelch(motorDataChan{i},window, noverlap, f, Fs);    % calculate the pwelch for each electrode
    welch{i} = reshape(welch{i}, size(welch{i}, 2), []);
end    

[MIFeaturesLabel, MIFeaturesLabelName] = GetFeatures(MIData, trials, numChans, welch, Fs);


% Select features as in the offline phase
MIFeaturesLabel = zscore(MIFeaturesLabel);
AllDataInFeatures = reshape(MIFeaturesLabel, trials, []);
EEG_Features = AllDataInFeatures(:, SelectedIdx);
end