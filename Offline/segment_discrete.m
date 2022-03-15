function [dataVar, remove_label] = segment_discrete(dataVar, EEG_data, EEG_event, Fs, trialLength, markIndex, trial)
%% sortElectrodes sorts the EEG_data into the dataVar by electrode name 
% after electrodes were removed in the preprocessing stage. Segments the
% data into trialLength + buffer.

% dataVar = over-arching main data storage structure
% EEG_data = as outputed by the preprocessing stage
% EEG_events = event markers used to segment the data
% Fs = sample rate (used to transform time to sample points)
% trialLength = used to measure end of segment
% markIndex = EEG_data segment location
% EEG_chans = channel information (name & location)

% add a buffer prior for each segment for the filtering phase
CONSTANTS = Configuration();
buff_start = CONSTANTS.BUFFER_START;
buff_end = CONSTANTS.BUFFER_END;

remove_label = 0;

if (EEG_event(markIndex).latency) - buff_start < 1
    remove_label = 1;
    dataVar(trial,:,:) = nan;
    return
end

dataVar(trial,:,:) = EEG_data(:,(EEG_event(markIndex).latency) - buff_start : (EEG_event(markIndex).latency + Fs*(trialLength) + buff_end));
end
