function [seq_data, seq_label] = create_sequence(data, labels, seq_len)
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
    error('need to return data as a cell array if seq_len = 1!!') % a reminder for what needs to be done
    seq_data = data;
    seq_label = labels;
    return
end

% define the new label vector
seq_label = labels(seq_len:end);

% create the sequences of the eeg recordings
num_of_rec = size(data,1); % number of recordings
seq_data = cell(num_of_rec - seq_len, 1); % initialize an empty cell to contain the sequences

for i = seq_len:size(data,1)
    seq_data{i - seq_len + 1} = data(i - seq_len + 1:i,:,:);
end
end
