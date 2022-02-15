function [] = MI6_LearnModel(recordingFolder, model, saveModel)
% MI5_LearnModel_Scaffolding outputs a weight vector for all the features
% using a simple multi-class LDA approach.
% Add your own classifier (SVM, CSP, DL, CONV, Riemann...), and make sure
% to add an accuracy test.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function reads aggregated recording features from $recordingFolder$,
% and depending on the model to train trains a clasiffier and displays
% a cross validation 5 k-fold score. If you want to use the model
% afterwards in the online phase, set saveModel to 1.
% The modes(classifers) are:
% 0 - lda 1 - svm rbf 2 - AdaBoostM2

%% Read the features & labels 
features = cell2mat(struct2cell(load(strcat(recordingFolder, '\selected_feat.mat'))));
labels = cell2mat(struct2cell(load(strcat(recordingFolder, '\all_labels.mat'))));


if model == 0
    c = cvpartition(labels, 'KFold', 5);
    discrCVModel = fitcdiscr(features, labels, 'CVPartition', c);
    loss = kfoldLoss(discrCVModel);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%'])
    
    if saveModel == 1
        discrCVModel = fitcdiscr(features, labels);
        save(strcat(recordingFolder,'Mdl.mat'), 'discrCVModel');       
    end    
elseif model == 1
    t = templateSVM('KernelFunction', 'gaussian');
    Mdl = fitcecoc(features, labels, 'Learners', t);
    CVMdl = crossval(Mdl, 'kfold', 5);
    loss = kfoldLoss(CVMdl);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%']) 
    
    if saveModel == 1
        t = templateSVM('KernelFunction','gaussian');
        Mdl = fitcecoc(features, labels, 'Learners', t);
        save(strcat(recordingFolder,'Mdl.mat'), 'Mdl'); 
    end
elseif model == 2
    t = templateTree('MaxNumSplits', 1);
    Mdl = fitcensemble(features, labels, 'Method', 'AdaBoostM2', 'Learners', t, 'NumLearningCycles', 100);
    CVMdl = crossval(Mdl, 'kfold', 5);
    loss = kfoldLoss(CVMdl);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%']) 
    
    if saveModel == 1
        t = templateTree('MaxNumSplits',1);
        Mdl = fitcensemble(features, labels, 'Method', 'AdaBoostM2', 'Learners',  t, 'NumLearningCycles', 100);
        save(strcat(recordingFolder,'Mdl.mat'), 'Mdl'); 
    end

end

end


