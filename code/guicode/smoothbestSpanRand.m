% bestSpan
function [bestSpan,bestAlpha, bestBeta] = smoothbestSpanRand(t,y,method,num_iterations,wtb)

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

if nargin < 5
    wtb = 0; 
end % waitbar

if nargin < 4
    % Number of random search iterations
    num_iterations = 100; 
end
if nargin < 3; method = 'lowess'; end

% Initialize variables to track best span and corresponding minimum GCV
minGCV = inf;
bestSpan = NaN;

% Penalty parameters bounds (chosen experimentally)
alpha_lower = 0.001; 
alpha_upper = 0.1;
beta_lower = 0.001;
beta_upper = 0.1;

if  wtb==1 
    % Create the waitbar
    h = waitbar(0,'Please wait...','Name','Estimate the best span',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0)
end

for iter = 1:num_iterations
    if wtb==1
        % Check for Cancel button press
        if getappdata(h,'canceling')
            break
        end
        waitbar(iter/num_iterations,h,sprintf('%3.00f%% Complete...',iter/num_iterations*100))
    end
    % Randomly select alpha and beta
    alpha = alpha_lower + (alpha_upper - alpha_lower) * rand;
    beta = beta_lower + (beta_upper - beta_lower) * rand;
    
    % Loop over possible span values
    for span = 0.01:0.01:1
        % Apply LOESS smoothing
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
            bestAlpha = alpha;
            bestBeta = beta;
        end
    end
end

if wtb==1
    % Close the waitbar
    delete(h)
end