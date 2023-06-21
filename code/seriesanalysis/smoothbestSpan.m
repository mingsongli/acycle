% bestSpan
function bestSpan = smoothbestSpan(t,y,method,alpha,beta)

% input
%   t: time
%   y: value
%   method: smooth method
%   alpha: Penalty parameters
%   beta: Penalty parameters
% output
%   bestSpan
%
% Mingsong Li, aided by GPT-4
%
% Penalty parameters (chosen experimentally, you might want to fine-tune them)
if nargin < 4; alpha = 0.01; beta = 0.01; end
if nargin < 3; method = 'lowess'; end
if nargin < 2; y = t; t = 1:length(y); end


% Initialize variables to track best span and corresponding minimum GCV
minGCV = inf;
bestSpan = NaN;


% Loop over possible span values
for span = 0.05:0.01:0.95
    % Apply smoothing
    y_smoothed = smooth(t, y, span, method);
    
    % Calculate residuals and the Mean Squared Error (MSE)
    residuals = y - y_smoothed;
    MSE = mean(residuals.^2);
    
    % Calculate the effective degrees of freedom (df) 
    df = length(t) / span; 
    
    % Calculate GCV score with penalty term
    GCV = MSE / (1 - df/length(t))^2 + alpha/span + beta*span;  % penalty terms added
    
    % Update best span and minimum GCV if current GCV is less than minimum GCV
    if GCV < minGCV
        minGCV = GCV;
        bestSpan = span;
    end
end

% Apply smoothing with the best span
% y_smoothed_best = smooth(t, y, bestSpan, method);