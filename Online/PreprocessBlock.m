function [] = PreprocessBlock(block, Fs, recordingFolder)
%% Online Preprocessing
% Preprocessing using EEGLAB function. Assumes Wearable Sensing DSI-24 EEG
% The function preprocess raw data chunk as in the offline phase.
% Make sure parameters are in sync.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1f
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% Same parameters as in offline phase
electrodesToRemove = [];
plotLowPassHighPassFreqResp = 0;
plotScroll = 0;
plotSpectraMaps = 0;
useLowPassHighPass = 1;
useNotchHighPass = 1;
resampleFsHz = 120;
automaticNoiseRejection = 0;
automaticAverageReReference = 0;

blockPath = strcat(recordingFolder, '\', 'block.mat');
save(blockPath, 'block');

EEG = pop_importdata('dataformat', 'matlab', 'nbchan', 13, 'data', blockPath, 'srate', Fs, 'pnts', 0, 'xmin', 0);
EEG.setname = 'MI_sub';

% update channel names - each group should update this according to
% their own openBCI setup.
% EEG = pop_select(EEG, 'nochannel',1);% remove time stamp
EEG = pop_select(EEG, 'nochannel', electrodesToRemove);% remove because too noisy

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
numChans = size(EEG_chans, 1);

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
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5,'hicutoff', 50, 'plotfreqz', 1);
        EEG = eeg_checkset(EEG );
    else
        EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'hicutoff', 50);
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
    [~, V_Rejected_Sample_Range] = pop_rejcont(EEG, 'elecrange', [1:EEG.nbchan] ,'freqlimit', [0.5 50] , 'threshold', 10, 'epochlength', 0.5, 'contiguous', 4, 'addlength', 0.25, 'taper', 'hamming');
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

EEG_data = EEG.data;
MIData = [];
for channel=1:numChans
    MIData(1, channel ,:) = EEG_data(channel, :);    
end

% Save the data into .mat variables on the computer
save(strcat(recordingFolder,'\','MIData.mat'),'MIData');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
end

