function loss = elboLoss(Y,T,mu,logSigmaSq)

% Reconstruction loss.
reconstructionLoss = mse(Y,T);

% KL divergence.
KL = -0.5 * sum(1 + logSigmaSq - mu.^2 - exp(logSigmaSq),1);
KL = mean(KL);

% Combined loss.
loss = reconstructionLoss + KL;

end