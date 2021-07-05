# BCI4ALS- Team 1- Headset 54
## README

This is the code repository for the BCI4ALS, team 1, with reimagined headset 54 from Or Rabani.
The code is a fork of Asaf Harel(harelasa@post.bgu.ac.il) basic code for the course BCI-4-ALS which
was taken place in Ben Gurion University during 2020/2021. You are free to use, change, adapt and
% so on - but please cite properly if published. We assume you have already set up a Matlab 
enviornment with libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins istalled. Additionally,
Anaconda python 3.7 with pygame installed to run the python code.


✨  Team 1 whishes happing coding   ✨ 

## Project Structure

The repository is structured into 4 directories:

- Offline- Matlab code used for offline training.
- Online- Matlab code used for online training.
- Python- Python code that works with the online Matlab code.
- Headset54- Materials regarding the headset wiring and additional guiding materials, etc...

### Offline

1. MI1_Training.m- Code for recording new training sessions.
2. MI2_Preprocess.m- Function to preprocess raw EEG data.
3. MI3_SegmentData.m- Function that segments the preprocessed data into chunks.
4. MI4_ExtractFeatures.m- Function to extract features from the segmented chunks.
5. MI5_LearnModel.m- Function to train a classifer based on the features extracted earlier.
6. trainModelScript.m- A script that aides in running functions 2-5 in a batch. It also
 helps to use the aggregation featurs of function 4 and helps to combine both raw and features-only
 data. Features only data is created when co-training on an online session. The aggregation features
 allows to aggregate multiple recording into one training dataset.
4. prepareTraining.m- Prepare a training vector for training.

### Online

1. MI_Online_Learning.m- A script used to co-train or run the application of the online session.
   That is, co-train using feedback or run only the target application(no feedback, only predictions to application output).
2. PreprocessBlock.m- Simillar to the offline phase, this function preprocess online chunk.
3. ExtractFeaturesFromBlock.m- Simillar to the offline phase, this function extract features frin the proprocessed chunk.
4. prepareTraining.m- Prepare a training vector for co-learning.

### Python

1. feedback.py- Script that runs the co-learning feedback application.
2. UI.py- Script that runs the actual application.

## Headset54

1. IMG_1065.MOV- Or  Rabani(orabani@campus.haifa.ac.il) explains how to position the headset.
2. IMG_1060.jpg - IMG_1064.jpg- Images of how to position the headset.

### I'm lost! How to use this code?

An explanation fo the general work flow might help. First,
we open Matlab. Next, we add to the path libLSL for Matlab. Additionally,
it is recommended to add eeglab to the path or add it manually in each script. 
Next, add to the path the entire repository and its subdirectories. Now we are ready to roll:
1. Open MI1_Training.m, read the documentation and change parameters as needed. Most importantly, change 
   where to save the training vector(rootFolder). The training vector is a vector containing the labels for each trial.
2. Next, open OpenBCI and start a session, don't forget to configure the network widget correctly.
3. Open lab recorder.
4. Run MI1_Training.m and follow the console instructions.
5. Change the output dir of the lab recorder(File name/Template) to the directory created automatically in step 4. 
   (If you can't change the output dir, make sure BIDS is not checked). Name the file EEG.XDF.
6. Update the lab recorder streams and start recording. Make sure the status bar in the bottom shows an increasing
   number of data(KBs recieved). 
7. Continue to training.
8. After several recording sessions, go to trainModelScript.m. Alter the recordings array with the recording you just preformed. As this is raw recordings, set all of the entires to raw.
9. Alter the parameters as you see fit, change target classifer as well to see different test results. Make sure saveModel equals 1.
10. Now we can try to do Online classification. First, make sure the parameters in PreprocessBlock.m and 
    ExtractFeaturesFromBlock.m are the same as in the Online code.
11. Next, change trainFolderPath to where to store the online recorded features. 
12. Change recordingFolder to the last folder in the recordings array in trainModelScript.m. The offline code aggregates the     recording and always saves the result in the last folder.
13. Change eeglab folder path to the correct path.
14. Run the python code, UI or feedback.
15. Run MI_Online_Learning.m and alter parameters according to which python code is running.
16. Preform several online sessions.
17. Next, you can train on these sessions(only on the correct trials, wrong or both) in the trainModelScript.m
    but choose features instead of raw this time(in the array parameters, see the file for more info).
18. Good Luck!

***

For more info, see the documentation located in each code file.