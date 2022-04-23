function visualize_results(class_time, pred, seg_time, title)
% plot the time points and their class and predicted calss of segments
%
% Inputs:
%   class_time: a 2-d array, in the first row there are the labels of each
%               time point, and in row 2 there are the time points
%   pred: the predicted class of each segment
%   seg_time: the end time of each segment
%   title: a header for the title of the plot ('train'\'test'\'val')
%


% if no data just return
if isempty(class_time) || isempty(pred) || isempty(seg_time)
    return
end
% plot the labels and predictions over time
figure('Name', [title ' - classification visualization'])
plot(class_time(2,:), class_time(1,:), 'r*', 'MarkerSize', 2); hold on; xlabel('time'); ylabel('labels');
plot(seg_time, pred, 'b+', 'MarkerSize', 2)

end