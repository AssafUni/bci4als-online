function [] = MI4_ExtractFeatures(recordingFolder, lastRecordingFolder)
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

load(strcat(recordingFolder, 'EEG_chans.mat'));                   % load the openBCI channel location
load(strcat(recordingFolder, 'MIData.mat'));                      % load the EEG data
targetLabels = cell2mat(struct2cell(load(strcat(recordingFolder, '\trainingVec'))));

% Some parameters
trials = size(MIData, 1);                                           % get number of trials from main data variable
numChans = size(MIData,2);                                    % get number of channels from main data variable
[R, C] = size(EEG_chans);                                           % get EEG_chans (char matrix) size - rows and columns
chanLocs = reshape(EEG_chans',[1, R*C]);                            % reshape into a vector in the correct order

%% for using only specific channels
% motor1Index = strfind(chanLocs,'C03');                      % find first occipital channel
% motor1Index = ceil(motor1Index/C);                          % index of C01 channel
% motor2Index = strfind(chanLocs,'C04');                      % find second occipital channel
% motor2Index = ceil(motor2Index/C);                          % index of C02 channel
% MIData = MIData(:,[motor1Index motor2Index],:);             % only use the occipital channels (C1 & C2)
clear motor1Index motor2Index chanLocs R C
%% Power Spectrom

% init cells for  Power Spectrom display
motorDataChan = {};
welch = {};
idxTarget = {};
lg={};

% Some parameters for pre-features processing
motorIndex = {'C03','C04'};                 % INSERT the chosen electrode (for legend)
freq.low = Configuration.PREPROCESS_LOW_PASS; % INSERT the lowest freq you want
freq.high = Configuration.PREPROCESS_HIGH_PASS; % INSERT the highst freq you want
freq.Jump = 0.1;                            % SET the freq resolution you desire
f_vector = freq.low:freq.Jump:freq.high;           % freaquncies vector
trailT = length(MIData);                    % trail length
window = [];                                % INSERT time window for pwelch
noverlap = [];                              % INSERT number of overlaps for pwelch

% calculate for each electrode in each of the conditions its own Power
% Spectrom
q = 0;
for i = 1:numChans
    if mod(i,5) == 0
        figure;
        q = 1;
    else
        q = q + 1;
    end

    motorDataChan{i} = squeeze(MIData(:,i,:))';                     % convert the data to a 2D matrix fillers by channel
    welch{i} = pwelch(motorDataChan{i},window, noverlap, f_vector, Configuration.SAMPLE_RATE);    % calculate the pwelch for each electrode

    for j = 1:Configuration.N_CLASSES
        idxTarget{j} = find(targetLabels == j);                         % find the target index
        %        title(['Electrode: ',motorIndex{i}]);
        %        lg{j} = [num2str(conditionFreq(j)),  ' [Hz]'];         % txt for legend
    end
end    

%%%%%%%%5
%%%%%%%%
%%%%%%%%%
[MIFeaturesLabel, MIFeaturesLabelName] = GetFeatures(MIData, welch);

MIFeaturesLabel = zscore(MIFeaturesLabel);

% Reshape into 2-D matrix
MIFeatures = reshape(MIFeaturesLabel,trials,[]);
MIFeaturesLabelName = reshape(MIFeaturesLabelName,trials,[]);
AllDataInFeatures = MIFeatures;
AllDataInLabels = targetLabels;

%% handeling the featuer matrix depanding on the mode

%% mode 1 - Aggregate all previous recordings
if Configuration.FE_MULTIPLE_RECORDINGS == 1        
    LastAllDataInFeatures = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInFeatures'))));
    LastAllDataInLabels = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInLabels'))));
    AllDataInFeatures = [AllDataInFeatures ;LastAllDataInFeatures];
    AllDataInLabels = [AllDataInLabels  LastAllDataInLabels];
    
    %% feature selection
    class = fscnca(AllDataInFeatures,AllDataInLabels); % feature selection
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');
    
    if Configuration.FE_MODE == 0
        SelectedIdx = selected(1:Configuration.FE_N);
    else
        SelectedIdx = cell2mat(struct2cell(load(Configuration.FE_FILE)));
    end

    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature
    MIFeaturesSelectedLabelName = MIFeaturesLabelName(:,SelectedIdx);
    %% saving
    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
 
%% mode 1 - using only one recording  
elseif Configuration.FE_MULTIPLE_RECORDINGS == 0
    %% feature selection
    class = fscnca(AllDataInFeatures,AllDataInLabels); % feature selection
    
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');
    
    if Configuration.FE_MODE == 0
        % taking only the specified number of features with the largest weights
        SelectedIdx = selected(1:Configuration.FE_N);
    else
        SelectedIdx = cell2mat(struct2cell(load(Configuration.FE_FILE)));
    end    
    
    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature
    MIFeaturesSelectedLabelName = MIFeaturesLabelName(:,SelectedIdx);
    
    %% saving
    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
end

disp('Successfuly extracted features!');

end

