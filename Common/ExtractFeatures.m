function [] = ExtractFeatures(recordingFolder, funcConf)
%% This function extracts features for the machine learning process.
% It takes recorded and extracted features from an online session.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function uses the features that were already extracted from the
% online session and aggregates it with all the other recorded sessions
% features.
% The function has two funcConf.modes:
% 1. Extract features from one recording
% 2. Aggregate data from previous recordings & if used with this function
%    in order iteratively aggregate many recordings together into the
%    %recordingFolder%. 
% The parameters of the functions are as follows:
% 1. The folder of which the features files are located in
% 2. Whether to aggregate only correct trials, wrong or both.
% 3. Last recording folder inorder to aggreagate.
% 4. Feature to select funcConf.mode as in extractFeatures.
% 5. Wether to use only this recording features or aggregate previous
% recordings.


if funcConf.correctWrongOrBoth == 0
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInFeaturesCorrect.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabelsCorrect.mat'))));
elseif funcConf.correctWrongOrBoth == 1
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInFeaturesWrong.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabelsWrong.mat'))));
else 
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllClassDataInFeatures.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllClassDataInLabels.mat'))));
end

trials = size(AllDataLabels, 2);

% MIFeaturesLabel = zscore(MIAllDataFeatures);
MIFeatures = reshape(MIAllDataFeatures,trials,[]);
AllDataInFeatures = MIFeatures;
AllDataInLabels = AllDataLabels;

if funcConf.mode == 1
    LastAllDataInFeatures = cell2mat(struct2cell(load(strcat(funcConf.lastRecordingFolder,'\AllDataInFeatures'))));
    LastAllDataInLabels = cell2mat(struct2cell(load(strcat(funcConf.lastRecordingFolder,'\AllDataInLabels'))));
    AllDataInFeatures = [AllDataInFeatures ;LastAllDataInFeatures];
    AllDataInLabels = [AllDataInLabels  LastAllDataInLabels];

    class = fscnca(AllDataInFeatures, AllDataInLabels); % feature selection
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');

    SelectedIdx = selected(1:funcConf.Features2Select);

    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature

    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');   
elseif funcConf.mode == 0
    class = fscnca(AllDataInFeatures, AllDataInLabels); % feature selection
    % sorting the weights in desending order and keeping the indexs
    [~,selected] = sort(class.FeatureWeights,'descend');

    SelectedIdx = selected(1:funcConf.Features2Select);

    MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature

    save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
    save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
    save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
    save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
end

end

