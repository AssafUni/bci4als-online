# BCI4ALS- Team 1- Headset 72

- This is the code repository for the BCI4ALS - TAU, team omri, with reimagined headset 72 from Or Rabani.
- You are free to use, change, adapt and so on - but please cite properly if published.
- We assume you have already set up a Matlab environment with libLSL, OpenBCI, EEGLab with ERPLAB & loadXDF plugins installed.

## Project Structure

The repository is structured into 7 directories:
1. scripts - each script has its own perpuse explained in the top of the script.
2. functions - all the functions that we use in the scripts.
3. recordings - recordings files, each 'subject' has its own folder.
4. DL pipelines - Deep learning NN architectures.
5. feature extraction methods - feature extraction functions.
6. figures and models - all our saved models and their figures are placed here.
7. Documents - docs related to the project.

For more info, see the documentation located in each code file.

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
