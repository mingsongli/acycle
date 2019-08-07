function B = movemean(A,n,option)

% INPUT:
% A: 1 column series
% n: window
% option:

% OUTPUT
% B: results
if ~nargin
    error('Error in movemean. No input data.')
end

nptsA = length(A);
if n >= nptsA
    error('Error in movemean. n must be small than A.')
end

if nargin < 2
    error('Error in movemean. No window.')
end

if nargin < 3
    option = 'regular';
end
if nargin >3
    error('Error in movemean. Too much arguments.')
end

if mod(n,2) == 0
    n = n-1;
end

nptsB = nptsA - (n-1); %  number of points of series B
normalB = (n+1)/2; %
B = zeros(nptsA,1);

if strcmp(option, 'omitnan')
    for i = 1:nptsB
        C = A(i:(i+n-1));
        C = C(~isnan(C));
        B(normalB+i-1) = mean(C);
    end
   
    for j = 1:(normalB-1)
        C=A(1:normalB+j-1);
        C = C(~isnan(C));
        B(j) = mean(C);
        k = nptsA-j-normalB+2;
        D = A(k:nptsA);
        D = D(~isnan(D));
        B(nptsA-j+1) = mean(D);
    end
else
    
    for i = 1:nptsB
        B(normalB+i-1) = mean(A(i:(i+n-1)));
    end

    for j = 1:(normalB-1)
        B(j) = mean(A(1:normalB+j-1));
        k = nptsA-j-normalB+2;
        B(nptsA-j+1) = mean(A(k:nptsA));
    end

end
