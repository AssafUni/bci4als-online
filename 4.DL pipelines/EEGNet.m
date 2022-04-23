function eegnet = EEGNet(train_ds, val_ds, constants)
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
%
% Output:
%   eegnet: the trained EEGNet model
%

% extract the input dimentions for the input layer
input_samples = read(train_ds);
input_size = size(input_samples{1,1});

% define the network layers
layers = [
    imageInputLayer(input_size, 'Normalization','none')
    convolution2dLayer([1 64],8,"Padding","same")
    batchNormalizationLayer
    groupedConvolution2dLayer([input_size(1) 1],2,"channel-wise")
    batchNormalizationLayer
    eluLayer
    averagePooling2dLayer([1 4],"Stride",[1 4])
    dropoutLayer(0.5)
    groupedConvolution2dLayer([1 16],1,"channel-wise","Padding","same")
    convolution2dLayer(1,16,"Padding","same")
    batchNormalizationLayer
    eluLayer
    averagePooling2dLayer([1 8],"Stride",[1 8])
    dropoutLayer(0.25)
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];

% display the network
% analyzeNetwork(layers)

% set some training and optimization parameters
options = trainingOptions('adam', ...
    'Plots','training-progress', ...
    'Verbose', true, ...
    'VerboseFrequency',constants.VerboseFrequency, ...
    'MaxEpochs', constants.MaxEpochs, ...
    'MiniBatchSize',constants.MiniBatchSize, ...
    'Shuffle','every-epoch', ...
    'ValidationData', val_ds, ...
    'ValidationFrequency', constants.ValidationFrequency, ...
    'ValidationPatience', 15,...
    'LearnRateSchedule', 'piecewise',...
    'LearnRateDropPeriod', 100,...
    'LearnRateDropFactor', 0.1,...
    'OutputNetwork', 'last-iteration');

% train the network
eegnet = trainNetwork(train_ds, layers, options);

end