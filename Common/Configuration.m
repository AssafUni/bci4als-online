classdef Configuration
   properties (Constant)

    RNG_CONST = 546351789; % For reproducibility
    ROOT_PATH = '';

    PREPROCESS_BAD_ELECTRODES = []; %electrodesToRemove
    PREPROCESS_PLOT = true; % plot during preprocessing?
    PREPROCESS_AVOID_FILTER = -1;
    PREPROCESS_HIGH_PASS = 50; % in Hz, to avoid applying the filter set to 'PREPROCESS_AVOID_FILTER'
    PREPROCESS_LOW_PASS = 1; % in Hz, to avoid applying the filter set to 'PREPROCESS_AVOID_FILTER'
    PREPROCESS_NOISE_REJECTION = 0; % automaticNoiseRejection
    PREPROCESS_AVG_REREF = 0; % automaticAverageReReference 
    SAMPLE_RATE = 125;

    FE_MODE = 0; % FeatureSelectMode
    FE_N = 6; % Features2Select 
    FE_FILE = ''; %Feature2SelectFile
    FE_POWER_ONLY = 0; % onlyPowerBands 

    % When training on online data(from features only in the recording array),
    % you can train on correct labled trials, wrong, or both.
    ONLINE_COLEARN_MODEcorrectWrongOrBoth = 2; % 0 correct 1 wrong 2 both - On features only train, on what to train
    % which model to train
    CLASSIFIER_TYPE = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
    % Whether to save or not to save the model
    CLASSIFIER_SAVE = 1;% saveModel
   end
end