function features = feat_from_offline(folder)

MI2_Preprocess(folder);
MI3_SegmentData(folder);
features = MI4_wavelet_ExtractFeatures(folder, 1);

end
