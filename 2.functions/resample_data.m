function [data, labels] = resample_data(data, labels, options)

arguments
    data
    labels
    options.class_1 = 0
    options.class_2 = 0
    options.class_3 = 0
    options.display = false
end

% find each class indices
class_1 = data(labels == 1);
class_2 = data(labels == 2);
class_3 = data(labels == 3);

% resample the data
class_1_resampled = repmat(class_1, options.class_1, 1);
class_2_resampled = repmat(class_2, options.class_2, 1);
class_3_resampled = repmat(class_3, options.class_3, 1);

% create the labels for each resampled class
labels_1 = ones(size(class_1_resampled,1),1);
labels_2 = ones(size(class_2_resampled,1),1).*2;
labels_3 = ones(size(class_3_resampled,1),1).*3;


data = [data; class_1_resampled; class_2_resampled; class_3_resampled];
labels = [labels; labels_1; labels_2; labels_3];

if options.display
    disp('new data distribution');
    tabulate(labels);
end
end