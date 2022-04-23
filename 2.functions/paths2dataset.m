function [data, labels, sup_vec, time_samp] = paths2dataset(data_paths, options)
% this function read the recordings data segment and preprocces it
%
% Inputs:
%   data_paths: folder paths to where the data (XDF file) is stored
%   options: a structure containing the options of the split function
%
% Outputs:
%   data: a cell array containing the data, each
%                   cell contains one sample of recorded data.
%   labels: an array containing the train\test\val labels.
%   sup_vec: an array containing the class of each time stamp in its first
%            row and the time stamps in its second row for train\test\val set
%   time_samp: array containing the time stamps of each 
%              segment end time for train\test\val set

%% extract the parameters from options structure for later use
feat_or_data     = options.feat_or_data;     % return "train" as data or features
feat_alg         = options.feat_alg;         % feature extraction algorithm choose from {'basic', 'wavelet'}
cont_or_disc     = options.cont_or_disc;     % segmentation type choose from {'discrete', 'continouos'}
seg_dur          = options.seg_dur;          % segments duration in seconds
overlap          = options.overlap;          % following segments overlapping duration in seconds
thresh           = options.threshold;        % threshold for labeling in continuous segmentation
seq_len          = options.sequence_len;
constants        = options.constants;

%% if a discrete segmentation is chosen and sequence length is not 1 then change it to 1
if strcmp(cont_or_disc, 'discrete') && seq_len ~= 1
    seq_len = 1;
    uiwait(msgbox('Since you chose a discrete segmentation, sequence length is set to 1!'));
end

%% create a waitbar to show progress
f = waitbar(0, 'preprocessing data, pls wait');
warning('off');

%% extract features or raw data from folders paths
data = []; labels = []; sup_vec = []; time_samp = []; % define empty matrices
num_rec = length(data_paths);                         % number of recordings
for i = 1:num_rec
    waitbar(i/num_rec, f, ['preprocessing data, recording ' num2str(i) ' out of ' num2str(num_rec)]);
    folder = data_paths{i};
    [curr_segment, curr_label, curr_sup_vec, curr_time_sampled] = MI2_SegmentData(folder, cont_or_disc, seg_dur, overlap, thresh, constants); % segment the raw data
    curr_segment = MI3_Preprocess(curr_segment, cont_or_disc, constants); % aplly filters - iir BP and notch
    if strcmp(feat_or_data, 'feat')
        curr_segment = get_features(curr_segment, feat_alg); % extract features
    end
    [curr_data, curr_label, curr_time_sampled] = create_sequence(curr_segment, curr_label, seq_len, curr_time_sampled); % create sequence if required
    data  = cat(1, data, curr_data);
    labels = cat(1, labels, curr_label);
    sup_vec = cat(2, sup_vec, curr_sup_vec);
    time_samp = cat(2, time_samp, curr_time_sampled);
end
% close the waitbar
delete(f);
warning('on')
% fix time points to be continuous
[sup_vec, time_samp] = fix_times(sup_vec, time_samp);
end
