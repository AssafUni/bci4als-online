

BP_filter = designfilt('bandpassiir','StopbandFrequency1',1,...
    'PassbandFrequency1',3,...
    'PassbandFrequency2',40,...
    'StopbandFrequency2',43,...
    'StopbandAttenuation1',60,...
    'PassbandRipple',1,...
    'StopbandAttenuation2',60,...
    'SampleRate',125);
% fvtool(BP_filter)
a = (0:(125*12))./125;
b = sin(a.*(50*pi)) + sin(a.*(1*pi)) + sin(a.*(100*pi));
plot(b); hold on;
b_filt = filtfilt(BP_filter, b);
plot(b_filt)
%%
% design an IIR notch filter
N  = 6;    % Order
F0 = 50;   % Center frequency
BW = 0.5;  % Bandwidth
Fs = 125;  % Sampling Frequency

h = fdesign.notch('N,F0,BW', N, F0, BW, Fs);

notch_filter = design(h, 'butter', ...
    'SOSScaleNorm', 'Linf');
fvtool(notch_filter)

a = (0:(125*12))./125;
b = sin(a.*(50*pi)) + sin(a.*(1*pi)) + sin(a.*(100*pi));
plot(b); hold on;
b_filt = filter(notch_filter, b);
plot(b_filt)