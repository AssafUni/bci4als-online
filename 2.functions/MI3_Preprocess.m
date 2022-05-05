function filt_data = MI3_Preprocess(segments, cont_or_disc, constants)
% this function is aplying the preprocess filtering phase in the pipeline. 
% It filters the data using BP and notch filters.
%
% Inputs:
%   - segments - a 3D matrix containing the segmented raw data, its
%   dimentions are [trials, channels, time (data samples)].
%   - cont_or_disc - a string specifying if the segmentation type is
%   continuous or discrete.
%
% Output:
%   - postprocces_segments - a 3D matrix of the segments after being
%   preproccesed, the dimentions are the same as in 'segments'

% Notes - add in the future:
% - see comments in the end the script

% define some usefull variables
num_trials   = size(segments,4);
num_channels = size(segments,1);

% import some constants for the filters design and filtering 
buff_start   = constants.BUFFER_START;
buff_end     = constants.BUFFER_END;
Fs           = constants.SAMPLE_RATE;
high_freq    = constants.HIGH_FREQ;
low_freq     = constants.LOW_FREQ;
high_width   = constants.LOW_WIDTH;
low_width    = constants.LOW_WIDTH;
notch_freq   = constants.NOTCH;
notch_width  = constants.NOTCH_WIDTH;

% implement a bandpass filter and a notch filter.
% we will use IIR filters to get faster preprocessing in the online sessions.

persistent BP_filter notch_filter; 

if isempty(BP_filter)
    % design an IIR bandpass filter
    h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', low_freq - low_width, low_freq, ...
    high_freq, high_freq + high_width, 60, 1, 60, Fs);
    
    BP_filter = design(h, 'cheby1', ...
        'MatchExactly', 'passband', ...
        'SOSScaleNorm', 'Linf');
    
    % design an IIR notch filter
    N  = 6;            % Order
    F0 = notch_freq;   % Center frequency
    BW = notch_width;  % Bandwidth
    
    h = fdesign.notch('N,F0,BW', N, F0, BW, Fs);


notch_filter = design(h, 'butter', ...
    'SOSScaleNorm', 'Linf');

set(notch_filter,'PersistentMemory',true);    % save the filter in memory for next function call
set(BP_filter,'PersistentMemory',true);       % save filter in memory for next function call
end

trial_length = size(segments,2);
filt_data = zeros(num_channels,trial_length - buff_start - buff_end, 1, num_trials);

if strcmp(cont_or_disc, 'discrete')
    for i = 1:num_trials
        % BP filtering
        temp = filter(BP_filter, squeeze(segments(:,:,:,i)).');
        temp = temp.';
        % notch filtering
        temp = filter(notch_filter, temp, 2);
        % allocate the filtered data into a new matrix
        filt_data(:,:,:,i) = temp(:,buff_start + 1:end - buff_end);
    end
elseif strcmp(cont_or_disc, 'continuous')
    % NOTICE that there is not difference between cont and disc for now we
    % might change it later if needed!
    for i = 1:num_trials
        % BP filtering
        temp = filter(BP_filter, squeeze(segments(:,:,:,i)).');
        temp = temp.';
        % notch filtering
        temp = filter(notch_filter, temp, 2);
        % allocate the filtered data into a new matrix
        filt_data(:,:,:,i) = temp(:,buff_start + 1:end - buff_end);
    end
else
    error('pls select a valid segmetation type for the variabe "cont_or_disc"!')
end

end

% consider adding in the future

% % remove blinks
% EEG = pop_autobsseog( EEG, 128, 128, 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[1  5]});
% EEG = pop_autobssemg( EEG, 5.12, 5.12, 'bsscca', {'eigratio', 1000000}, 'emg_psd', {'ratio', [10],'fs', 125,'femg', 15,'estimator', spectrum.welch({'Hamming'}, 62),'range', [0  8]});

% Automatic noise rejection using pop_rejcont
% if Configuration.PREPROCESS_NOISE_REJECTION ~= 0
%     [~, V_Rejected_Sample_Range] = pop_rejcont(EEG, 'elecrange', [1:EEG.nbchan] ,'freqlimit', [Configuration.PREPROCESS_LOW_PASS Configuration.PREPROCESS_HIGH_PASS] , 'threshold', 10, 'epochlength', 0.5, 'contiguous', 4, 'addlength', 0.25, 'taper', 'hamming');
%     EEG = pop_select(EEG, 'nopoint',V_Rejected_Sample_Range);
% end

% Apply LaPlacian Filter
% if Configuration.PREPROCESS_LAPLACIAN ~= 0
%     EEG.data(1,:) = EEG.data(1,:) - ((EEG.data(3,:) + EEG.data(5,:) + EEG.data(7,:) + EEG.data(9,:))./4);
%     EEG.data(2,:) = EEG.data(2,:) - ((EEG.data(4,:) + EEG.data(6,:) + EEG.data(8,:) + EEG.data(10,:))./4);
% end                