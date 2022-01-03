%% MI Online script
% The script is used to either co-train using feedback or preform
% actual classification for application use. The script communications
% with a UI written in python using tcp/ip. The code assumes a model
% was trained first and saved as Mdl.mat using the MI5_LearnModel
% function in the offline phase.

% This code creates an online EEG buffer which utilizes the model trained
% offline, and corresponding conditions, to classify between the possible labels.
% Assuming: 
% 1. EEG is recorded using Wearable Sensing / openBCI and streamed through LSL.
% 2. MI classifier has been trained
% 3. A different machine/client is reading this predictions.
% 4. Target labels are [1 2 3] (left idle right)

% This code is part of the BCI-4-ALS Course written by Asaf Harel
% and edited by Team 1
% (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
% so on - but please cite properly if published.

clearvars
close all
clc

% Change parameters
testNum = input('Please enter test number: ');    % prompt to enter test number
% Where to store the online recording, to use later for training a new
% model.
trainFolderPath = 'NewHeadsetRecordingsOmri\'; 
trainFolder = strcat(trainFolderPath, '\OnlineTest', num2str(testNum), '\');
mkdir(trainFolder);

% The folder where the offline training took place. This is the last
% aggregated folder.
recordingFolder = 'NewHeadsetRecordingsOmri\Test4\';
eeglab;
    
%% Set params
feedbackFlag = 0;                                   % 1-with feedback matlab gui, 0-no feedback matlab gui
apllication_python = 0;                             % predictions sent to python application gui
feedback_python = 0;                                % predictions sent to python feedback gui
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
numTrials = 1;                                      % number of trials overall
trialTime = 60;                                    % duration of each trial in seconds
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
    disp('Connecting to python script!');
    t = tcpip('localhost', 50007);
    fopen(t);
    disp('Connected!!');
end

%% sending expected_list to python
if feedback_python ==1
    disp('Setting up feedback for python!!');
    for i=1:size(cueVec,2)+1
        recieved_msg = 1;
        mag = '';
        while (recieved_msg)
                [mag, count] = fread(t, [1, t.BytesAvailable]);
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
    disp('Done!!');
end

    
%% This is the main online script

correctPreds = 0;
totalPreds = 0;

disp('Starting feedback training!!');
end_train = 0;
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
        pause(0.2)
        if ~isempty(myChunk)
            %% TODO: check how to insert blinking to online 
            % remove blinks
            % myChunk = pop_autobsseog( myChunk, 128, 128, 'sobi', {'eigratio', 1000000}, 'eog_fd', {'range',[1  5]});
            % myChunk = pop_autobssemg( myChunk, 5.12, 5.12, 'bsscca', {'eigratio', 1000000}, 'emg_psd', {'ratio', [10],'fs', 125,'femg', 15,'estimator', spectrum.welch({'Hamming'}, 62),'range', [0  8]});
            % Apply LaPlacian Filter
            myChunk(1,:) = myChunk(1,:) - ((myChunk(3,:) + myChunk(5,:) + myChunk(7,:) + myChunk(9,:))./4);    % LaPlacian (Cz, F3, P3, T3)
            myChunk(2,:) = myChunk(2,:) - ((myChunk(4,:) + myChunk(6,:) + myChunk(8,:) + myChunk(10,:))./4);    % LaPlacian (Cz, F4, P4, T4)

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
            [EEG_Features, AllDataInFeatures] = ExtractFeaturesFromBlock(recordingFolder);

            % Predict using previously learned model:
            myPrediction(decCount) = predict(Mdl, EEG_Features);
            
            if myPrediction(decCount) == cueVec(trial)
                correctPreds = correctPreds + 1;
            end
            
            totalPreds = totalPreds + 1;
  
            %% update feedback using matlab gui         
            if feedbackFlag
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
            %% update application / feedback using python gui
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
                    [bytes, count] = fread(t, [1, t.BytesAvailable]);
                    if count > 0
                        disp('Got it!!');
                        recieved_msg = 0;
                        disp(bytes)
                        if (count == 3 && bytes(1) == 'e' && bytes(2) == 'n' && bytes(3) == 'd') || (count == 7 && bytes(1) == 'n' && bytes(2) == 'e' && bytes(3) == 'x' && bytes(4) == 't' && bytes(5) == 'e' && bytes(6) == 'n' && bytes(7) == 'd')
                            disp('Connection closed, done!!');
                            end_train = 1;
                        end                        
                    end
                end
                
                if end_train == 1
                    break
                end
                
                %send prediction
                fwrite(t, data);
                
            end
        
            disp(strcat('Iteration:', num2str(iteration)));
            disp(strcat('The estimated target is:', num2str(myPrediction(decCount))));
            
            % Either use a voting machine here, or don't and use a voting
            % machine in the python gui.
            [final_vote] = myPrediction(decCount); % sendVote(myPrediction);
            
            % Save features and results to use later
            if final_vote ~= cueVec(trial)
                wrongCounter = wrongCounter + 1;
                wrongClass(wrongCounter,:,:) = AllDataInFeatures;
                wrongClassLabel(wrongCounter) = cueVec(trial);
                wrongClassSelectedFeatures(wrongCounter,:,:) = EEG_Features;                
            else
                correctCounter = correctCounter + 1;
                correctClass(correctCounter,:,:) = AllDataInFeatures;
                correctLabel(correctCounter) = cueVec(trial);  
                correctClassSelectedFeatures(correctCounter,:,:) = EEG_Features;  
            end
            
            allClass(decCount,:,:) = AllDataInFeatures;
            allClassLabel(decCount) = cueVec(trial);
            allClassSelectedFeatures(decCount,:,:) = EEG_Features; 
            
            % clear buffer
            myBuffer = [];    
            
            if end_train == 1
                break
            end             
        end
        
        if end_train == 1
            break
        end         
    end
    
    if end_train == 1
        break
    end     
end

% Save recording to use later in traning the model
if exist('wrongClass') == 1
    save(strcat(trainFolder,'\AllDataInFeaturesWrong.mat'),'wrongClass');
    save(strcat(trainFolder,'\AllDataInLabelsWrong.mat'),'wrongClassLabel');
    save(strcat(trainFolder,'\WrongClassSelectedFeatures.mat'),'wrongClassSelectedFeatures');
end
if exist('correctClass') == 1
    save(strcat(trainFolder,'\AllDataInFeaturesCorrect.mat'),'correctClass');
    save(strcat(trainFolder,'\AllDataInLabelsCorrect.mat'),'correctLabel');
    save(strcat(trainFolder,'\CorrectClassSelectedFeatures.mat'),'correctClassSelectedFeatures')
end
if exist('allClass') == 1
    save(strcat(trainFolder,'\AllClassDataInFeatures.mat'),'allClass');
    save(strcat(trainFolder,'\AllClassDataInLabels.mat'),'allClassLabel');
    save(strcat(trainFolder,'\AllClassSelectedFeatures.mat'),'allClassSelectedFeatures')
end

if apllication_python ==1 
    bytes = '';
    recieved_msg = 1;
    while (recieved_msg)
        [bytes, count] = fread(t, [1, t.BytesAvailable]);
        if count > 0
            recieved_msg = 0;
        end
    end
    %send wxit msg
    fwrite(t, 'exit');
    %close the connection
    fclose(t);
end

disp((correctPreds / totalPreds) * 100.0);
disp(correctPreds);
disp(totalPreds);

close all;
