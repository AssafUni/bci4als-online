classdef multi_recording < handle & matlab.mixin.Copyable & recording
    properties (SetAccess = protected)
        rec_idx
        recordings
        num_rec
    end

    methods
        % define the object
        function obj = multi_recording(recordings)
            if nargin > 0  % support an empty class members
                % concatenate all the relevant data
                obj.num_rec = length(recordings);
                obj.segments = []; obj.labels = []; obj.supp_vec = []; obj.sample_time = []; obj.rec_idx = [];
                counter = 1;
                for i = 1:obj.num_rec
                    if ~isa(recordings{i}, 'recording')
                        error('"multi_recording" class inputs must be "recording" class objects!')
                    end
                    obj.path{i} = recordings{i}.path;
                    obj.Name{i} = recordings{i}.Name;
                    obj.markers{i} = recordings{i}.markers;
                    obj.segments    = cat(1, obj.segments, recordings{i}.segments);
                    obj.labels      = cat(1, obj.labels, recordings{i}.labels);
                    obj.supp_vec    = cat(2, obj.supp_vec, recordings{i}.supp_vec);
                    obj.sample_time = cat(2, obj.sample_time, recordings{i}.sample_time);
                    obj.raw_data    = cat(2, obj.raw_data, recordings{i}.raw_data);
                    obj.features    = cat(1, obj.features, recordings{i}.features);
                    obj.rec_idx     = cat(1, obj.rec_idx, [counter, counter + length(recordings{i}.labels) - 1]);
                    counter = counter + length(recordings{i}.labels);
                end
                [obj.supp_vec, obj.sample_time]   = fix_times(obj.supp_vec, obj.sample_time); % fix time points
                obj.options = recordings{1}.options;
                obj.constants = recordings{1}.constants;
                for i = 1:obj.num_rec
                    obj.recordings{i} = copy(recordings{i}); % save copies and not pointers!
                end
            end
        end

        % create a data set from the obj segments and labels
        function create_ds(obj) 
            create_ds@recording(obj)
            for i = 1:obj.num_rec
                obj.recordings{i}.create_ds
            end
        end

        % normalization of data store
        function normalize_ds(obj)
            normalize_ds@recording(obj)
            for i = 1:obj.num_rec
                obj.recordings{i}.normalize_ds
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
                options.print = true;
            end
            % evaluate for the multi_recording
            [pred, thresh, CM] = evaluate@recording(obj, model, CM_title = options.CM_title, ...
                    criterion = options.criterion, criterion_thresh = options.criterion_thresh, ...
                    thres_C1 = options.thres_C1, print = options.print);
            % evaluate for recordings without printing
            for i = 1:obj.num_rec
                options.print = false;
                obj.recordings{i}.evaluate(model, CM_title = options.CM_title, ...
                    criterion = options.criterion, criterion_thresh = options.criterion_thresh, ...
                    thres_C1 = options.thres_C1, print = options.print);
            end
        end

        % train test validation split ### need to add an option for cross
        % recordings split ###
        function [train, test, val] = train_test_split(obj, test_ratio, val_ratio)
            % calculate the number of recordings for each set
            num_test = round(obj.num_rec*test_ratio);
            num_val  = round(obj.num_rec*val_ratio);
            % create a random indices array
            split_rec_idx = randperm(obj.num_rec, obj.num_rec);
            % allocate indices for each set
            test_idx  = split_rec_idx(1:num_test);
            if num_val > 0
                val_idx   = split_rec_idx(num_test + 1:num_test + num_val);
            else
                val_idx = [];
            end
            train_idx = split_rec_idx(num_test + num_val + 1:end);
            % create new objects
            train = multi_recording(obj.recordings(train_idx));
            test  = multi_recording(obj.recordings(test_idx));
            val   = multi_recording(obj.recordings(val_idx));
        end

        % visualize fc activations of a model
        function visualize_act(obj, dim_red_algo, num_dim)
            if isempty(obj.fc_act)
                disp(['You need to calculate the "fc" layer activations in order to visualize them' newline ...
                    'Use the "fc_activation" method to do so!']);
                return
            end
            if strcmp(dim_red_algo, 'tsne')
                points = tsne(obj.fc_act, 'Algorithm', 'exact', 'Distance', 'cityblock', 'NumDimensions', num_dim);
            elseif strcmp(dim_red_algo, 'pca')
                points = pca(obj.fc_act);
                points = points.';
                points = points(:,1:num_dim);
            else 
                disp('pls choose an algorithm from {"pca","tsne"}')
                return
            end

            if num_dim == 2
                scatter_2D(points, obj);
            elseif num_dim == 3
                scatter_3D(points, obj);
            end
        end
    end
end
            









