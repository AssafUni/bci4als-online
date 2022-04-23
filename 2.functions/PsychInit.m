function [window,white,ifi] = PsychInit()
% PsychInit gets all the psychtoolbox initialization parameters
% working. Mainly opening the screen and getting all the relevant pixel
% information

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% This function will make the Psychtoolbox window semi-transparent:   
PsychDebugWindowConfiguration(0, 0.8); 

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');


% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
if length(screens) > 1
    screenNumber = screens(2);
else
    screenNumber = screens;
end

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
% Open an on screen window
[window, ~] = PsychImaging('OpenWindow', screenNumber, black);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 70);

% set highest priority for screen processes
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel); 

end

