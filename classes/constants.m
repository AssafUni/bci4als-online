classdef constants < handle
   properties (Constant)
    % ### add electrodes names and locations ###
    % paths
    channel_loc_path = 'C:\Users\tomer\Desktop\ALS\interfaces\channel_loc.ced';

    % general settings - DO NOT CHANGE THEM
    N_CLASSES                  = 3;
    IDLE_LABEL                 = 1; % DO NOT CHANGE THIS
    LEFT_LABEL                 = 2; % DO NOT CHANGE THIS
    RIGHT_LABEL                = 3; % DO NOT CHANGE THIS
    SAMPLE_RATE                = 125;     
    RNG_CONST                  = 1; % For reproducibility - need to fix cause its not reproducable as for now
    ROOT_PATH                  = '';
    
    % buffers size for segmentations
    BUFFER_START               = 1500; 
    BUFFER_END                 = 0;        
    
    % new recording settings
    TRIALS_PER_CLASS           = 10; % num of examples per class
    TRIAL_LENGTH               = 5;  % duration of each class mark

    % filters constants
    HIGH_FREQ       = 30;      % BP high cutoff frequency in HZ
    HIGH_WIDTH      = 3;       % the width of the transition band for the high freq cutoff
    LOW_FREQ        = 7;       % BP low cutoff frequency in HZ
    LOW_WIDTH       = 3;       % the width of the transition band for the low freq cutoff
    NOTCH           = 50;      % frequency to implement notch filter
    NOTCH_WIDTH     = 0.5;     % the width of the notch filter

    % preprocessing settings and options
    PREPROCESS_BAD_ELECTRODES  = [12,13,14,15,16]; % electrodes to remove
    PREPROCESS_NOISE_REJECTION = 0;       % automaticNoiseRejection
    PREPROCESS_AVG_REREF       = 0;       % automaticAverageReReference
    PREPROCESS_LAPLACIAN       = 0;       % 1 - use laplacian filtering, 0 - don't use

    % EEGNet & EEGNet_lstm training options
    VerboseFrequency = 50;
    MaxEpochs =  500;
    MiniBatchSize = 150;
    ValidationFrequency =  50;
    
    % features settings and options
    FE_MULTIPLE_RECORDINGS     = 0;
    FE_MODE                    = 0;       % FeatureSelectMode
    FE_N                       = 6;       % Features2Select 
    FE_FILE                    = '';      % Feature2SelectFile
    FE_POWER_ONLY              = 0;       % onlyPowerBands 

   end
end