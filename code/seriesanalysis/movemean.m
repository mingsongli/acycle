function y = movemean(x,w)
%
% movemean returns an array of local w-point mean values,
%   where each mean is calculated over a sliding window of length w
%   across neighboring elements of x.
%   When w is odd, the window is centered about the element in the current position.
%   When k is even, the window is centered about the left element near the center. 
%   The window size is automatically truncated at the endpoints 
%   when there are not enough elements to fill the window. 
%    When the window is truncated, the mean is taken over only the elements that fill the window. 
%   
% INPUT
% x: input vector (size: m x 1)
% w: desired window size (either odd or even number)
% OUTPUT
% y: smoothed output signal; y is the same size as x.
%
% By Mingsong Li, Dec. 24, 2018, Penn State
%   Email: limingsonglms@gmail.com
%

narginchk(2,2);
validateattributes(x,{'numeric'}, ...
    {'vector','real','nonempty','finite'},mfilename,'x',1);
x = full(double(x(:)));

% Preserve the historical row-index window direction and column-vector
% output while sharing the strict, toolbox-free numerical implementation.
% Missing values are now rejected instead of being silently omitted.
data = [(1:numel(x))',x];
summary = acycleFixedCountMovingSummary(data,'mean',w);
y = summary(:,2);
