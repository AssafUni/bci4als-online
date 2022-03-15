function [eegnet_lstm, train_accuracy, test_accuracy] = EEGNet_lstm(train_data, train_lab, val_data, val_lab, test_data, test_lab)
% this function generate and train the Deep network presented in the paper 
% "EEGNet: A Compact Convolutional Neural Network for EEG-based 
% Brain-Computer Interfaces", with an additional lstm kayer, and returns
% the trained model.
% pdf of the paper - https://arxiv.org/pdf/1611.08024v4.pdf
% code from the paper - https://github.com/vlawhern/arl-eegmodels
%
% Input: 
%   - train_data - a 3D matrix of the EEG recordings that will be used to
%   train the model, dim 1 is trial, dim 2 is channels and dim 3 is time (samples).
%   - train_lab - row vector of labels for the trining data
%   - val_data - a 3D matrix of the EEG recordings that will be use to
%   validate the model, dim 1 is trial, dim 2 is channels and dim 3 is time (samples).
%   - val_lab - row vector of labels for the validation data
%   - test_data - a 3D matrix of the EEG recordings that will be used to
%   test the model, dim 1 is trial, dim 2 is channels and dim 3 is time (samples).
%   - test_lab - row vector of labels for the test data
%
% Output:
%   - eegnet - the trained EEGNet model
%   - train_accuracy - accuracy of the model on the train set
%   - test_accuracy - accuracy of the model on the test set


% shift the data dimentions to match the input layer - hXwXcXn
% (height,width,channels,number of images)
for i = 1:size(train_data,1)
    train_data{i} = permute(train_data{i},[2,3,4,1]);
end
for i = 1:size(val_data,1)
    val_data{i} = permute(val_data{i},[2,3,4,1]);
end
for i = 1:size(test_data,1)
    test_data{i} = permute(test_data{i},[2,3,4,1]);
end

% extract the input dimentions for the input layer
input_size = size(train_data{1});


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
    dropoutLayer(0.25)];

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

% define the target vectors for train and validation sets
response_val = categorical(val_lab.'); % define the labels vector as categorical
response_train = categorical(train_lab.'); % define the labels vector as categorical


% set some training and optimization parameters
options = trainingOptions('adam', ...  
    'Plots','training-progress', ...
    'Verbose', true, ...
    'VerboseFrequency',50, ...
    'MaxEpochs', 500, ...
    'MiniBatchSize',100, ...
    'Shuffle','every-epoch', ...
    'ValidationData', {val_data, response_val}, ...
    'ValidationFrequency', 50, ...
    'OutputNetwork', 'best-validation-loss');

% train the network
eegnet_lstm = trainNetwork(train_data, response_train, layers, options);

% compute and display the accuracy of the model on the test and train sets
train_pred = predict(eegnet_lstm, train_data);
val_pred = predict(eegnet_lstm, val_data);
test_pred = predict(eegnet_lstm, test_data);


[~,train_pred] = max(train_pred,[],2);
[~,val_pred] = max(val_pred,[],2);
[~,test_pred] = max(test_pred,[],2);


train_accuracy = sum((train_pred.' - train_lab) == 0)/length(train_lab);
val_accuracy = sum((val_pred.' - val_lab) == 0)/length(val_lab);
test_accuracy = sum((test_pred.' - test_lab) == 0)/length(test_lab);

display(['EEGNet has finish training!' newline ...
    sprintf('train accuray is: %.3f',train_accuracy) newline ...
    sprintf('validation accuray is: %.3f',val_accuracy) newline ...
    sprintf('test accuray is: %.3f',test_accuracy)]);

% plot confusion matrices
C_train = confusionmat(train_lab,train_pred);
C_test = confusionmat(test_lab,test_pred);
figure('Name', 'train confusion matrix');
confusionchart(C_train);
figure('Name', 'test confusion matrix');
confusionchart(C_test);


end