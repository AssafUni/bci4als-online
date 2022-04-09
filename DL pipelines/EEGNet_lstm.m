function [eegnet_lstm, train_accuracy, test_accuracy] = EEGNet_lstm(train_ds, val_ds, test_ds)
% this function generate and train the Deep network presented in the paper 
% "EEGNet: A Compact Convolutional Neural Network for EEG-based 
% Brain-Computer Interfaces", with an additional lstm kayer, and returns
% the trained model.
% pdf of the paper - https://arxiv.org/pdf/1611.08024v4.pdf
% code from the paper - https://github.com/vlawhern/arl-eegmodels
%
% Input: 
%   train_ds: a datastore containing the training data and labels. 
%   val_ds: a datastore containing the validation data and labels.
%   test_ds: a datastore containing the test data and labels.
%
% Output:
%   eegnet: the trained EEGNet model
%   train_accuracy: accuracy of the model on the train set
%   test_accuracy: accuracy of the model on the test set

conf = Configuration();
% extract the input dimentions for the input layer
input_samples = read(train_ds);
input_size = size(input_samples{1,1});

% define the network layers
layers = layerGraph();

tempLayers = [
    sequenceInputLayer(input_size(1:3))
    sequenceFoldingLayer()];

layers = addLayers(layers,tempLayers);

tempLayers = [
    convolution2dLayer([1 64], 8, "Padding","same")
    batchNormalizationLayer()
    groupedConvolution2dLayer([input_size(1) 1], 2, 8)
    batchNormalizationLayer()
    eluLayer(1)
    averagePooling2dLayer([1 4], "Stride", [1 4])
    dropoutLayer(0.5)
    groupedConvolution2dLayer([1 16], 1, 16, "Padding","same")
    convolution2dLayer([1 1], 16, "Padding", "same")
    batchNormalizationLayer()
    eluLayer(1)
    averagePooling2dLayer([1 8], "Stride", [1 8])
    dropoutLayer(0.5)];

layers = addLayers(layers,tempLayers);

tempLayers = [
    sequenceUnfoldingLayer()
    flattenLayer()
    lstmLayer(128, "OutputMode","last")
    dropoutLayer(0.5)
    fullyConnectedLayer(3)
    softmaxLayer()
    classificationLayer()];

layers = addLayers(layers,tempLayers);
layers = connectLayers(layers,"seqfold/out","conv_1");
layers = connectLayers(layers,"seqfold/miniBatchSize","sequnfold/miniBatchSize");
layers = connectLayers(layers,"dropout_2","sequnfold/in");

% display the network
% % analyzeNetwork(layers);

% set some training and optimization parameters - cant use parallel pool
% since we have an LSTMLayer in the network
options = trainingOptions('adam', ...  
    'Plots','training-progress', ...
    'Verbose', true, ...
    'VerboseFrequency',conf.VerboseFrequency, ...
    'MaxEpochs', conf.MaxEpochs, ...
    'MiniBatchSize',conf.MiniBatchSize, ...
    'Shuffle','every-epoch', ...
    'ValidationData', val_ds, ...
    'ValidationFrequency', conf.ValidationFrequency, ...
    'ValidationPatience', 50,...
    'LearnRateSchedule', 'piecewise',...
    'LearnRateDropPeriod', 80,...
    'LearnRateDropFactor', 0.1,...
    'OutputNetwork', conf.OutputNetwork);

% train the network
eegnet_lstm = trainNetwork(train_ds, layers, options);

% compute and display the accuracy of the model on the test and train sets
% compute predictions
train_pred = predict(eegnet_lstm, train_ds);
val_pred = predict(eegnet_lstm, val_ds);
test_pred = predict(eegnet_lstm, test_ds);

% determine the labels - we can change the classification rules if needed
[~,train_pred] = max(train_pred,[],2);
[~,val_pred] = max(val_pred,[],2);
[~,test_pred] = max(test_pred,[],2);

% get the real labels
train_lab = readall(train_ds);
val_lab = readall(val_ds);
test_lab = readall(test_ds);

train_lab = cellfun(@(X) double(X), train_lab(:,2), 'UniformOutput', true);
val_lab = cellfun(@(X) double(X),val_lab(:,2), 'UniformOutput', true);
test_lab = cellfun(@(X) double(X),test_lab(:,2), 'UniformOutput', true);

% compute the accuracy - or any other criterion
train_accuracy = sum((train_pred - train_lab) == 0)/length(train_lab);
val_accuracy = sum((val_pred - val_lab) == 0)/length(val_lab);
test_accuracy = sum((test_pred - test_lab) == 0)/length(test_lab);

display(['EEGNet has finish training!' newline ...
    sprintf('train accuray is: %.3f',train_accuracy) newline ...
    sprintf('validation accuray is: %.3f',val_accuracy) newline ...
    sprintf('test accuray is: %.3f',test_accuracy)]);

% plot confusion matrices for deafault classification threshold & function
C_train = confusionmat(train_lab,train_pred);
C_test = confusionmat(test_lab,test_pred);
figure('Name', 'train confusion matrix');
confusionchart(C_train, ["Idle";"Left"; "Right"]);
figure('Name', 'test confusion matrix');
confusionchart(C_test, ["Idle";"Left"; "Right"]);


end