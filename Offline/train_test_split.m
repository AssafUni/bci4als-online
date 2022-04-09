function [train, train_labels, test_set, test_labels, val, val_labels, train_sup_vec, test_sup_vec, val_sup_vec] = train_test_split(data_paths, options)
% this function splits the data set into train,test and validation sets
% while maintaining an even class distribution between these sets.
%
% Inputs:
%   data_paths: folder paths to where the data (XDF file) is stored
%   options: a structure containing the options of the split function
%
% Outputs:
%   train\test\val: a cell array containing the train\test\val set, each
%   cell contains one sample of recorded data.
%   train\test\val_labels: an array containing the train\test\val labels.


%################# need to fix the percentage of test train, due to rounding we get ################
%################# too many test examples, consider spliting after loading all the  ################
%################# folders instead of spliting each folder at a time. this is a     ################  
%################# problem only in the state where cross_rec = true                 ################

% extract the parameters from options structure for later use
test_split_ratio = options.test_split_ratio; % percent of the data which will go to the test set
cross_rec        = options.cross_rec;        % true - test and train share recordings, false - tests are a different recordings then train
feat_or_data     = options.feat_or_data;     % return "train" as data or features
val_set          = options.val_set;          % create a validation set when creating test train split
val_split_ratio  = options.val_split_ratio;  % percentage of data to allocate to validation set from training set
feat_alg         = options.feat_alg;         % feature extraction algorithm choose from {'basic', 'wavelet'}
cont_or_disc     = options.cont_or_disc;     % segmentation type choose from {'discrete', 'continouos'}
seg_dur          = options.seg_dur;          % segments duration in seconds
overlap          = options.overlap;          % following segments overlapping duration in seconds
thresh           = options.threshold;        % threshold for labeling in continuous segmentation
seq_len          = options.sequence_len;

% calculate the step size for continouos segmentation
CONSTANTS = Configuration();
start_buff = CONSTANTS.BUFFER_START;
Fs = CONSTANTS.SAMPLE_RATE;
segment_size = seg_dur*Fs;      % segments size
overlap_size = overlap*Fs;      % overlap between every 2 segments
step_size = segment_size - overlap_size; % step size between 2 segments

% define empty matrices
train = []; train_labels = [];
test_set = []; test_labels = [];
val = []; val_labels = [];
train_sup_vec = []; test_sup_vec = []; val_sup_vec = [];

% if there are not enought recording sessions then dont split base on
% different recordings
if length(data_paths) < 4
    cross_rec = 1;
    disp(['not enought recordings for different recording split hence split' newline...
        'is done regulary, meaning "cross_rec = true" pls press any key to continue!']);
    pause()
end

% create a waitbar to show progress
f = waitbar(0, 'preprocessing data, pls wait');
warning('off');


if strcmp(feat_or_data, 'feat')
    % extract features and split into train and test
    if ~cross_rec
        % different recording sessions for train and test
        num_total_rec = length(data_paths);
        num_test_val_rec = round(num_total_rec*test_split_ratio);
        rec_idx = randperm(num_total_rec, num_test_val_rec);
        for i = 1:length(data_paths)
            waitbar(i/length(data_paths),f,['preprocessing data, recording ' num2str(i) ' out of ' num2str(length(data_paths))]);
            folder = data_paths{i};
            [curr_feat, curr_label] = feat_from_offline(folder, feat_alg, cont_or_disc, seg_dur, overlap, thresh);
            if ismember(i,rec_idx)
                test_set  = cat(1, test_set, curr_feat);
                test_labels = cat(2, test_labels, curr_label);
            else
                train  = cat(1, train, curr_feat);
                train_labels = cat(2, train_labels, curr_label);
            end
        end
    else
        % same recording sessions for train and test
        for i = 1:length(data_paths)
            waitbar(i/length(data_paths),f,['preprocessing data, recording ' num2str(i) ' out of ' num2str(length(data_paths))]);
            folder = data_paths{i};
            [curr_feat, curr_label] = feat_from_offline(folder, feat_alg, cont_or_disc, seg_dur, overlap, thresh);
            % keep an even distribution of labels in the split sets
            c = cvpartition(curr_label,'Holdout',test_split_ratio);
            curr_test = curr_feat(test(c),:);
            curr_test_labels = curr_label(test(c));
            test_set  = cat(1, test_set, curr_test);
            test_labels = cat(2, test_labels, curr_test_labels);
            curr_feat(test(c),:) = [];      % remove test data from train data
            curr_label(test(c)) = []; % remove test labels from train labels
            train  = cat(1, train, curr_feat);
            train_labels = cat(2, train_labels, curr_label);
        end
    end

elseif strcmp(feat_or_data, 'data')
    % divide the data itself into test and train
    if ~cross_rec
        % different recording sessions for train and test
        num_total_rec = length(data_paths);
        num_test_val_rec = round(num_total_rec*(test_split_ratio + val_split_ratio));
        rec_idx = randperm(num_total_rec, num_test_val_rec);
        num_test_rec = round(num_total_rec*test_split_ratio);
        idx = randperm(length(rec_idx), num_test_rec);
        test_idx = rec_idx(idx);
        rec_idx(idx) = [];
        val_idx = rec_idx;
        for i = 1:length(data_paths)
            waitbar(i/length(data_paths),f,['preprocessing data, recording ' num2str(i) ' out of ' num2str(length(data_paths))]);
            folder = data_paths{i};
            [segments, curr_label, curr_sup_vec] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh);
            curr_data = MI3_Preprocess(segments, cont_or_disc);
            [curr_data, curr_label] = create_sequence(curr_data, curr_label, seq_len);
            curr_sup_vec(1:(seq_len - 1)*step_size + segment_size + start_buff - 1) = [];
            if ismember(i,test_idx)
                test_set  = cat(1, test_set, curr_data);
                test_labels = cat(2, test_labels, curr_label);
                test_sup_vec = cat(2, test_sup_vec, curr_sup_vec);
            elseif ismember(i,val_idx)
                val  = cat(1, val, curr_data);
                val_labels = cat(2, val_labels, curr_label);
                val_sup_vec = cat(2, val_sup_vec, curr_sup_vec);
            else
                train  = cat(1, train, curr_data);
                train_labels = cat(2, train_labels, curr_label);
                train_sup_vec = cat(2, train_sup_vec, curr_sup_vec);
            end
        end
    else
        % same recording sessions for train and test
        for i = 1:length(data_paths)
            waitbar(i/length(data_paths),f,['preprocessing data, recording ' num2str(i) ' out of ' num2str(length(data_paths))]);
            folder = data_paths{i};
            [segments, curr_label] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh);
            curr_data = MI3_Preprocess(segments, cont_or_disc);
            [curr_data, curr_label] = create_sequence(curr_data, curr_label, seq_len);
            % keep an even distribution of labels in the split sets
            c = cvpartition(curr_label,'Holdout',test_split_ratio);
            curr_test = curr_data(test(c),:,:);
            curr_test_labels = curr_label(test(c));
            test_set  = cat(1, test_set, curr_test);
            test_labels = cat(2, test_labels, curr_test_labels);
            curr_data(test(c),:,:) = [];      % remove test data from train data
            curr_label(test(c)) = []; % remove test labels from train labels
            train  = cat(1, train, curr_data);
            train_labels = cat(2, train_labels, curr_label);
        end
    end
else
    error(['please provide a legit value for feat_or_data variable!' newline ...
        'set to "feat" if you wish to get features set or "data" to get data set'])
end

% close the waitbar
delete(f);
warning('on')

% set the validation set if requiried
if (val_set && cross_rec) || (val_set && strcmp(feat_or_data, 'feat'))
    c = cvpartition(train_labels, 'Holdout', val_split_ratio);
    val = train(test(c),:,:);
    val_labels = train_labels(test(c));
    train(test(c),:,:) = [];        % remove val data from train data
    train_labels(test(c)) = [];     % remove val labels from train labels
end
end