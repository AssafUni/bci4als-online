Configuration = Configuration();
answer = input('do you wish to record new data? (y/n):');
if strcmp(answer,'y')
    [recordingFolder] = MI1_Training();
    disp('Finished stimulation and EEG recording. Stop the LabRecorder and press any key to continue...');
    pause;
else 
    foldname = input('pls enter subject number:');
    recordingFolder = strcat('eeg recordings\sub',int2str(foldname));
end