function [datelabel, depth1, depth2, depth, age, ageerr, datetype, calcurve, resage, reserr, dateboot] = udgetdata(inputfile)

File = fopen(inputfile);
Contents = textscan(File,'%s %f %f %f %f %s %s %f %f %s','headerlines',1,'delimiter','\t');
fclose(File);
datelabel = Contents{1};
depth1 = Contents{2};
depth2 = Contents{3};
depth = NaN(size(depth1));
age = Contents{4};
ageerr = Contents{5};
datetype = Contents{6};
calcurve = Contents{7};
resage = Contents{8};
resage(isnan(resage)==1) = 0;
reserr = Contents{9};
reserr(isnan(reserr)==1) = 0;
dateboot = Contents{10};
dateboot = strncmpi(dateboot,'y',1); % convert yes/no to 1/0

% check for trailing NaNs (artefact of Micros**t Excel)
while isnan(age(end)) == 1
	datelabel = datelabel(1:end-1);
	depth1 = depth1(1:end-1);
	depth2 = depth2(1:end-1);
	age = age(1:end-1);
	ageerr = ageerr(1:end-1);
	datetype = datetype(1:end-1);
	calcurve = calcurve(1:end-1);
	resage = resage(1:end-1);
	reserr = reserr(1:end-1);
	dateboot = dateboot(1:end-1);
	depth = depth(1:end-1);	
end

% Find mean depth, identify type of depth input
for i = 1:length(depth1)
	if depth2(i) > depth1(i) % a standard core depth interval
		depth(i) = (depth1(i) + depth2(i))/2;
	elseif isnan(depth2(i)) == 1 % user input NaN as depth2, assume 1 cm slice
		depth2(i) = depth1(i)+1;
		depth(i) = (depth1(i) + depth2(i))/2;
	elseif depth2(i) == depth1(i) % user set depth1 and depth2 the same
		depth(i) = depth1(i);
	elseif depth2(i) < depth1(i) % depth1 is mean depth, depth2 is p/m depth error
		depth(i) = depth1(i);
	end
end

% Sort by depth
[~,ind] = sort(depth);
datelabel = datelabel(ind);
depth1 = depth1(ind);
depth2 = depth2(ind);
depth = depth(ind);
age = age(ind);
ageerr = ageerr(ind);
datetype = datetype(ind);
calcurve = calcurve(ind);
resage = resage(ind);
reserr = reserr(ind);
dateboot = logical(dateboot(ind));


end %  end function