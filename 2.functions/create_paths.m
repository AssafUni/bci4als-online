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

counter = 0;
for i = 1:length(recorders)
    for j = 1:length(folders_num{i})
        counter = counter + 1;
        curr_path = ['C:\Users\tomer\Desktop\ALS\project\3.recordings\rec_',...
            recorders{i}, '\', 'Test', num2str(folders_num{i}(j))];
        data_paths{counter} = curr_path;
    end
end
end