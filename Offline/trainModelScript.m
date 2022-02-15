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
addpath ..\Common\
addpath(genpath('..\..\interfaces\eeglab2021.1\'))  % #### change according to your local path ####
Configuration = Configuration();

rng(Configuration.RNG_CONST) % For reproducibility
offline = 0;

% choose folders to agregate data from
recordings_offline = [
    {'..\NewestHeadsetRecordingsTomer\Test1'}
];
recordings_online = [];

% data pipeline
all_feat  = [];
all_label = [];

for i = 1:size(recordings_offline, 1)
    folder = recordings_offline{i};
    curr_feat = feat_from_offline(folder);
    curr_label = load(strcat(recordings_offline{i}, '\labels.mat'));
    all_feat  = cat(1, all_feat, curr_feat);
    all_label = cat(2, all_label, curr_label.labels);
end

for i = 1:size(recordings_online, 1) 
    folder = recordings_online{i};
    curr_feat = feat_from_online(folder, Configuration.ONLINE_COLEARN_MODE_CWB);
    all_feat  = cat(1, all_feat, curr_feat);
    all_label = cat(2, all_label, curr_label.labels);
end

folder = '..\NewHeadsetRecordingsOmri\combined';
selected_feat = MI5_feature_selection(all_feat, all_label, folder);
MI6_LearnModel(folder, Configuration.CLASSIFIER_TYPE, Configuration.CLASSIFIER_SAVE);





