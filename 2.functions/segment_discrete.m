function [segments, labels, sup_vec, seg_time_sampled] = segment_discrete(EEGstruct, seg_dur, constants)

% extract the times events and data from EEGstruc
times = EEGstruct.times;
events = squeeze(struct2cell(EEGstruct.event)).';
data = EEGstruct.data;
marker_times = cell2mat(events(:,2));
marker_sign = events(:,1);

% define segmentation parameters
buff_start = constants.BUFFER_START; % buffer befor the segment
buff_end = constants.BUFFER_END;     % buffer after the segment
Fs = constants.SAMPLE_RATE;          % sample rate
segment_size = floor(seg_dur*Fs); % segments size

% create a support vector containing the movement class in each timestamp
% and an array of the time every segment ends
seg_time_sampled_indices = marker_times(strcmp(marker_sign, '9.000000000000000'));
times = (0:(length(times) - 1))./Fs;
seg_time_sampled = times(seg_time_sampled_indices);
sup_vec = zeros(1,length(times));
for j = 1:length(times)
    last_markers = find(marker_times <= j);
    if isempty(last_markers)
        sup_vec(j) = 1;
    elseif strcmp(marker_sign{last_markers(end)}, '2.000000000000000')
        sup_vec(j) = 2;
    elseif strcmp(marker_sign{last_markers(end)}, '3.000000000000000')
        sup_vec(j) = 3;
    else
        sup_vec(j) = 1;
    end
end
times = [times, ((1:124).*(1./Fs) + times(end))]; % add time points for future concatenating
sup_vec = [sup_vec, zeros(1,124)]; % add zeros for future concatenating
sup_vec = [sup_vec; times];

% get the labels
labels = str2double(marker_sign(strcmp(marker_sign, '3.000000000000000') | ...
    strcmp(marker_sign, '2.000000000000000') | strcmp(marker_sign, '1.000000000000000'))); 

% segment the data 
start_times_indices = marker_times(strcmp(marker_sign, '1111.000000000000'));
segments = [];
for i = 1:length(start_times_indices)
    if start_times_indices(i) - buff_start < 1
        labels(1) = [];
        seg_time_sampled(1) = [];
        continue
    elseif start_times_indices(i) + segment_size + buff_end > size(data, 2)
        labels(end) = [];
        seg_time_sampled(end) = [];
        continue
    end
        segments(:,:,end + 1) = data(:,start_times_indices(i) - buff_start : start_times_indices(i) + segment_size + buff_end - 2);
end
segments(:,:,1) = []; % clear zeros
end

