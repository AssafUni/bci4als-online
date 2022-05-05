function data_paths = create_paths(recorders, folders_num)
% this function creates paths to the desired recordings files and labels
%
% Inputs:
%   recorders: a cell array with the recorders names
%   folders_num: a cell array with the numbers of the desired recordings
%                for each recorder
%
% Outputs:
%   data_paths: a cell array with all the paths to the desired recordings
%               and labels
%

% get the local path of the project folder
root_path = which("create_paths");
root_path = split(root_path, {'\','/'});
root_path = root_path(1:end - 2);
if isunix
    root_path = strjoin(root_path, '/'); 
else
    root_path = strjoin(root_path, '\'); 
end

% build the paths of the recordings files
counter = 0;
for i = 1:length(recorders)
    for j = 1:length(folders_num{i})
        counter = counter + 1;
        path = fullfile(root_path, '3.recordings', strcat('rec_', recorders{i}), strcat('Test', num2str(folders_num{i}(j))));
        data_paths{counter} = path; %#ok<AGROW> 
    end
end
end