function [srn1,locatnan] = ecocotrackn(locat,srsh,iniloc,srn,method)
%   locat:  initial points for seach . default is zero. 
%   srshreshold:  seach sed. rate 
%   initial: rows
%   srsh: shreshold
%   srn:
%   method: 0 = relative to nearest value;
%           1 = relative to median of nearest 5 value
locatnan = locat;
[nrow, ncol] = size(locat);
srn1 = NaN*zeros(1,ncol);

i = 1;
% iniloc = locat(initial,1);
locaj = locat(:,1);
for j = 1:nrow
    if abs(locaj(j) - iniloc) < srsh
        locajm = abs(locaj - iniloc);
        locajm1 = locaj(locajm == min(locajm));
        srn1(i,1) = locajm1(1);
    end
end

% locatnan(initial,1) = NaN;

for j = 2:ncol
       locatT = locat(:,j);
       % ecocoj = ecoco(locatT,j);
       locatTm = abs((locatT - iniloc));
       locn = min(locatTm);
       if locn > srsh
            srn1(i,j) = NaN;
%             if isnan(srn1(i,j-1))
%             else
%              iniloc = srn1(i,j-1);
%             end
       else
         %  locatTmax = abs((locatT - iniloc).*ecocoj);
         %  locn = max(locatTmax);
         %  location = find(locatTmax == locn);
           location = find(locatTm == locn);
           locatnan(location,j) = NaN;
           % if more than 1 options
           if length(location) > 1
%                 locatTmax = abs((locatT-nanmean(srn1(i,1:j))).*ecocoj);
%                 locn = max(locatTmax);
%                 location = find(locatTmax == locn);
                locatTm = abs(locatT-nanmedian(srn1(i,1:j)));
                locn = min(locatTm);
                location = find(locatTm == locn);
                if length(location) > 1
                    location = location(1);
                end
           end

%            if ismember(locatT(location), srn(:,j))
%                return
%            end

    if isnan(location)
        continue
    elseif isempty(location)
        continue
    else
           srn1(i,j) = locatT(location);
    end
           
           if isnan(srn1(i,j-1))
           else
              if method == 0
                iniloc = srn1(i,j-1);
              elseif method == 1
                 if j > 5
                     iniloc = nanmedian(srn1(i,j-5:j-1));
                 else
                     iniloc = nanmedian(srn1(i,1:j-1));
                 end
              end
           end
       end
end