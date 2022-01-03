function [] = MI4_ExtractFeatures(recordingFolder, lastRecordingFolder, FeatureSelectMode, Features2Select, Feature2SelectFile, mode, onlyPowerBands, plotSpectrom, plotSpectogram, plotBins, plotBinsFeaturesSelected)
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
numTargets = 3;                                                     % set number of possible targets (classes)
Fs = 125;                                                           % preprocessing output sample rate
trials = size(MIData, 1);                                           % get number of trials from main data variable
[R, C] = size(EEG_chans);                                           % get EEG_chans (char matrix) size - rows and columns
chanLocs = reshape(EEG_chans',[1, R*C]);                            % reshape into a vector in the correct order

%% for using only specific channels
% motor1Index = strfind(chanLocs,'C03');                      % find first occipital channel
% motor1Index = ceil(motor1Index/C);                          % index of C01 channel
% motor2Index = strfind(chanLocs,'C04');                      % find second occipital channel
% motor2Index = ceil(motor2Index/C);                          % index of C02 channel
% MIData = MIData(:,[motor1Index motor2Index],:);             % only use the occipital channels (C1 & C2)
clear motor1Index motor2Index chanLocs R C
numChans = size(MIData,2);                                    % get number of channels from main data variable
%% Power Spectrom

% init cells for  Power Spectrom display
motorDataChan = {};
welch = {};
idxTarget = {};
lg={};

% Some parameters for pre-features processing
motorIndex = {'C03','C04'};                 % INSERT the chosen electrode (for legend)
freq.low = 0.5;                             % INSERT the lowest freq you want
freq.high = 50;                             % INSERT the highst freq you want
freq.Jump = 0.1;                            % SET the freq resolution you desire
f_vector = freq.low:freq.Jump:freq.high;           % freaquncies vector
trailT = length(MIData);                    % trail length
window = [];                                % INSERT time window for pwelch
noverlap = [];                              % INSERT number of overlaps for pwelch

if plotSpectrom == 1
    figure;
end

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
    if plotSpectrom == 1
        ax = subplot(5,1,q);
    end

    motorDataChan{i} = squeeze(MIData(:,i,:))';                     % convert the data to a 2D matrix fillers by channel
    welch{i} = pwelch(motorDataChan{i},window, noverlap, f_vector, Fs);    % calculate the pwelch for each electrode

    for j = 1:numTargets
        idxTarget{j} = find(targetLabels == j);                         % find the target index
        if plotSpectrom == 1
            plot(f_vector, log10(mean(welch{i}(:,idxTarget{j}), 2)));              % ploting the mean power spectrum in dB by each channel & target
            hold on

            xlabel('Frequency [Hz]', 'FontWeight', 'bold');
            ylabel('Power [dB]', 'FontWeight', 'bold');
        end
        %        title(['Electrode: ',motorIndex{i}]);
        %        lg{j} = [num2str(conditionFreq(j)),  ' [Hz]'];         % txt for legend
    end
    if plotSpectrom == 1
        legend(lg)
        sgtitle(['Power Spectrom For The Choosen Electrode']);
    end
end    

% Plot spectogram
if plotSpectogram == 1
    %% Spectogram

    tVec = 0:1/Fs:(trailT/Fs)-1/Fs;
    fig = figure;
    sgtitle(['Spectogram']);
    specPrep = cell(2, 2); % Assign a data cell

    n = 1;
    for i = 1:numTargets
        for k = 1:numChans
            subplot(numChans, numTargets, n);
    
            %  Calculate the spectrogram for each of the electrodes under each
            %  of the conditions.
            for j = 1:length(idxTarget{i})
                [~, ~, ~, ps{i, k}(:,:,j)] = spectrogram(squeeze(MIData(idxTarget{i}(j), k,:)), window, noverlap, [], Fs, 'power');
            end
            n = n +1;
    
            % Make an average and convert the data to decibels
            specPrep{i, k} = mean(10*log10(ps{i, k}), 3);
    
            % Plot the spectrograms
            imagesc(tVec, f_vector, specPrep{i, k});
    
            %title(['Condition: ', num2str(conditionFreq(i)), ' [Hz]', ' - ', 'Electrode: ', motorIndex{k}]);
            axis xy % Flip axis
            cb = colorbar ; % Add colorbar
            cb.Label.String = 'Power [dB]';
            cb.Label.FontSize = 12;
            han = axes(fig, 'visible', 'off');
            han.XLabel.Visible = 'on';
            han.YLabel.Visible = 'on';
            xlabel('Time [sec]', 'FontSize', 15, 'FontWeight', 'bold');
            ylabel('Frequency [Hz]', 'FontSize', 15, 'FontWeight', 'bold');
    
        end
    end    
end




%%%%%%%%5
%%%%%%%%
%%%%%%%%%
[MIFeaturesLabel, MIFeaturesLabelName] = GetFeatures(MIData, trials, numChans, welch, Fs);

MIFeaturesLabel = zscore(MIFeaturesLabel);

% Reshape into 2-D matrix
MIFeatures = reshape(MIFeaturesLabel,trials,[]);
MIFeaturesLabelName = reshape(MIFeaturesLabelName,trials,[]);
AllDataInFeatures = MIFeatures;
AllDataInLabels = targetLabels;

% Plot bins for evaluating features seperation for all features
if plotBins == 1
    TrainIdxTarget = {};
    for j = 1:numTargets
        TrainIdxTarget{j} = find(LableTrain == j);
    end    
    
    bins = 50;
    j = 0;
    figure;
    for i = 1:size(FeaturesTrain,2)-1
        if mod(i, 5) == 0
            figure;
            j = 1;
        else
           j = j + 1; 
        end
        subplot(5,1,j);
        % present the different conditions on top of each other
        histogram(FeaturesTrain(TrainIdxTarget{2},i),bins)  % display left class
        hold on
        histogram(FeaturesTrain(TrainIdxTarget{3},i),bins)  % display right class
        hold off
        title(['Feat :', num2str(i)]);
    end
    legend('Left', 'Right','Location','southoutside')
    sgtitle(['Histograms For The Features']);   
end


%% handeling the featuer matrix depanding on the mode

%% mode 1 - Aggregate all previous recordings
if mode == 1        
    LastAllDataInFeatures = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInFeatures'))));
    LastAllDataInLabels = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInLabels'))));
    AllDataInFeatures = [AllDataInFeatures ;LastAllDataInFeatures];
    AllDataInLabels = [AllDataInLabels  LastAllDataInLabels];
    
    %% feature selection
    class = fscnca(AllDataInFeatures,AllDataInLabels); % feature selection
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');
    
    if FeatureSelectMode == 0
        SelectedIdx = selected(1:Features2Select);
    else
        SelectedIdx = cell2mat(struct2cell(load(Feature2SelectFile)));
    end

    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature
    MIFeaturesSelectedLabelName = MIFeaturesLabelName(:,SelectedIdx);
    %% saving
    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
 
%% mode 1 - using only one recording  
elseif mode == 0
    %% feature selection
    class = fscnca(AllDataInFeatures,AllDataInLabels); % feature selection
    
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');
    
    if FeatureSelectMode == 0
        % taking only the specified number of features with the largest weights
        SelectedIdx = selected(1:Features2Select);
    else
        SelectedIdx = cell2mat(struct2cell(load(Feature2SelectFile)));
    end    
    
    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature
    MIFeaturesSelectedLabelName = MIFeaturesLabelName(:,SelectedIdx);
    
    %% saving
    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
end

% Plot bins of feature seperation only for selected features
if plotBinsFeaturesSelected == 1
    TrainIdxTarget = {};
    for j = 1:numTargets
        TrainIdxTarget{j} = find(LableTrain == j);
    end    
    
    bins = 50;
    figure;
    for i = 1:size(MIFeaturesSelected,2)
        subplot(length(SelectedIdx),1,i);
        % present the different conditions on top of each other
        histogram(MIFeaturesSelected(TrainIdxTarget{2},i),bins)  % display left class
        hold on
        histogram(MIFeaturesSelected(TrainIdxTarget{3},i),bins)  % display right class
        hold off
        title([MIFeaturesSelectedLabelName(1, i)]);
    end
    legend('Left', 'Right','Location','southoutside')
    sgtitle(['Histograms For The Features']);   
end
disp('Successfuly extracted features!');

end

