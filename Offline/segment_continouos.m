function [segments, labels] = segment_continouos(EEGstruct, segment_duration, overlap_duration, class_thres)
% this function creates a continouos segmentation of the raw data
%
% Input:
%   - EEGstruct - the eeg structure loaded from the EEG.xdf file
%   - segment_duration - the duration of each segment in seconds.
%   - overlap_duration - the overlap duration between following
%   segmentations in seconds.
%   - class_thres - a threshold for the classification of every segment,
%   int between 0-1.
%
% Output:
%   - segments - a 3D matrix of the segmented data, dimentions are -
%   [trials, channels, time (sampled data)].
%   - labels - labels vector for the segmented data
%

CONSTANTS = Configuration();
start_buff = CONSTANTS.BUFFER_START;
end_buff = CONSTANTS.BUFFER_END;

% extract the times events and data from EEGstruc
times = EEGstruct.times;
events = squeeze(struct2cell(EEGstruct.event)).';
data = EEGstruct.data;
marker_times = cell2mat(events(:,2));
marker_sign = cell2mat(events(:,1));

% reject data prior to recording start marker and after recording end marker
start_rec_marker_idx = strcmp(events(:,1),'111.0000000000000');
end_rec_marker_idx = strcmp(events(:,1),'99.00000000000000');
if sum(start_rec_marker_idx) > 1 || find(start_rec_marker_idx) ~= 1 || sum(end_rec_marker_idx) > 1 || find(end_rec_marker_idx) ~= size(events,1)
    error(['there is a problem in the events structure due to one of the reasons:' newline...
        '1. start recording marker has been marked more than once.' newline...
        '2. there is more then 1 marker for starting recording' newline...
        '3. end recording marker has been marked more than once.' newline...
        '4. there is more then 1 marker for ending recording' newline...
        'pls review the events structure to find the problem and fix it'])
end
end_rec_idx = events{end_rec_marker_idx,2};
start_rec_idx = events{start_rec_marker_idx,2};
% data(:,end_rec_idx + end_buff:end) = []; % delete the data after expirement ended
% data(:,1:start_rec_idx - start_buff) = []; % delete the data prior to expirement start time

% define segmentation parameters
Fs = Configuration.SAMPLE_RATE;          % sample rate
segment_size = segment_duration*Fs + start_buff + end_buff;      % segments size
overlap_size = overlap_duration*Fs +start_buff + end_buff;      % overlap between every 2 segments
step_size = segment_size - overlap_size; % step size between 2 segments


% initialize empty segments matrix and labels vector
num_segments = floor((size(data,2) - segment_size)/step_size) + 1;
num_channels = EEGstruct.nbchan;
segments = zeros(num_segments, num_channels, segment_size);
labels = zeros(1, num_segments);

% create a support vector containing the movement tag in each timestamp
sup_vec = zeros(1,length(times));
for j = 1:length(times)
    last_markers = find(marker_times <= j);
    if isempty(last_markers)
        sup_vec(j) = 1;
    elseif strcmp(marker_sign(last_markers(end),:), '2.000000000000000')
        sup_vec(j) = 2;
    elseif strcmp(marker_sign(last_markers(end),:), '3.000000000000000')
        sup_vec(j) = 3;
    else
        sup_vec(j) = 1;
    end
end
% sup_vec(end_rec_idx + end_buff:end) = [];  % delete the labels after expirement ended
% sup_vec(1:start_rec_idx - start_buff) = [];  % delete the labels prior to expirement start time


% segment the data and create a new labels vector
start_idx = 1;
for i = 1:num_segments
    % create the ith segment
    seg_idx = (start_idx : start_idx + segment_size - 1); % data indices to segment
    segments(i,:,:) = data(:,seg_idx); % enter the current segment into segments
    start_idx = start_idx + step_size; % add step size to the starting index

    % find the ith label
    tags = sup_vec(seg_idx);
    tags = tags(start_buff + 1: end - end_buff);
    class_2 = sum(tags == 2);
    class_3 = sum(tags == 3);
    if class_2 >=  (segment_size - start_buff - end_buff)*class_thres
        labels(i) = 2;
    elseif class_3 >=  (segment_size - start_buff - end_buff)*class_thres
        labels(i) = 3;    
    else
        labels(i) = 1; 
    end
end
end