classdef Configuration
   properties (Constant)
       
    RNG_CONST                  = 1;       % For reproducibility
    ROOT_PATH                  = '';
    
    N_CLASSES                  = 3;
    TRIALS_PER_CLASS           = 10;
    IDLE_LABEL                 = 1;
    LEFT_LABEL                 = 2;
    RIGHT_LABEL                = 3;
    TRIAL_LENGTH               = 5;
    TRIAL_LENGTH_CLASSIFY      = 5; % this value cant be larger than TRIAL_LENGTH

    PREPROCESS_BAD_ELECTRODES  = [];      % electrodesToRemove
    PREPROCESS_PLOT            = true;    % plot during preprocessing?
    PREPROCESS_AVOID_FILTER    = -1;
    PREPROCESS_HIGH_PASS       = 40;      % in Hz, to avoid applying the filter set to 'PREPROCESS_AVOID_FILTER'
    PREPROCESS_LOW_PASS        = 5;       % in Hz, to avoid applying the filter set to 'PREPROCESS_AVOID_FILTER'
    PREPROCESS_NOTCH           = 50;
    PREPROCESS_NOISE_REJECTION = 0;       % automaticNoiseRejection
    PREPROCESS_AVG_REREF       = 0;       % automaticAverageReReference
    PREPROCESS_LAPLACIAN       = 0;       % 1 - use laplacian filtering, 0 - don't use
    SAMPLE_RATE                = 125;     % set to 0 if you don't want to resample
    
    FE_MULTIPLE_RECORDINGS     = 0;
    FE_MODE                    = 0;       % FeatureSelectMode
    FE_N                       = 6;       % Features2Select 
    FE_FILE                    = '';      % Feature2SelectFile
    FE_POWER_ONLY              = 0;       % onlyPowerBands 

    % When training on online data(from features only in the recording array),
    % you can train on correct labled trials, wrong, or both.

    ONLINE_COLEARN_MODE_CWB = 2; % 0 correct 1 wrong 2 both - On features only train, on what to train
    CLASSIFIER_TYPE                       = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
    CLASSIFIER_SAVE                       = 1; % 0 - dont save, 1 - save the model
   end
end