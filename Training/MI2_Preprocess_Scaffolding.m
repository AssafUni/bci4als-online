function [] = MI2_Preprocess_Scaffolding(recordingFolder, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference)
%% Offline Preprocessing
% dataFolder - where the EEG (data & meta-data) are stored.
% Assumes openBCI 
% EEGLAB installed with ERPLAB & loadXDF plugins istalled

% Preprocessing using EEGLAB function. Assumes Wearable Sensing DSI-24 EEG
% 1. load XDF file (Lab Recorder LSL output)
% 2. look up channel names - each group on their own
% 3. remove redundant channels - not necessary for openBCI
% 4. re-reference to mastoid (or other) reference channel - done ANALOG by openBCI hardware
% 5. filter data above 0.5 & below 40 Hz
% 6. notch filter @ 50 Hz
% 7. advanced artifact removal (ICA/ASR/Cleanline...) - EEGLAB functionality

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

subjects = 1;                               % change if using multiple user paradigm
sessions = 1;                               % change if using multiple sessions on same person
recordingFile = strcat(recordingFolder,'\','EEG.XDF');

% load subject data (assume XDF)
EEG = pop_loadxdf(recordingFile, 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG.setname = 'MI_sub';

% Apply LaPlacian Filter
EEG.data(3,:) = EEG.data(3,:) - ((EEG.data(11,:) + EEG.data(13,:) + EEG.data(5,:) + EEG.data(9,:))./4);
EEG.data(4,:) = EEG.data(4,:) - ((EEG.data(12,:) + EEG.data(14,:) + EEG.data(6,:) + EEG.data(10,:))./4);

% update channel names - each group should update this according to
% their own openBCI setup.
% EEG = pop_select(EEG, 'nochannel',1);% remove time stamp
EEG = pop_select(EEG, 'nochannel', electrodesToRemove);% remove because too noisy

EEG_chans(1,:) = 'P03'; % ??
EEG_chans(2,:) = 'P04'; % ??
EEG_chans(3,:) = 'C03'; % ??
EEG_chans(4,:) = 'C04';
EEG_chans(5,:) = 'CP5';
EEG_chans(6,:) = 'CP6';
EEG_chans(7,:) = '001';
EEG_chans(8,:) = '002';
EEG_chans(9,:) = 'CP1';
EEG_chans(10,:) = 'CP2';
EEG_chans(11,:) = 'FC1';
EEG_chans(12,:) = 'FC2';
EEG_chans(13,:) = 'FC5';
EEG_chans(14,:) = 'FC6';
EEG_chans(15,:) = 'C0Z';
EEG_chans(16,:) = 'FPz';

EEG_chans(electrodesToRemove, :) = [];

if plotScroll ~= 0
    pop_eegplot(EEG, 1, 1, 1);
end

% Resampling using the resampleFsHz parameter in HZ
if resampleFsHz ~= 0
    EEG = pop_resample(EEG, resampleFsHz);
end

% Filtering low-pass and high-pass using useLowPassHighPass parameter
if useLowPassHighPass ~= 0
    if plotLowPassHighPassFreqResp ~= 0
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5,'hicutoff', 40, 'plotfreqz', 1);
        EEG = eeg_checkset(EEG );
    else
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'hicutoff', 40);
        EEG = eeg_checkset(EEG );
    end
end

% Filtering notch and high-pass using useNotchHighPass parameter
if useNotchHighPass ~= 0
    if plotLowPassHighPassFreqResp ~= 0
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'plotfreqz', 1);
        EEG = eeg_checkset(EEG );  
    else
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5);
        EEG = eeg_checkset(EEG );  
    end
    
    % notch filter - this uses the ERPLAB filter
    EEG  = pop_basicfilter(EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
    EEG = eeg_checkset(EEG );
end

% Automatic noise rejection using pop_rejcont
if automaticNoiseRejection ~= 0
    [~, V_Rejected_Sample_Range] = pop_rejcont(EEG, 'elecrange', [1:EEG.nbchan] ,'freqlimit', [0.5 40] , 'threshold', 10, 'epochlength', 0.5, 'contiguous', 4, 'addlength', 0.25, 'taper', 'hamming');
    EEG = pop_select(EEG, 'nopoint',V_Rejected_Sample_Range);
end
    
% Average referencing
if automaticAverageReReference ~= 0
    EEG = pop_reref(EEG, []);
end

if plotScroll ~= 0
    pop_eegplot(EEG, 1, 1, 1);
end

if plotSpectraMaps ~= 0
    figure; pop_spectopo(EEG, 1, [0      238304.6875], 'EEG' , 'percent', 50, 'freq', [6 10 22], 'freqrange',[0 64],'electrodes','off');
end

% Save the data into .mat variables on the computer
EEG_data = EEG.data;
EEG_event = EEG.event;
save(strcat(recordingFolder,'\','cleaned_sub.mat'),'EEG_data');
save(strcat(recordingFolder,'\','EEG_events.mat'),'EEG_event');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
                
end
