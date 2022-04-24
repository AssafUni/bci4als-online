function ds = set2ds(data, labels, constants)
% this function creates a data store from a data set
%
% Inputs:
%   - data: a cell array containing the data
%   - labels: a vector containing the labels
%
% Outputs:
%   - ds: a data store containing 'data' and 'labels'

if isempty(data)
    ds = [];
    return 
end

% shift the data dimentions to match the input layer of sequential/image input 
% layer - hXwXcXn (height,width,channels,number of images)
data = cellfun(@(x) permute(x, [2,3,4,1]), data, 'UniformOutput', false);

% create cells of the labels - notice we need to feed the datastore with
% categorical instead of numeric labels
if size(labels,1) == 1
    labels = labels.'; % adjust labels dimentions if needed
end
labels = mat2cell(categorical(labels), ones(1,length(labels)));

% define the datastores and their read size - for best runtime performance 
% configure read size to be the same as the minibatch size of the network
read_size = constants.MiniBatchSize;
ds = arrayDatastore([data labels], 'ReadSize', read_size, 'IterationDimension', 1, 'OutputType', 'same');
end