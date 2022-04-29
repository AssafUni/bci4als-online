function scatter_2D(data, multi_Rec)

labels = multi_Rec.labels;

figure('Name', 'clusters')
scatter(data(labels == 1,1), data(labels == 1,2), 'r'); hold on
scatter(data(labels == 2,1), data(labels == 2,2), 'b'); hold on
scatter(data(labels == 3,1), data(labels == 3,2), 'g'); hold on
legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});
drawnow

% mark a specific recording in the cluster
while true
    in = input(['pls select a recording to display its cluster members from 1:' num2str(multi_Rec.num_rec) ' - ']);
    if isempty(in)
        break
    end
    % get the picked recording data and labels
    idx = multi_Rec.rec_idx(in,:);
    rec_labels = multi_Rec.labels(idx(1):idx(2));
    rec_points = data(idx(1):idx(2),:);

    % plot all data points
    figure('Name', ['data points from ' all_rec.Name{in}])
    scatter(data(labels == 1,1), data(labels == 1,2), 'r'); hold on
    scatter(data(labels == 2,1), data(labels == 2,2), 'b'); hold on
    scatter(data(labels == 3,1), data(labels == 3,2), 'g'); hold on

    % plot the picked recording data points as filled points
    scatter(rec_points(rec_labels == 1,1), rec_points(rec_labels == 1,2), 'r', 'filled'); hold on
    scatter(rec_points(rec_labels == 2,1), rec_points(rec_labels == 2,2), 'b', 'filled'); hold on
    scatter(rec_points(rec_labels == 3,1), rec_points(rec_labels == 3,2), 'g', 'filled'); hold on
    legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});
    drawnow
end
% close all figures?
answer = input('Do you want to close all plots? type anything to close them: ');
if ~isempty(answer)
    close all;
end
end
