function [] = MI2_Preprocess(recordingFolder, electrodesToRemove, useLowPassHighPass, useNotchHighPass, plotLowPassHighPassFreqResp, plotScroll, plotSpectraMaps, resampleFsHz, automaticNoiseRejection, automaticAverageReReference)
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

% remove blinks
EEG = pop_autobsseog( EEG, 128, 128, 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[1  5]});
EEG = pop_autobssemg( EEG, 5.12, 5.12, 'bsscca', {'eigratio', 1000000}, 'emg_psd', {'ratio', [10],'fs', 125,'femg', 15,'estimator', spectrum.welch({'Hamming'}, 62),'range', [0  8]});

% Apply LaPlacian Filter
%%%%% Change according to your wiring and keep in sync with online LaPlacian
EEG.data(1,:) = EEG.data(1,:) - ((EEG.data(3,:) + EEG.data(5,:) + EEG.data(7,:) + EEG.data(9,:))./4);
EEG.data(2,:) = EEG.data(2,:) - ((EEG.data(4,:) + EEG.data(6,:) + EEG.data(8,:) + EEG.data(10,:))./4);

% update channel names - each group should update this according to
% their own openBCI setup.
% EEG = pop_select(EEG, 'nochannel',1);% remove time stamp
EEG = pop_select(EEG, 'nochannel', electrodesToRemove);% remove because too noisy

% Add OR change channels according to your wiring
EEG_chans(1,:) = 'C03'; 
EEG_chans(2,:) = 'C04'; 
EEG_chans(3,:) = 'CP1'; 
EEG_chans(4,:) = 'CP2';
EEG_chans(5,:) = 'FC1';
EEG_chans(6,:) = 'FC2';
EEG_chans(7,:) = 'CP5';
EEG_chans(8,:) = 'CP6';
EEG_chans(9,:) = 'FC5';
EEG_chans(10,:) = 'FC6';
EEG_chans(11,:) = 'T03';
EEG_chans(12,:) = 'T04';
EEG_chans(13,:) = 'C0Z';

% Removing channels according to input
EEG_chans(electrodesToRemove, :) = [];

% Plot eeglab scroll plot
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
