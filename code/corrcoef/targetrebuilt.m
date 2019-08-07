function targetnew = targetrebuilt(target)
%
% Get peaks of target
% OUTPUT 
% targetnew: 2 column dataset 
% col 1 = variance
% col 2 = frequency
%
% INPUT
%   target: 2 column frequency-power series
% 
% by Mingsong Li, Penn State, 2017

psh = 1/2*mean(target(:,2));
[targetpks(:,1),targetpks(:,2)] = findpeaks(target(:,2));

npks = length(targetpks(:,1));
j=1;
for i = 1:npks
    if targetpks(i,1) >= psh
        targetnew(j,1) = targetpks(i,1);
        targetnew(j,2) = target(targetpks(i,2),1);
        j=j+1;
    end
end