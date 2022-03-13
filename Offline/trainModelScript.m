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
    {'..\rec_assaf\Test1'}, {'..\rec_assaf\Test2'}, {'..\rec_assaf\Test3'}...
    {'..\rec_assaf\Test4'}, {'..\rec_assaf\Test5'}, {'..\rec_assaf\Test6'}...
    {'..\rec_assaf\Test7'}, {'..\rec_assaf\Test8'}, {'..\rec_assaf\Test9'}...
    {'..\rec_assaf\Test10'}, {'..\rec_assaf\Test11'}, {'..\rec_assaf\Test12'}...
    {'..\rec_assaf\Test13'}, {'..\rec_assaf\Test14'}, {'..\rec_assaf\Test15'}...
    {'..\rec_assaf\Test16'}, {'..\rec_assaf\Test17'}, {'..\rec_assaf\Test18'}];
% recordings_offline = [{'..\rec_omri\offline\Test1'}, {'..\rec_omri\offline\Test2'}, {'..\rec_omri\offline\Test3'}...
%                       {'..\rec_omri\offline\Test4'}, {'..\rec_omri\offline\Test5'}];
% recordings_offline = [{'..\rec_assaf\Test11'}, {'..\rec_assaf\Test15'}, {'..\rec_assaf\Test7'}...
%                       {'..\rec_assaf\Test9'}, {'..\rec_assaf\Test5'}, {'..\rec_assaf\Test1'}];
recordings_online = [];

% define the wanted pipeline and split options
data_paths = [recordings_offline; recordings_online];
options.test_split_ratio = 0.1;  % percent of the data which will go to the test set
options.cross_rec = true;  % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data = 'data'; % return "train" as data or features
options.val_set = true; % create a validation set when creating test train split
options.val_ratio = 0.1; % percentage of data to allocate to validation set from training set
options.feat_alg = 'wavelet'; % feature extraction algorithm, choose from {'basic', 'wavelet'}

% define the classic ML model type to train and some other parameters
model_alg = 'LDA'; % ML model to train, choose from {'SVM', 'ADABOOST', 'LDA'}
save_model = 'false'; % choose to save the trained model or not #### need to add the saving folder path as a variable this feat is not working for now ######


[train, train_labels, test, test_labels, val, val_labels] = ...
    train_test_split(data_paths, options);


% classic ML models pipeline
if strcmp(options.feat_or_data,'feat')
    folder = '..\NewHeadsetRecordingsOmri\combined';
    [selected_feat_idx]  = MI5_feature_selection(train, train_labels);
    train = train(:,selected_feat_idx);
    test = test(:,selected_feat_idx);
    val = val(:,selected_feat_idx);
    MI6_LearnModel(train, train_labels, model_alg, save_model);
else
    % DL models pipeline
    [train_acuraccy, test_acuraccy] = EEGNet(train, train_labels, val, val_labels, test, test_labels);
end

