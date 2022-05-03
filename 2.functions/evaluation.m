function [class_pred, thresh, CM] = evaluation(model, data_store, options)
% this function classifies a data store according to the given model and a
% threshold for class 1 (Idle) or a criterion threshold or by its default
% classification function (max)
%
% Input:
%   - model: classification model
%   - data_store: a data store consistent with the model 
%   - thres_C1 (optional): classification threshold for class 1
%   - CM_title (optional): a header for the CM plot ('test', 'validation'
%   etc.)
%   - criterion (optional): a criterion for the perfcurve function
%   - criterion_thresh (optional): must be suplied with 'criterion', the
%   criterion threshold for classification working point.
%
% Output:
%   - CM: a confusion matrix
%   - thresh: the classification threshold for class 1 if 'criterion' and
%   'criterion_thresh' is given.

arguments
    model
    data_store
    options.thres_C1 = []
    options.CM_title = ''
    options.criterion = []
    options.criterion_thresh = []
    options.print = false;
end

if isempty(data_store)
    class_pred = [];
    thresh = [];
    CM = [];
    return
end

% extract true labels
data_set = readall(data_store);
class_true = cellfun(@double ,data_set(:,2), 'UniformOutput', true);

if ~isempty(options.criterion) && ~isempty(options.criterion_thresh) % predict with criterion
    % predict using the model
    scores = predict(model, data_store);

    % get the criterion you desire 
    [crit_values,~,thresholds] = perfcurve(class_true, scores(:,1), 1, 'XCrit', options.criterion);

    % set a working point for class 1 (Idle)
    [~,I] = min(abs(crit_values - options.criterion_thresh));
    thresh = thresholds(I); % the working point

    % label the samples according to the criterion threshold
    class_pred = zeros(size(class_true)); % set an empty labels vector
    class_pred(scores(:,2) >= scores(:,3)) = 2;
    class_pred(scores(:,2) < scores(:,3)) = 3;
    class_pred(scores(:,1) >= thresh) = 1;

    title = [' confusion matrix - ' options.criterion ' = '  num2str(options.criterion_thresh)];
elseif ~isempty(options.thres_C1) % predict with threshold for class 1
    % predict using the model
    scores = predict(model, data_store);

    % label the samples according to the threshold
    class_pred = zeros(size(class_true)); % set an empty labels vector
    class_pred(scores(:,2) >= scores(:,3)) = 2;
    class_pred(scores(:,2) < scores(:,3)) = 3;
    class_pred(scores(:,1) >= options.thres_C1) = 1;

    title = [' confusion matrix - class 1 threshold = '  num2str(options.thres_C1)];
    thresh = [];
else % deafult prediction
    scores = predict(model, data_store);
    [~, class_pred] = max(scores, [],2);
    title = ' confusion matrix';
    thresh = [];
end

CM = confusionmat(class_true,class_pred);
accuracy = sum(class_true == class_pred)/length(class_true);
% plot the confusion matrix
if options.print
    figure('Name', [options.CM_title title]);
    confusionchart(CM,["Idle";"Left"; "Right"]);
    disp([options.CM_title ' accuracy is: ' num2str(accuracy)]);
end

end