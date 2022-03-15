function [segments, labels, EEG_chans] = MI2_SegmentData(recordingFolder, cont_or_disc, seg_dur, overlap, thresh)
% Segment data using markers
% This function segments the continuous data into trials or epochs creating
% a 3D matrix where dimentions are - [trial, channels, time (data samples)]
%
% Input: 
%   - recordingFolder - a path of the folder containing the EEG.xdf file
%   - cont_or_disc - segmentation type, 'discrete' or 'continuous'
%   - seg_dur - segmentation duration in seconds, only relevant if
%   cont_or_disc = 'continuous'
%   - overlap - overlap between following segmentations,only relevant if
%   cont_or_disc = 'continuous'
%
% Output: 
%   - segments - a 3D matrix containing segments of the raw data,
%   dimentions are [trial, channels, time (sampled data)]
%   - labels - a label vector coresponding to the trials in segments
%


% load subject data and labels
recordingFile = strcat(recordingFolder, '\', 'EEG.XDF');
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG');
load(strcat(recordingFolder, '\labels.mat')); % load the labels vector 

% Parameters and previous variables:
Fs = Configuration.SAMPLE_RATE;               % sample rate
trialLength = Configuration.TRIAL_LENGTH;     % each trial length

% define the channels names - change path to where the channel_loc.ced file is at
EEG = pop_chanedit(EEG, 'load',{'..\..\interfaces\channel_loc.ced','filetype','autodetect'},'rplurchanloc',1);
EEG_chans = transpose(string({EEG.chanlocs(:).labels}));

% extract the events and data
EEG_event = EEG.event;
EEG_data = EEG.data;

% remove unwanted channels
chan2remove = Configuration.PREPROCESS_BAD_ELECTRODES; % indices of chanels to remove
EEG_data(chan2remove,:) = [];

% update the EEG structure
EEG.data = EEG_data;
EEG.nbchan = EEG.nbchan - length(chan2remove);

% check for inconsistencies in the events data and the labels vector
num_labels = length(labels);   % derive number of trials from training label vector
for i = 1:length(EEG_event)
    if strcmp('1111.000000000000',EEG_event(i).type)  % find trial start marker
        markerIndex(i) = 1;                           % index markers
    else
        markerIndex(i) = 0;
    end
end
markerIndex = find(markerIndex);  % index of each trial start
num_trials = length(markerIndex); % derive number of trials from start markers

if num_trials ~= num_labels       % Check for consistancy across events & trials
    error(['Some form of mis-match between number of recorded and planned trials!' newline...
        'pls check the labels vector and the event data'])
end

% segmentation process
segments = [];                 % initialize an empty matrix
numChans = size(EEG_chans,1);  % number of channels 
if strcmp(cont_or_disc, 'discrete')
    for trial = 1:num_trials
        [segments, remove_label] = segment_discrete(segments, EEG_data, EEG_event, Fs, trialLength, markerIndex(trial), trial);
        if remove_label
            labels(trial) = nan;
        end
    end
    labels(isnan(labels)) = [];
    segments(isnan(segments(:,1,1)),:,:) = [];
elseif strcmp(cont_or_disc, 'continuous')
    [segments, labels] = segment_continouos(EEG, seg_dur, overlap, thresh);
end
end
