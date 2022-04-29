classdef recording < handle & matlab.mixin.Copyable
    properties (SetAccess = protected)
        path        
        options
        Name 
        raw_data
        markers
        segments
        features
        labels
        supp_vec 
        data_store 
        sample_time 
        constants
        predictions
        fc_act
    end

    methods
        % define the object
        function obj = recording(file_path, options)  
            if nargin > 0
                obj.path = file_path;
                obj.options = options;
                obj.constants = options.constants;
                % extract values from the options structure for better code readability
                cont_or_disc  = options.cont_or_disc;
                seg_dur = options.seg_dur;
                overlap = options.overlap;
                threshold = options.threshold;
                feat_or_data = options.feat_or_data;
                feat_alg = options.feat_alg;
                sequence_len = options.sequence_len;
                % set a name for the obj according to its file path
                strs = split(file_path, '\');
                obj.Name = [strs{end - 1}(5:end) ' - ' strs{end}];            
                % load the raw data and events from the xdf file - using evalc function to suppress any printing from eeglab functions
                [~, EEG] = evalc("pop_loadxdf([file_path '\EEG.xdf'], 'streamtype', 'EEG')"); 
                obj.raw_data = EEG.data;
                obj.markers = EEG.event;
                [segments, labels, obj.supp_vec, sample_time] = ...
                    MI2_SegmentData(file_path, cont_or_disc, seg_dur, overlap, threshold, obj.constants); % create segments
                segments = MI3_Preprocess(segments, cont_or_disc, obj.constants); % filter the segments
                if strcmp(feat_or_data, 'feat')
                    obj.features = get_features(segments, feat_alg); % create features if needed
                end 
                [obj.segments, obj.labels, obj.sample_time] = create_sequence(segments, labels, sequence_len, sample_time);
            end
        end
            
        % create a new obj with resampled segments (data)
        function new_obj = rsmpl_data(obj, resample)
            new_obj = copy(obj);
            if ~isempty(obj.segments) && ~isempty(obj.labels)
                [new_obj.segments, new_obj.labels] = resample_data(obj.segments, obj.labels, resample, true);
            end
        end
            
        % create a data set from the obj segments and labels
        function create_ds(obj) 
            if ~isempty(obj.segments) && ~isempty(obj.labels)
                obj.data_store = set2ds(obj.segments, obj.labels, obj.constants);
            end
        end

        % normalization of data store
        function normalize_ds(obj)
            if ~isempty(obj.data_store)
                obj.data_store = transform(obj.data_store, @norm_eeg);
            end
        end
        
        % data augmentation
        function new_obj = augment(obj)
            new_obj = copy(obj);
            if ~isempty(obj.data_store)
                new_obj.data_store = transform(obj.data_store, @augment_data);
            end
        end

        % predictions and evaluation
        function [pred, thresh, CM] = evaluate(obj, model, options)
            arguments
                obj
                model
                options.thres_C1 = [];
                options.CM_title = '';
                options.criterion = [];
                options.criterion_thresh = [];
                options.print = false;
            end
            if ~isempty(obj.data_store)
                [pred, thresh, CM] = evaluation(model, obj.data_store, CM_title = options.CM_title, ...
                    criterion = options.criterion, criterion_thresh = options.criterion_thresh, ...
                    thres_C1 = options.thres_C1, print = options.print);
                obj.predictions = pred;
            end
        end
        
        % visualization of predictions
        function visualize(obj, options)
            arguments
                obj
                options.title = '';
            end
            if ~isempty(obj.supp_vec) && ~isempty(obj.predictions) && ~isempty(obj.sample_time) && ~isempty(obj.Name)
                visualize_results(obj.supp_vec, obj.predictions, obj.sample_time, options.title)
            end
        end

        % model activations operations
        function fc_activation(obj, model)
            % find the FC layer index
            num_layer = 0;
            for i = 1:length(model.Layers)
                if strcmp('fc', model.Layers(i).Name)
                    num_layer = i - 1;
                end
            end
            if num_layer
                % extract activations from the fc layer
                obj.fc_act = activations(model, obj.data_store, num_layer);
                obj.fc_act = squeeze(permute(obj.fc_act, [4,1,2,3]));
                obj.fc_act = reshape(obj.fc_act, [size(obj.fc_act,1), size(obj.fc_act,2)*size(obj.fc_act,3)]);
            else
                disp(['No fully connected layer found, pls check the model architecture and the layers names.' newline...
                    'If there is a fully conected layer then change the layer name to "fc"'])
            end
        end
    end
end
