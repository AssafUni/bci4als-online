function [train, train_labels, test, test_labels, val, val_labels] = train_test_split(data_paths, options)
% this function splits the data set into train,test and validation sets.
%
% Inputs:
%   - data_paths - folder paths to where the data (XDF file) is stored
%   - test_split_ratio - a number between 0-1, determines the percentage of
%   trials to allocate for the testing set from all the data.
%   - cross_rec - true, test and train share recordings. false, tests are 
%   a different recordings then train.
%   - feat_or_data - a tring of either "feat" or "data" to determine if the
%   sets the function returns are features or data samples.
%   - val_set - true(1), a validation set will be created. false(0), a 
%   validation set will not be created.
%   - val_ratio - a number between 0-1, determines the percentage of
%   trials to allocate for the validation set from the training set.

%################# need to add the correct/wrong/both options for online recordings ################

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

% calculate the step size for continouos segmentation
CONSTANTS = Configuration();
Fs = CONSTANTS.SAMPLE_RATE;
segment_size = seg_dur*Fs;      % segments size
overlap_size = overlap*Fs;      % overlap between every 2 segments
step_size = segment_size - overlap_size; % step size between 2 segments

% define empty matrices
train = []; train_labels = [];
test = []; test_labels = [];

% if there are not enought recording sessions then dont split base on
% different recordings
if length(data_paths) < 4
    cross_rec = 1;
    disp(['not enought recordings for different recording split hence split is done regulary, meaning "cross_rec = true"' newline...
        'pls press any key to continue!']);
    pause()
end

if strcmp(feat_or_data, 'feat')
    % extract features and split into train and test
    if ~cross_rec
        % different recording sessions for train and test
        rec_num = length(data_paths);
        num_test_rec = round(rec_num*test_split_ratio);
        rec_idx = randperm(rec_num, num_test_rec);
        for i = 1:length(data_paths)
            folder = data_paths{i};
            [curr_feat, curr_label] = feat_from_offline(folder, feat_alg, cont_or_disc, seg_dur, overlap, thresh);
            if ismember(i,rec_idx)
                test  = cat(1, test, curr_feat);
                test_labels = cat(2, test_labels, curr_label);
            else
                train  = cat(1, train, curr_feat);
                train_labels = cat(2, train_labels, curr_label);
            end
        end
    else
        % same recording sessions for train and test
        for i = 1:length(data_paths)
            folder = data_paths{i};
            [curr_feat, curr_label] = feat_from_offline(folder, feat_alg, cont_or_disc, seg_dur, overlap, thresh);
            % make sure to keep even distribution of labels in the split sets
            test_idx_1 = find(curr_label == 1);
            test_idx_2 = find(curr_label == 2);
            test_idx_3 = find(curr_label == 3);
            idx_1 = randperm(length(test_idx_1), round(length(test_idx_1)*test_split_ratio));
            idx_2 = randperm(length(test_idx_2), round(length(test_idx_2)*test_split_ratio));
            idx_3 = randperm(length(test_idx_3), round(length(test_idx_3)*test_split_ratio));
            test_idx = [test_idx_1(idx_1), test_idx_2(idx_2), test_idx_3(idx_3)]; % set the test set idx
            curr_test = curr_feat(test_idx,:);
            curr_test_labels = curr_label(test_idx,:);
            test  = cat(1, test, curr_test);
            test_labels = cat(2, test_labels, curr_test_labels);
            curr_feat(test_idx,:) = [];      % remove test data from train data
            curr_label(test_idx) = []; % remove test labels from train labels
            train  = cat(1, train, curr_feat);
            train_labels = cat(2, train_labels, curr_label);
        end
    end

elseif strcmp(feat_or_data, 'data')
    % divide the data itself into test and train
    if ~cross_rec
        % different recording sessions for train and test
        rec_num = length(data_paths);
        num_test_rec = round(rec_num*test_split_ratio);
        rec_idx = randperm(rec_num, num_test_rec);
        for i = 1:length(data_paths)
            folder = data_paths{i};
            [segments, curr_label] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh);
            curr_data = MI3_Preprocess(segments, cont_or_disc);
            if ismember(i,rec_idx)
                test  = cat(1, test, curr_data);
                test_labels = cat(2, test_labels, curr_label);
            else
                train  = cat(1, train, curr_data);
                train_labels = cat(2, train_labels, curr_label);
            end
        end
    else
        % same recording sessions for train and test
        for i = 1:length(data_paths)
            folder = data_paths{i};
            [segments, curr_label] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh);
            curr_data = MI3_Preprocess(segments, cont_or_disc);
            % make sure to keep even distribution of labels in the split sets
            test_idx_1 = find(curr_label == 1);
            test_idx_2 = find(curr_label == 2);
            test_idx_3 = find(curr_label == 3);
            idx_1 = randperm(length(test_idx_1), round(length(test_idx_1)*test_split_ratio));
            idx_2 = randperm(length(test_idx_2), round(length(test_idx_2)*test_split_ratio));
            idx_3 = randperm(length(test_idx_3), round(length(test_idx_3)*test_split_ratio));
            test_idx = [test_idx_1(idx_1), test_idx_2(idx_2), test_idx_3(idx_3)]; % set the test set idx
            curr_test = curr_data(test_idx,:,:);
            curr_test_labels = curr_label(test_idx);
            test  = cat(1, test, curr_test);
            test_labels = cat(2, test_labels, curr_test_labels);
            curr_data(test_idx,:,:) = [];      % remove test data from train data
            curr_label(test_idx) = []; % remove test labels from train labels
            train  = cat(1, train, curr_data);
            train_labels = cat(2, train_labels, curr_label);
        end
    end
else
    error(['please provide a legit value for feat_or_data variable!' newline ...
        'set to "feat" if you wish to get features set or "data" to get data set'])
end

% set the validation set if requiried
if val_set
    val_idx_1 = find(train_labels == 1);
    val_idx_2 = find(train_labels == 2);
    val_idx_3 = find(train_labels == 3);
    idx_1 = randperm(length(val_idx_1), round(length(val_idx_1)*val_split_ratio));
    idx_2 = randperm(length(val_idx_2), round(length(val_idx_2)*val_split_ratio));
    idx_3 = randperm(length(val_idx_3), round(length(val_idx_3)*val_split_ratio));
    val_idx = [val_idx_1(idx_1), val_idx_2(idx_2), val_idx_3(idx_3)]; % set the val set idx
    val = train(val_idx,:,:);
    val_labels = train_labels(val_idx);
    train(val_idx,:,:) = [];        % remove val data from train data
    train_labels(val_idx) = [];     % remove val labels from train labels
else
    val = []; val_labels = [];
end
end