%% to do list:
% - add the eegnet_bilstm model to the model selection option
% - create a VAE with the EEGNet structure (need to create custom layers
% for the decoder... this will take alot of work)
% - create the script for preprocessing hyperparameters optimization
% - run the bilstm model and compare to the lstm 
% - add a wait bar when creating alot of 'recording' class members to keep
% track on the progress
% - in validate_model_c script, load the data into train,val,test,new_data
% objects, so when visualizing them we can know who belogns to each set.
% - validate the WGN we add as an augmentation