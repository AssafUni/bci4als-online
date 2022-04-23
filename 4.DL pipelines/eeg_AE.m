function AE = eeg_AE(train_ds, val_ds)
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

conf = Configuration();
% extract the input dimentions for the input layer
input_samples = read(train_ds);
input_size = size(input_samples{1,1});

data = readall(train_ds);

% train an autoencoder
AE = trainAutoencoder(data(:,1), 100, 'MaxEpochs', 200,...
                'UseGPU', true,'ShowProgressWindow',true);

end