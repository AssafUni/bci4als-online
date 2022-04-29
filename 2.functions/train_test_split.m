function [train, train_labels, test_set, test_labels, val, val_labels, ...
    train_sup_vec, test_sup_vec, val_sup_vec, train_time_samp, val_time_samp, ...
    test_time_samp, test_rec_idx, val_rec_idx] = train_test_split(data_paths, options)
% this function read the recordings data segment and preprocces it and then 
% splits it into train, test and validation sets while maintaining an even
% class distribution between these sets.
%
% Inputs:
%   data_paths: folder paths to where the data (XDF file) is stored
%   options: a structure containing the options of the split function
%
% Outputs:
%   train\test\val: a cell array containing the train\test\val set, each
%                   cell contains one sample of recorded data.
%   train\test\val_labels: an array containing the train\test\val labels.
%   train\test\val_sup_vec: an array containing the class of each time
%                           stamp in its first row and the time stamps in
%                           its second row for train\test\val set
%   test\val_rec_idx: indices of the recordings selcted for test\val set
%   train\test\val_time_samp: array containing the time stamps of each 
%                             segment end time for train\test\val set

%% things to add:
% - an output containing the indices of each recording in each set
% - an output containing the paths of each set
% - 

%% extract the parameters from options structure for later use
test_split_ratio = options.test_split_ratio; % percent of the data which will go to the test set
cross_rec        = options.cross_rec;        % true - test and train share recordings, false - tests are a different recordings then train
feat_or_data     = options.feat_or_data;     % return "train" as data or features
val_split_ratio  = options.val_split_ratio;  % percentage of data to allocate to validation set from training set
feat_alg         = options.feat_alg;         % feature extraction algorithm choose from {'basic', 'wavelet'}
cont_or_disc     = options.cont_or_disc;     % segmentation type choose from {'discrete', 'continouos'}
seg_dur          = options.seg_dur;          % segments duration in seconds
overlap          = options.overlap;          % following segments overlapping duration in seconds
thresh           = options.threshold;        % threshold for labeling in continuous segmentation
seq_len          = options.sequence_len;     % length of a sequence to enter in sequence DL models
constants        = options.constants;        % a class member with constants that are used in the pipeline 

%% define empty matrices and cells
all_set        = []; all_labels    = []; all_sup_vec    = []; all_time_samp   = [];
train          = []; train_labels  = []; train_sup_vec  = []; train_time_samp = [];
test_set       = []; test_labels   = []; test_sup_vec   = []; test_time_samp  = [];
val            = []; val_labels    = []; val_sup_vec    = []; val_time_samp   = [];
test_rec_idx   = []; val_rec_idx   = [];

num_total_rec = length(data_paths);
curr_segment = cell(num_total_rec,1); curr_label = cell(num_total_rec,1); 
curr_sup_vec = cell(num_total_rec,1); curr_time_sampled = cell(num_total_rec,1);
curr_data = cell(num_total_rec,1);

%% if there are not enought recording sessions then dont split base on different recordings
if 0 < length(data_paths)*test_split_ratio && length(data_paths)*test_split_ratio < 1 && ~cross_rec
    cross_rec = true;
    uiwait(msgbox(['not enought recordings for different recording split hence split' newline...
        'is done regulary, meaning "cross_rec = true"' newline 'pls press any key to continue!']));
end

%% if a discrete segmentation is chosen and sequence length is not 1 then change it to 1
if strcmp(cont_or_disc, 'discrete') && seq_len ~= 1
    seq_len = 1;
    uiwait(msgbox('Since you chose a discrete segmentation, sequence length is set to 1!'));
end

%% create a waitbar to show progress
f = waitbar(0, 'preprocessing data, pls wait');
warning('off');

%% extract features or raw data from folders paths
for i = 1:num_total_rec
    waitbar(i/num_total_rec, f, ['preprocessing data, recording ' num2str(i) ' out of ' num2str(num_total_rec)]);
    folder = data_paths{i};
    [curr_segment{i}, curr_label{i}, curr_sup_vec{i}, curr_time_sampled{i}] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh, constants); % segment the raw data
    curr_segment{i} = MI3_Preprocess(curr_segment{i}, cont_or_disc, constants); % aplly filters - iir BP and notch
    if strcmp(feat_or_data, 'feat')
        curr_data{i} = get_features(curr_segment{i}, feat_alg);
    end
    [curr_data{i}, curr_label{i}, curr_time_sampled{i}] = create_sequence(curr_segment{i}, curr_label{i}, seq_len, curr_time_sampled{i});
end

% close the waitbar
delete(f);
warning('on')

%% split into train val and test sets
if ~cross_rec % take different recordings for each set
    % set indices for each set
    num_test_val_rec = round(num_total_rec*(test_split_ratio + val_split_ratio));
    rec_idx          = randperm(num_total_rec, num_test_val_rec);
    num_test_rec     = round(num_total_rec*test_split_ratio);
    idx              = randperm(length(rec_idx), num_test_rec);
    test_rec_idx     = rec_idx(idx);
    rec_idx(idx)     = [];
    val_rec_idx      = rec_idx;
    % agregate and split the data, labels etc...
    for i = 1:num_total_rec
        if ismember(i,test_rec_idx)
            test_set        = cat(1, test_set, curr_data{i});
            test_labels     = cat(1, test_labels, curr_label{i});
            test_sup_vec    = cat(2, test_sup_vec, curr_sup_vec{i});
            test_time_samp  = cat(2, test_time_samp, curr_time_sampled{i});
        elseif ismember(i,val_rec_idx)
            val             = cat(1, val, curr_data{i});
            val_labels      = cat(1, val_labels, curr_label{i});
            val_sup_vec     = cat(2, val_sup_vec, curr_sup_vec{i});
            val_time_samp   = cat(2, val_time_samp, curr_time_sampled{i});
        else
            train           = cat(1, train, curr_data{i});
            train_labels    = cat(1, train_labels, curr_label{i});
            train_sup_vec   = cat(2, train_sup_vec, curr_sup_vec{i});
            train_time_samp = cat(2, train_time_samp, curr_time_sampled{i});
        end
    end
    % fix time points to be continuous
    [test_sup_vec, test_time_samp]   = fix_times(test_sup_vec, test_time_samp);
    [val_sup_vec, val_time_samp]     = fix_times(val_sup_vec, val_time_samp);
    [train_sup_vec, train_time_samp] = fix_times(train_sup_vec, train_time_samp);

else        % same recording sessions for train val and test
    % agregate all data
    for i = 1:num_total_rec
        all_set       = cat(1, all_set, curr_data{i});
        all_labels    = cat(1, all_labels, curr_label{i});
        all_sup_vec   = cat(2, all_sup_vec, curr_sup_vec{i});
        all_time_samp = cat(2, all_time_samp, curr_time_sampled{i});
    end
    [all_sup_vec, all_time_samp] = fix_times(all_sup_vec, all_time_samp);
    % keep an even distribution of labels in the split sets
    c = cvpartition(all_labels, 'Holdout', test_split_ratio);
    test_set       = all_set(test(c),:,:);
    test_labels    = all_labels(test(c));
    test_time_samp = all_time_samp(test(c));
    all_set(test(c),:,:)   = [];      % remove test data from all_set
    all_labels(test(c))    = [];      % remove test labels from all_labels
    all_time_samp(test(c)) = [];      % remove test time sampled from all_time_samp
    ratio = 1/(1 - test_split_ratio); % the ratio between old all_set and new all_set size
    c = cvpartition(all_labels, 'Holdout', val_split_ratio*ratio); % notice that we want to take the
    % val split ratio from all data hence we will multiple it by ratio to keep the same number of data points
    train           = all_set(training(c),:,:);
    train_labels    = all_labels(training(c));
    train_time_samp = all_time_samp(training(c));
    val             = all_set(test(c),:,:);
    val_labels      = all_labels(test(c));
    val_time_samp   = all_time_samp(test(c));
    % for visualization we will keep for each set all the time points
    val_sup_vec   = all_sup_vec;
    train_sup_vec = all_sup_vec;
    test_sup_vec  = all_sup_vec;
end

end