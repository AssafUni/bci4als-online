function [EEG_Features] = ExtractPowerBands(EEG,features,Fs)
% ExtractPowerBands Extracts the amplitude of the different powerbands
% between the frequencies specified in powerbandFreqs.

chans = size(EEG,1);                                    % how many channels in the data
numFeatures = size(features,1);                         % how many features
for chan = 1:chans
    for feat = 1:numFeatures
        EEG_Features(chan,feat) = bandpower(EEG(chan,:)',Fs,features(feat,:));
    end
end
EEG_Features = reshape(EEG_Features,[1,chans*features]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Add further features here %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

