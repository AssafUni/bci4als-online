function [EEG_Features, AllDataInFeatures] = ExtractFeaturesFromBlock(recordingFolder)
load(strcat(recordingFolder,'EEG_chans.mat'));
load(strcat(recordingFolder,'MIData.mat'));
load(strcat(recordingFolder,'SelectedIdx.mat'));

numTargets = 3;
Fs = 120; 
trials = size(MIData,1);
[R, C] = size(EEG_chans);
chanLocs = reshape(EEG_chans',[1, R*C]);
numChans = size(MIData,2);

motorDataChan = {};
welch = {};
idxTarget = {};
lg={};

freq.low = 0.5;
freq.high = 60;
freq.Jump = 0.1; 
f = freq.low:freq.Jump:freq.high;
trailT = length(MIData);
window = [];
noverlap = [];

for i = 1:numChans
    motorDataChan{i} = squeeze(MIData(:,i,:))';                     % convert the data to a 2D matrix fillers by channel
    motorDataChan{i} = reshape(motorDataChan{i}, size(motorDataChan{i}, 2), []);
    welch{i} = pwelch(motorDataChan{i},window, noverlap, f, Fs);    % calculate the pwelch for each electrode
    welch{i} = reshape(welch{i}, size(welch{i}, 2), []);
end    

%% PLEASE ENTER RLEVENT FREAQUENCIES

% frequency bands features
bands{1} = [15.5,18.5];
bands{2} = [8,10.5];
bands{3} = [10,15.5];
bands{4} = [17.5,20.5];
bands{5} = [12.5,30];

% times of frequency band features
times{1} = (1*Fs : 3*Fs);
times{2} = (3*Fs : 4.5*Fs);
times{3} = (4.25*Fs : size(MIData,3));
times{4} = (2*Fs : 2.75*Fs);
times{5} = (2.5*Fs : 4*Fs);

numFeatures = length(bands);                                             % how many features overall exist
MIFeaturesLabel = NaN(trials,numChans,numFeatures);                      % init features+labels matrix
MIFeaturesLabelName = string(zeros(trials,numChans,numFeatures));
%save(strcat(recordingFolder,'\','releventFreq.mat'),'releventFreq');    % save the bastards

%% Extract features (powerbands in alpha, beta, delta, theta, gamma bands)
for trial = 1:trials
    for channel = 1:numChans
        n = 1;
        
        for feature = 1:numFeatures
            % Extract features: bandpower +-1 Hz around each target frequency
            MIFeaturesLabel(trial,channel,n) = bandpower(squeeze(MIData(trial,channel,times{feature})),Fs,bands{feature});
            str = strcat("Channel ", num2str(channel), ", BandPower ",  num2str(bands{feature}(1)), "-", num2str(bands{feature}(2)));
            MIFeaturesLabelName(trial,channel,n) = str;
            n = n+1;
        end
        
        
        %% NOVEL Features
        
        % Normalize the Pwelch matrix
        pfTot = sum(welch{channel}(:,trial));% Calculate the total power for each trail
        normlizedMatrix = welch{channel}(:,trial)./pfTot; % Normalize the Pwelch matrix by dividing the matrix in its sum for each trail
        
        % rootTotalPower
        MIFeaturesLabel(trial,channel,n) = sqrt(pfTot);%Calculate the square-root of the total power
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "square-root of the total power");
        n = n+1;
        
        % spectral_moment
        MIFeaturesLabel(trial,channel,n)=sum(normlizedMatrix.*f');%calculate the spectral moment
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral moment");
        n = n+1;
        
        % spectral_edge
        probfunc=cumsum(normlizedMatrix); %create matrix of cumulative sum
        %the frequency that 90% of the power resides below it and 10% of the power resides above it
        valuesBelow=@(z)find(probfunc(:,z)<=0.9); %creating local function
        %Apply function to each element of normlizedMatrix
        fun4Values = arrayfun(valuesBelow, 1:size(normlizedMatrix',1), 'un',0);
        lengthfunc=@(y)length(fun4Values{y})+1;%creating local function for length
        %Apply function to each element of normlizedMatrix
        fun4length = cell2mat(arrayfun(lengthfunc, 1:size(normlizedMatrix',1), 'un',0));
        MIFeaturesLabel(trial,channel,n)=f(fun4length);%insert it to the featurs matrix
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral_edge");
        n = n+1;
        
        % spectral_entropy
        MIFeaturesLabel(trial,channel,n)=-sum(normlizedMatrix.*log2(normlizedMatrix)); %calculate the spectral entropy
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral_entropy");
        n = n+1;
        
        % slope
        transposeMat=(welch{channel}(:,trial)'); %transpose matrix
        %create local function for computing the polyfit on the transposed matrix and the frequency vector
        FitFH=@(k)polyfit(log(f(1,:)),log(transposeMat(k,:)),1);
        %convert the cell that gets from the local func into matrix, perform the
        %function on transposeMat, the slope is in each odd value in the matrix
        %Apply function to each element of tansposeMat
        pFitLiner = cell2mat(arrayfun(FitFH, 1:size(transposeMat,1), 'un',0));
        MIFeaturesLabel(trial,channel,n)=pFitLiner(1:2 :length(pFitLiner));
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "slope");
        n = n+1;
        
        % intercept
        %the slope is in each double value in the matrix
        MIFeaturesLabel(trial,channel,n)=pFitLiner(2:2:length(pFitLiner));
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "intercept");
        
        n= n+1;
        
        % Mean frequency
        % returns the mean frequency of a power spectral density (PSD) estimate, pxx.
        % The frequencies, f, correspond to the estimates in pxx.
        MIFeaturesLabel(trial,channel,n) = meanfreq(normlizedMatrix,f);
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "mean frequency");
        n= n+1;
        
        % Occupied bandwidth
        % returns the 99% occupied bandwidth of the power spectral density (PSD) estimate, pxx.
        % The frequencies, f, correspond to the estimates in pxx.
        MIFeaturesLabel(trial,channel,n) = obw(normlizedMatrix,f);
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "occupied bandwidth");
        n= n+1;
        
        % Power bandwidth
        MIFeaturesLabel(trial,channel,n) = powerbw(normlizedMatrix,Fs);
        MIFeaturesLabelName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "power bandwidth");
        n=n+1;
        
        
        % Shannon Entropy
        %         MIFeaturesLabel(trial,channel,n) = wentropy(squeeze(MIData(trial,channel,:)),'shannon');
        
        
    end
end

MIFeaturesLabel = zscore(MIFeaturesLabel);
AllDataInFeatures = reshape(MIFeaturesLabel, trials, []);
EEG_Features = AllDataInFeatures(:, SelectedIdx);
end