function [segments] = MI3_SegmentData(recordingFolder)
%% Segment data using markers
% This function segments the continuous data into trials or epochs creating
% a 3D matrix where dimentions are - [trial, channels, time (data samples)]
%
% Input: 
%   - recordingFolder - a path of the folder containing the raw data 
%
% Output: 
%   - MIData - a 3D matrix containing segments of the raw data
%

%% Parameters and previous variables:
Fs = Configuration.SAMPLE_RATE;               % openBCI sample rate
trialLength = Configuration.TRIAL_LENGTH_CLASSIFY;        % needs to be equal to offline trainig parameters
load(strcat(recordingFolder, '\EEG_data.mat'));                % load the filtered EEG data in .mat format
load(strcat(recordingFolder, '\EEG_chans.mat'));                  % load the EEG channel locations
load(strcat(recordingFolder, '\EEG_events.mat'));                 % load the EEG event markers
load(strcat(recordingFolder, '\labels.mat'));                % load the training vector (which target at which trial)

numChans = size(EEG_chans,1);                                   % how many chans do we have?
num_labels = length(labels);                                  % derive number of trials from training label vector
% events = struct('type', {EEG_events(1,1:end).type});
for i = 1:length(EEG_event)
    if strcmp('1111.000000000000',EEG_event(i).type)               % find trial start marker
        markerIndex(i) = 1;                                    % index markers
    else
        markerIndex(i) = 0;
    end
end
markerIndex = find(markerIndex);                                % index of each trial start
trials = length(markerIndex);                                   % derive number of trials from start markers

% Check for consistancy across events & trials
if trials ~= num_labels
    disp('!!!! Some form of mis-match between number of recorded and planned trials.')
    return
end
segments = [];                                                 % initialize main matrix

%% Main data segmentation process:
for trial = 1:trials
    [segments] = sortElectrodes(segments, EEG_data, EEG_event, Fs, trialLength, markerIndex(trial), numChans, trial);
end

save(strcat(recordingFolder,'\segments.mat'),'segments');

end
