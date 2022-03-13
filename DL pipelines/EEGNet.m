function [eegnet, train_accuracy, test_accuracy] = EEGNet(train_data, train_lab, val_data, val_lab, test_data, test_lab)
% this function generate and train the Deep network presented in the paper 
% "EEGNet: A Compact Convolutional Neural Network for EEG-based 
% Brain-Computer Interfaces", and returns the trained model
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
train_data = permute(train_data, [2,3,4,1]);
val_data = permute(val_data, [2,3,4,1]);
test_data = permute(test_data, [2,3,4,1]);

% extract the input dimentions for the input layer
input_size = size(train_data);
input_size = input_size(1:3);

% define the network layers
layers = [
    imageInputLayer(input_size,"Name","imageinput")
    convolution2dLayer([1 64],8,"Name","temporal conv2D","Padding","same")
    batchNormalizationLayer("Name","batchnorm_1")
    groupedConvolution2dLayer([16 1],2,"channel-wise","Name","groupedconv_1","Padding","same","Stride",[16 1])
    batchNormalizationLayer("Name","batchnorm_2")
    eluLayer(1,"Name","elu_1")
    averagePooling2dLayer([1 4],"Name","avgpool2d_1","Padding","same","Stride",[1 4])
    dropoutLayer(0.5,"Name","dropout_1")
    groupedConvolution2dLayer([1 16],1,"channel-wise","Name","groupedconv_2","Padding","same")
    groupedConvolution2dLayer([1 1],16,1,"Name","groupedconv_3","Padding","same")
    batchNormalizationLayer("Name","batchnorm_3")
    eluLayer(1,"Name","elu_2")
    averagePooling2dLayer([1 8],"Name","avgpool2d_2","Padding","same","Stride",[1 8])
    dropoutLayer(0.5,"Name","dropout_2")
    spaceToDepthLayer([1 1],"Name","spaceToDepth")
    fullyConnectedLayer(3,"Name","fc")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

% define the target vectors for train and validation sets
response_val = categorical(val_lab.'); % define the labels vector as categorical
response_train = categorical(train_lab.'); % define the labels vector as categorical


% set some training and optimization parameters
options = trainingOptions('adam', ...  
    'Plots','training-progress', ...
    'Verbose', true, ...
    'VerboseFrequency',100, ...
    'MaxEpochs', 1200, ...
    'MiniBatchSize',45, ...
    'Shuffle','every-epoch', ...
    'ValidationData', {val_data, response_val}, ...
    'ValidationFrequency', 30, ...
    'OutputNetwork', 'last-iteration');

% train the network
eegnet = trainNetwork(train_data, response_train, layers, options);

% compute and display the accuracy of the model on the test and train sets
train_pred = predict(eegnet, train_data);
test_pred = predict(eegnet, test_data);

[~,train_pred] = max(train_pred,[],2);
[~,test_pred] = max(test_pred,[],2);

train_accuracy = sum((train_pred.' - train_lab) == 0)/length(train_lab);
test_accuracy = sum((test_pred.' - test_lab) == 0)/length(test_lab);

display(['EEGNet has finish training!' newline ...
    sprintf('train accuray is: %.3f',train_accuracy) newline ...
    sprintf('test accuray is: %.3f',test_accuracy)]);

% plot confusion matrices
C_train = confusionmat(train_lab,train_pred);
C_test = confusionmat(test_lab,test_pred);
figure('train confusion matrix');
confusionchart(C_train);
figure('test confusion matrix');
confusionchart(C_test);


end