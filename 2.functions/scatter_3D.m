function scatter_3D(data, multi_Rec)

labels = multi_Rec.labels;

figure('Name', 'clusters')
scatter3(data(labels == 1,1), data(labels == 1,2), data(labels == 1,3), 'r'); hold on
scatter3(data(labels == 2,1), data(labels == 2,2), data(labels == 2,3), 'b'); hold on
scatter3(data(labels == 3,1), data(labels == 3,2), data(labels == 3,3), 'g'); hold on
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
    figure('Name', ['data points from ' multi_Rec.Name{in}])
    scatter3(data(labels == 1,1), data(labels == 1,2), data(labels == 1,3), 'r'); hold on
    scatter3(data(labels == 2,1), data(labels == 2,2), data(labels == 2,3), 'b'); hold on
    scatter3(data(labels == 3,1), data(labels == 3,2), data(labels == 3,3), 'g'); hold on

    % plot the picked recording data points as filled points
    scatter3(rec_points(rec_labels == 1,1), rec_points(rec_labels == 1,2), rec_points(rec_labels == 1,3), 'r', 'filled'); hold on
    scatter3(rec_points(rec_labels == 2,1), rec_points(rec_labels == 2,2), rec_points(rec_labels == 2,3), 'b', 'filled'); hold on
    scatter3(rec_points(rec_labels == 3,1), rec_points(rec_labels == 3,2), rec_points(rec_labels == 3,3), 'g', 'filled'); hold on
    legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});
    drawnow
end
% close all figures?
answer = input('Do you want to close all plots? type anything to keep them open: ');
if isempty(answer)
    close all;
end
end
