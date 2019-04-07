function [Y] = ebrief(X,dim,a)
% ebrief: evlutionary brief data. Find peaks for each row of data X
% (default)
% INPUT
%   X: data to be evaluated. A vector or Matrix.
%   dim: dimention. 1 = row (default); 2 = column.
%   a: new value
% OUTPUT
%   Y: new data show peaks only
%   Mingsong Li, June 2017
%
if nargin > 4
    error('Too many input arguments')
end
if nargin < 3
    a = 0;
if nargin < 2
    dim = 1;
end
end

if dim == 2;
    X = X';
end
[nrow, ncol] = size(X);

Y = a * ones(nrow,ncol);

for i = 1:nrow
    [~, locs] = findpeaks(X(i,:));
    Y(i,locs) = X(i,locs);
end

if dim == 2;
    Y = Y';
end