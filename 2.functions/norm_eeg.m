function norm_data =  norm_eeg(datastore)

% seperate data and labels
data = datastore(:,1);
labels = datastore(:,2);

% normalize the data
data = cellfun(@(X) (X - min(X(:)))./max(max(max(max(X - min(X(:)))))), data, "UniformOutput", false);

norm_data = [data labels];
end
