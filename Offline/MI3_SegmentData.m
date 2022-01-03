function MI3_SegmentData(recordingFolder)
%% Segment data using markers
% This function segments the continuous data into trials or epochs in a matrix ready for classifier training.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

%% Parameters and previous variables:
Fs = 125;               % openBCI sample rate
trialLength = 5;        % needs to be equal to offline trainig parameters
load(strcat(recordingFolder, '\cleaned_sub.mat'));                % load the filtered EEG data in .mat format
load(strcat(recordingFolder, '\trainingVec.mat'));                % load the training vector (which target at which trial)
load(strcat(recordingFolder, '\EEG_chans.mat'));                  % load the EEG channel locations
numChans = size(EEG_chans,1);                                   % how many chans do we have?
EEG_events = load(strcat(recordingFolder, '\EEG_events.mat'));                 % load the EEG event markers
EEG_event = EEG_events.EEG_event;

trials1 = length(trainingVec);                                  % derive number of trials from training label vector
events = struct('type', {EEG_event(1:end).type});
for i = 1:length(events)
    if strcmp('1111.000000000000',events(i).type)               % find trial start marker
        marker1Index(i) = 1;                                    % index markers
    else
        marker1Index(i) = 0;
    end
end
mark1Index = find(marker1Index);                                % index of each trial start
trials = length(mark1Index);                                    % derive number of trials from start markers

% Check for consistancy across events & trials
if trials ~= trials1
    disp('!!!! Some form of mis-match between number of recorded and planned trials.')
    return
end
MIData = [];                                                 % initialize main matrix

%% Main data segmentation process:
for trial = 1:trials
    [MIData] = sortElectrodes(MIData, EEG_data, EEG_event, Fs, trialLength, mark1Index(trial), numChans, trial);
end

save(strcat(recordingFolder,'\MIData.mat'),'MIData');

end
