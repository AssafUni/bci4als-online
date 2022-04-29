% this script performs data aggregation, data preprocessing and training a
% model to predict right left or idle, follow the instructions bellow to
% manage the script:
% 
% - change the folders paths in 'data_paths'
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
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('C:\Users\tomer\Desktop\ALS\project\')); 
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\eeglab2021.1\'))  % #### change according to your local eeglab path ####
warning('on');

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {[1, 3:12], [], []}; % recordings numbers - make sure that they exist
data_paths = create_paths(recorders, folders_num);
% apperantly we have bad recordings from tomer
% currently bad recordings from tomer: [2] 


%% define the wanted pipeline and data split options
options.test_split_ratio = 0.1;            % percent of the data which will go to the test set
options.val_split_ratio  = 0.1;          % percent of the data which will go to the test set - if set to 0 val set isn't created
options.cross_rec        = false;        % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.model_algo       = 'EEGNet';     % ML model to train, choose from {'EEGNet', 'EEGNet_lstm','SVM', 'ADABOOST', 'LDA'}
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'discrete';   % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4;            % following segments overlapping duration in seconds
options.threshold        = 0.7;          % threshold for labeling in continuous segmentation - percentage of the window containing the class (0-1)
options.sequence_len     = 1;            % length of a sequence to enter in sequence DL models
options.resample         = [1,1,1];      % resample size for each class [class1, class2, class3]
options.constants        = constants(); % a class member with constants that are used in the pipeline 

%% preprocess the data into train, test and validation sets
[train, train_labels, test, test_labels, val, val_labels, ...
    train_sup_vec, test_sup_vec, val_sup_vec, train_time_samp, ...
    val_time_samp, test_time_samp, test_rec_idx, val_rec_idx] = ...
    train_test_split(data_paths, options);

%% check data distribution in each data set
disp('training data distribution'); train_distr = tabulate(train_labels); tabulate(train_labels)
disp('validation data distribution'); tabulate(val_labels)
disp('testing data distribution'); tabulate(test_labels)

% fix imbalanced data in the train set for better fitting - we just resample classes 2 & 3
[train_rsmpl, train_labels_rsmpl] = resample_data(train, train_labels, options.resample, true);

%% create a datastore for the data - this is usefull if we want to augment our data while training the NN
train_ds = set2ds(train, train_labels, options.constants);
train_ds_rsmpl = set2ds(train_rsmpl, train_labels_rsmpl, options.constants);
test_ds = set2ds(test, test_labels, options.constants);
val_ds = set2ds(val, val_labels, options.constants);

% normalize all data sets
train_ds = transform(train_ds, @norm_eeg);
train_ds_rsmpl = transform(train_ds_rsmpl, @norm_eeg);
test_ds = transform(test_ds, @norm_eeg);
val_ds = transform(val_ds, @norm_eeg);

% add augmentation functions to the train datastore (X flip & random
% gaussian noise) - helps preventing overfitting
train_ds_aug = transform(train_ds_rsmpl, @augment_data);

%% train a model - the 'algo' name will determine which model to train
model = train_my_model(options.model_algo, options.constants, "train_ds", train_ds_aug, "val_ds", val_ds);

%% set working points and evaluate the model on all data stores
[test_class_pred, thresh] = evaluation(model, test_ds, CM_title = 'test', criterion = 'sens', criterion_thresh = 0.9);
train_class_pred = evaluation(model, train_ds, CM_title = 'train', thres_C1 = thresh);
val_class_pred = evaluation(model, val_ds, CM_title = 'val', thres_C1 = thresh);

%% visualize the results
visualize_results(train_sup_vec, train_class_pred, train_time_samp, 'train')
visualize_results(test_sup_vec, test_class_pred, test_time_samp, 'test')
visualize_results(val_sup_vec, val_class_pred, val_time_samp, 'val')

%% save the model and its settings
mdl_struct.options = options;
mdl_struct.model = model;
uisave('mdl_struct', 'mdl_struct');

%% visualize the network weights - try to explaine the network computations
% temporal_conv_weights = model.Layers(3).Weights;