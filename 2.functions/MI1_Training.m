function [recordingFolder, testNum] = MI1_Training()
%% MOTOR IMAGERY Training
% This code creates a training paradigm with (#) numTargets on screen for
% (#) numTrials. Before each trial, one of the targets is cued (and remains
% cued for the entire trial).This code assumes EEG is recorded and streamed
% through LSL for later offline preprocessing and model learning.

% The function prompts for a test number, and creates a new folder in
% $rootFolder$. Next, the training begins according to parameters given
% after %Parameters%. The training will be saved into a vector which
% corresponds to the true label of the trial. Simultaneously, the
% lab recorder should create an XDF file(EEG.xdf) that should be paired with
% the training vector.

%% Make sure you have Psychtoolbox & Lab Streaming Layer installed.
% Set parameters (these will need to change according to your system):
addpath(genpath('C:\Users\tomer\Desktop\ALS\interfaces\'))  
constant = constants();

% prompt to enter subject ID or name
testNum = input('Please enter test number: ');
%%%%% Change root folder according to your system %%%%%
rootFolder = 'C:\Users\tomer\Desktop\ALS\project\3.recordings\new recordings'; 
% Define recording folder location and create the folder
recordingFolder = strcat(rootFolder, '\Test', num2str(testNum), '\');
if ~exist(recordingFolder, 'dir') % create the folder if its not exist
    mkdir(recordingFolder);
end
% set parameters
trialLength = constant.TRIAL_LENGTH;   % each trial length in seconds 
cueLength = 0.5;                       % cue length in seconds
readyLength = 1.5;                     % ready length in seconds
nextLength = 0.5;                      % next length in seconds
numTrials = constant.TRIALS_PER_CLASS; % number of trials per class
numTargets = constant.N_CLASSES;       % number of targets (classes)
startRecordings = 111;                 % start recording marker
endRecrding = 99;                      % end recording marker
startTrail = 1111;                     % start trial marker
endTrail = 9;                          % end trial marker
Idle = constant.IDLE_LABEL;            % idle class number
Left = constant.LEFT_LABEL;            % left class number
Right = constant.RIGHT_LABEL;          % right class number

%% Lab Streaming Layer Init
% load the LSL library
disp('Loading the Lab Streaming Layer library...');
lib = lsl_loadlib();                    

% start marker lsl stream
disp('Opening Marker Stream...');
info = lsl_streaminfo(lib, 'MarkerStream', 'Markers', 1, 0, 'cf_string', 'myuniquesourceid23443');
outletStream = lsl_outlet(info);        % create an outlet stream using the parameters above
disp('Open Lab Recorder & check for MarkerStream and EEG stream, start recording, return here and hit any key to continue.');
pause;                                  % Wait for experimenter to press a key

%% Prepare frequencies and binary sequences
% prepare set of training trials (IMPORTANT FOR LATER MODEL TRAINING)
labels = (1:numTargets);
labels = repmat(labels, 1, numTrials);
labels = labels(randperm(length(labels)));

save(strcat(recordingFolder,'labels.mat'), 'labels');

%% Record Training Stage
[window, white] = PsychInit(); % Psychtoolbox Screen Params Init
outletStream.push_sample(startRecordings); % start of recording
num_trials = length(labels);
for trial = 1:num_trials
    
    currentTrial = labels(trial); % What condition is it?
    
    if currentTrial == Idle       % idle target
        
        myimgfile = 'square.jpeg';
        
    elseif currentTrial == Left   % left target
        
        myimgfile = 'arrow_left.jpeg';
        
    elseif currentTrial == Right  % right target
        
        myimgfile = 'arrow_right.jpeg';
    end

    % display "next"
    DrawFormattedText(window, 'Next', 'center','center', white); % place text in center of screen
    Screen('Flip', window);
    pause(nextLength);               % "Next" stays on screen

    % display the image related to the current class for a brief time
    ima = imread(myimgfile, 'jpeg');
    Screen('PutImage', window, ima);  % put image on screen
    Screen('Flip', window);           % now visible on screen
    pause(cueLength);

    % display "Ready"
    DrawFormattedText(window, 'Ready', 'center', 'center', white); % place text in center of screen
    Screen('Flip', window);
    pause(readyLength);                         % "Ready" stays on screen
    
    % display the image related to the current class
    Screen('PutImage', window, ima);         % put image on screen
    Screen('Flip', window);                  % now visible on screen
    outletStream.push_sample(startTrail);    % new trial marker
    outletStream.push_sample(currentTrial);  % the class of the trial marker
    pause(trialLength);                      % target stays on screen
    outletStream.push_sample(endTrail);      % end trial marker
end
%% End of recording session
outletStream.push_sample(endRecrding);   % 99 is end of experiment
ShowCursor;
sca;
Priority(0);
disp('Stop the LabRecorder recording!');

