function features = get_features(segments, feat_alg)
% this function preproces the raw data and extract features from offline recordings.
%
% Inputs:
%   - folder - a path of the folder containing the raw data (and labels) we
%   would like to feature.
%   - feat_alg - the feature algorithm to use for feature extraction.
%   choose on from the following: {'basic', 'wavelet'}
%
% Output:
%   - features - a feature matrix extracted from the raw data



% choose the desired feature extraction method based on feat_alg
if strcmp(feat_alg, 'wavelet')
    features = MI4_wavelet_ExtractFeatures(segments);
elseif strcmp(feat_alg, 'basic')
    features = MI4_ExtractFeatures(segments);
end

end
