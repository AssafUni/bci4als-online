function [test_results] = MI5_LearnModel_Scaffolding(recordingFolder, model, cv, saveModel)
% MI5_LearnModel_Scaffolding outputs a weight vector for all the features
% using a simple multi-class LDA approach.
% Add your own classifier (SVM, CSP, DL, CONV, Riemann...), and make sure
% to add an accuracy test.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.
%% Read the features & labels 
MIAllDataFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIAllDataInFeaturesSelected.mat'))));
MIFeatures = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIFeaturesSelected.mat'))));
MIFeaturesTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\MIFeaturesTestSelected.mat'))));
AllDataLabels = cell2mat(struct2cell(load(strcat(recordingFolder,'\AllDataInLabels.mat'))));
LabelTrain = cell2mat(struct2cell(load(strcat(recordingFolder,'\LableTrain')))); % label vector
LabelTest = cell2mat(struct2cell(load(strcat(recordingFolder,'\LableTest')))); % label vector

%% test data
if model == 0
    if cv == 1
        c = cvpartition(AllDataLabels, 'KFold', 5);
        discrCVModel = fitcdiscr(MIAllDataFeatures, AllDataLabels, 'CVPartition', c);
        loss = kfoldLoss(discrCVModel);
        disp(['test accuracy - ' num2str((1 - loss)*100) '%'])
    else
        testPrediction = classify(MIFeaturesTest, MIFeatures, LabelTrain, 'linear');
        test_results = (testPrediction'-LabelTest);
        test_results = (sum(test_results == 0)/length(LabelTest))*100;
        disp(['test accuracy - ' num2str(test_results) '%'])        
    end
    
    if saveModel == 1
        discrCVModel = fitcdiscr(MIAllDataFeatures, AllDataLabels);
        save(strcat(recordingFolder,'Mdl.mat'), 'discrCVModel');       
    end    
else
    if model == 1
        if cv == 1
            t = templateSVM('KernelFunction','gaussian');
            Mdl = fitcecoc(MIAllDataFeatures, AllDataLabels, 'Learners', t);
            CVMdl = crossval(Mdl, 'kfold', 5);
            loss = kfoldLoss(CVMdl);
            disp(['test accuracy - ' num2str((1 - loss)*100) '%']) 
        else
            t = templateSVM('KernelFunction','gaussian');
            Mdl = fitcecoc(MIFeatures, LabelTrain, 'Learners', t);
            testPrediction = predict(Mdl, MIFeaturesTest);   
            test_results = (testPrediction'-LabelTest);
            test_results = (sum(test_results == 0)/length(LabelTest))*100;
            disp(['test accuracy - ' num2str(test_results) '%'])              
        end
    end
    
    if saveModel == 1
        t = templateSVM('KernelFunction','gaussian');
        Mdl = fitcecoc(MIAllDataFeatures, AllDataLabels, 'Learners', t);
        save(strcat(recordingFolder,'Mdl.mat'), 'Mdl');        
    end
end

end


