function [] = MI6_LearnModel(features, labels, model_alg, saveModel)
% MI6_LearnModel_Scaffolding outputs a weight vector for all the features
% using a simple multi-class LDA approach.
% Add your own classifier (SVM, CSP, DL, CONV, Riemann...), and make sure
% to add an accuracy test.

% The function reads aggregated recording features from $recordingFolder$,
% and depending on the model to train trains a clasiffier and displays
% a cross validation 5 k-fold score. If you want to use the model
% afterwards in the online phase, set saveModel to 1.
% The modes(classifers) are:
% 0 - lda 1 - svm rbf 2 - AdaBoostM2

% this function creates and train a classification model
%
% Input: fill in after fixing the code
%
% Output: fill in after fixing the code
%
%

%########### need to change the loading data method, and the saving model
% folder. i think the way they compute the accuracy is wrong here need to
% verify it and fix if needed #############

if strcmp(model_alg, 'LDA')
    c = cvpartition(labels, 'KFold', 5);
    discrCVModel = fitcdiscr(features, labels, 'CVPartition', c);
    loss = kfoldLoss(discrCVModel);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%'])
    
    if saveModel == 1
        discrCVModel = fitcdiscr(features, labels);
%         save(strcat(recordingFolder,'Mdl.mat'), 'discrCVModel');       
    end    
elseif strcmp(model_alg, 'SVM')
    t = templateSVM('KernelFunction', 'gaussian');
    Mdl = fitcecoc(features, labels, 'Learners', t);
    CVMdl = crossval(Mdl, 'kfold', 5);
    loss = kfoldLoss(CVMdl);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%']) 
    
    if saveModel == 1
        t = templateSVM('KernelFunction','gaussian');
        Mdl = fitcecoc(features, labels, 'Learners', t);
%         save(strcat(recordingFolder,'Mdl.mat'), 'Mdl'); 
    end
elseif strcmp(model_alg, 'ADABOOST')
    t = templateTree('MaxNumSplits', 1);
    Mdl = fitcensemble(features, labels, 'Method', 'AdaBoostM2', 'Learners', t, 'NumLearningCycles', 100);
    CVMdl = crossval(Mdl, 'kfold', 5);
    loss = kfoldLoss(CVMdl);
    disp(['test accuracy - ' num2str((1 - loss)*100) '%']) 
    
    if saveModel == 1
        t = templateTree('MaxNumSplits',1);
        Mdl = fitcensemble(features, labels, 'Method', 'AdaBoostM2', 'Learners',  t, 'NumLearningCycles', 100);
%         save(strcat(recordingFolder,'Mdl.mat'), 'Mdl'); 
    end

end

end


