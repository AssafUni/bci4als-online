function [recordingFolder, testNum] = MI1_Training()
%% MOTOR IMAGERY Training
% This code creates a training paradigm with (#) numTargets on screen for
% (#) numTrials. Before each trial, one of the targets is cued (and remains
% cued for the entire trial).This code assumes EEG is recorded and streamed
% through LSL for later offline preprocessing and model learning.

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

% The function prompts for a test number, and creates a new folder in
% $rootFolder$. Next, the training begins according to parameters given
% after %Parameters%. The training will be saved into a vector which
% corresponds to the true label of the trial. Simultaneously, the
% lab recorder should create an XDF file(EEG.xdf) that should be paired with
% the training vector.

%% Make sure you have Psychtoolbox & Lab Streaming Layer installed.
%%%%% Set parameters (these will need to change according to your system):

% prompt to enter subject ID or name
testNum = input('Please enter test number: ');
%%%%% Change root folder according to your system %%%%%
rootFolder = 'D:\EEG\subjects\'; 
% Define recording folder location and create the folder
recordingFolder = strcat(rootFolder, '\Test', num2str(testNum), '\');
mkdir(recordingFolder);
%%% Parameters
trialLength = 5;                        % each trial length in seconds 
cueLength = 0.5;
readyLength = 0.5;
nextLength = 0.5;
% set length and classes
numTrials = 5;                         % set number of training trials per condition
numTargets = 3;                         % set number of possible targets (classes)
% set markers
startRecordings = 111;

% Marker stream markers
startTrail = 1111; 
Idle = 1;
Left = 2;
Right = 3;
endTrail = 9;
endRecrding = 99;

%% Lab Streaming Layer Init
disp('Loading the Lab Streaming Layer library...');
% Init LSL parameters
lib = lsl_loadlib();                    % load the LSL library
disp('Opening Marker Stream...');
% Define stream parameters
info = lsl_streaminfo(lib, 'MarkerStream', 'Markers', 1, 0, 'cf_string', 'myuniquesourceid23443');
outletStream = lsl_outlet(info);        % create an outlet stream using the parameters above
disp('Open Lab Recorder & check for MarkerStream and EEG stream, start recording, return here and hit any key to continue.');
pause;                                  % Wait for experimenter to press a key

%% Psychtoolbox, Stim, Screen Params Init:
disp('Setting up Psychtoolbox parameters...');
disp('This will open a black screen - good luck!');
% This function will make the Psychtoolbox window semi-transparent:   
Screen('Preference', 'SkipSyncTests', 1);
% PsychDebugWindowConfiguration(0, 1); 
PsychDebugWindowConfiguration(0, 0.8);  % Use this to debug the psychtoolbox screen


disp('Initializing...');
[window,white,~,~,screenYpixels,~,~,ifi] = PsychInit();
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);                     % set highest priority for screen processes
vbl = Screen('Flip', window);                   % get the vertical beam line
waitFrames = 1;                                 % how many frames to wait for between screen refresh
%% Prepare frequencies and binary sequences
% prepare set of training trials (IMPORTANT FOR LATER MODEL TRAINING)
disp('Generating training...');
trainingVec = prepareTraining(numTrials, numTargets);    % vector with the conditions for each trial %% ask asaf%%
save(strcat(recordingFolder,'trainingVec.mat'), 'trainingVec');

% Define the keyboard keys that are listened for:
KbName('UnifyKeyNames');
escapeKey = KbName('Escape');                   % let psychtoolbox know what the escape key is

HideCursor;                                     % hides cursor on screen
%% Record Training Stage
outletStream.push_sample(startRecordings);    % start of recordings. Later, reject all EEG data prior to this marker
totTrials = length(trainingVec);
disp('Starting training...');
for trial = 1:totTrials
    
    currentTrial = trainingVec(trial);           % What condition is it?
    
    if currentTrial == Idle % idle target
        
        myimgfile='square.jpeg';
        
    elseif currentTrial == Left % left target
        
        myimgfile='arrow_left.jpeg';
        
    elseif currentTrial == Right % right target
        
        myimgfile='arrow_right.jpeg';
    end
    disp('Loading image...');
    ima=imread(myimgfile, 'jpeg');
    Screen('PutImage', window, ima); % put image on screen
    Screen('Flip', window);           % now visible on screen
    pause(cueLength);
    % Show "Ready" on screen for 2 seconds, followed by the relevant target
    disp('Presenting ready...');
    Screen('TextSize', window, 70);             % Draw text in the bottom portion of the screen in white
    DrawFormattedText(window, 'Ready', 'center', screenYpixels * 0.75, white);
    Screen('Flip', window);
    pause(readyLength);                         % "Ready" stays on screen
    
    disp('Showing image...');  
    Screen('PutImage', window, ima); % put image on screen
    Screen('Flip', window);           % now visible on screen
    disp('Starting trial...');
    outletStream.push_sample(startTrail);  % new trial recording
    outletStream.push_sample(currentTrial);  % new trial recording 
    
    disp('Pausing...'); 
    pause(trialLength);              % target stays on screen
    
    disp('Presenting next...'); 
    Screen('TextSize', window, 70);  % Draw text in the bottom portion of the screen in white
    DrawFormattedText(window, 'Next', 'center', screenYpixels * 0.75, white);
    Screen('Flip', window);
    disp('Pausing...');
    pause(nextLength);               % "Next" stays on screen
    
    [~,~, keyCode] = KbCheck;    % check for keyboard press
    if keyCode(escapeKey)        % pushed escape key - SHUT IT DOWN!!!
        ShowCursor;
        sca;
        return
    end
    % Show on screen all the stimuli - assures correct refresh rate
    vbl = Screen('Flip', window, vbl + (waitFrames - 0.5) * ifi);
    %end
    disp('Ending trial...');
    outletStream.push_sample(endTrail); % represent that the last section ends
end
%% End of recording session
outletStream.push_sample(endRecrding);   % 99 is end of experiment
ShowCursor;
sca;
Priority(0);
disp('Stop the LabRecorder recording!');

