% this script performs data aggregation, data preprocessing and training an
% autoencoder model to validate good recordings, follow the instructions bellow to
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
addpath(genpath('..\')); 
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('..\..\interfaces\eeglab2021.1\'))  % #### change according to your local eeglab path ####
warning('on');

% define a class member with all the constants used in the pipeline 
Configuration = Configuration();

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {(1:12), [], []}; % recordings numbers - make sure that they exist
counter = 0;
for i = 1:length(recorders)
    for j = 1:length(folders_num{i})
        counter = counter + 1;
        curr_path = ['C:\Users\tomer\Desktop\ALS\project\rec_',...
            recorders{i}, '\', 'Test', num2str(folders_num{i}(j))];
        data_paths{counter} = curr_path;
    end
end
% apperantly we have one bad recording from tomer, try finding it and delete it
% bad recordings tomer = [2]

%% define the wanted pipeline and data split options
options.test_split_ratio = 0.1;          % percent of the data which will go to the test set
options.val_split_ratio  = 0;            % percent of the data which will go to the test set - if set to 0 val set isn't created
options.cross_rec        = false;        % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.model_algo       = 'EEGNet_AE';  % ML model to train, choose from {'EEGNet', 'EEGNet_lstm', 'EEGNet_AE', 'SVM', 'ADABOOST', 'LDA'}
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'discrete';   % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4.5;          % following segments overlapping duration in seconds
options.threshold        = 0.7;          % threshold for labeling in continuous segmentation - percentage of the window containing the class (0-1)
options.sequence_len     = 1;            % length of a sequence to enter in sequence DL models, set to 1 if you dont want to create sequences (for EEGNet model)

%% preprocess the data into train, test and validation sets
[train, train_labels, test, test_labels] = train_test_split(data_paths, options);

%% check data distribution in each data set
disp('training data distribution'); train_distr = tabulate(train_labels); tabulate(train_labels)
disp('testing data distribution'); tabulate(test_labels)

% fix imbalanced data in the train set for better fitting - we just resample classes 2 & 3
[train_rsmpl, train_labels_rsmpl] = resample_data(train, train_labels, "class_2", 2, "class_3", 2, "display", true);

%% create a datastore for the data - this is usefull if we want to augment our data while training the NN
train_ds = set2ds(train, train_labels);
train_ds_rsmpl = set2ds(train_rsmpl, train_labels_rsmpl);
test_ds = set2ds(test, test_labels);

% add augmentation functions to the train datastore (X flip & random
% gaussian noise) - helps preventing overfitting
train_ds_aug = transform(train_ds_rsmpl, @augment_data);

%% train a model - the 'algo' name will determine which model to train
% model = train_my_model(options.model_algo, "train_ds", train_ds_aug);



%% visualize the results - lets see the clusters!


%% save the model and its settings
EEGNet_AU.options = options;
EEGNet_AU.model = model;
save('..\figures and models\EEGNet_lstm_tomer\EEGNet_AU', 'EEGNet_AU')

%% visualize the network weights - try to explaine the network computations
temporal_conv_weights = model.Layers(3).Weights;