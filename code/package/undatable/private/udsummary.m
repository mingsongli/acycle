function [summarymat, shadingmat, depthrange, sarsummarymat, sarshadingmat] = udsummary(depthstart, depthend, nsim, agedepmat, interpinterval, inputfile, writedir, bootpc, xfactor, depthcombine, sar, savebigmat)

%--- Summarise the data agedepmat data to discrete depth probabilities

depthrange = [depthstart ceil(depthstart):interpinterval:floor(depthend) depthend]';
depthrange = unique(depthrange);
if max(depthrange) < depthend
    depthrange = [depthrange; depthend];
end

% replace depth nans with very negative values (must all be unique or interp will error)
numdeps = length(find(isnan(agedepmat(:,2,:))));
replogical = false(size(agedepmat));
replogical(:,2,:) = isnan(agedepmat(:,2,:));
agedepmat(replogical) = linspace(-9999-numdeps, -9999, numdeps); % always in ascending order
clear replogical


tempage = NaN(length(depthrange),nsim);

% attempt to use faster precompiled binary
try
	checkmex = sum(nakeinterp1([1; 10],[1; 100],[2:2:9]')) == 180;
catch err
end

% Check for presence of precompiled binary
if exist('err','var') == 1
	warning(err.message)
	disp('Compiling nakeinterp1.c will increase speed. Using slower interpolation')
	for i = 1:nsim
		tempage(:,i) = interp1qr(agedepmat(:,2,i),agedepmat(:,1,i),depthrange);
	end

end

% Check that precompiled binary returned correct result before using
if exist('checkmex','var') == 1
	if checkmex ~= 1
		warning('nakeinterp1 binary found but needs to be recompiled (help mex)')
		for i = 1:nsim
			tempage(:,i) = interp1qr(agedepmat(:,2,i),agedepmat(:,1,i),depthrange);
		end
	else
		nakedepthrange = depthrange;
		nakedepthrange(1) = nakedepthrange(1)+(10^-10);
		for i = 1:nsim
			tempage(:,i) = nakeinterp1(agedepmat(:,2,i),agedepmat(:,1,i),nakedepthrange);
		end
	end
end

% create probability density cloud for ages
allprctiles = prctile(tempage,[1:99, 100*(1-erf(2/sqrt(2)))/2, 100*(1-erf(1/sqrt(2)))/2, 100-100*(1-erf(1/sqrt(2)))/2, 100-100*(1-erf(2/sqrt(2)))/2] , 2);
shadingmat = allprctiles(:,1:99);
summarymat = [allprctiles(:,[50, 100:end]), nanmean(tempage,2)]; % summarymat is: median, 2siglo, 1siglo, 1sighi, 2sighi, mean

% create probability density cloud for sedrates
if sar == 0
	% 1 depth, 2 age, 3 median sed rate (from model)
	sarsummarymat = [depthrange(1:end-1), summarymat(1:end-1,1), diff(depthrange) ./ diff(summarymat(:,1) / 1000)];
	sarshadingmat = [];
elseif sar == 1
	% diff the entire accumulation model
	% tempsar = diff(depthrange) ./ diff(tempage / 1000);

	% diff the 1:99 percentiles
	tempsar = diff(depthrange) ./ diff(allprctiles / 1000);
	
	% 1 depth, 2 age, 3 median sed rate (from model), 4 2siglo, 5 1siglo, 6 1sighi, 7 2sighi
	sarsummarymat = nan(size(tempsar,1),7);

	% 1 depth, 2 age, 3 median sed rate (from model)
	sarsummarymat(:,1:3) = [depthrange(1:end-1), summarymat(1:end-1,1), diff(depthrange) ./ diff(summarymat(:,1) / 1000)];
		
	% Need to look into this more, but long tail of impossibly high sedimentation rates so limiting to only <= 3x median
	% index = tempsar > 3 * sarsummarymat(:,3);
	% tempsar(index) = NaN;
	% if nsim ~= 2000, save('tempsar.mat','tempsar','tempage'), end
	
	% create probability density cloud for SARs
	sarallprctiles = prctile(tempsar,[1:99, 100*(1-erf(2/sqrt(2)))/2, 100*(1-erf(1/sqrt(2)))/2, 100-100*(1-erf(1/sqrt(2)))/2, 100-100*(1-erf(2/sqrt(2)))/2] , 2);
	sarshadingmat = sarallprctiles(:,1:99);
	
	% 4 2siglo, 5 1siglo, 6 1sighi, 7 2sighi
	sarsummarymat(:,4:7) = sarallprctiles(:,100:end);
end

% save to disk
savename = strrep(inputfile,'.txt','_admodel.txt');
[~,NAME,EXT] = fileparts(savename);
savename = [NAME,EXT];
savename = [writedir,savename];

if depthcombine == 1
	comtag = 'Yes';
elseif depthcombine == 0
	comtag = 'No'; 
end

printsar = sarsummarymat;
printsar(end+1,:) = NaN;

fid_output = fopen(savename,'w');
fprintf(fid_output,'%s',['Undatable run on ',datestr(now,31),'. nsim=',num2str(nsim),' bootpc=',num2str(bootpc,'%.2g'),' xfactor=',num2str(xfactor,'%.2g'),' combine=',comtag]);
if sar == 0
	fprintf(fid_output,'\r\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','Depth','Median age','Mean age','95.4% age','68.2% age','68.2% age','95.4% age','Median SAR');
	for i = 1:size(depthrange,1)
		fprintf(fid_output,'\r\n%f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.2f',depthrange(i),summarymat(i,1),summarymat(i,6),summarymat(i,2),summarymat(i,3),summarymat(i,4),summarymat(i,5),printsar(i,3));
	end
elseif sar == 1
		fprintf(fid_output,'\r\n%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','Depth','Median age','Mean age','95.4% age','68.2% age','68.2% age','95.4% age','Median SAR','95.4% SAR','68.2% SAR','68.2% SAR','95.4% SAR');
	for i = 1:size(depthrange,1)
		fprintf(fid_output,'\r\n%f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.0f\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f',depthrange(i),summarymat(i,1),summarymat(i,6),summarymat(i,2),summarymat(i,3),summarymat(i,4),summarymat(i,5),printsar(i,3),printsar(i,4),printsar(i,5),printsar(i,6),printsar(i,7));
	end
end
fclose(fid_output);


% Save output (if savemat selected)
if savebigmat == 1
	[~,writename,~] = fileparts(inputfile);
	writename = [writename '_bigmat'];
	save([writedir,writename,'.mat'],'-v7.3','depthrange','tempage')
end

end % end function

