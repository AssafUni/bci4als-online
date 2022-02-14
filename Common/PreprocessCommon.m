function [EEG, EEG_chans] = PreprocessCommon(recordingFolder, EEG)
    EEG = pop_select(EEG, 'nochannel', Configuration.PREPROCESS_BAD_ELECTRODES);% remove because too noisy

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
    EEG_chans(Configuration.PREPROCESS_BAD_ELECTRODES, :) = [];
    numChans = size(EEG_chans, 1);

    % TODO: for now removing it from here
    % % remove blinks
    % EEG = pop_autobsseog( EEG, 128, 128, 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[1  5]});
    % EEG = pop_autobssemg( EEG, 5.12, 5.12, 'bsscca', {'eigratio', 1000000}, 'emg_psd', {'ratio', [10],'fs', 125,'femg', 15,'estimator', spectrum.welch({'Hamming'}, 62),'range', [0  8]});

    % Apply LaPlacian Filter
    %%%%% Change according to your wiring and keep in sync with online LaPlacian
    EEG.data(1,:) = EEG.data(1,:) - ((EEG.data(3,:) + EEG.data(5,:) + EEG.data(7,:) + EEG.data(9,:))./4);
    EEG.data(2,:) = EEG.data(2,:) - ((EEG.data(4,:) + EEG.data(6,:) + EEG.data(8,:) + EEG.data(10,:))./4);

    % assuming no  need to resample
    % Resampling using the resampleFsHz parameter in HZ
    if Configuration.SAMPLE_RATE ~= 0
        EEG = pop_resample(EEG, Configuration.SAMPLE_RATE);
    end

    % Filtering low-pass and high-pass using useLowPassHighPass parameter
    % if you want to plot uncomment below
    %EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5,'hicutoff', 40, 'plotfreqz', 1);
    EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'hicutoff', Configuration.PREPROCESS_HIGH_PASS);
    EEG = eeg_checkset(EEG );  

    % Filtering notch and high-pass using useNotchHighPass parameter
    % if you want to plot uncomment below
    %EEG = pop_eegfiltnew(EEG, 'locutoff', 0.5, 'plotfreqz', 1);
    EEG = pop_eegfiltnew(EEG, 'locutoff', Configuration.PREPROCESS_LOW_PASS);
    EEG = eeg_checkset(EEG );      

    % notch filter - this uses the ERPLAB filter
    EEG  = pop_basicfilter(EEG,  1:EEG.nbchan , 'Boundary', 'boundary', 'Cutoff',  Configuration.PREPROCESS_NOTCH, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
    EEG = eeg_checkset(EEG );

    % Automatic noise rejection using pop_rejcont
    if Configuration.PREPROCESS_NOISE_REJECTION ~= 0
        [~, V_Rejected_Sample_Range] = pop_rejcont(EEG, 'elecrange', [1:EEG.nbchan] ,'freqlimit', [Configuration.PREPROCESS_LOW_PASS Configuration.PREPROCESS_HIGH_PASS] , 'threshold', 10, 'epochlength', 0.5, 'contiguous', 4, 'addlength', 0.25, 'taper', 'hamming');
        EEG = pop_select(EEG, 'nopoint',V_Rejected_Sample_Range);
    end

    % Average referencing
    if Configuration.PREPROCESS_AVG_REREF ~= 0
        EEG = pop_reref(EEG, []);
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

