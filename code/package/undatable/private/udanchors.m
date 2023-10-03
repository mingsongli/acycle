function [rundepth, rundepth1, rundepth2, rundepthpdf, runprob2sig, runboot, runncaldepth] = udanchors(depthrange, depth, depth1, depth2, summarymat, rundepth, rundepth1, rundepth2, rundepthpdf, runprob2sig, runboot)

% calculate bottom anchor
P = polyfit(  depthrange(depthrange <= rundepth(end) & depthrange >= rundepth(end-2)), summarymat(depthrange <= rundepth(end) & depthrange >= rundepth(end-2) , 1), 1);
botanchdepth = rundepth(end) + abs(rundepth(end) - rundepth(end-2));
botdepthpdf = {[botanchdepth 1]};
botanchage = P(1)*botanchdepth + P(2);
botancherr = (mean(summarymat(depthrange <= rundepth(end) & depthrange >= rundepth(end-2) , 4)) - mean(summarymat(depthrange <= rundepth(end) & depthrange >= rundepth(end-2) , 3))) / 2;
botanchpdf = normpdf(botanchage-3*botancherr:1:botanchage+3*botancherr,botanchage,botancherr);
botanchpdf = {[[botanchage-3*botancherr:1:botanchage+3*botancherr]' [botanchpdf]']};

% calculate top anchor
P = polyfit(  depthrange(depthrange >= rundepth(1) & depthrange <= rundepth(3)), summarymat(depthrange >= rundepth(1) & depthrange <= rundepth(3) , 1), 1);
topanchdepth = rundepth(1) - abs(rundepth(1) - rundepth(3));
topdepthpdf = {[topanchdepth 1]};
topanchage = P(1)*topanchdepth + P(2);
topancherr = (mean(summarymat(depthrange >= rundepth(1) & depthrange <= rundepth(3) , 4)) - mean(summarymat(depthrange >= rundepth(1) & depthrange <= rundepth(3) , 3))) / 2;
topanchpdf = normpdf(topanchage-3*topancherr:1:topanchage+3*topancherr,topanchage,topancherr);
topanchpdf = {[[topanchage-3*topancherr:1:topanchage+3*topancherr]' topanchpdf']};

% prep input for second run
rundepth = [topanchdepth; rundepth; botanchdepth];
rundepth1 = [topanchdepth; rundepth1; botanchdepth];
rundepth2 = [topanchdepth; rundepth2; botanchdepth];
rundepthpdf(2:end+1,:) = rundepthpdf(1:end,:);
rundepthpdf(1,:) = topdepthpdf;
rundepthpdf(end+1,:) = botdepthpdf;
runprob2sig(:,2:end+1) = runprob2sig(:,1:end);
runprob2sig(:,1) = topanchpdf;
runprob2sig(:,end+1) = botanchpdf;

%comment this out bootstrap uppermost and lowermost date
runboot(1)=0; runboot(end)=0;

% anchors will always be excluded from bootstrapping. Change '0's to '1's to bootstrap anchors
runboot = logical([0; runboot; 0]);

runncaldepth = length(rundepth);