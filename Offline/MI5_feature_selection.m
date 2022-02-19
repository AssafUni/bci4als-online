function selected_feat = MI5_feature_selection(all_feat,all_labels, saving_folder)
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

if Configuration.FE_MODE == 0
    SelectedIdx = selected(1:Configuration.FE_N);
else
    SelectedIdx = cell2mat(struct2cell(load(Configuration.FE_FILE)));
end

selected_feat = all_feat(:,SelectedIdx); % updating the matrix feature
% selected_feat_names = feat_names(:,SelectedIdx);

% saving
save(strcat(saving_folder,'\all_feat.mat'),'all_feat');
save(strcat(saving_folder,'\selected_feat.mat'),'selected_feat');
save(strcat(saving_folder,'\SelectedIdx.mat'),'SelectedIdx');
save(strcat(saving_folder,'\all_labels.mat'),'all_labels'); 
% save(strcat(saving_folder,'\selected_feat_names.mat'),'selected_feat_names'); 

end


