

function [gammln1,xx] = gammln(xx)
    % Inputs:
    %   xx: double scalar
    % Output:
    %   gammln1: double scalar

    cof = [76.18009172947146, -86.50532032941677, 24.01409824083091, ...
           -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5];
    stp = 2.5066282746310005;

    x = xx;
    y = x;
    tmp = x + 5.5;
    tmp = (x + 0.5) * log(tmp) - tmp;
    ser = 1.000000000190015;

    for j = 1:6
        y = y + 1.0;
        ser = ser + cof(j) / y;
    end

    gammln1 = tmp + log(stp * ser / x);
end

% Test case
% xx = 5.0;
% result = gammln(xx);
% disp(result);
