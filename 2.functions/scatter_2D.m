function scatter_2D(data, recording)

labels = recording.labels;

figure('Name', 'clusters')
scatter(data(labels == 1,1), data(labels == 1,2), 'r'); hold on
scatter(data(labels == 2,1), data(labels == 2,2), 'b'); hold on
scatter(data(labels == 3,1), data(labels == 3,2), 'g'); hold on
legend({'class 1 - idle', 'class 2 - left', 'class 3 - right'});
drawnow

% mark a specific recording in the cluster
while true
    % input message
    in = input(['pls select a recording to display its cluster members from 1:' num2str(length(recording.recordings)) ' - ']);
    if isempty(in) % stop itterating if no input
        break
    end

    % extract the group name if its a multi class with a group name and
    % determine who is rec variable
    if isa(recording.recordings{in}, 'multi_recording')
        rec = recording.recordings{in};
        group_name = rec.group;  % specify 'train' 'val' 'test' for plots title
        % keep getting into multi recordings if its a nested multi recording
        % untill getting to a recording class object 
        while isa(rec, 'multi_recording')
            in = input(['the selected recording is a multi recording, select a sub recording from 1:' num2str(length(rec.recordings)) ' - ']);
            if isa(rec.recordings{in}, 'recording')
                break
            end
            rec = rec.recordings{in};
        end        
    else
        rec = recording;
        group_name = [];   
    end

    % get the picked recording data and labels
    idx = rec.rec_idx(in,:);
    rec_labels = rec.labels(idx(1):idx(2));
    rec_points = data(idx(1):idx(2),:);

    % plot all data points
    if ~isempty(group_name)
        title = ['data points from ' group_name ' set, recording: ' rec.Name{in}];
    else
        title = ['data points from ' rec.Name{in}];
    end
    figure('Name', title)
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
