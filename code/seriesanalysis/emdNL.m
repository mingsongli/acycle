% pure EMD, an implementation of HHT
% coded by Po-Nan Li @ Inst. of Phys., Academia Sinica, Taiwan

function c = emd(y, goal)
%%

sz = length(y);
t = 1:sz;

%% Solve EMD

c = zeros(goal+1,sz);
h = y;
r = h;
for m = 1:goal
    count = 0;
    h = r;
    while(count < ceil(sqrt(sz)))        
        
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
