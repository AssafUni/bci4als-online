function script_setup()
% this function adds usefull paths to matlab search path - eeglab, liblsl,
% chanels locations file, the root path of the project.

    % create a constant object
    addpath(genpath('..\classes')); % add the root folder of the project to the search path
    C = constants();
    
    % add relevant paths to the script
    warning('off'); % suppress a warning about function names conflicts (there is nothing to do with it...)
    addpath(genpath(C.root_path)); 
    addpath(genpath(C.eeglab_path));
    addpath(genpath(C.lab_recorder_path));
    addpath(genpath(C.liblsls_path));
    warning('on');

end