function [features] = MI4_wavelet_ExtractFeatures(recordingFolder, flag_save)
% This function extracts features for the machine learning process.

addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\eeglab2021.1')); % eeglab path

% Load previous variables:
load(strcat(recordingFolder,'\EEG_chans.mat'));                  % load the openBCI channel location
load(strcat(recordingFolder,'\segments.mat'));                     % load the EEG data
targetLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\labels'))));

num_trials = size(segments,1);
num4test = round(0.2*num_trials);    % define how many test trials after feature extraction

% compute the ICA of each section and transform it to the ICA vectors
segments(:,12:13,:) = [];
ICA_data = segments;                                              % just to allocate memory and save run time
for i = 1:size(segments,1)
    ICA_Mdl = rica(squeeze(ICA_data(i,:,:)).', size(ICA_data,2),'Standardize', 1 ); % ICA model
    temp_ICA_data(1,:,:) = transform(ICA_Mdl, squeeze(ICA_data(i,:,:)).').';    % trasform the data
    ICA_data(i,:,:) = temp_ICA_data(1,:,:);
end

% find the ica components that best represents C3, C4 & Cz
locations = logical(strcmp(EEG_chans,'C3') + strcmp(EEG_chans,'C4') + strcmp(EEG_chans,'CZ'));
norm_segments = segments;
a = find(locations)';
final_ica = [];
for v = 1:size(ICA_data,1)
    for i = a
        score = 0;
        electrode = segments(v,i,:);
        mu = ICA_Mdl.Mu(i);
        sigma = ICA_Mdl.Sigma(i);
        electrode = (electrode - mu)./sigma;  % normalize the electrode
        norm_segments(v,i,:) = electrode;
        for j = 1:size(ICA_data,2)
            component = ICA_data(v,j,:);
            pvaf = 1 - var(electrode - component)/var(electrode); % calculate Pvaf
            if pvaf > score % check if its a better ica component to represent the electrode
                score = pvaf;
                comp_num = j;
            end
        end
        final_ica(v,find(locations) == i,:) = ICA_data(v,comp_num,:);
    end
end

%% visulize the ica transform
% for i = 1:size(norm_segments,1)
%     label = targetLabels(1,i);
%     t = 1:length(norm_segments(i,1,:));
%     figure('Name', strcat('C3 - ', num2str(label)));
%     plot(t, squeeze(norm_segments(i,1,:)), t, squeeze(final_ica(i,1,:)));
%     legend({'c3','c3 ica'});
%     figure('Name', strcat('C4 - ', num2str(label)));
%     plot(t, squeeze(norm_segments(i,2,:)), t, squeeze(final_ica(i,2,:)));
%     legend({'c4','c4 ica'});
%     figure('Name', strcat('CZ - ', num2str(label)));
%     plot(t, squeeze(norm_segments(i,3,:)), t, squeeze(final_ica(i,3,:)));
%     legend({'cz', 'cz ica'})
% end

% wavelet transform - feature extraction
features = [];
for i = 1:size(final_ica,1)
    temp_features = [];
    for j = 1:size(final_ica,2)
        [cA1,cD1] = dwt(squeeze(final_ica(i,j,:)),'db12'); % ~30 - 60 HZ
        [cA2,cD2] = dwt(cA1,'db12'); % ~15 - 30 HZ
        [cA3,cD3] = dwt(cA2,'db12'); % ~7.5 - 15 HZ
        [cA4,cD4] = dwt(cA3,'db12'); % ~3.75 - 7.5 HZ
        MAV = [mean(cD2) mean(cD3) mean(cD4)];
        RMS = [rms(cD2) rms(cD3) rms(cD4)];
        temp_features = [temp_features, MAV, RMS];
    end
    features = [features; temp_features];
end

if flag_save
    save(strcat(recordingFolder,'\features.mat'),'features');
%     save(strcat(recordingFolder,'\feat_names.mat'),'feat_names');
end
% % divide into test and train sets
% idleIdx = find(targetLabels == 3);
% leftIdx = find(targetLabels == 1);
% rightIdx = find(targetLabels == 2);
% testIdx = randperm(min([length(rightIdx) length(leftIdx) length(idleIdx)]),round(num4test/3));                       % picking test index randomly
% testIdx = [idleIdx(testIdx) leftIdx(testIdx) rightIdx(testIdx)];    % taking the test index from each class
% testIdx = sort(testIdx);                                            % sort the trials
% 
% % split test data
% FeaturesTest = features(testIdx,:,:);     % taking the test trials features from each class
% LabelTest = targetLabels(testIdx);        % taking the test trials labels from each class
% 
% % split train data
% FeaturesTrain = features;
% FeaturesTrain(testIdx,:,:) = [];          % delete the test trials from the features matrix, and keep only the train trials
% LabelTrain = targetLabels;
% LabelTrain(testIdx) = [];                   % delete the test trials from the labels matrix, and keep only the train labels
% 
% % saving
% save(strcat(recordingFolder,'/FeaturesTrain.mat'),'FeaturesTrain');
% save(strcat(recordingFolder,'/FeaturesTest.mat'),'FeaturesTest');
% save(strcat(recordingFolder,'/LabelTest.mat'),'LabelTest');
% save(strcat(recordingFolder,'/LabelTrain.mat'),'LabelTrain');

disp('Successfuly extracted features!');

end
