function [dataVar] = sortElectrodesGeneric(dataVar, condition, EEG_data, EEG_events, Fs, trialLength,subPlace, markIndex, EEG_chans)
%% sortElectrodes sorts the EEG_data into the dataVar by electrode name 
% after electrodes were removed in the preprocessing stage. Segments the
% data into trialLength.


% dataVar = over-arching main data storage structure
% condition = react (1-3 contrast conditions) / stare
% EEG_data = as outputed by the preprocessing stage
% EEG_events = event markers used to segment the data
% Fs = sample rate (used to transform time to sample points)
% trialLength = used to measure end of segment
% subPlace = index where to insert the data in dataVar
% markIndex = EEG_data segment location
% EEG_chans = channel information (name & location)

% First take out channel labels from original EEGLAB / XDF format
chans = struct('type', {EEG_chans(1:end).labels});
% For each channel, take data from the marker to trialLength
for channel=1:length(chans)
    dataVar(subPlace).(condition).(chans(channel).type) = EEG_data(channel,EEG_events(markIndex).latency : (EEG_events(markIndex).latency+Fs*(trialLength)));    
end


