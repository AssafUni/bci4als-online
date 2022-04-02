% this script performs data aggregation, data preprocessing and training a
% model to predict right left or idle, follow the instructions bellow to
% manage the script:
% 
% change the folders paths in 'recordings_offline' and 'recordings_online'
% to the relevant recordings you intend to use to train the model.
%
% notice the path of eeglab package - line 13, change it as you wish to
% match the path it is stored in your PC. 
%
% notice that data from online recordings can be correct/wrong (or both)
% predictions from the model we used in the online training. this might be
% usefull to set different weights in the loss function for wrong
% predictions to improve the model.

clc; clear all; close all;

% add relevant paths to the script
addpath('..\Common\')
addpath(genpath('..\..\interfaces\eeglab2021.1\'))  % #### change according to your local eeglab path ####
addpath('..\DL pipelines\')    % path of DL models we might use
addpath('..\feature extraction methods\') % path of feature extraction methods we might use


% define a class member with all the constants used in the pipeline 
Configuration = Configuration();

% rng(Configuration.RNG_CONST) % For reproducibility

% select folders to aggregate data from - online, offline or both
% recordings_offline = [
%     {'..\rec_assaf\Test1'}, {'..\rec_assaf\Test2'}, {'..\rec_assaf\Test3'}...
%     {'..\rec_assaf\Test4'}, {'..\rec_assaf\Test5'}, {'..\rec_assaf\Test6'}...
%     {'..\rec_assaf\Test7'}, {'..\rec_assaf\Test8'}, {'..\rec_assaf\Test9'}...
%     {'..\rec_assaf\Test10'}, {'..\rec_assaf\Test11'}, {'..\rec_assaf\Test12'}...
%     {'..\rec_assaf\Test13'}, {'..\rec_assaf\Test14'}, {'..\rec_assaf\Test15'}...
%     {'..\rec_assaf\Test16'}, {'..\rec_assaf\Test17'}, {'..\rec_assaf\Test18'}...
%     {'..\rec_omri\offline\Test1'}, {'..\rec_omri\offline\Test2'}, {'..\rec_omri\offline\Test3'}...
%     {'..\rec_omri\offline\Test4'}, {'..\rec_omri\offline\Test5'}];
recordings_offline = [{'..\rec_omri\offline\Test1'}, {'..\rec_omri\offline\Test2'}, {'..\rec_omri\offline\Test3'}...
                      {'..\rec_omri\offline\Test4'}, {'..\rec_omri\offline\Test5'}];
% recordings_offline = [{'..\rec_assaf\Test11'}, {'..\rec_assaf\Test15'}, {'..\rec_assaf\Test7'}...
%                       {'..\rec_assaf\Test9'}, {'..\rec_assaf\Test5'}, {'..\rec_assaf\Test1'}];
recordings_online = [];

% define the wanted pipeline and split options
data_paths = [recordings_offline; recordings_online];
options.test_split_ratio = 0.2;         % percent of the data which will go to the test set
options.cross_rec        = true;         % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.val_set          = true;         % create a validation set when creating test train split
options.val_split_ratio  = 0.2;         % percentage of data to allocate to validation set from training set
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'continuous'; % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4;            % following segments overlapping duration in seconds
options.threshold        = 0.6;          % threshold for labeling in continuous segmentation
options.sequence_len     = 5;            % length of a sequence to enter in sequence DL models, set to 1 if you dont want to create sequences (for EEGNet model)
options.DL_model         = 'EEGNet_lstm';% specify which DL model to train from {'EEGNet', 'EEGNet_lstm'}

% define the classic ML model type to train and some other parameters
model_alg = 'LDA'; % ML model to train, choose from {'SVM', 'ADABOOST', 'LDA'}
save_model = 'false'; % choose to save the trained model or not #### need to add the saving folder path as a variable this feat is not working for now ######


[train, train_labels, test, test_labels, val, val_labels] = ...
    train_test_split(data_paths, options);

%% create a datastore for the data - this is usefull if we want to augment our data while training the NN
% shift the data dimentions to match the input layer - hXwXcXn
% (height,width,channels,number of images)
for i = 1:size(train,1)
    train{i} = permute(train{i},[2,3,4,1]);
end
for i = 1:size(val,1)
    val{i} = permute(val{i},[2,3,4,1]);
end
for i = 1:size(test,1)
    test{i} = permute(test{i},[2,3,4,1]);
end

% create cells of the labels - notice we need to feed the datastore with
% categorical instead of numeric labels
train_labels_cell = mat2cell(categorical(train_labels.'), ones(1,length(train_labels)));
test_labels_cell = mat2cell(categorical(test_labels.'), ones(1,length(test_labels)));
val_labels_cell = mat2cell(categorical(val_labels.'), ones(1,length(val_labels)));

% define the datastores and their read size - for best runtime performance 
% configure read size to be the same as the minibatch size of the network
read_size = Configuration.MiniBatchSize;
train_ds = arrayDatastore([train train_labels_cell], 'ReadSize', read_size, 'IterationDimension', 1, 'OutputType', 'same');
test_ds = arrayDatastore([test test_labels_cell], 'ReadSize', read_size, 'IterationDimension', 1, 'OutputType', 'same');
val_ds = arrayDatastore([val val_labels_cell], 'ReadSize', read_size, 'IterationDimension', 1, 'OutputType', 'same');

% add augmentation functions to the train datastore (X flip & random
% gaussian noise) - helps preventing overfitting
train_ds_aug = transform(train_ds, @augment_data);
% preview(train_ds_aug)


%% classic ML models pipeline
if strcmp(options.feat_or_data,'feat')
    [selected_feat_idx]  = MI5_feature_selection(train, train_labels);
    train = train(:,selected_feat_idx);
    test = test(:,selected_feat_idx);
    val = val(:,selected_feat_idx);
    MI6_LearnModel(train, train_labels, model_alg, save_model);
else % DL models pipeline
    if strcmp(options.DL_model, 'EEGNet')
        [eegnet, train_acuraccy, test_acuraccy] = EEGNet(train(:,1:13,:), train_labels, val(:,1:13,:), val_labels, test(:,1:13,:), test_labels);
    elseif strcmp(options.DL_model, 'EEGNet_lstm')
        [eegnet_lstm, train_acuraccy, test_acuraccy] = EEGNet_lstm(train_ds_aug, val_ds, test_ds);
    end
end

%% set working points and classification functions
% get the scores of the test set from the network
test_pred = predict(eegnet_lstm, test_ds);

% get the criterion you desire - here i chose sensitivity and specificity
% for class 1
[X,Y,T] = perfcurve(test_labels, test_pred(:,1), 1, 'XCrit', 'sens', 'YCrit', 'spec');
figure('Name', 'perfcurve'); xlabel('sensetivity'); ylabel('speceficity');
plot(X,Y) % plot the perfcurve for visualization

% set a working point of specificity = 0.95 for class 1 (Idle)
[~,I] = min(abs(X - 0.88));
thresh = T(I); % the working point

% label the samples according to the new threshold and plot CM
labels = zeros(size(temp_test_labels)); % set an empty labels vector
labels(test_pred(:,1) >= thresh) = 1;
labels(test_pred(:,1) < thresh & test_pred(:,2) >= test_pred(:,3)) = 2;
labels(test_pred(:,1) < thresh & test_pred(:,2) < test_pred(:,3)) = 3;
C_test = confusionmat(test_labels,labels);
title = sprintf('test confusion matrix - sensetivity aprox %.2f for class 1 (Idle)', X(I));
figure('Name', title);
confusionchart(C_test,["Idle";"Left"; "Right"]);


% save the model and its settings
% EEGNet_lstm_2.options = options;
% EEGNet_lstm_2.model = eegnet_lstm;
% save('..\figures and plots\EEGNet_lstm_omri_and_assaf\EEGNet_lstm_2', 'EEGNet_lstm_2')

% classify time points instead of samples according to the number of
% the last #num samples classified in each class and check if we are
% missing any action (left\right). this will be our final evaluation of the
% classifier!


%% visualize the network weights - try to explaine the network computations
temporal_conv_weights = eegnet_lstm.Layers(3).Weights;