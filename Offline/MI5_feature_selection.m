function Selected_Idx = MI5_feature_selection(all_feat,all_labels, saving_folder)
% this is the feature selection process in the pipeline
%
% Input:
%
% Output:
%
%


% ###### need to change and improve the feature selection process #######


class = fscnca(all_feat, all_labels); % feature selection

% sorting the weights in desending order and keeping the indexs
[~, selected] = sort(class.FeatureWeights,'descend');
Selected_Idx = selected(1:Configuration.FE_N);

end


