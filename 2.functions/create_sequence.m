function [seq_data, seq_label, seg_time_sampled] = create_sequence(data, labels, seq_len, seg_time_sampled)
% this function creates a sequence of eeg data recordings
%
% Inputs:
%
%
% Outputs:
%
%
%


% if sequence length is 1 then dont perform sequencing!
if seq_len == 1
    seq_data = squeeze(mat2cell(data, size(data,1), size(data,2), size(data,3), ones(size(data,4),1)));
    seq_label = labels;
    return
end

% define the new label vector
seq_label = labels(seq_len:end);
seg_time_sampled = seg_time_sampled(seq_len:end);

% create the sequences of the eeg recordings
num_of_rec = size(data,4); % number of recordings
seq_data = cell(num_of_rec - seq_len, 1); % initialize an empty cell to contain the sequences

for i = seq_len:size(data,4)
    seq_data{i - seq_len + 1} = data(:,:,:,i - seq_len + 1:i);
end
end
