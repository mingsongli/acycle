function [loc,val] = findnpk(dat,n,o)
% input
%   dat: vector of data
%   n: number of peaks
%   o: order: 1 = peak; 0 = trough
% output
%   loc: location
%   val: value
% Mingsong Li, Jan 9, 2019
%
if nargin < 3; o=1;end
if nargin < 2; n=1;end

npts = length(dat);
if n >= npts
    error('Error: n is larger than number of points of dat')
    return
end

b = sort(dat);
loc = [];
val = [];
k=1;
for i = 1:n
    if o == 1
        a = find(dat == b(end-i+1));
        for j = 1 : length(a)
            loc(k) = a(j);
            val(k) = dat(a(j));
            k = k+1;
        end
        
    elseif o == 0
        a = find(dat == b(i));
        for j = 1 : length(a)
            loc(k) = a(j);
            val(k) = dat(a(j));
            k = k+1;
        end
    end
end