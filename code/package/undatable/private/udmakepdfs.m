function [medians, p68_2, p95_4, probtoplot, rundepth, rundepth1, rundepth2, rundepthpdf, runprob2sig, runboot, runncaldepth, udrunshuffle] = udmakepdfs(depth, depth1, depth2, age, ageerr, calcurve, resage, reserr, dateboot, depthcombine)

yeartype='Cal BP'; % for matcal

%---CREATE DEPTH PDFs

depthpdf = cell(length(depth1),1);
for i = 1:length(depth1)
	if depth2(i) > depth1(i) % standard core depth interval --> equal probability
		depthpdf{i}(:,1) = linspace(depth1(i), depth2(i), 10^4);
		depthpdf{i}(:,2) = ones(size(linspace(depth1(i), depth2(i), 10^4)));
	elseif depth1(i) == depth2(i) % no depth error given --> no uncertainty
		depthpdf{i}(1,1) = depth(i);
		depthpdf{i}(1,2) = 1;
	elseif depth2(i) < depth1(i) % depth with p/m error --> normdist (trimmed to 2 sig)
		depthpdf{i}(:,1) = linspace(depth(i)-2*depth2(i), depth(i)+2*depth2(i), 10^4);
		depthpdf{i}(:,2) = normpdf(linspace(depth(i)-2*depth2(i), depth(i)+2*depth2(i), 10^4),depth(i),depth2(i));
	end
end

%---CREATE CAL AGE PDFs

medians = NaN(size(age,1),1);

p68_2 = cell(1,size(age,1));
p95_4 = cell(1,size(age,1));
probtoplot = cell(1,size(age,1));
prob2sig = cell(1,size(age,1));

for j = 1:size(age,1)

	if strcmpi(calcurve{j},'none') == 1 % create dists for calendar ages
		
		if ageerr(j) > 0 % norm dist
			pdfrng = age(j)-4*ageerr(j):age(j)+4*ageerr(j);
			prob_temp = normpdf(pdfrng,age(j),ageerr(j));
			prob_temp = [pdfrng' prob_temp'];
			p68_2{j} = [age(j)+1*ageerr(j), age(j)-1*ageerr(j), erf(1/sqrt(2))];
			p95_4{j} = [age(j)+2*ageerr(j), age(j)-2*ageerr(j), erf(2/sqrt(2))];
			probtoplot{j} = prob_temp(prob_temp(:,2)/max(prob_temp(:,2)) > 0.001, :); % trim tails
			prob2sig{j} = prob_temp(prob_temp(:,1)<=p95_4{j}(1,1) & prob_temp(:,1)>=p95_4{j}(1,2),:);
		elseif ageerr(j) == 0 %uni dist
			p68_2{j} = NaN;
			p95_4{j} = NaN;
			prob_temp = [age(j) 1];
			prob2sig{j} = [age(j) 1];
			probtoplot{j} = [age(j) 1];
		end
		
	else  % create calibrated PDFs for 14C ages
		[p95_4{j},p68_2{j},prob_temp] = udmatcal(age(j),ageerr(j),calcurve{j},yeartype,'resage',resage(j),'reserr',reserr(j),'plot',0);
		p95_4=flipud(p95_4);
		%take only 95.4% range(s)
		prob2sig_temp = [];
		for k=1:size(p95_4{j},1) % possible to have multiple 95.4 intervals
			prob2sig_temp = [prob2sig_temp; prob_temp(prob_temp(:,1)<=p95_4{j}(k,1) & prob_temp(:,1)>=p95_4{j}(k,2),:)];
		end
		prob2sig{j} = sortrows(prob2sig_temp,1);
		probtoplot{j} = prob_temp(prob_temp(:,2)/max(prob_temp(:,2)) > 0.001, :); % trim tails
		
	end
	
	% get median age
	[~, median_ind] = min(abs( cumsum(prob_temp(:,2)) - 0.5 ));
	medians(j) = prob_temp(median_ind,1);

	
end

%---COMBINE AGE PDFs with EXACT SAME DEPTH INTERVAL

% find all dates with same depth, depth1 & depth2 values
[~,uni,~] = unique(depth+depth1+depth2, 'stable');
rundepth = depth(uni);
sanity1 = length(rundepth);
sanity2 = length(unique(rundepth)); % sanity1 and sanity2 should always be the same!
rundepth1 = depth1(uni);
rundepth2 = depth2(uni);
rundepthpdf = depthpdf(uni);
runprob2sig = prob2sig(uni);
runboot = dateboot(uni);
runncaldepth = length(rundepth);
udrunshuffle = 0;

% for each date with multiple dates, combine their probtoplot and then do HPD, then calculate prob2 from that
if depthcombine == 1 && length(depth) > length(rundepth)
	combdepths = unique(depth(diff(depth+depth1+depth2)==0),'stable');
	for i = 1:length(combdepths)
		theseproball = probtoplot(depth == combdepths(i));
		for j = 1:length(theseproball)
			if j == 1
				proballi = theseproball{j};
			else
				proballi(end+1:end+size(theseproball{j},1),:) = theseproball{j};
			end
		end
		uniques = unique(proballi(:,1));
		proballout = NaN(size(uniques,1),2);
		for j = 1:length(uniques)
			proballout(j,1) = uniques(j);
			proballout(j,2) = sum(proballi(proballi(:,1) == uniques(j),2));
		end
		proballout = sortrows(proballout,1);

		% HPD intervals
		if size(proballout,1) == 1 % uniform, 1 year, no need for HPD
			runprob2sig = proballout;
		else
			proballout(:,2) = proballout(:,2)/sum(proballout(:,2)); % normalise to between 0 and 1
			hpd = sortrows(proballout(:,1:2),2);
			hpd(:,3) = cumsum(hpd(:,2));
			hpd95_4 = hpd(hpd(:,3) >= 1-erf(2/sqrt(2)), :);
			hpd95_4 = sortrows(hpd95_4,1);
			ind2 = find(diff(hpd95_4(:,1)) > 1);
			clear p95_4temp % just in case there was one already
			if isempty(ind2) == 1
				p95_4temp(1,1) = hpd95_4(end,1);
				p95_4temp(1,2) = hpd95_4(1,1);
				p95_4temp(1,3) = sum(hpd95_4(1:end,2));
			else
				z = 0;
				clear indy2
				for j = 1:length(ind2)
					z = z + 1;
					indy2(z,1) = ind2(j);
					z = z + 1;
					indy2(z,1) = ind2(j)+1;
				end
				indy2 = [ 1 ; indy2; length(hpd95_4(:,1)) ];
				z=0;
				for j = 2:2:length(indy2)
					z = z+1;
					p95_4temp(z,1) = hpd95_4(indy2(j),1);
					p95_4temp(z,2) = hpd95_4(indy2(j-1),1);
					p95_4temp(z,3) = sum(hpd95_4(indy2(j-1):indy2(j),2));
				end
			end
			
			%take only 95.4% range(s)
			prob2out=[];
			for k=1:size(p95_4temp,1) % possible to have multiple 95.4 intervals
				prob2out=[prob2out; proballout(proballout(:,1)<=p95_4temp(k,1) & proballout(:,1)>=p95_4temp(k,2),:)];
			end
			prob2out = sortrows(prob2out,1);
			runprob2sig{rundepth == combdepths(i)} = [prob2out(:,1), prob2out(:,2)/sum(prob2out(:,2))]; % normalise to between 0 and 1
		end		
	end
elseif depthcombine == 0 && length(depth) > length(rundepth)
	udrunshuffle = 1; % if depths not combined, possible bias to first entered of depths with same value, so will be shuffled per nsim in udrun
end

end % end function