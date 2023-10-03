function [agedepmat] = udrun(nsim, bootpc, xfactor, rundepth, rundepth1, rundepth2, rundepthpdf, runprob2sig, runboot, runncaldepth, udrunshuffle, allowreversal)

% 1.0 ------- Sample age and depth PDFs and put them in agedepmat
% create agedepmat. col1 = age, col2 = depth

agedepmat = NaN(runncaldepth,2,nsim); % space for intermediate points will be added in step 4.0
for i = 1:length(rundepth)
	% age
	if size(runprob2sig{i},1) > 1
		agedepmat(i,1,:) = randsample(runprob2sig{i}(:,1),nsim,true,runprob2sig{i}(:,2));
	else
		agedepmat(i,1,:) = repmat(runprob2sig{i}(:,1),1,nsim);
	end
	% depth
	if size(rundepthpdf{i},1) > 1
		agedepmat(i,2,:) = randsample(rundepthpdf{i}(:,1),nsim,true,rundepthpdf{i}(:,2));
	else
		agedepmat(i,2,:) = repmat(rundepthpdf{i}(:,1),1,nsim);
	end
end


% 2.0 ------ Bootstrap
if sum(runboot) > 0 && bootpc > 0
	% 	tic
	runorder = (1:size(agedepmat,1)); % Run # of all dates
	bootind = runorder(runboot); % Run # of dates to be bootstrapped
	nobootind = runorder(~runboot); % Run # dates not to be bootstrapped
	nkeep = length(bootind)-round((bootpc/100)*length(bootind)); % Number of bootind to keep per nsim
	if nkeep < 1; nkeep = 1; end
	outputmat = NaN(nkeep+length(nobootind),2,nsim); % The final output matrix of all kept dates
	for i = 1:nsim
		outputmat(:,:,i) = agedepmat(sort([bootind(randperm(numel(bootind),nkeep)), nobootind]),:,i);
	end
	agedepmat = outputmat; % Should be NaN-free
	clear outputmat
	% 	toc
	% 	disp(' ')
end


% 3.0 ------- Kick out reversals

if udrunshuffle == 1 % udrunshuffle is set in udmakepdfs
	% shuffle all agedepmat rows
	shufind = NaN(size(agedepmat,1),1,nsim);
	nrows = size(agedepmat,1);
	for i = 1:nsim
		shufind(:,1,i) = randperm(nrows,nrows); % shuffle indices
	end
	% now sort each nsim by shufind
	% fast way: https://stackoverflow.com/questions/30412770/sortrows-in-the-2nd-dimension-of-3d-matrix
	[m,n,p] = size(agedepmat);
	linind = bsxfun(@plus, bsxfun(@plus, shufind, (0:n-1)*m), reshape((0:p-1)*m*n, 1, 1, p));
	clear shufind
	agedepmat = agedepmat(linind);
	clear linind
end
% sort each nsim by sampled depth
[m,n,p] = size(agedepmat);
[~, rowind] = sort(agedepmat(:,2,:), 1);
linind = bsxfun(@plus, bsxfun(@plus, rowind, (0:n-1)*m), reshape((0:p-1)*m*n, 1, 1, p));
clear rowind
agedepmat = agedepmat(linind);
clear linind


% age-depth reversal/repeat removal script
agedepmat = flipdim(agedepmat,1); % working from bottom to top, in direction of sedimentation
workingmat = agedepmat; 
diffmat = workingmat(2:end,:,:)-workingmat(1:end-1,:,:);
if allowreversal == 0 % --> remove reversals and repeats
	while numel(find(diffmat(:,1,:)>=0)) + numel(find(diffmat(:,2,:)>=0)) > 0	
		% find age and depth reversals & repeats
		indr = find(diffmat>=0);
		[irows,icols,iters] = ind2sub(size(diffmat),indr);
		% NaN the age and depth values for the age reversals/repeats
		if isempty(icols(icols==1)) == 0
			ind = sub2ind(size(workingmat),[irows(icols==1)+1 irows(icols==1)+1],[icols(icols==1) icols(icols==1)+1],[iters(icols==1) iters(icols==1)]);
			workingmat(ind) = NaN;
		end
		% NaN the age and depth values for the depth reversals/repeats
		if isempty(icols(icols==2)) == 0
			ind = sub2ind(size(workingmat),[irows(icols==2)+1 irows(icols==2)+1],[icols(icols==2)-1 icols(icols==2)],[iters(icols==2) iters(icols==2)]);
			workingmat(ind) = NaN;
		end
		% send the NaNs of 3d matrix to the bottom of 2nd dimension without sorting the other stuff
		% https://fr.mathworks.com/matlabcentral/answers/386380-move-all-nan-to-end-of-matrix-columns
		[~,idr] = sort(isnan(workingmat),1);
		S = size(workingmat);
		[~,id2,id3] = ndgrid(1:S(1),1:S(2),1:S(3));
		workingmat = workingmat(sub2ind(S,idr,id2,id3));
		% calculate new diffmat for next while loop
		diffmat = workingmat(2:end,:,:)-workingmat(1:end-1,:,:);
	end
elseif allowreversal == 1 % --> only remove repeats
	while numel(find(diffmat(:,1,:)==0)) + numel(find(diffmat(:,2,:)==0)) > 0
		% find age and depth repeats
		indr = find(diffmat==0);
		[irows,icols,iters] = ind2sub(size(diffmat),indr);
		% NaN the age and depth values for the age repeats
		if isempty(icols(icols==1)) == 0
			ind = sub2ind(size(workingmat),[irows(icols==1)+1 irows(icols==1)+1],[icols(icols==1) icols(icols==1)+1],[iters(icols==1) iters(icols==1)]);
			workingmat(ind) = NaN;
		end
		% NaN the age and depth values for the depth repeats
		if isempty(icols(icols==2)) == 0
			ind = sub2ind(size(workingmat),[irows(icols==2)+1 irows(icols==2)+1],[icols(icols==2)-1 icols(icols==2)],[iters(icols==2) iters(icols==2)]);
			workingmat(ind) = NaN;
		end
		% send the NaNs of 3d matrix to the bottom of 2nd dimension without sorting the other stuff
		% https://fr.mathworks.com/matlabcentral/answers/386380-move-all-nan-to-end-of-matrix-columns
		[~,idr] = sort(isnan(workingmat),1);
		S = size(workingmat);
		[~,id2,id3] = ndgrid(1:S(1),1:S(2),1:S(3));
		workingmat = workingmat(sub2ind(S,idr,id2,id3));
		% calculate new diffmat for next while loop
		diffmat = workingmat(2:end,:,:)-workingmat(1:end-1,:,:);
	end
end
agedepmat = workingmat;
clear workingmat


% 4.0 ------ Insert intermediate points (sed rate uncertainty)
% disp('Calculating sedimentation rate uncertainty')

intmat = NaN(size(agedepmat,1)-1,2,nsim);
for i = 1:size(intmat,1)
	% disp([num2str(i/size(intmat,1)*100,'%.2f'),'%'])
	for j = 1:2 % 1 = age, 2 = depth
		% calc gaussian intpoints for all nsims for this age or depth pair
		% fully vectorised way that is not possible using normpdf and randsample
		if allowreversal == 0
			adtop = agedepmat(i+1,j,:); % upper bounds
			adbot = agedepmat(i,j,:); % lower bounds
		elseif allowreversal == 1
			adtop = min([agedepmat(i+1,j,:); agedepmat(i,j,:)],[],1,'includenan');
			adbot = max([agedepmat(i+1,j,:); agedepmat(i,j,:)],[],1,'includenan');
		end
		meanmat = (adtop+adbot)/2; % mid points
		diffmat = abs(adtop-adbot); % intervals
		normmat = randn(size(meanmat)); % normal randoms (mu = 0, sig = 1)
		intpts = meanmat + (xfactor .* diffmat .* normmat); % int points
		% check for int points outside desired range and resample
		indrp = NaN;
		while isempty(indrp) ~= 1
			indrp = unique([find(intpts - adtop < 0 ); find(intpts - adbot > 0 );]);
			normmat = randn(1,1,numel(indrp)); % new normmat attempt
			intpts(indrp) = meanmat(indrp) + (xfactor .* diffmat(indrp) .* normmat);
		end
		% send to intmat
		intmat(i,j,:) = intpts;
	end
end
% now splice intmat and agedepmat together
bigmatrix = NaN(size(agedepmat,1)+size(agedepmat,1)-1,2,nsim);
bigmatrix(1:2:end,:,:) = agedepmat;
bigmatrix(2:2:end-1,:,:) = intmat;
agedepmat = bigmatrix;
clear bigmatrix

% flip before sending back to undatable
agedepmat = flipdim(agedepmat,1);

