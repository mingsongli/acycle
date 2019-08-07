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

m=length(x);
y=zeros(m,1);

halfw = floor(w/2);
idx1 = halfw + 1;    % starting index of input signal with moving window of size w

if mod(w,2)
    % odd number
    %   first section
    for i = 1: idx1-1
        y(i) = median(x(1: idx1-1+i));
    end
    %   body
    for i = idx1 : m-idx1+1
        y(i) = median( x(i-halfw : i+halfw));
    end
    %   last section
    for i = m-idx1+2 : m
        y(i) = median(x( i-halfw : m));
    end
    
else
    % even number
    %   first section
    for i = 1: halfw-1
        y(i) = median(x(1: halfw+i));
    end
    %   body
    for i = halfw : m-idx1+1
        y(i) = median( x(i-(halfw-1) : i+halfw));
    end
    %   last section
    for i = m-idx1+2 : m
         y(i) = median(x(i-(halfw-1) : m));
    end
end