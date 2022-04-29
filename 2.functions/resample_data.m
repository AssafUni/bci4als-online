function [data, labels] = resample_data(data, labels, rsmpl_size, display)
% this function resamples each class by the factors in rsmpl_size. each
% class resample factor is stored in rsmpl_size in the index which is
% equall to the class number.
% Inputs:
%   data: data matrix to resample
%   labels: the true class of the data
%   rsmpl_size: an array with the resample factors for each class. each
%               class resample factor is stored in the index coresponding to that class
%               number.
%   display: bool, specify if you want to display the new data distribution
%
% Outputs:
%   data: the resampled data 
%   labels: labels of the resampled data
%

% find each class indices
class_1 = data(labels == 1);
class_2 = data(labels == 2);
class_3 = data(labels == 3);

% resample the data
class_1_resampled = repmat(class_1, rsmpl_size(1), 1);
class_2_resampled = repmat(class_2, rsmpl_size(2), 1);
class_3_resampled = repmat(class_3, rsmpl_size(3), 1);

% create the labels for each resampled class
labels_1 = ones(size(class_1_resampled,1),1);
labels_2 = ones(size(class_2_resampled,1),1).*2;
labels_3 = ones(size(class_3_resampled,1),1).*3;


data = [data; class_1_resampled; class_2_resampled; class_3_resampled];
labels = [labels; labels_1; labels_2; labels_3];

if display
    disp('new data distribution');
    tabulate(labels);
end
end