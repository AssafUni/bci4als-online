function [MIFeatures, MIFeaturesName] = GetFeatures(MIData, welch)
    trials = size(MIData, 1);                                           % get number of trials from main data variable
    numChans = size(MIData,2);                                    % get number of channels from main data variable

    freq.low = Configuration.PREPROCESS_LOW_PASS; % INSERT the lowest freq you want
    freq.high = Configuration.PREPROCESS_HIGH_PASS; % INSERT the highst freq you want
    freq.Jump = 0.1;                            % SET the freq resolution you desire
    f_vector = freq.low:freq.Jump:freq.high;           % freaquncies vector
    %% PLEASE ENTER RLEVENT FREAQUENCIES
    
    % frequency bands features
    bands{1} = [15.5,18.5];
    bands{2} = [8,10.5];
    bands{3} = [10,15.5];
    bands{4} = [17.5,20.5];
    bands{5} = [12.5,30];
    
    % times of frequency band features
    times{1} = (1 : 2*Configuration.SAMPLE_RATE);
    times{2} = (2*Configuration.SAMPLE_RATE : 3*Configuration.SAMPLE_RATE);
    times{3} = (3*Configuration.SAMPLE_RATE : 4*Configuration.SAMPLE_RATE);
    times{4} = (1 : 4*Configuration.SAMPLE_RATE);
    times{5} = (1 : 3*Configuration.SAMPLE_RATE);
   
    numFeatures = length(bands);                                        % how many features overall exist
    MIFeatures = NaN(trials,numChans,numFeatures);                      % init features+labels matrix
    MIFeaturesName = string(zeros(trials,numChans,numFeatures));        % save features names for plotting
    
    
    %% Extract features (powerbands in alpha, beta, delta, theta, gamma bands)
    for trial = 1:trials
        for channel = 1:numChans
            n = 1;
            
            for feature = 1:numFeatures
                % Extract features: bandpower +-1 Hz around each target frequency
                MIFeatures(trial,channel,n) = bandpower(squeeze(MIData(trial,channel,times{feature})),Configuration.SAMPLE_RATE,bands{feature});
                str = strcat("Channel ", num2str(channel), ", BandPower ",  num2str(bands{feature}(1)), "-", num2str(bands{feature}(2)));
                MIFeaturesName(trial,channel,n) = str;
                n = n+1;
            end
                        
            %% NOVEL Features
            
            % Normalize the Pwelch matrix
            pfTot = sum(welch{channel}(:,trial));% Calculate the total power for each trail
            normlizedMatrix = welch{channel}(:,trial)./pfTot; % Normalize the Pwelch matrix by dividing the matrix in its sum for each trail
            
            % rootTotalPower
            MIFeatures(trial,channel,n) = sqrt(pfTot);%Calculate the square-root of the total power
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "square-root of the total power");
            n = n+1;
            
            % spectral_moment
            MIFeatures(trial,channel,n)=sum(normlizedMatrix.*f_vector');%calculate the spectral moment
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral moment");
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
            MIFeatures(trial,channel,n)=f_vector(fun4length);%insert it to the featurs matrix
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral_edge");
            n = n+1;
            
            % spectral_entropy
            MIFeatures(trial,channel,n)=-sum(normlizedMatrix.*log2(normlizedMatrix)); %calculate the spectral entropy
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "spectral_entropy");
            n = n+1;
            
            % slope
            transposeMat=(welch{channel}(:,trial)'); %transpose matrix
            %create local function for computing the polyfit on the transposed matrix and the frequency vector
            FitFH=@(k)polyfit(log(f_vector(1,:)),log(transposeMat(k,:)),1);
            %convert the cell that gets from the local func into matrix, perform the
            %function on transposeMat, the slope is in each odd value in the matrix
            %Apply function to each element of tansposeMat
            pFitLiner = cell2mat(arrayfun(FitFH, 1:size(transposeMat,1), 'un',0));
            MIFeatures(trial,channel,n)=pFitLiner(1:2 :length(pFitLiner));
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "slope");
            n = n+1;
            
            % intercept
            %the slope is in each double value in the matrix
            MIFeatures(trial,channel,n)=pFitLiner(2:2:length(pFitLiner));
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "intercept");
            
            n= n+1;
            
            % Mean frequency
            % returns the mean frequency of a power spectral density (PSD) estimate, pxx.
            % The frequencies, f, correspond to the estimates in pxx.
            MIFeatures(trial,channel,n) = meanfreq(normlizedMatrix,f_vector);
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "mean frequency");
            n= n+1;
            
            % Occupied bandwidth
            % returns the 99% occupied bandwidth of the power spectral density (PSD) estimate, pxx.
            % The frequencies, f, correspond to the estimates in pxx.
            MIFeatures(trial,channel,n) = obw(normlizedMatrix,f_vector);
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "occupied bandwidth");
            n= n+1;
            
            % Power bandwidth
            MIFeatures(trial,channel,n) = powerbw(normlizedMatrix,Configuration.SAMPLE_RATE);
            MIFeaturesName(trial,channel,n) = strcat("Channel ", num2str(channel), ", ", "power bandwidth");
            n=n+1;
            
            
            % Shannon Entropy
            %         MIFeaturesLabel(trial,channel,n) = wentropy(squeeze(MIData(trial,channel,:)),'shannon');
            
            
        end
    end
end

