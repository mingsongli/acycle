%   order:  initial points for seach . default is zero. 
%   srshreshold: shreshold
function [srslice_range,srn_all,srn_best,eccout_all] = ...
    ecocotrack(locatcc,out_ecc,out_eci,out_ecoco,out_norbit,out_depth,sr1,sr2,srstep,srsh,srslice,sig,ci,plotn,sh_norb)
% sr1 = 1;    % unit = cm/kyr
% sr2 = 25;   % unit = cm/kyr
% srstep = .25;   % unit = cm/kyr
% srsh = 2.5;     % unit = cm/kyr
% srslice = 5;
% sig = 0.3;  % correlation coefficient cutoff value. if < sig, drop it.
% ci = 6; % if sigificant level of H0 < 10%, results will be evaluated.

srshrange = (sr1:srsh:sr2)/srstep;
srshrange = round(srshrange);
srshrange = srshrange - (srshrange(1)) + 1; % debug
srsh_n = length(srshrange);
srshreshold = srsh/srstep;
%
m3 = size(locatcc,2);

srslice_range = round(linspace(1,m3,srslice+1));
eccout_all = NaN * ones(srsh_n,7*(srslice));
srn_all = NaN * ones(srsh_n,m3);
srn_best = NaN * ones(1,m3);

for j=1:srslice
    srs1 = srslice_range(j);
    srs2 = srslice_range(j+1);
    locat = locatcc(:,srs1:srs2);
    [~, ncol] = size(locat);
    srn = zeros(srsh_n,ncol);
    locatnan1 = locat;
    % track sr maps for given location map locat
    for i = 1:srsh_n
        [srn1,locationnan] = ecocotrackn(locat,srshreshold,srshrange(i),srn,1);
        locatnan1(isnan(locationnan)) = NaN;
        srn(i,:) = srn1;
    end
    srn_all(:,srs1:srs2) = srn;
    % counts properties of each sedimentation solutions
    sr_s_i =1:srsh_n;
    sr_s_i = sr_s_i';
    [eccounts] = eccount(srn,out_ecc(:,srs1:srs2),out_eci(:,srs1:srs2),...
        out_ecoco(:,srs1:srs2),out_norbit(:,srs1:srs2));
    % eccounts: 1 column: mean; 2 = median; 3 = number of points; 4: ecc; 5
    %           = eci; 6 = ecoco; 7 = norbit
    % Delete those of corrcoef < sigificant value; and confid. intervals > 5% 
    eccounts = sortrows(eccounts);  % sort
    for i = 1:srsh_n
        if eccounts(i,4) < sig;
            sr_s_i(i) = NaN;
        end
        if eccounts(i,5) > ci;
            sr_s_i(i) = NaN;
        end
        if eccounts(i,7) < sh_norb;
            sr_s_i(i) = NaN;
        end
        % delete similar sedimentation solutions. Keep larger ones
        if i > 1
            if eccounts(i,1) - eccounts(i-1,1) < srshreshold;
                %if eccounts(i-1,7) > eccounts(i,7)  
                if eccounts(i-1,6) > eccounts(i,6)
                    sr_s_i(i) = NaN;
                else
                    sr_s_i(i-1) = NaN;
                end
            end
        end
    end
    eccountsnew = eccounts;
    for i = 1:srsh_n
        if ~isnan(sr_s_i(i))
        else
            %eccountsnew(i,:) = eccounts(~isnan(sr_s_i),:);
            eccountsnew(i,:) = NaN * ones(1,7);
        end
    end
%    best_ecocorb = max(eccountsnew(:,7));
%    best_idx = find(eccountsnew(:,7)==best_ecocorb);
    best_ecoco = max(eccountsnew(:,6));
    best_idx = find(eccountsnew(:,6)==best_ecoco);
    %if j == 1
    %    srn_best(1,srs1:srs2) = srn1(eccountsnew(:,7)==best_ecocorb,:);
    %else
    srn_best(:,srs1:srs2) = srn(best_idx,:);
   % end
    % delete repeated rows
    % eccountsnew = unique(eccountsnew,'rows');
    % delete similar sedimentation rates, keep the one has largest ecocorb.
    eccount_row = size(eccountsnew,1);
    eccout_all(1:eccount_row,7*j-6:7*j) = eccountsnew;
end

% 
if plotn == 1
figure; 
plot(sr1+srstep*(srn_best(1,:)-1),out_depth,'o')
xlim([sr1 sr2])
ylim([min(out_depth) max(out_depth)])
xlabel('Sedimentation rate (cm/kyr)')
ylabel('Depth (m)')
title('Tracked highest ecoco*SL*#orbits value')
set(gca,'Ydir','reverse')
end