clc; clear; close all;

rng(546351789) % For reproducibility

correctWrongOrBoth = 0;
selectFeaturesOrLoadSelected = 0;

recordingFolder = 'D:\EEG\Online\bci4als-online\28April\OnlineSub8\';
testFolder = 'D:\EEG\Online\bci4als-online\28April\OnlineSub8\';

if selectFeaturesOrLoadSelected == 0
    load(strcat(recordingFolder,'SelectedIdx.mat'));
    
    if correctWrongOrBoth == 0
        MIAllDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInFeaturesCorrect.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInLabelsCorrect.mat'))));
    elseif correctWrongOrBoth == 1
        MIAllDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInFeaturesWrong.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInLabelsWrong.mat'))));
    else 
        MIAllDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\AllClassDataInFeatures.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllClassDataInLabels.mat'))));
    end 
    
    trials = size(AllDataLabels, 2);
%     MIAllDataFeatures = zscore(MIAllDataFeatures);
    MIAllDataFeatures = reshape(MIAllDataFeatures,trials,[]);
    EEG_Features = MIAllDataFeatures(:, SelectedIdx);
else
    if correctWrongOrBoth == 0
        MIDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\CorrectClassSelectedFeatures.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInLabelsCorrect.mat'))));
    elseif correctWrongOrBoth == 1
        MIDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\WrongClassSelectedFeatures.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllDataInLabelsWrong.mat'))));
    else 
        MIDataFeatures = cell2mat(struct2cell(load(strcat(testFolder,'\AllClassSelectedFeatures.mat'))));
        AllDataLabels = cell2mat(struct2cell(load(strcat(testFolder,'\AllClassDataInLabels.mat'))));
    end   
    
    trials = size(AllDataLabels, 2);
    MIDataFeatures = reshape(MIDataFeatures,trials,[]);
    EEG_Features = MIDataFeatures(:, SelectedIdx);    
end

load(strcat(recordingFolder,'Mdl.mat'));

testPrediction = predict(Mdl, EEG_Features);
test_results = (testPrediction'-AllDataLabels);
test_results = (sum(test_results == 0)/length(AllDataLabels))*100;
disp(['test accuracy - ' num2str(test_results) '%'])   