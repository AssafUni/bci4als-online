# BCI4ALS- Team 1- Headset 54
## README

to do list:
- change online feature extraction to behave like offline feature extraction but with the correct/wrong/both option

- need to inform in the saved files which model was used to label the online session recording.

- fix commonpreprocces - change the filters and make them work properly
 

This is the code repository for the BCI4ALS, team 1, with reimagined headset 54 from Or Rabani.
The code is a fork of Asaf Harel(harelasa@post.bgu.ac.il) basic code for the course BCI-4-ALS which
was taken place in Ben Gurion University during 2020/2021. You are free to use, change, adapt and
so on - but please cite properly if published. We assume you have already set up a Matlab
environment with libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins installed. Additionally,
Anaconda python 3.7 with pygame installed to run the python code.


✨  Team 1 wishes happy coding   ✨

- Assaf Peleg(assafpel@post.bgu.ac.il)
- Noa Bayer(noabay@post.bgu.ac.il)
- Adi Krasin(adikra@post.bgu.ac.il)
- Dor Zazon(zazond@post.bgu.ac.il)

## Project Structure

The repository is structured into 7 directories:

- Offline- Matlab code used for offline training.
- Online- Matlab code used for online training.
- Python- Python code that works with the online Matlab code.
- Headset54- Materials regarding the headset wiring and additional guiding materials, etc...
- NewHeadsetRecordingsOmri- Recording from the new headset on Omri(Our mentor), we managed to reach with all three recordings 66%-70% accurecy with onlyPowerBands=0 and 57%-70% with onlyPowerBands=1. These recordings were created
in the home of Omri where there are many inteferences and noise. The classifier is the SVM RBF.
- NewHeadsetRecordingsAssaf- Recordings from the new headset on Assaf, we managed to reach with all the recordings 60%-86% in my house where there are many inteferences and noise with onlyPowerBands=0 and 30%-60% with onlyPowerBands=1. The classifier is the SVM RBF.
- OldHeadsetRecordings- Recordings from the old headset. We managed to get with the old headset at Noa's house where the training took place at a very quiet location with not many inteferences most of the time 60%-96% combining both offline and online recording and with onlyPowerBands=0. Please
note that the code now don't support these recordings and the channel mapping has changed, i.e. the laplacian is wrong and we omit channels that existed here. To reach best results with old recording, we recommend to go back in history of the repository and look for old recordings, the preprocess files the matchs them, the
channels that were removed and the recordings that were used. The classifier is the SVM RBF.
- Documents- Important documents including but not limited to- A general guide and where to go next, UX and video, Product specification document and more...

### Offline

This part of the code is responsible for recording raw EEG data from the headset, preprocess it, segment it, extract features and
train a classifier.

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

This part of the code is responsible for loading the classifier that was trained in the offline section, record raw EEG data, preprocess it, extract features and
make a prediction using the classifier. Additionally, it saves the features to use for training later(co-learning) and sends the predictions to the python interface using
TCP/IP. The communication part of the code is really simple and sends chunks of data to the python code, until it recives the string "next", in which it sends the next portion of data.

1. MI_Online_Learning.m- A script used to co-train or run the application of the online session.
   That is, co-train using feedback or run only the target application(no feedback, only predictions to application output).
2. PreprocessBlock.m- Simillar to the offline phase, this function preprocess online chunk.
3. ExtractFeaturesFromBlock.m- Simillar to the offline phase, this function extract features from the preprocessed chunk.
4. prepareTraining.m- Prepare a training vector for co-learning.

### Python

The python code is seperated into two files, both communicate with the matlab code using TCP/IP. A feedback file which is used for co-learning, and ui file which is used
for the actual application used by the mentor.

1. feedback.py- Script that runs the co-learning feedback application. The Matlab code creates the labels for the co-learning session, sends them to the python code which will present to the user what to imagine and depending on the prediction made in the matlab code, will move a red rectangle to the appropriate side.
2. UI.py- Script that runs the actual application. As in the feedback script, the Matlab code will sends the prediction to the python code. However, as this is the real application no labels exist. Instead, three colums will be presented to the user and depending on the prediction made in the matlab code, the appropriate column will be filled. When a threshold will be passed(voting), the action regarding that column will execute. The right column is used to signal for help(shows a help sign and sounds an alarm) while the left column is used to open another interface to allow to pick yes or no response.

## Headset54

1. IMG_1065.MOV- Or Rabani(orabani@campus.haifa.ac.il) explains how to position the headset.
2. IMG_1060.jpg - IMG_1064.jpg- Images of how to position the headset.

## Recordings

The general structure of the recordings directory are as follows:

1. In each recording directory are many Test directories. Each one corresponds to a testing session. Each session includes 5 trial per target- i.e. 15 trials in total.
2. The EEG.xdf is the recording captured by the lab recorder from the eeg stream and the marker stream.
3. The AllDataInFeatures.mat is the features generated by the MI4_ExtractFeatures.m and run by trainModelScript.m, i.e. aggregating all previous Test folder data in to one training set features. The companion file
to this is the AllDataInLabels.mat which is the labels for each trial.
4. The Mdl.mat is the model created by MI5_LearnModel.m and run by trainModelScript.m, i.e. training an svm rbf model from the aggregated training set features of all previous and the current folder.
5. The EEG_chans.mat is a file containing the channels that were included in the preprocess step, created by MI2_Preprocess.m and run by trainModelScript.m.
6. The SelectedIdx.mat is the selected features for the training set that were chosen from AllDataInFeatures.mat, this is created also by MI4_ExtractFeatures.m. You will need this in the online training to select the correct features. We don't
have to worry about this in the online phase most of the time as the Mdl.mat and SelectedIdx.mat reside in the same folder and therefore when setting the recording folder in MI_Online_Learning.m to the appropiate location it will pick correctly both files.
7. The trainingVec.mat is the vector containing the labels during the training phase. It is created by MI1_Training.m.
8. The MIData.mat is the segmented raw data file that is created after the preprocess step. It is created by MI3_SegmentData.m.


### I'm lost! How to use this code?

An explanation for the general work flow might help. First,
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
6. Update the lab recorder streams, select both of them(eeg and marker), and start recording. Make sure the status bar in the bottom shows an increasing
   number of data(KBs recieved).
7. Continue to training.
8. After several recording sessions, go to trainModelScript.m. Alter the recordings array with the recording you just preformed. As this is raw recordings, set all of the entries to raw.
9. Alter the parameters as you see fit, change target classifer as well to see different test results. Make sure saveModel equals 1.
10. Now we can try to do Online classification. First, make sure the parameters in PreprocessBlock.m and
    ExtractFeaturesFromBlock.m are the same as in the Online code.
11. Next, change trainFolderPath to where to store the online recorded features.
12. Change recordingFolder to the last folder in the recordings array in trainModelScript.m. The offline code aggregates the recording and always saves the result in the last folder.
13. Change eeglab folder path to the correct path.
14. Run the python code, UI or feedback.
15. Run MI_Online_Learning.m and alter parameters according to which python code is running.
16. Preform several online sessions.
17. Next, you can train on these sessions(only on the correct trials, wrong or both) in the trainModelScript.m
    but choose features instead of raw this time(in the array parameters, see the file for more info).
18. To run the python code, first choose feedback_python or application_python in the MI_Online_Learning.m.
    Next, run feedback.py or UI.py. Finally, run MI_Online_Learning.m.
18. Good Luck!

***

For more info, see the documentation located in each code file and the docs file in the documents folder.

### Trobuleshooting

#### Our offline classifier preforms very poorly
1. A look on the OpenBCI waves output can help us determine the amount of noise we have. The more
   noise, the less able will be our classifier.
2. Click several times on the notch filter to bring it to 50hz, even if it is currently on 50hz.
   A look on the FFT around 50hz should reveal a negative peak. If you still see a peak, try replacing the bateries or
   move to another room. Try eliminiate all sources of noise such as electricity. Try to reposition the headset.
   Make sure you put the ear pieces on your ear lobes.
3. Click several times on the band pass and set it on 5-50hz. Even if it is already on 5-50hz.
4. If you bring the notch filter to none, a noisy channel should be higher than 30 uVrms.
5. If all channels are lower than 20 uVrms and have simillar uVrms it should be ok.
6. Another important thing to check is that the FFT has a moderate slope down towards the hightest frequencites.
7. Thanks to Or Rabani(orabani@campus.haifa.ac.il) for the help on these points.

* Note: To remove the 25hz peak, you'll need to avoid using a charger and be far away from electronic devices.

### The dongle is pluged in but cannot connect to the headset.
1. Try replacing the batteries.

### PsychToolbox is stuck and not moving forward with the training
1. First, it might take some time in slow computers.
2. Second, put the transparency on a lower value than 1(there is a line in the code already for this) and watch the log to see where it is stuck.

### Nothing works :(
1. Disconnect the dongle.
2. Close all programs.
3. Wait a bit!
4. Try again. :)

Thanks to all the course staff: Oren Shirki(shrikio@bgu.ac.il), Lahav foox(fooxl@post.bgu.ac.il), Asaf Harel(harelasa@post.bgu.ac.il), Or Rabani(orabani@campus.haifa.ac.il) and Daniel Polyakov(polydani@post.bgu.ac.il).
