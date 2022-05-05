classdef constants < handle
%    ##### need to verify the locations are updated to the new headset in the channel_loc file #####
    properties (Constant)
        % general settings - DO NOT CHANGE THEM UNLESS YOU WORK ON A DIFFERENT  PROBLEM!
        N_CLASSES                  = 3;
        IDLE_LABEL                 = 1; % DO NOT CHANGE THIS
        LEFT_LABEL                 = 2; % DO NOT CHANGE THIS
        RIGHT_LABEL                = 3; % DO NOT CHANGE THIS
        SAMPLE_RATE                = 125;
        
        % buffers size for segmentations
        BUFFER_START               = 2500; 
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
    
        % electrodes names and locations
        electrode_num = [1,2,3,4,5,6,7,8,9,10,11];
        electrode_loc = {'C3','C4','Cz','FC1','FC2','FC5','FC6','CP1','CP2','CP5','CP6'};
    end
    
    properties (Access = public)
        eeglab_path
        root_path
        channel_loc_path
        lab_recorder_path
        liblsls_path   
    end

    methods 
        % verify and set important paths for the scripts when constructing a class object
        function obj = constants()
            % find paths of files
            if exist('eeglab.m', 'file')
                obj.eeglab_path = which('eeglab.m');
                obj.eeglab_path = obj.eeglab_path(1:end - 9);
            else
                obj.eeglab_path = input('pls insert your full eeglab folder path, for example - C:\\Users\\eeglab2021.1: ');
            end
            if exist('LabRecorder.exe', 'file')
                obj.lab_recorder_path = which('LabRecorder.exe');
                obj.lab_recorder_path = obj.lab_recorder_path(1:end - 16);
            else
                obj.lab_recorder_path = input('pls insert your full lab recorder folder path, for example - C:\\Users\\LabRecorder: ');
            end
            if exist('lsl_loadlib.m', 'file')
                obj.liblsls_path = which('lsl_loadlib.m');
                obj.liblsls_path = obj.liblsls_path(1:end - 14);
            else
                obj.liblsls_path = input('pls insert your full liblsl folder path, for example - C:\\Users\\liblsl-Matlab: ');
            end

            obj.channel_loc_path = which('channel_loc.ced'); % chanel location file path
            obj.root_path = which('constants.m');            % root path of the project
            obj.root_path = obj.root_path(1:end - 20);
        end
    end
end