function y = moveMedian(x,w)
%
% moveMedian returns an array of local w-point median values, 
%   where each median is calculated over a sliding window of length w 
%   across neighboring elements of x. 
%   When w is odd, the window is centered about the element in the current position. 
%   When k is even, the window is centered about the left element near the center. 
%   The window size is automatically truncated at the endpoints 
%   when there are not enough elements to fill the window. 
%    When the window is truncated, the median is taken over only the elements that fill the window. 
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

validateattributes(x,{'numeric'},{'vector','real','nonempty'}, ...
    mfilename,'x',1);
validateattributes(w,{'numeric'}, ...
    {'scalar','integer','positive','finite'},mfilename,'w',2);
x = x(:);
halfw = floor(w/2);
if mod(w,2)
    window = [halfw,halfw];
else
    % Match the historical convention exactly: W/2-1 samples behind the
    % current position and W/2 samples ahead, with truncated endpoints.
    window = [max(0,halfw-1),halfw];
end
% MOVMEDIAN implements the same shrinking endpoint windows in compiled
% code.  Replacing thousands of interpreted MEDIAN calls is material for
% robust-red Monte Carlo runs while leaving the numerical definition
% unchanged (individual medians can differ only at floating-point
% roundoff because the compiled reduction order is implementation-defined).
y = movmedian(x,window,1,'Endpoints','shrink');
