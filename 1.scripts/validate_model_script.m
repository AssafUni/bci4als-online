% this script is for validating models with new recordings, it can be also
% used to check if the recordings are good or not. if the model fails to
% maintain proper accuracy it might be due to bad recordings or due to
% overfitted model. if the model is overfitted you should see it when you
% train the model and check the results on the validation and test sets.
% if the model is okay and the recordings are not good then you should
% recieve low accuracy when predicting on the recording, thus you can check
% every recording seperatly to find wich ones are not good enought.
% bad recordings might be caused due to noise, placing electrodes in the
% wrong position or hardware problems (which we can't fix ourselves)

clc; clear all; close all;
% add relevant paths to the script
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('C:\Users\tomer\Desktop\ALS\project\')); 
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\'))  % #### change according to your local eeglab path ####
warning('on');

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {[], [1:5], []}; % recordings numbers - make sure that they exist
data_paths = create_paths(recorders, folders_num);
% apperantly we have bad recordings...
% currently bad recordings from tomer: [2] 


%% load the model and its options
uiopen("load")
options = mdl_struct.options;
model = mdl_struct.model;
constants = options.constants;

%% create a data store from the paths
[data, labels, sup_vec, time_samp] = paths2dataset(data_paths, options);
ds = set2ds(data, labels);

class_pred = evaluation(model, ds, CM_title = 'data');
visualize_results(sup_vec, class_pred, time_samp, 'train')









