% this script performs data aggregation, data preprocessing and training a
% model to predict right left or idle, follow the instructions bellow to
% manage the script:
% 
% - change the folders paths in 'recordings_offline' and 'recordings_online'
%   to the relevant recordings you intend to use to train the model.
% - change the options settings according to the desired pipeline you wish
%   to create.
% - for more changes check the 'Configuration' class function in 'Common'
%   folder.
%
% Notes:
%   notice the path of eeglab package in the begining of the script,
%   change it as you wish to match the path it is stored in your PC. 
%

clc; clear all; close all;

% add relevant paths to the script
addpath(genpath('..\')); 
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('..\..\interfaces\eeglab2021.1\'))  % #### change according to your local eeglab path ####
warning('on');

% addpath('..\Common\')
% addpath('..\DL pipelines\')    % path of DL models we might use
% addpath('..\feature extraction methods\') % path of feature extraction methods we might use

% define a class member with all the constants used in the pipeline 
Configuration = Configuration();

% rng(Configuration.RNG_CONST) % For reproducibility

% select folders to aggregate data from - online, offline or both
recordings_offline = [
    {'..\rec_tomer\Test1'}, {'..\rec_tomer\Test2'}, {'..\rec_tomer\Test3'}...
    {'..\rec_tomer\Test4'}, {'..\rec_tomer\Test5'}, {'..\rec_tomer\Test6'}...
    {'..\rec_tomer\Test7'}, {'..\rec_tomer\Test8'}, {'..\rec_tomer\Test9'}...
    {'..\rec_tomer\Test10'}, {'..\rec_tomer\Test11'}, {'..\rec_tomer\Test12'}];

%     {'..\rec_tomer\Test13'}, {'..\rec_tomer\Test14'}, {'..\rec_tomer\Test15'}...
%     {'..\rec_tomer\Test16'}, {'..\rec_tomer\Test17'}, {'..\rec_tomer\Test18'}...
%     {'..\rec_tomer\Test19'}, {'..\rec_tomer\Test20'}, {'..\rec_tomer\Test21'}...
%     {'..\rec_tomer\Test22'}, {'..\rec_tomer\Test23'}, {'..\rec_tomer\Test24'}

% recordings_offline = [{'..\rec_omri\Test1'}, {'..\rec_omri\Test2'}, {'..\rec_omri\Test3'}...
%                       {'..\rec_omri\Test4'}, {'..\rec_omri\Test5'}];

recordings_online = [];

% define the wanted pipeline and split options
data_paths = [recordings_offline; recordings_online];
options.test_split_ratio = 0.1;          % percent of the data which will go to the test set
options.val_split_ratio  = 0.1;          % percentage of data to allocate to validation set from training set
options.val_set          = true;         % create a validation set when creating test train split
options.cross_rec        = false;        % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.DL_model         = 'EEGNet_lstm';% specify which DL model to train from {'EEGNet', 'EEGNet_lstm'}
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'continuous'; % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4;            % following segments overlapping duration in seconds
options.threshold        = 0.7;          % threshold for labeling in continuous segmentation - percentage of the window containing the class (0-1)
options.sequence_len     = 4;            % length of a sequence to enter in sequence DL models, set to 1 if you dont want to create sequences (for EEGNet model)

% define the classic ML model type to train and some other parameters
model_alg = 'LDA';    % ML model to train, choose from {'SVM', 'ADABOOST', 'LDA'}
save_model = 'false'; % choose to save the trained model or not #### need to add the saving folder path as a variable this feat is not working for now ######

[train, train_labels, test, test_labels, val, val_labels,...
    train_sup_vec, test_sup_vec, val_sup_vec] = ...
    train_test_split(data_paths, options);

% check data distribution in each data set
disp('training data distribution')
train_distr = tabulate(train_labels);
tabulate(train_labels)
disp('validation data distribution')
tabulate(val_labels)
disp('testing data distribution')
tabulate(test_labels)

% fix imbalanced data in the train set for better fitting - we just
% resample classes 2 & 3
train_class_2 = train(train_labels == 2);
train_class_3 = train(train_labels == 3);
ratio_1_2 = floor(train_distr(1,2)/train_distr(2,2));
ratio_1_3 = floor(train_distr(1,2)/train_distr(3,2));
train_class_2 = repmat(train_class_2, round(ratio_1_2*0.5),1);
train_class_3 = repmat(train_class_3, round(ratio_1_3*0.5),1);
train_class_2_lab = ones(1,size(train_class_2,1)).*2;
train_class_3_lab = ones(1,size(train_class_3,1)).*3;

train = [train; train_class_2; train_class_3];
train_labels = [train_labels, train_class_2_lab, train_class_3_lab];
disp('new training data distribution');
tabulate(train_labels);


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
labels = zeros(size(test_labels)); % set an empty labels vector
labels(test_pred(:,1) >= thresh) = 1;
labels(test_pred(:,1) < thresh & test_pred(:,2) >= test_pred(:,3)) = 2;
labels(test_pred(:,1) < thresh & test_pred(:,2) < test_pred(:,3)) = 3;
C_test = confusionmat(test_labels,labels);
title = sprintf('test confusion matrix - sensetivity aprox %.2f for class 1 (Idle)', X(I));
figure('Name', title);
confusionchart(C_test,["Idle";"Left"; "Right"]);


% save the model and its settings
EEGNet_lstm.options = options;
EEGNet_lstm.model = eegnet_lstm;
save('..\figures and models\EEGNet_lstm_tomer\EEGNet_lstm', 'EEGNet_lstm')

% classify time points instead of samples according to the number of
% the last #num samples classified in each class and check if we are
% missing any action (left\right). this will be our final evaluation of the
% classifier!
if ~isempty(train_sup_vec)
    Fs = Configuration.SAMPLE_RATE;
    segment_size = options.seg_dur*Fs;       % segments size
    overlap_size = options.overlap*Fs;       % overlap between every 2 segments
    step_size = segment_size - overlap_size; % step size between 2 segments
    time = (0:(length(test_sup_vec) - 1))./Fs;
    figure('Name', 'test labels vs time plot')
    plot(time, test_sup_vec, 'r*', 'MarkerSize', 2); hold on; xlabel('time'); ylabel('labels');
    plot(time(1:step_size:end), labels, 'b+', 'MarkerSize', 2)
end


%% visualize the network weights - try to explaine the network computations
temporal_conv_weights = eegnet_lstm.Layers(3).Weights;