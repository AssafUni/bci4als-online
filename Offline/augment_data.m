function aug_data = augment_data(datastore)
% this function creates an augmented data from the processed data the
% NN recieves
%
% Inputs:
%   data: a 3d matrix containing the processed and segmented data samples
%         of the EEG recordings
%   aug_types: a string array containing the types of augmentations you
%              desire to perform on the data set
%
% outputs:
%   aug_data: a cell array containing the augmented data in the first
%             column and the labels (as categorical objects) in the second
%             column

% seperate data and labels
data = datastore(:,1);
labels = datastore(:,2);

N = size(data,1); % extract number of samples

% aplly x flip with 0.5 probability 
indices = randperm(N, round(N*0.5));
data(indices) = cellfun(@(X) flip(X,2), data(indices), "UniformOutput", false);

% aplly random gaussian noise with 0.5 probability - need to add the function

aug_data = [data labels];
end

