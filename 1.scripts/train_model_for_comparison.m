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
% a quick paths check and setup (if required) for the script
script_setup()

%% select folders to aggregate data from
recorders = {'tomer', 'omri', 'nitay'}; % people we got their recordings

train_folders_num = {[1:4, 6:14, 16:17], [1,3,5], []}; % recordings numbers for train data - make sure that they exist
val_folders_num =  {[5], [2], []}; % recordings numbers for validation data- make sure that they exist
test_folders_num = {[15], [4], []}; % recordings numbers for test data - make sure that they exist

train_data_paths = create_paths(recorders, train_folders_num);
val_data_paths = create_paths(recorders, val_folders_num);
test_data_paths = create_paths(recorders, test_folders_num);
% apperantly we have bad recordings from tomer
% currently bad recordings from tomer: [1,2] 


%% define the wanted pipeline and data split options
options.test_split_ratio = 0.1;          % percent of the data which will go to the test set
options.val_split_ratio  = 0.1;          % percent of the data which will go to the test set - if set to 0 val set isn't created
options.cross_rec        = false;        % true - test and train share recordings, false - tests are a different recordings then train
options.feat_or_data     = 'data';       % return "train" as data or features
options.model_algo       = 'EEGNet';     % ML model to train, choose from {'EEGNet', 'EEGNet_lstm', 'EEGNet_bilstm', 'SVM', 'ADABOOST', 'LDA'}
options.feat_alg         = 'wavelet';    % feature extraction algorithm, choose from {'basic', 'wavelet'}
options.cont_or_disc     = 'discrete';   % segmentation type choose from {'discrete', 'continuous'}
options.seg_dur          = 5;            % segments duration in seconds
options.overlap          = 4.5;          % following segments overlapping duration in seconds
options.threshold        = 0.7;          % threshold for labeling in continuous segmentation - percentage of the window containing the class (0-1)
options.sequence_len     = 7;            % length of a sequence to enter in sequence DL models
options.resample         = [0,0,0];      % resample size for each class [class1, class2, class3]
options.constants        = constants();  % a class member with constants that are used in the pipeline 

%% preprocess the data into train, test and validation sets
train = paths2Mrec(train_data_paths, options);
val = paths2Mrec(val_data_paths, options);
test = paths2Mrec(test_data_paths, options);

%% check data distribution in each data set
disp('training data distribution'); train_distr = tabulate(train.labels); tabulate(train.labels)
disp('validation data distribution'); tabulate(val.labels)
disp('testing data distribution'); tabulate(test.labels)

% resample train set - this is how we reballance our training distribution
train_rsmpl = train.rsmpl_data();


%% create a datastore for the data - this is usefull if we want to augment our data while training the NN
train.create_ds();
train_rsmpl.create_ds();
val.create_ds();
test.create_ds();

% normalize all data sets
train.normalize_ds();
train_rsmpl.normalize_ds();
val.normalize_ds();
test.normalize_ds();

% add augmentation functions to the train datastore (X flip & random
% gaussian noise) - helps preventing overfitting
train_rsmpl_aug = train_rsmpl.augment();

%% train a model - the 'algo' name will determine which model to train
model = train_my_model(options.model_algo, options.constants, ...
    "train_ds", train_rsmpl_aug.data_store, "val_ds", val.data_store);

%% set working points and evaluate the model on all data stores
[~, thresh] = test.evaluate(model, CM_title = 'test', print = true);
val.evaluate(model, CM_title = 'val', print = true);
train.evaluate(model, CM_title = 'train', print = true);

%% visualize the predictions
train.visualize("title", 'train'); 
val.visualize("title", 'val'); 
test.visualize("title", 'test');

%% save the model its settings and the recordings names that were used to create it
mdl_struct.options = options;
mdl_struct.model = model;
mdl_struct.test_names = test.Name;
mdl_struct.val_name = val.Name;
mdl_struct.train_name = train.Name;
uisave('mdl_struct', 'mdl_struct');

%% visualize the network weights - try to explaine the network computations
% temporal_conv_weights = model.Layers(3).Weights;