function [] = MI2_Preprocess(recordingFolder)
%% Offline Preprocessing
% recordingFolder - where the EEG (data & meta-data) are stored.
% Assumes openBCI 
% EEGLAB installed with ERPLAB & loadXDF plugins istalled

% Preprocessing using EEGLAB function. Assumes Wearable Sensing DSI-24 EEG
% 1. Load XDF file (Lab Recorder LSL output)
% 2. Look up channel names - each group on their own
% 3. Remove redundant channels - not necessary for openBCI
% 4. Resample data for faster preprocessing time
% 5. Re-reference to mastoid (or other) reference channel - done ANALOG by openBCI hardware
% 6. Filter data above 0.5 & below 40 Hz according to input
% 7. Notch filter @ 50 Hz according to input 

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function preprocess training data recorded earlier into
% $recordingFolder$. The xdf file should be named EEG.XDF.
% The function expects to be given several parameters as follows:
% 1. the recording folder used in the training
% 2. an array that cosists of the electrodes numbers you wish to remove.
%    (If an electrode during recording don't record any data or the data is too
%    noisy, this might cause errors).
% 3. 0 or 1 depending if you want to preform a low-high pass filter.
% 4. 0 or 1 depending if you want to preform a notch filder.
% 5. Some plotting options
% 6. Resampling and artifacts removal options

recordingFile = strcat(recordingFolder, '\', 'EEG.XDF');

% load subject data (assume XDF)
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname = 'MI_sub';

[EEG, EEG_chans] = PreprocessCommon(recordingFolder, EEG);

% Save the data into .mat variables on the computer
EEG_data = EEG.data;
EEG_event = EEG.event;
save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
                
end
