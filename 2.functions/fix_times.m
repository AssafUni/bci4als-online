function [sup_vec, time_samp] = fix_times(sup_vec, time_samp)
% fix time points to be continuous for better visualization
%
% Inputs:
%   sup_vec: a 2-d array, in the first row there are the labels of each
%            time point, and in row 2 there are the time points
%   time_samp: the end time of each segment sampled from the data
%
% Outputs:
%   sup_vec: a 2-d array, in the first row there are the labels of each
%            time point, and in row 2 there are the fixed, continuous, time points
%   time_samp: the fixed, continuous, end time of each segment sampled from the data
%

if isempty(sup_vec) || isempty(time_samp)
    sup_vec = [];
    time_samp = [];
    return
end

time = [sup_vec(2,:) 0]; % we concatenate the 0 for the for loop to be able to correct the last recording
time_diff = time(2:end) - time(1:end-1);
new_rec_idx = find(time_diff < 0) + 1;

time_samp = [time_samp 0]; % we concatenate the 0 for the for loop to be able to correct the last recording
all_time_diff = time_samp(2:end) - time_samp(1:end-1);
new_rec_idx_seg = find(all_time_diff < 0) + 1;

% make the time continuous
for i = 1:length(new_rec_idx) - 1
    time(new_rec_idx(i):new_rec_idx(i + 1) - 1) = time(new_rec_idx(i):new_rec_idx(i + 1) - 1) + time(new_rec_idx(i) - 1);
    time_samp(new_rec_idx_seg(i):new_rec_idx_seg(i + 1) - 1) = time_samp(new_rec_idx_seg(i):new_rec_idx_seg(i + 1) - 1) + time(new_rec_idx(i) - 1);
end

time(end) = [];      % remove the added time point
time_samp(end) = []; % remove the added time point
sup_vec(2,:) = time; % update the time points in the support vector

end