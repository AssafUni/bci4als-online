function multi_rec = paths2Mrec(paths, options)
% this function creates a multi recording object from the given paths and
% options
%
% Inputs:
%   paths: a cell array containing the paths of the data files (EEG
%          recordings in XDF format)
%   options: a structure containing the options for the data preprocessing
%
% Output:
%   multi_rec: a multi recording object containing the data from the data
%              paths, preprocessed as specified in options


    recordings = cell(1,length(paths));
    for i = 1:length(paths)
        recordings{i} = recording(paths{i}, options); % crete a class member for each path
    end
    multi_rec = multi_recording(recordings); % create a class member from all paths
end