function ranks = multivariateTiedRank(values)
%MULTIVARIATETIEDRANK Average ranks of a vector, smallest value ranked 1.
%   RANKS = MULTIVARIATETIEDRANK(VALUES) returns the ascending ranks of
%   VALUES(:). Tied values receive their average rank, matching the
%   tie handling of R's rank() and the Statistics Toolbox tiedrank()
%   without requiring that toolbox.
%
%   NaN values are ranked as if they were ordinary numbers (they sort to
%   the end in MATLAB); callers are expected to have removed them.

values = double(values(:));
n = numel(values);
ranks = zeros(n,1);
if n == 0
    return
end

[sortedValues,order] = sort(values);

i = 1;
while i <= n
    j = i;
    while j < n && sortedValues(j+1) == sortedValues(i)
        j = j + 1;
    end
    averageRank = (i + j) / 2;
    ranks(order(i:j)) = averageRank;
    i = j + 1;
end
end
