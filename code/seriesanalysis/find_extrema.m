function [max_p, max_v, min_p, min_v] = find_extrema(y)
% find maximas
% [tmp_v, tmp_p] = findpeaks(y);
tmp_p = find(y(2:end-1)>y(1:end-2) & y(2:end-1)>y(3:end)) + 1;
tmp_v = y(tmp_p);
max_p = zeros(1, length(tmp_p)+2);
max_v = zeros(size(max_p));
max_p(1) = 1;
max_v(1) = y(1);
max_p(end) = length(y);
max_v(end) = y(end);
max_p(2:(end-1)) = tmp_p;
max_v(2:(end-1)) = tmp_v;
% additional check
if length(max_p) > 5
    m1 = ( max_v(3) - max_v(2) ) / ( max_p(3) - max_p(2) );
    test = max_v(2) - m1 * ( max_p(2) - max_p(1) );
    if test > max_v(1)
        max_v(1) = test;
    end
    m2 = ( max_v(end-1) - max_v(end-2) ) / ( max_p(end-1) - max_p(end-2) );
    test = max_v(end-1) + m2 * ( max_p(end) - max_p(end-1) );
    if test > max_v(end)
        max_v(end) = test;
    end
end

% find minimas
% [tmp_v, tmp_p] = findpeaks(-y);
tmp_p = find(y(2:end-1)<y(1:end-2) & y(2:end-1)<y(3:end)) + 1;
tmp_v = y(tmp_p);
min_p = zeros(1, length(tmp_p)+2);
min_v = zeros(size(min_p));
min_p(1) = 1;
min_v(1) = y(1);
min_p(end) = length(y);
min_v(end) = y(end);
min_p(2:(end-1)) = tmp_p;
min_v(2:(end-1)) = tmp_v;
% additional check
if length(min_p) > 5
    m1 = ( min_v(3) - min_v(2) ) / ( min_p(3) - min_p(2) );
    test = min_v(2) - m1 * ( min_p(2) - min_p(1) );
    if test < min_v(1)
        min_v(1) = test;
    end
    m2 = ( min_v(end-1) - min_v(end-2) ) / ( min_p(end-1) - min_p(end-2) );
    test = min_v(end-1) + m2 * ( min_p(end) - min_p(end-1) );
    if test < min_v(end)
        min_v(end) = test;
    end
end
end