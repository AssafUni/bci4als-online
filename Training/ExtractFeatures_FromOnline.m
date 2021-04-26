function [] = ExtractFeatures_FromOnline(recordingFolder, correctWrongOrBoth, lastRecordingFolder, Features2Select)

if correctWrongOrBoth == 0
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIAllDataInFeaturesCorrect.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabelsCorrect.mat'))));
elseif correctWrongOrBoth == 1
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIAllDataInFeaturesWrong.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabelsWrong.mat'))));
else 
    MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIAllDataInFeatures.mat'))));
    AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabels.mat'))));
end

MIFeaturesLabel = zscore(MIAllDataFeatures);
MIFeatures = reshape(MIFeaturesLabel,trials,[]);
AllDataInFeatures = MIFeatures;
AllDataInLabels = AllDataLabels;

LastAllDataInFeatures = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInFeatures'))));
LastAllDataInLabels = cell2mat(struct2cell(load(strcat(lastRecordingFolder,'\AllDataInLabels'))));
AllDataInFeatures = [AllDataInFeatures ;LastAllDataInFeatures];
AllDataInLabels = [AllDataInLabels  LastAllDataInLabels];

class = fscnca(AllDataInFeatures, AllDataInLabels); % feature selection
% sorting the weights in desending order and keeping the indexs
[~,selected] = sort(class.FeatureWeights,'descend');

SelectedIdx = selected(1:Features2Select);

MIAllDataInFeaturesSelected = AllDataInFeatures(:,SelectedIdx); % updating the matrix feature

save(strcat(recordingFolder,'\AllDataInFeatures.mat'),'AllDataInFeatures');
save(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'),'MIAllDataInFeaturesSelected');
save(strcat(recordingFolder,'\SelectedIdx.mat'),'SelectedIdx');
save(strcat(recordingFolder,'\AllDataInLabels.mat'),'AllDataInLabels');    
end

