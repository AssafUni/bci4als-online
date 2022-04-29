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

%% things to add
% 1. prediction section
% 2. evaluation section
% 3. clustering evaluation
% 4. add options.save & options.save_path and make the saving automatic
%%

clc; clear all; close all;

% add relevant paths to the script
addpath(genpath('..\')); 
warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it)
addpath(genpath('..\..\interfaces\eeglab2021.1\'))  % #### change according to your local eeglab path ####
warning('on');

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings
folders_num = {[1 3:12], [], []}; % recordings numbers - make sure that they exist
data_paths = create_paths(recorders, folders_num);
% apperantly we have one bad recording from tomer, try finding it and delete it
% bad recordings tomer = [2]

%% define the wanted pipeline and data split options
options.test_split_ratio = 0.1;          % percent of the data which will go to the test set
options.val_split_ratio  = 0.1;            % percent of the data which will go to the test set - if set to 0 val set isn't created
options.cross_rec        = false;        % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.model_algo       = 'EEG_AE';  % ML model to train, choose from {'EEGNet', 'EEGNet_lstm', 'EEG_AE', 'SVM', 'ADABOOST', 'LDA'}
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'discrete';   % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4.5;          % following segments overlapping duration in seconds
options.threshold        = 0.7;          % threshold for labeling in continuous segmentation - percentage of the window containing the class (0-1)
options.sequence_len     = 1;            % length of a sequence to enter in sequence DL models, set to 1 if you dont want to create sequences (for EEGNet model)
options.resample         = [1,1,1];      % resample size for each class [class1, class2, class3]
options.constants        = constants();  % a class member with constants that are used in the pipeline

%% preprocess the data into train, test and validation sets
[train, train_labels, test, test_labels, val, val_labels] = train_test_split(data_paths, options);

%% check data distribution in each data set
disp('training data distribution'); train_distr = tabulate(train_labels); tabulate(train_labels)
disp('testing data distribution'); tabulate(test_labels)

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
[AE] = train_my_model(options.model_algo, options.constants, "train_ds", train_ds_aug, 'val_ds', val_ds);
netE = AE(1);
netD = AE(2);

%% visualize the results - lets see the clusters!
% create dlarrays from the data so we can predict on it with the dlseries model
dltrain = dlarray(permute(cell2mat(train),[2,3,4,1]), 'SSCB'); 
dltest = dlarray(permute(cell2mat(test),[2,3,4,1]), 'SSCB'); 
dlval = dlarray(permute(cell2mat(val),[2,3,4,1]), 'SSCB'); 

% predict the 'features' of each data store
features_test = predict(netE, dltest);
features_train = predict(netE, dltrain);
features_val = predict(netE, dlval);

% predict the reconstruction of the data stores
% reconstruct_train = modelPredictions(netE,netD,train_ds);
% reconstruct_test = modelPredictions(netE,netD,test_ds);
% reconstruct_val = modelPredictions(netE,netD,val_ds);

% make clusters
all_features = gather(extractdata(cat(2, features_train, features_val, features_test)));
all_labels = cat(1, train_labels, val_labels, test_labels);
low_dim_data = tsne(all_features.', 'Algorithm', 'exact', 'Distance', 'euclidean');

figure(1)
scatter(low_dim_data(all_labels == 1,1), low_dim_data(all_labels == 1,2), 'r'); hold on
scatter(low_dim_data(all_labels == 2,1), low_dim_data(all_labels == 2,2), 'b'); hold on
scatter(low_dim_data(all_labels == 3,1), low_dim_data(all_labels == 3,2), 'g');
legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});


%% save the model and its settings 
EEG_AE.options = options;
EEG_AE.encoder = netE;
EEG_AE.decoder = netD;
uisave('EEG_AE', 'EEG_AE');
