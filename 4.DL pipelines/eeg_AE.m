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
%   netE: the trained encoder model
%   netD: the trained decoder model
%

%% things to add and improve
% 1. make a function that resize the data in the data stores to be
%    apropriate to the AE - meaning the size of the input needs to be equal to
%    the size of the output. (fix segment_discrete indices afterward!!!)
% 2. add the validation loss in the figure
% 3. reduce the AE size (?)
% 4. get more data to train the AE (?)
% 5. add an augmentation to the training data store
% 6. add function for the AE evaluation (predict, clustering etc.)

%%
% extract the input dimentions for the input layer
input_samples = read(train_ds);
input_size = size(input_samples{1,1});
numLatentChannels = 100;

% define some constants for the decoder
Rehsape_size = [1,78,32];
num_units = Rehsape_size(1)*Rehsape_size(2)*Rehsape_size(3);

% encoder layes
layers_encoder = [
    imageInputLayer(input_size, 'Normalization', 'none')
    convolution2dLayer([1, 64], 8, "Padding", "same", 'stride', [1, 2])
    eluLayer
    convolution2dLayer([input_size(1), 1], 16, 'stride', [input_size(1), 1], 'Padding', 'same')
    eluLayer
    convolution2dLayer([1, 32], 32, "stride", [1, 4], "Padding", "same")
    eluLayer
    fullyConnectedLayer(2*numLatentChannels)
    samplingLayer];

% decoder layers
layers_decoder = [
    featureInputLayer(numLatentChannels)
    fullyConnectedLayer(num_units)
    ReshapeLayer(Rehsape_size)
    transposedConv2dLayer([1 32], 32, "stride", [1, 4], "Cropping", "same")
    eluLayer
    transposedConv2dLayer([input_size(1), 1], 16, 'stride', [input_size(1), 1], 'Cropping', 'same')
    reluLayer
    transposedConv2dLayer([1, 64], 8, 'stride', [1 2], "Cropping", "same")
    eluLayer
    transposedConv2dLayer([1, 64], 1, "Cropping", "same")];

% display the network
% analyzeNetwork(layers_decoder)
% analyzeNetwork(layers_encoder)

% define the encoder and decoder networks
netE = dlnetwork(layers_encoder);
netD = dlnetwork(layers_decoder);

%% training procces
% start by defining some parameters
num_epochs = 300;
val_epoch_freq = 10;
mini_batch_size = constants.MiniBatchSize;
learn_rate = 1e-3;
trailingAvgE = []; trailingAvgSqE = []; trailingAvgD = []; trailingAvgSqD = []; % adam solver parameters

% define a minibatch queue for train and val data stores
numOutputs = 1;

mbq_train = minibatchqueue(train_ds, numOutputs, ...
    'MiniBatchSize', mini_batch_size, ...
    'MiniBatchFcn', @preprocessMiniBatch, ...
    'MiniBatchFormat', "SSCB", ...
    'PartialMiniBatch', "discard");

mbq_val = minibatchqueue(val_ds, numOutputs, ...
    'MiniBatchSize', mini_batch_size, ...
    'MiniBatchFcn', @preprocessMiniBatch, ...
    'MiniBatchFormat', "SSCB");

% initialize the training progress plot
figure
C = colororder;
lineLossTrain = animatedline(Color=C(2,:));
ylim([0 inf])
xlabel("Iteration")
ylabel("Loss")
grid on

% Train the network using a custom training loop. For each epoch, shuffle
% the data and loop over mini-batches of data.
iteration = 0;
start = tic;

% Loop over epochs.
for epoch = 1:num_epochs
%  % calculate the loss of the validation set every 'val_epoch_freq' epochs
%  if mod(epoch, val_epoch_freq) == 0
%     % insert validation loss values in the figure
%     reset(mbq_val)
%     i = 0;
%     while hasdata(mbq_val)
%         i = i + 1;
%         % Read mini-batch of data.
%         X = next(mbq_train);
% 
%         % Evaluate loss and gradients.
%         [loss(i)] = dlfeval(@modelLoss,netE,netD,X);
%     end
%     loss = double(extractdata(loss)); % need to calculate the total loss instead
%     addpoints(lineLossVal,iteration,loss)
%     drawnow
%  end
    % Shuffle data.
    shuffle(mbq_train);

    % Loop over mini-batches.
    while hasdata(mbq_train)
        iteration = iteration + 1;

        % Read mini-batch of data.
        X = next(mbq_train);

        % Evaluate loss and gradients.
        [loss,gradientsE,gradientsD] = dlfeval(@modelLoss,netE,netD,X);

        % Update learnable parameters.
        [netE,trailingAvgE,trailingAvgSqE] = adamupdate(netE, ...
            gradientsE,trailingAvgE,trailingAvgSqE,iteration,learn_rate);

        [netD, trailingAvgD, trailingAvgSqD] = adamupdate(netD, ...
            gradientsD,trailingAvgD,trailingAvgSqD,iteration,learn_rate);

        % Display the training progress.
        D = duration(0,0,toc(start),Format="hh:mm:ss");
        loss = double(extractdata(loss));
        addpoints(lineLossTrain,iteration,loss)
        title("Epoch: " + epoch + ", Elapsed: " + string(D))
        drawnow
    end
end
AE = [netE, netD];
end