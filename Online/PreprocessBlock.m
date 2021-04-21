function [] = PreprocessBlock(block, Fs, recordingFolder)
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

EEG = pop_importdata('dataformat', 'matlab', 'nbchan', 16, 'data', blockPath, 'srate', Fs, 'pnts', 0, 'xmin', 0);
EEG.setname = 'MI_sub';

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
numChans = size(EEG_chans, 1);

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

EEG_data = EEG.data;
MIData = [];
for channel=1:numChans
    MIData(1, channel ,:) = EEG_data(channel, :);    
end

% Save the data into .mat variables on the computer
save(strcat(recordingFolder,'\','MIData.mat'),'MIData');
save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
end

