function AE = eeg_AE(train_ds, val_ds, constants)
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
data = readall(train_ds);

numLatentChannels = 100;
input_size = [11,625,1];

layers_encoder = [
    imageInputLayer(input_size, 'Normalization', 'none')
    convolution2dLayer([1, 64], 8, "Padding", "same")
    eluLayer
    maxPooling2dLayer([1, 2], "Stride", [1, 2])
    convolution2dLayer([input_size(1), 1], 16)
    eluLayer
    maxPooling2dLayer([1, 2], "Stride", [1, 2])
    convolution2dLayer([1, 32], 32, "stride", [1, 4], "Padding", "same")
    eluLayer
    fullyConnectedLayer(2*numLatentChannels)
    samplingLayer];

% display the network
analyzeNetwork(layers_encoder)
projectionSize = [1,39,32];

layers_decoder = [
    featureInputLayer(numLatentChannels)
    projectAndReshapeLayer(projectionSize,numLatentChannels)
    transposedConv2dLayer([1 32], 32, "stride", [1, 4], "Cropping", "same")
    maxUnpooling2dLayer([1, 2], "Stride", [1, 2])
    eluLayer
    transposedConv2dLayer([input_size(1), 1], 16)
    maxUnpooling2dLayer([1, 2], "Stride", [1, 2])
    reluLayer
    transposedConv2dLayer([1, 64], 8, "Cropping", "same")
    eluLayer
    transposedConv2dLayer([1, 64], 1, "Cropping", "same")
    sigmoidLayer];

% display the network
analyzeNetwork(layers_decoder)

end