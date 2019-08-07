function x = domaintrans(x1,t)

% domaintrans  transformation of domain

% x1:  a m member vector
% t:   if t is a constant, sampling rate of
%      if t is a m member vector
%
% Mingsong Li, Penn State, May 15, 2019
if nargin > 2; error('Error: Too many input arguments'); end
if nargin < 1; t = 1; end
if nargin == 0; error('Error: Too few input arguments'); end
if length(x1) < 2; error('Error: First input argument has too few elements');  end

if length(t) == 1
    
    x = cumsum(x1.*t);
    
elseif length(t) ~= length(x1)
    
    error('Error: Length of the second input argument must have the same length of the first input argument');
    
else
    
    x = cumsum(x1.*t);
    
end