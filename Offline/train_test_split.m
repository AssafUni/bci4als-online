function [train, train_labels, test, test_labels, val, val_labels] = train_test_split(data_paths, split_ratio, cross_rec, feat_or_data, val_set, val_ratio)
% this function splits the data set into train set and test set.
% set cross_rec to 0 if you want to make a test set that has data from
% different recording sessions then the train set.
% split ratio is the ratio between train and test data size, expressing the
% test set proportion to the data size.

%################# need to add the correct/wrong/both options for online recordings ################

%################# need to fix the percentage of test train, due to rounding we get ################
%################# too many test examples, consider spliting after loading all the  ################
%################# folders instead of spliting each folder at a time.               ################

train = []; train_labels = [];
test = []; test_labels = [];

% if there are not enought recording sessions then dont split base on
% different recordings
if length(data_paths) < 4
    cross_rec = 1;
end

if strcmp(feat_or_data, 'feat')
    % extract features and split into train and test
    if ~cross_rec
        % different recording sessions for train and test
        rec_num = length(data_paths);
        num_test_rec = round(rec_num*split_ratio);
        rec_idx = randperm(rec_num, num_test_rec);
        for i = 1:length(data_paths)
            folder = data_paths{i};
            curr_feat = feat_from_offline(folder);
            curr_label = load(strcat(data_paths{i}, '\labels.mat'));
            curr_label = curr_label.labels;
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
            curr_feat = feat_from_offline(folder);
            curr_label = load(strcat(data_paths{i}, '\labels.mat'));
            curr_label = curr_label.labels;
            % make sure to keep even distribution of labels in the split sets
            test_idx_1 = find(curr_label == 1);
            test_idx_2 = find(curr_label == 2);
            test_idx_3 = find(curr_label == 3);
            idx_1 = randperm(length(test_idx_1), floor(length(test_idx_1)*split_ratio));
            idx_2 = randperm(length(test_idx_2), floor(length(test_idx_2)*split_ratio));
            idx_3 = randperm(length(test_idx_3), floor(length(test_idx_3)*split_ratio));
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
        num_test_rec = round(rec_num*split_ratio);
        rec_idx = randperm(rec_num, num_test_rec);
        for i = 1:length(data_paths)
            folder = data_paths{i};
            MI2_Preprocess(folder);
            curr_data = MI3_SegmentData(folder);
            curr_label = load(strcat(data_paths{i}, '\labels.mat'));
            curr_label = curr_label.labels;
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
            MI2_Preprocess(folder);
            curr_data = MI3_SegmentData(folder);
            curr_label = load(strcat(data_paths{i}, '\labels.mat'));
            curr_label = curr_label.labels;
            % make sure to keep even distribution of labels in the split sets
            test_idx_1 = find(curr_label == 1);
            test_idx_2 = find(curr_label == 2);
            test_idx_3 = find(curr_label == 3);
            idx_1 = randperm(length(test_idx_1), floor(length(test_idx_1)*split_ratio));
            idx_2 = randperm(length(test_idx_2), floor(length(test_idx_2)*split_ratio));
            idx_3 = randperm(length(test_idx_3), floor(length(test_idx_3)*split_ratio));
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
    idx_1 = randperm(length(val_idx_1), round(length(val_idx_1)*val_ratio));
    idx_2 = randperm(length(val_idx_2), round(length(val_idx_2)*val_ratio));
    idx_3 = randperm(length(val_idx_3), round(length(val_idx_3)*val_ratio));
    val_idx = [val_idx_1(idx_1), val_idx_2(idx_2), val_idx_3(idx_3)]; % set the val set idx
    val = train(val_idx,:,:);
    val_labels = train_labels(val_idx);
    train(val_idx,:,:) = [];        % remove val data from train data
    train_labels(val_idx) = [];     % remove val labels from train labels
else
    val = []; val_labels = [];
end
end