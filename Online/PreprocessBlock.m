function [] = PreprocessBlock(recordingFolder, block)
    %% Online Preprocessing
    % Preprocessing using EEGLAB function. Assumes Wearable Sensing DSI-24 EEG
    % The function preprocess raw data chunk as in the offline phase.
    % Make sure parameters are in sync.

    % This code is part of the BCI-4-ALS Course written by Asaf Harel
    % and edited by Team 1f
    % (harelasa@post.bgu.ac.il) in 2020. You are free to use, change, adapt and
    % so on - but please cite properly if published.

    blockPath = strcat(recordingFolder, '\', 'block.mat');
    save(blockPath, 'block');

    EEG = pop_importdata('dataformat', 'matlab', 'nbchan', 13, 'data', blockPath, 'srate', Fs, 'pnts', 0, 'xmin', 0);
    EEG.setname = 'MI_sub';

    [EEG, EEG_chans] = PreprocessCommon(recordingFolder, EEG);

    % Save the data into .mat variables on the computer
    save(strcat(recordingFolder,'\','MIData.mat'),'MIData');
    save(strcat(recordingFolder,'\','EEG_chans.mat'),'EEG_chans');
    end

