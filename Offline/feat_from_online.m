function [features, labels] = feat_from_online(folder, correctWrongOrBoth)
%% This function extracts features for the machine learning process.
% It takes recorded and extracted features from an online session.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function uses the features that were already extracted from the
% online session and aggregates it with all the other recorded sessions
% features.
% The function has two modes:
% 1. Extract features from one recording
% 2. Aggregate data from previous recordings & if used with this function
%    in order iteratively aggregate many recordings together into the
%    %recordingFolder%. 
% The parameters of the functions are as follows:
% 1. The folder of which the features files are located in
% 2. Whether to aggregate only correct trials, wrong or both.
% 3. Last recording folder inorder to aggreagate.
% 4. Feature to select mode as in extractFeatures.
% 5. Wether to use only this recording features or aggregate previous
% recordings.


if correctWrongOrBoth == 0
    features = cell2mat(struct2cell(load(strcat(folder,'\features_correct.mat'))));
    labels = cell2mat(struct2cell(load(strcat(folder,'\labels_correct.mat'))));
elseif correctWrongOrBoth == 1
    features = cell2mat(struct2cell(load(strcat(folder,'\features_wrong.mat'))));
    labels = cell2mat(struct2cell(load(strcat(folder,'\labels_wrong.mat'))));
else 
    features = cell2mat(struct2cell(load(strcat(folder,'\features_both.mat'))));
    labels = cell2mat(struct2cell(load(strcat(folder,'\labels_both.mat'))));
end  

end

