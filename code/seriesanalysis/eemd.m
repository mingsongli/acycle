function [modes] = eemd(y, goal, ens, nos)
% EEMD function: 1-D ensemble EMD
% Decomposes a signal into intrinsic mode functions
% INPUT:
%    y: input signal
%   goal: number of intrinsic modes to decompose
%   ens: number of ensemble members
%   nos: amplitude of added noise
% OUTPUT
%   modes: the decomposed components (IMFs) of the original signal.

%% Note 
% Choosing the best values for goal, ens, and nos in Ensemble Empirical Mode 
% Decomposition (EEMD) depends on the characteristics of your signal and 
% the specific requirements of your analysis. 
%
% Here are some general guidelines:
%   goal (Number of Intrinsic Mode Functions - IMFs):
%       This should be based on the complexity of your signal. 
%       If the signal has many frequency components, you might need more IMFs.
%       A starting point is to set goal slightly higher than the number of 
%       expected significant frequency components in your signal.
%   ens (Number of Ensemble Members):
%       A larger number of ensembles generally provides a more stable and 
%       accurate decomposition, but it also increases computational time.
%       Typical values range from 10 to 100. Start with a moderate value 
%       like 50 and adjust based on the stability of the results and computational constraints.
%   nos (Amplitude of Added Noise):
%       The noise level should be small enough to avoid distorting the signal 
%       significantly, but large enough to aid in the decomposition process.
%       A common approach is to set the noise level to a small percentage 
%       of the standard deviation of the signal, such as 10% to 20%.
%
% Calls for:
%   emd:
%
% written by Neil Po-Nan Li @ Inst. of Physics, Academia Sinica, Taiwan
% v1   2012/9/26
% v1.1 2014/3/17
%
% Mingsong Li, Peking University
%   added comments

% standard deviation of the input signal y is calculated
stdy = std(y);

if stdy < 0.01
    stdy = 1; % Prevent division by zero or very small standard deviation
end
y = y ./ stdy; % Normalize the signal

wbr = 1;  % plot waitbar or not. 1 = yes; 0 == no

% Initialize
sz = length(y); % Length of the signal
modes = zeros(goal+1, sz); % Preallocate array for modes


% for acycle
if wbr == 1
%     hwaitbar = waitbar(0,'EEMD: Slow Process. [CTRL + C to quit]',...    
%            'WindowStyle','modal');
    hwaitbar = waitbar(0,'1','Name','EEMD [CTRL + C to quit]',...    
           'WindowStyle','modal',...
           'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    hwaitbar_find = findobj(hwaitbar,'Type','Patch');
    set(hwaitbar_find,'EdgeColor',[0 0.9 0],'FaceColor',[0 0.9 0]) % changes the color to blue
    setappdata(hwaitbar,'canceling',0)
    waitbarstep = 0;
end
% Ensemble loop
%parfor k = 1:ens % Parallel loop for ensemble members
for k = 1:ens % Parallel loop for ensemble members
    disp(['Running ensemble # ', num2str(k),' / ',num2str(ens)]); % Display current ensemble number
    wn = randn(1, sz) .* nos; % Generate white noise
    y1 = y + wn; % Add noise to the signal
    y2 = y - wn; % Subtract noise from the signal
    modes = modes + emdNL(y1, goal); % Perform EMD on the noisy signal and accumulate the modes
    if nos > 0 && ens > 1
        modes = modes + emdNL(y2, goal);  % Perform EMD on the negative noisy signal and accumulate the modes
    end
    
    % waitbar
    if wbr == 1
        waitbarstep = waitbarstep+1; 
        pause(0.0001); %
        waitbar(waitbarstep / ens, hwaitbar, sprintf('Running ensemble # %d / %d',k,ens))
        if getappdata(hwaitbar,'canceling')
            break
        end
    end
end
% close waitbar
if ishandle(hwaitbar)
    close(hwaitbar);
end
try
    delete(hwaitbar)
catch
end
% Post-processing
modes = modes .* stdy ./ (ens); % Scale back the modes and average over ensemble members
if nos > 0 && ens > 1
    modes = modes ./ 2; % Further averaging if noise is used and more than one ensemble member
end

end
