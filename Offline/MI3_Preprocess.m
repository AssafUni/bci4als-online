function postprocces_segments = MI3_Preprocess(segments, cont_or_disc)
% this function is aplying the preprocess phase in the pipeline. it filters
% the data using BP and notch filters.
%
% Inputs:
%   - segments - a 3D matrix containing the segmented raw data, its
%   dimentions are [trials, channels, time (data samples)].
%
% Output:
%   - postprocces_segments - a 3D matrix of the segments after being
%   preproccesed, the dimentions are the same as in 'segments'

% add in the future
% 1. Remove redundant channels
% 2. redifine bad channels as an interpulation of it's neighbor channels 
% 3. see comments in the end of PreprocessCommon

postprocces_segments = PreprocessCommon(segments, cont_or_disc);
                
end