function [features, labels] = feat_from_online(folder, correctWrongOrBoth)
%% This function extracts features for the machine learning process.
% It takes recorded and extracted features from an online session.

%######## need to change all the protocol for saving/loading online features to be consistent with the offline methods ##########
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

