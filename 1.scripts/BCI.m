clc; clear all; close all;
%%%%%% need to fix the time delays between each classification iteration %%%%%%

% add relevant paths to the script
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('C:\Users\tomer\Desktop\ALS\project\')); 
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\'))  % #### change according to your local liblsl path ####
warning('on');

%% load the model and its options
uiopen("load")
options = mdl_struct.options;
model = mdl_struct.model;
constants = options.constants;

% define some constants
remove_elec = constants.PREPROCESS_BAD_ELECTRODES;
start_buff = constants.BUFFER_START;
end_buff = constants.BUFFER_END;
Fs = constants.SAMPLE_RATE;
idle_label = constants.IDLE_LABEL;
left_label = constants.LEFT_LABEL;
right_label = constants.RIGHT_LABEL;
seg_dur = options.seg_dur;           % segments duration in seconds
overlap = options.overlap;           % following segments overlapping duration in seconds
sequence_len = options.sequence_len; % length of a sequence to enter in sequence DL models
step_size = seg_dur - overlap;

%% Lab Streaming Layer Init
lib = lsl_loadlib();
% resolve a stream...
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end
inlet = lsl_inlet(result{1});
inlet.open_stream()

%% extract data from stream, preprocess and classify
data = [];
predictions = ones(1,5);
data_size = floor(seg_dur*Fs + step_size*Fs*(sequence_len - 1) + start_buff + end_buff);
segment_size = floor(seg_dur*Fs + start_buff + end_buff);
while true
    tic;
    chunk = inlet.pull_chunk();
    chunk(remove_elec,:) = [];
    data = [data, chunk];
    if size(data,2) < data_size
        pause(0.1)
        continue
    end
    data = data(:,end - data_size + 1:end);

    % segment the data   
    start_idx = 1;
    for i = 1:sequence_len
        % create the ith segment
        seg_idx = (start_idx : start_idx + segment_size - 1); % data indices to segment
        segments(i,:,:) = data(:,seg_idx); % enter the current segment into segments
        start_idx = start_idx + floor(step_size*Fs); % add step size to the starting index
    end

    % filter the data
    filt_segments = Preprocess_block(segments, constants);

    % reorder dimentions to match the sequence input shape
    sequence = permute(filt_segments,[2,3,4,1]);

    % predict - using the last 5 predictions to prevent false positives
    predictions(1) = [];
    curr_prediction = classify(model, sequence);
    predictions(5) = double(curr_prediction);
    disp(predictions);
    if sum(predictions == 2) >= 2 || sum(predictions == 3) >= 2
        disp(predictions(end));
        predictions = ones(1,5);
        pause(3);
        continue
    else
        disp(predictions)
    end
    time = toc;
    pause(step_size - time); % pause till next iteration begins
    toc
end





