% this script is for recording new data.
% 1. open the openbci gui and connect to the electrodes setup
% 2. load the desired settings in the gui and start an lsl stream
% 3. open labrecorder and unmark the "BIDS" window, change the file name to
%    "EEG.xdf", and set the saving path to "..\new recordings\Test#" where #
%    is the number of recording you entered in the script
% 4. make sure the electrodes are placed correctly - this is very important
% 5. run the script and follow the instructions in the command window
% 6. when the simulation is finished stop the labrecorder!.

% a quick paths check and setup (if required) for the script
script_setup()

% call the simulation function
MI1_Training();
disp('Finished simulation and EEG recording. pls Stop the LabRecorder!');





