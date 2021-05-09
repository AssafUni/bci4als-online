%function MI_Online_Learning(recordingFolder)
%% MI Online Scaffolding
% This code creates an online EEG buffer which utilizes the model trained
% offline, and corresponding conditions, to classify between the possible labels.
% Assuming: 
% 1. EEG is recorded using Wearable Sensing / openBCI and streamed through LSL.
% 2. MI classifier has been trained
% 3. A different machine/client is reading this LSL oulet stream for the commands sent through this code
% 4. Target labels are [-1 0 1] (left idle right)

% Remaining to be done:
% 1. Add a "voting machine" which takes the classification and counts how
% many consecutive answers in the same direction / target to get a high(er)
% accuracy rate, even though it slows down the process by a large factor.
% 2. Add an online learn-with-feedback mechanism where there is a cue to
% one side (or idle) with a confidence bar showing the classification being
% made.

clearvars
close all
clc

subID = input('Please enter subject ID/Name: ');    % prompt to enter subject ID or name
%% Addpath for relevant folders - original recording folder and LSL folders
trainFolderPath = 'C:\master\bci\recording-28-4\'; 
% Define recording folder location and create the folder
trainFolder = strcat(trainFolderPath,'\OnlineSub',num2str(subID),'\');
mkdir(trainFolder);

recordingFolder = 'C:\master\bci\recording-28-4\OnlineSub3\';
% addpath('YOUR RECORDING FOLDER PATH HERE');
% addpath('YOUR LSL FOLDER PATH HERE');
addpath 'C:\ToolBoxes\eeglab2020_0'
addpath 'C:\ToolBoxes\eeglab2020_0\plugins\xdfimport1.14\xdf-EEGLAB'
eeglab;
    
%% Set params
feedbackFlag = 0;                                   % 1-with feedback, 0-no feedback
apllication_python = 1;                             % running application
feedback_python = 0;                                % feedback from python
% Fs = 300;                                         % Wearable Sensing sample rate
Fs = 125;                                           % openBCI sample rate
bufferLength = 5;                                   % how much data (in seconds) to buffer for each classification
% numVotes = 3;                                     % how many consecutive votes before classification?
% load('releventFreqs.mat');                          % load best features from extraction & selection stage
load(strcat(recordingFolder,'Mdl.mat'));            % load model weights from offline section
numConditions = 3;                                  % possible conditions - left/right/idle 
% Load cue images
images(1,:,:,:) = imread('square.jpeg', 'jpeg'); 
images(2,:,:,:) = imread('arrow_left.jpeg', 'jpeg');
images(3,:,:,:) = imread('arrow_right.jpeg', 'jpeg');
images_f_1 = imread('square.jpeg', 'jpeg'); 
images_f_2 = imread('leftt.png', 'png');
images_f_3 = imread('rightt.png', 'png');
numTrials = 5;                                      % number of trials overall
trialTime = 30;                                    % duration of each trial in seconds
cueVec = prepareTraining(numTrials,numConditions);  % prepare the cue vector



%% Lab Streaming Layer Init
disp('Loading the Lab Streaming Layer library...');
lib = lsl_loadlib();
% Initialize the command outlet marker stream
disp('Opening Output Stream...');
%info = lsl_streaminfo(lib,'MarkerStream','Markers',1,0,'cf_string','asafMIuniqueID123123');
%command_Outlet = lsl_outlet(info);
% Initialize the EEG inlet stream (from DSI2LSL/openBCI on different system)
disp('Resolving an EEG Stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end
disp('Success resolving!');
EEG_Inlet = lsl_inlet(result{1});

%% Initialize some more variables:
myPrediction = [];                                  % predictions vector
myBuffer = [];                                      % buffer matrix
iteration = 0;                                      % iteration counter
feedback_iteration = 1;
x_lim = 1000;
y_lim = 1000;
x_step = 50;
y_step = 50;
x_start = [500 500];
y_start = [0 0];
motorData = [];                                     % post-laPlacian matrix
decCount = 0;                                         % decision counter
wrongCounter = 0;
correctCounter = 0;
pause(0.2);                                         % give the system some time to buffer data
myChunk = EEG_Inlet.pull_chunk();                   % get a chunk from the EEG LSL stream to get the buffer going

%% Psychtoolbox, Stim, Screen Params Init:
% disp('Setting up Psychtoolbox parameters...');
% disp('This will open a black screen - good luck!');
% % This function will make the Psychtoolbox window semi-transparent:
% PsychDebugWindowConfiguration(0,0.5);               % Use this to debug the psychtoolbox screen
% 
% [window,white,~,~,screenYpixels,~,~,ifi] = PsychInit();
% topPriorityLevel = MaxPriority(window);
% Priority(topPriorityLevel);                         % set highest priority for screen processes
% vbl = Screen('Flip', window);                       % get the vertical beam line
% waitFrames = 1;                                     % how many frames to wait for between screen refresh
% % Define the keyboard keys that are listened for:
% KbName('UnifyKeyNames');
% escapeKey = KbName('Escape');                   % let psychtoolbox know what the escape key is
% HideCursor; 
% hides cursor on screen

%% plot feedback graph
if feedbackFlag == 1
    x2 = x_start;
    y2 = y_start;
    figure
    p = plot(x2, y2);
    numIter = numTrials;
    xlim([0 x_lim])
    ylim([0 y_lim])
    axes('pos',[.01 .9 0.5 0.1])
    image = imread('square.jpeg');
    imshow(image)
    k = 10;

    xlabel('X')
    ylabel('Y')
    title('	\leftarrow LEFT or RIGHT \rightarrow ');

    p.XDataSource = 'x2';
    p.YDataSource = 'y2';
end

%% calling gui from python
if apllication_python ==1 || feedback_python
    t = tcpip('localhost', 50007);
    fopen(t);
end

%% sending expected_list to python
if feedback_python ==1
    for i=1:size(cueVec,2)+1
        recieved_msg = 1;
        mag = '';
        while (recieved_msg)
                mag, count = fread(t, [1, t.BytesAvailable]);
                if count > 0
                    recieved_msg = 0;
                end
        end
        if i == size(cueVec,2)+1
            fwrite(t, "done");
            break;
        else
            if (cueVec(i) == 1)              %setting the right picture according Vec
                data = 'idle';
            elseif (cueVec(i) == 2)
                data = 'left';
            else
                data = 'right';
            end 
            fwrite(t, data);
        end
    end   
    
end

    
%% This is the main online script

for trial = 1:numTrials
    
%     Screen('TextSize', window, 70);             % Draw text in the bottom portion of the screen in white
%     DrawFormattedText(window, 'Ready', 'center',screenYpixels * 0.75, white);
%     Screen('Flip', window);
%     pause(1.5);                                 % "Ready" stays on screen
%     Screen('PutImage', window, squeeze(images(cueVec(trial),:,:,:))); % put image on screen
%     Screen('Flip',window);                      % now visible on screen
%     
    %% feedback picture according to cueVec(trial)
    if (cueVec(trial) == 1)              %setting the right picture according Vec
        image = images_f_1;
    elseif (cueVec(trial) == 2)
        image = images_f_2;
    else
        image = images_f_3;
    end
    %%
    
    feedback_iteration = 1;
    x2 = x_start;
    y2 = y_start; 
    
    trialStart = tic;
    while toc(trialStart) < trialTime
        iteration = iteration + 1;                  % count iterations
        
        myChunk = EEG_Inlet.pull_chunk();           % get data from the inlet
        % next 2 lines are relevant for Wearable Sensing only:
        %     myChunk = myChunk - myChunk(21,:);              % re-reference to ear channel (21)
        %     myChunk = myChunk([1:15,18,19,22:23],:);        % removes X1,X2,X3,TRG,A2
        pause(0.1)
        if ~isempty(myChunk)
            % Apply LaPlacian Filter
            myChunk(3,:) = myChunk(3,:) - ((myChunk(11,:) + myChunk(13,:) + myChunk(5,:) + myChunk(9,:))./4);
            myChunk(4,:) = myChunk(4,:) - ((myChunk(12,:) + myChunk(14,:) + myChunk(6,:) + myChunk(10,:))./4);

            myBuffer = [myBuffer myChunk];              % append new data to the current buffer
            motorData = [];
        else
            disp(strcat('Houston, we have a problem. Iteration:',num2str(iteration),' did not have any data.'));
        end
        
        % Check if buffer size exceeds the buffer length
        if (size(myBuffer,2)>(bufferLength*Fs))
            decCount = decCount + 1;            % decision counter
            block = [myBuffer];                 % move data to a "block" variable
            
            % Pre-process the data
            PreprocessBlock(block, Fs, recordingFolder);

            % Extract features from the buffered block:
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Add your feature extraction function from offline stage %%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [EEG_Features, AllDataInFeatures] = ExtractFeaturesFromBlock(recordingFolder);

            % Predict using previously learned model:
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%% Use whatever classfication method used in offline MI %%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            myPrediction(decCount) = predict(Mdl, EEG_Features);
 %% update feedback           
            if feedbackFlag
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % write a function that plots estimate on some type of graph: %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%plotEstimate(myPrediction); hold on
                feedback_iteration = feedback_iteration + 1;
                new_y = y2(feedback_iteration - 1) + y_step;
                if new_y > y_lim + y_step
                    feedback_iteration = 1;
                    x2 = x_start;
                    y2 = y_start;
                else
                    y2(feedback_iteration) = new_y;
                 
                    if myPrediction(decCount) == 2
                        new_x = x2(feedback_iteration - 1) - x_step;
                    elseif myPrediction(decCount) == 3
                        new_x = x2(feedback_iteration - 1) + x_step;    
                    else
                         new_x = x2(feedback_iteration - 1);
                    end
                    
                    if ((new_x > x_lim + x_step) || (new_x < 0 - x_step))
                        feedback_iteration = 1;
                        x2 = x_start;
                        y2 = y_start;
                    else
                        x2(feedback_iteration) = new_x;
                    end                    
                end

                imshow(image)
                refreshdata
                drawnow
            end
%% update application / feedback from python
            if apllication_python ==1 || feedback_python == 1
                bytes = '';
                recieved_msg = 1;
                if myPrediction(decCount) == 2
                        data = 'left';
                    elseif myPrediction(decCount) == 3
                        data = 'right';    
                    else
                         data = 'idle';
                end
                %this is for getting the right predictions and for the
                %check of python gui
%                 if cueVec(trial) == 2
%                         data_vec = 'left';
%                     elseif cueVec(trial) == 3
%                         data_vec = 'right';    
%                     else
%                          data_vec = 'idle';
%                 end
                
                %waiting for python to send message
                while (recieved_msg)
                    bytes, count = fread(t, [1, t.BytesAvailable]);
                    if count > 0
                        recieved_msg = 0;
                    end
                end
                %send prediction
                fwrite(t, data);
                
            end
        

    
%%
            disp(strcat('Iteration:', num2str(iteration)));
            disp(strcat('The estimated target is:', num2str(myPrediction(decCount))));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % write a function that sends the estimate to the voting machine %%
            %     the output should be between [-1 0 1] to match classes     %%
            %       this could look like a threshold crossing feedback       %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [final_vote] = myPrediction(decCount); % sendVote(myPrediction);
            
            % Update classifier - this should be done very gently! (and
            % mostly relevent to neural nets.
            if final_vote ~= cueVec(trial)
                wrongCounter = wrongCounter + 1;
                wrongClass(wrongCounter,:,:) = AllDataInFeatures;
                wrongClassLabel(wrongCounter) = cueVec(trial);
            else
                correctCounter = correctCounter + 1;
                correctClass(correctCounter,:,:) = AllDataInFeatures;
                correctLabel(correctCounter) = cueVec(trial);  
                % Send command through LSL:
                % command_Outlet.push_sample(final_vote);
            end
            
            allClass(decCount,:,:) = AllDataInFeatures;
            allClassLabel(decCount) = cueVec(trial);
            
            % clear buffer
            myBuffer = [];
        end
    end
end
if exist('wrongClass') == 1
    save(strcat(trainFolder,'\AllDataInFeaturesWrong.mat'),'wrongClass');
    save(strcat(trainFolder,'\AllDataInLabelsWrong.mat'),'wrongClassLabel');
end
if exist('correctClass') == 1
    save(strcat(trainFolder,'\AllDataInFeaturesCorrect.mat'),'correctClass');
    save(strcat(trainFolder,'\AllDataInLabelsCorrect.mat'),'correctLabel');
end
if exist('allClass') == 1
    save(strcat(trainFolder,'\AllDataInFeatures.mat'),'allClass');
save(strcat(trainFolder,'\AllDataInLabels.mat'),'allClassLabel');
end

if apllication_python ==1 
    bytes =''
    recieved_msg = 1
    while (recieved_msg)
        bytes, count = fread(t, [1, t.BytesAvailable]);
        if count > 0
            recieved_msg = 0;
        end
    end
    %send wxit msg
    fwrite(t, 'exit');
    %close the connection
    fclose(t);
end

close all;