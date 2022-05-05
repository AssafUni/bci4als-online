function eegnet_bilstm = EEGNet_bilstm(train_ds, val_ds, constants)
% this function generate and train the Deep network presented in the paper 
% "EEGNet: A Compact Convolutional Neural Network for EEG-based 
% Brain-Computer Interfaces", with an additional bilstm kayer, and returns
% the trained model.
% pdf of the paper - https://arxiv.org/pdf/1611.08024v4.pdf
% code from the paper - https://github.com/vlawhern/arl-eegmodels
%
% Input: 
%   train_ds: a datastore containing the training data and labels. 
%   val_ds: a datastore containing the validation data and labels.
%   constants: a structure contains the constants of the pipeline.
%
% Output:
%   eegnet_bilstm: the trained EEGNet model
%

% extract the input dimentions for the input layer
input_samples = read(train_ds);
input_size = size(input_samples{1,1});

% define the network layers
layers = [
    sequenceInputLayer(input_size(1:3))
    sequenceFoldingLayer()
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
    dropoutLayer(0.5)
    sequenceUnfoldingLayer()
    flattenLayer()
    bilstmLayer(128, "OutputMode","last")
    dropoutLayer(0.25)
    fullyConnectedLayer(3)
    softmaxLayer()
    classificationLayer()];

% create a layer graph and connect layers - this is a DAG network
layers = layerGraph(layers);
layers = connectLayers(layers,"seqfold/miniBatchSize","sequnfold/miniBatchSize");

% display the network
% analyzeNetwork(layers);

% set some training and optimization parameters - cant use parallel pool
% since we have an LSTMLayer in the network
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
    'LearnRateDropPeriod', 15,...
    'LearnRateDropFactor', 0.1,...
    'OutputNetwork', 'last-iteration');

% train the network
eegnet_bilstm = trainNetwork(train_ds, layers, options);

end