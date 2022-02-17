function [train_accuracy, test_accuracy] = EEGNet(train_data, train_lab, val_data, val_lab, test_data, test_lab)
% this is the Deep network presented in the paper "EEGNet: A Compact Convolutional Neural Network
% for EEG-based Brain-Computer Interfaces".
% pdf of the paper - https://arxiv.org/pdf/1611.08024v4.pdf
% code from the paper - https://github.com/vlawhern/arl-eegmodels
layers = [
    imageInputLayer([16 626 1],"Name","imageinput")
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

response_val = categorical(val_lab.'); % dfine the labels vector as categorical
response_train = categorical(train_lab.'); % dfine the labels vector as categorical

% shift the data dimentions to match the input layer - h-by-w-by-c-by-N
% (height,width,channels,number of images)
train_data = permute(train_data, [2,3,4,1]);
val_data = permute(val_data, [2,3,4,1]);
test_data = permute(test_data, [2,3,4,1]);


% set some training and optimization parameters
options = trainingOptions('adam', ...  
    'Plots','training-progress', ...
    'Verbose', true, ...
    'VerboseFrequency',100, ...
    'MaxEpochs', 200, ...
    'MiniBatchSize',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData', {val_data, response_val}, ...
    'ValidationFrequency', 30, ...
    'OutputNetwork', 'last-iteration');

eegnet = trainNetwork(train_data, response_train, layers, options);

train_pred = predict(eegnet, train_data);
test_pred = predict(eegnet, test_data);

[~,train_pred] = max(train_pred,[],2);
[~,test_pred] = max(test_pred,[],2);

train_accuracy = sum((train_pred.' - train_lab) == 0)/length(train_lab);
test_accuracy = sum((test_pred.' - test_lab) == 0)/length(test_lab);

display(['EEGNet has finish training!' newline ...
    sprintf('train accuray is: %.3f',train_accuracy) newline ...
    sprintf('test accuray is: %.3f',test_accuracy)]);

end