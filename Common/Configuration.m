classdef Configuration
   properties (Constant)
    % general settings - DO NOT CHANGE THEM
    N_CLASSES                  = 3;
    IDLE_LABEL                 = 1; % DO NOT CHANGE THIS
    LEFT_LABEL                 = 2; % DO NOT CHANGE THIS
    RIGHT_LABEL                = 3; % DO NOT CHANGE THIS
    SAMPLE_RATE                = 125;     
    RNG_CONST                  = 1; % For reproducibility - need to fix cause its not reproducable as for now
    ROOT_PATH                  = '';
    
    % buffers size for segmentations
    BUFFER_START               = 1800; 
    BUFFER_END                 = 500;   % this buffer is way too big for real time aplication - need to improve the BPF we are using     
    
    % new recording settings
    TRIALS_PER_CLASS           = 10; % num of examples per class
    TRIAL_LENGTH               = 5;  % duration of each class mark

    % filters constants
    HIGH_FREQ       = 40;      % BP high cutoff frequency in HZ
    HIGH_WIDTH      = 3;       % the width of the transition band for the high freq cutoff
    LOW_FREQ        = 5;       % BP low cutoff frequency in HZ
    LOW_WIDTH       = 3;       % the width of the transition band for the low freq cutoff
    NOTCH           = 50;      % frequency to implement notch filter
    NOTCH_WIDTH     = 0.5;     % the width of the notch filter

    % preprocessing settings and options
    PREPROCESS_BAD_ELECTRODES  = [12,13,14,15,16];      % electrodesToRemove
    PREPROCESS_NOISE_REJECTION = 0;       % automaticNoiseRejection
    PREPROCESS_AVG_REREF       = 0;       % automaticAverageReReference
    PREPROCESS_LAPLACIAN       = 0;       % 1 - use laplacian filtering, 0 - don't use

    % EEGNet & EEGNet_lstm training options
    VerboseFrequency = 50;
    MaxEpochs =  500;
    MiniBatchSize = 100;
    ValidationFrequency =  50;
    OutputNetwork = 'best-validation-loss';
    
    % features settings and options
    FE_MULTIPLE_RECORDINGS     = 0;
    FE_MODE                    = 0;       % FeatureSelectMode
    FE_N                       = 6;       % Features2Select 
    FE_FILE                    = '';      % Feature2SelectFile
    FE_POWER_ONLY              = 0;       % onlyPowerBands 

    % When training on online data(from features only in the recording array),
    % you can train on correct labled trials, wrong, or both. (not ussing
    % it yet - can be ignored)
    ONLINE_COLEARN_MODE_CWB = 2; % 0 correct 1 wrong 2 both - On features only train, on what to train
    CLASSIFIER_TYPE         = 1; % 0 - lda 1 - svm rbf 2 - AdaBoostM2
    CLASSIFIER_SAVE         = 1; % 0 - dont save, 1 - save the model
   end
end