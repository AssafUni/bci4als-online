function features = MI4_ExtractFeatures(recordingFolder, flag_save)
%% This function extracts features for the machine learning process.
% It takes the segmented data and extracts the power in each label
% into a variable which is fed into a modeling function.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function uses the preproccessed data to extract features. It supports
% two modes:
% 1. Extract features from one recording
% 2. Aggregate data from previous recordings & if used with this function
%    in order iteratively aggregate many recordings together into the
%    %recordingFolder%. 
% The parameters of the functions are as follows:
% 1. The current recording folder
% 2. The last(if first then leave empty combined with mode = 0) recording
%    folder. The last folder is the result of all the previous aggregated
%    recording.
% 3. The mode to select features. 0 for select using
%    neighborhood component analysis, or 1 to use $Feature2SelectFile$
%    as a file that stores a vector of features numbers to select.
% 4. The mode to aggregate previous recording ot not to aggregate and
%    use only current recording. 0 to use only current recording and
%    1 to aggregate all previous recordings.
% 5. Whether to generate only power bands features or not. 0 for all
%   features and 1 for only power bands features.
% 6. Plotting options.


%% Load previous variables:
load(strcat(recordingFolder, '\EEG_chans.mat'));                   % load the openBCI channel location
load(strcat(recordingFolder, '\segments.mat'));                      % load the EEG data

% Some parameters
trials   = size(segments, 1);      % get number of trials from main data variable
numChans = size(segments,2);       % get number of channels from main data variable

%% Power Spectrom
% init cells for  Power Spectrom display
welch     = {};

% Some parameters for pre-features processing
freq.low  = Configuration.PREPROCESS_LOW_PASS;     % INSERT the lowest freq you want
freq.high = Configuration.PREPROCESS_HIGH_PASS;    % INSERT the highst freq you want
freq.Jump = 0.1;                                   % SET the freq resolution you desire
f_vector  = freq.low:freq.Jump:freq.high;          % freaquncies vector
window    = [];                                    % INSERT time window for pwelch
noverlap  = [];                                    % INSERT number of overlaps for pwelch
% motorIndex = {'C03','C04'};                      % INSERT the chosen electrode (for legend)
% trailT  = length(segments);                        % trail length



% calculate each electrode Power spectrum (Pwelch)
for i = 1:numChans
    DataChan = squeeze(segments(:,i,:))';                                                    % convert the data to a 2D matrix fillers by channel
    welch{i} = pwelch(DataChan, window, noverlap, f_vector, Configuration.SAMPLE_RATE);    % calculate the pwelch for each electrode
end    

%% extract the features
[features, feat_names] = GetFeatures(segments, welch);

% Reshape into 2-D matrix
features = reshape(features,trials,[]);
feat_names = reshape(feat_names,trials,[]);

% saving
if flag_save
    save(strcat(recordingFolder,'\features.mat'),'features');
    save(strcat(recordingFolder,'\feat_names.mat'),'feat_names');
end

disp('Successfuly extracted features!');

end

