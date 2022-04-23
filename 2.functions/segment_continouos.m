function [segments, labels, sup_vec, seg_time_sampled] = segment_continouos(EEGstruct, segment_duration, overlap_duration, class_thres, constants)
% this function creates a continouos segmentation of the raw data
%
% Input:
%   EEGstruct: the eeg structure loaded from the EEG.xdf file
%   segment_duration: the duration of each segment in seconds.
%   overlap_duration: the overlap duration between following
%                     segmentations in seconds.
%   class_thres: a threshold for the classification of every segment,
%                int between [0,1].
%
% Output:
%   segments: a 3D matrix of the segmented data, dimentions are -
%             [trials, channels, time (sampled data)].
%   labels: labels vector for the segmented data
%   sup_vec: a vector of indications of the class presented in each
%            timestemp
%

start_buff = constants.BUFFER_START;
end_buff = constants.BUFFER_END;

% extract the times events and data from EEGstruc
times = EEGstruct.times;
events = squeeze(struct2cell(EEGstruct.event)).';
data = EEGstruct.data;
marker_times = cell2mat(events(:,2));
marker_sign = cell2mat(events(:,1));


% make some verifications on the markers
start_rec_marker_idx = strcmp(events(:,1),'111.0000000000000');
end_rec_marker_idx = strcmp(events(:,1),'99.00000000000000');
if sum(start_rec_marker_idx) > 1 || find(start_rec_marker_idx) ~= 1 || sum(end_rec_marker_idx) > 1 || find(end_rec_marker_idx) ~= size(events,1)
    error(['there is a problem in the events structure due to one of the reasons:' newline...
        '1. Start recording marker has been marked more than once.' newline...
        '2. There is more than 1 marker for starting recording' newline...
        '3. End recording marker has been marked more than once.' newline...
        '4. There is more than 1 marker for ending recording' newline...
        'Pls review the events structure to find the problem and fix it'])
end

% define segmentation parameters
Fs = constants.SAMPLE_RATE;          % sample rate
segment_size = floor(segment_duration*Fs + start_buff + end_buff);      % segments size
overlap_size = floor(overlap_duration*Fs +start_buff + end_buff);      % overlap between every 2 segments
step_size = segment_size - overlap_size; % step size between 2 segments


% initialize empty segments matrix and labels vector
num_segments = floor((size(data,2) - segment_size)/step_size) + 1;
num_channels = EEGstruct.nbchan;
segments = zeros(num_segments, num_channels, segment_size);
labels = zeros(num_segments, 1);

% create a support vector containing the movement class in each timestamp
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

% segment the data and create a new labels vector
times = (0:(length(times) - 1))./Fs;
seg_time_sampled = zeros(1,num_segments);
start_idx = 1;
for i = 1:num_segments
    % create the ith segment
    seg_idx = (start_idx : start_idx + segment_size - 1); % data indices to segment
    segments(i,:,:) = data(:,seg_idx); % enter the current segment into segments
    start_idx = start_idx + step_size; % add step size to the starting index

    % track time stamps of the end of segments
    seg_time_sampled(i) = times(seg_idx(end) - end_buff);

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
sup_vec(seg_idx(end) - end_buff + 1:end) = []; % trim unused labels
times(seg_idx(end) - end_buff + 1:end) = []; % trim unused times
times = [times, ((1:(step_size - 1)).*(1./Fs) + times(end))]; % add time points for future concatenating
sup_vec = [sup_vec, zeros(1,step_size - 1)]; % add zeros for future concatenating
sup_vec = [sup_vec; times];
end