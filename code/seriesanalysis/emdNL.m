% pure EMD, an implementation of HHT
% coded by Po-Nan Li @ Inst. of Phys., Academia Sinica, Taiwan

function c = emdNL(y, goal, pollFcn)
%EMDNL Historical fixed-sift EMD implementation used by EEMD.
%   C = EMDNL(Y,GOAL) preserves the historical calling convention.
%   C = EMDNL(Y,GOAL,POLLFcn) additionally invokes a zero-input callback
%   before each sifting iteration so a caller can cooperatively cancel.
%%

if nargin < 3
    pollFcn = [];
end

sz = length(y);
t = 1:sz;

%% Solve EMD

c = zeros(goal+1,sz);
h = y;
r = h;
for m = 1:goal
    if ~isempty(pollFcn)
        pollFcn();
    end
    internalExtrema = sum( ...
        (r(2:end-1) > r(1:end-2) & r(2:end-1) > r(3:end)) | ...
        (r(2:end-1) < r(1:end-2) & r(2:end-1) < r(3:end)));
    if internalExtrema < 2
        break
    end
    count = 0;
    h = r;
    while(count < ceil(sqrt(sz)))        
        if ~isempty(pollFcn)
            pollFcn();
        end
        count = count + 1;

        [mx_p, mx_v, mn_p, mn_v] = find_extrema(h);

        % interpolate by spline
        m1_mx = spline(t(mx_p), mx_v, t);
        m1_mn = spline(t(mn_p), mn_v, t);
        m1_av = (m1_mx + m1_mn) ./ 2;
        h = h - m1_av;
    end
    
    r = r - h;
    c(m,:) = h;
    
end

%%
c(end,:) = r;
