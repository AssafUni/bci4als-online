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

%% add and improve:
% - a mechanism to identify if a new recording is good or not
% - option to select a model only if you specify so

clc; clear all; close all; %#ok<CLALL> 
% add relevant paths to the script
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('C:\Users\tomer\Desktop\ALS\project\')); 
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\'));  % #### change according to your local eeglab path ####
warning('on');

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {[1:17], [1:5], []}; % recordings numbers - make sure that they exist
data_paths = create_paths(recorders, folders_num);
% apperantly we have bad recordings...
% currently bad recordings from tomer: [2] 

%% load the model and its options
uiopen("load")
options = mdl_struct.options;
model = mdl_struct.model;
constants = options.constants;

%% create a multi_recording class object from the paths and options
recordings = cell(1,length(data_paths));
for i = 1:length(data_paths)
    recordings{i} = recording(data_paths{i}, options); % crete a class member for each path
end
all_rec = multi_recording(recordings); % create a class member from all paths

%% predict data classes and visualize the results
all_rec.create_ds; % create a data store
all_rec.normalize_ds; % normalize the data store
all_rec.evaluate(model, "CM_title", 'all data'); % predict using the model
all_rec.visualize("title", 'all data'); % visualize predictions
all_rec.fc_activation(model); % get the fc layer activations
all_rec.visualize_act('tsne', 3); % search for clusters with t-sne or pca, visualize in 2d or 3d!
