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

rng(Configuration.RNG_CONST) % For reproducibility

% select folders to aggregate data from - online, offline or both
recordings_offline = [
    {'..\NewHeadsetRecordingsAssaf\Test1'}, {'..\NewHeadsetRecordingsAssaf\Test2'}, {'..\NewHeadsetRecordingsAssaf\Test3'},...
    {'..\NewHeadsetRecordingsAssaf\Test4'}, {'..\NewHeadsetRecordingsAssaf\Test5'}, {'..\NewHeadsetRecordingsAssaf\Test6'},...
    {'..\NewHeadsetRecordingsAssaf\Test7'}, {'..\NewHeadsetRecordingsAssaf\Test8'}, {'..\NewHeadsetRecordingsAssaf\Test9'},...
    {'..\NewHeadsetRecordingsAssaf\Test10'}, {'..\NewHeadsetRecordingsAssaf\Test11'}, {'..\NewHeadsetRecordingsAssaf\Test12'},...
    {'..\NewHeadsetRecordingsAssaf\Test13'}, {'..\NewHeadsetRecordingsAssaf\Test14'}, {'..\NewHeadsetRecordingsAssaf\Test15'},...
    {'..\NewHeadsetRecordingsAssaf\Test16'}, {'..\NewHeadsetRecordingsAssaf\Test17'}, {'..\NewHeadsetRecordingsAssaf\Test18'}
    ];
recordings_online = [];

% define the wanted pipeline and split options
data_paths = [recordings_offline; recordings_online];
test_split_ratio = 0.1;  % percent of the data which will go to the test set
cross_rec = true;  % true - test and train share recordings, false - tests are a different recordings then train
feat_or_data = 'data'; % return "train" as data or features
val_set = true; % create a validation set when creating test train split
val_ratio = 0.1; % percentage of data to allocate to validation set from training set

[train, train_labels, test, test_labels, val, val_labels] = ...
    train_test_split(data_paths, test_split_ratio, cross_rec, feat_or_data, val_set, val_ratio);


% % classic ML models pipeline
% folder = '..\NewHeadsetRecordingsOmri\combined';
% selected_feat = MI5_feature_selection(all_feat, all_label, folder);
% MI6_LearnModel(folder, Configuration.CLASSIFIER_TYPE, Configuration.CLASSIFIER_SAVE);


% DL models pipeline
[train_acuraccy, test_acuraccy] = EEGNet(train, train_labels, val, val_labels, test, test_labels);

