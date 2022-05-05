function X = preprocessMiniBatch(data, label)

% Concatenate.
X = cat(4, data{:});

% convert into a dlarray
X = dlarray(X);

end