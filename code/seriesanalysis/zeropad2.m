function [dataX] = zeropad2(data,win,padding,ensureHalfWindowCoverage)
% Zero-pad the input data at both ends
%
% Inputs:
%   data    – N×2 matrix of uniformly sampled data (two columns)
%   win     – Window size (must be larger than the data’s sampling interval)
%   padding – Padding type:
%               1 = zero padding
%               2 = mirror padding
%               3 = mean-value padding
%               4 = random-value padding
%   ensureHalfWindowCoverage - optional logical. When true, use CEIL rather
%               than ROUND so the synthetic coordinate support reaches at
%               least WIN/2 beyond both original endpoints. This is used
%               by exact physical-depth eCOCO windows (default false).
%
% Based on evofft19.m
% April 2019 update by Nicolas Thibault & Giovanni Rizzi: added padding options
% Modified by Mingsong Li, April 2019 (Penn State)

if nargin < 3; padding = 1; end
if nargin < 2; win = 0.35 * abs(data(end,1) - data(1,1)); end
if nargin < 4 || isempty(ensureHalfWindowCoverage)
    ensureHalfWindowCoverage = false;
end
validateattributes(ensureHalfWindowCoverage,{'logical','numeric'}, ...
    {'scalar'},mfilename,'ensureHalfWindowCoverage',4);
% ensure data is sorted in the ascending order
data = sortrows(data);

x = data(:,1);
y = data(:,2);

% remove mean
% Use one consistently centred value system for both the retained record
% and every padding type.  The older implementation centred DATA but built
% mirror/mean/random edges from the uncentred Y, creating artificial jumps.
y = y-mean(y);
data(:,2) = y;
% get mean sampling rate
dt = mean(diff(x));
% number of zero-padding data
if logical(ensureHalfWindowCoverage)
    n = ceil(win/2/dt);
else
    n = round(win/2/dt);
end

% Build exactly N grid-aligned samples on each side.  Colon expressions
% ending at WIN/2 become uneven at the join whenever WIN/(2*DT) is not an
% integer, which in turn shifts eCOCO window centres.
X1x = x(1)-(n:-1:1).*dt;
X2x = x(end)+(1:n).*dt;

if padding == 1
    % zero padding
    X1y = zeros(numel(X1x),1);
    X2y = zeros(numel(X2x),1);
elseif padding == 2
    % mirror padding
    if n > numel(y)
        error('zeropad2:MirrorPaddingTooLong', ...
            'Mirror padding cannot exceed the input data length.');
    end
    X1y = y(n:-1:1);
    X2y = y(end:-1:end-n+1);
    %disp(size(X2x'))
    %disp(size(X2y))
elseif padding == 3
    % mean padding
    y_start_mean = mean(y(1:n));
    y_end_mean = mean(y(end-n+1:end));
    X1y = zeros(length(X1x),1) + y_start_mean;
    X2y = zeros(length(X2x),1) + y_end_mean;
elseif padding == 4
    % random padding
    y_start_mean = mean(y(1:n));
    y_end_mean = mean(y(end-n+1:end));
    X1y = randn(length(X1x),1) * std(y(1:n)) + y_start_mean;
    X2y = randn(length(X2x),1) * std(y(end-n+1:end)) + y_end_mean;
else
    error('Error: padding must be either 1, 2, 3, or 4')
end

X1 = [X1x(:),X1y(:)];
X2 = [X2x(:),X2y(:)];

% final result
dataX = [X1; data; X2];
