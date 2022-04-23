function filt_data = Preprocess_block(segments, constants)
% this function is aplying the preprocess filtering phase in the pipeline. 
% It filters the data using BP and notch filters.
%
% Inputs:
%   - segments - a 3D matrix containing the segmented raw data, its
%   dimentions are [trials, channels, time (data samples)].
%
% Output:
%   - filt_data - a 3D matrix of the segments after being
%   preproccesed, the dimentions are the same as in 'segments'

% Notes - add in the future:
% 1. Remove redundant channels
% 2. redifine bad channels as an interpulation of it's neighbor channels 
% 3. see comments in the end the script

% define some usefull variables
num_trials   = size(segments,1);
num_channels = size(segments,2);

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

trial_length = size(segments,3);
filt_data = zeros(num_trials,num_channels,trial_length - buff_start - buff_end);


for i = 1:num_trials
    % BP filtering
    temp = filter(BP_filter, squeeze(segments(i,:,:)).');
    temp = temp.';
    % notch filtering
    temp = filter(notch_filter, temp, 2);
    % allocate the filtered data into a new matrix
    filt_data(i,:,:) = temp(:,buff_start + 1:end - buff_end);
end
end
         