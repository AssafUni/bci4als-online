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
% - indices of each recording data examples
% - option to mark a specific recording in the clusters
% - a mechanism to identify if a new recording is good or not
% - option to select a model only if you specify so

clc; clear all; close all;
% add relevant paths to the script
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('C:\Users\tomer\Desktop\ALS\project\')); 
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\'))  % #### change according to your local eeglab path ####
warning('on');

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {[1, 3:12], [], []}; % recordings numbers - make sure that they exist
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
ds = set2ds(data, labels, constants);
ds = transform(ds, @norm_eeg);

%% predict on the new data and visualize the results
class_pred = evaluation(model, ds, CM_title = 'data');
visualize_results(sup_vec, class_pred, time_samp, 'train')

%% get activations from the fullyconnected layer and search for clusters with t-sne
% find the FC layer index
for i = 1:length(model.Layers)
    if strcmp('fc', model.Layers(i).Name)
        num_layer = i - 1;
    end
end
% extract activations from the fc layer
features = activations(model, ds, num_layer);
features = squeeze(permute(features, [4,1,2,3]));
features = reshape(features, [size(features,1), size(features,2)*size(features,3)]);
% use t-sne to remap the features into a 2-3D visualization
low_dim_data = tsne(features, 'Algorithm', 'exact', 'Distance', 'euclidean');
figure('Name', 'clusters')
scatter(low_dim_data(labels == 1,1), low_dim_data(labels == 1,2), 'r'); hold on
scatter(low_dim_data(labels == 2,1), low_dim_data(labels == 2,2), 'b'); hold on
scatter(low_dim_data(labels == 3,1), low_dim_data(labels == 3,2), 'g');
legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});

% mark a specific recording in the cluster











