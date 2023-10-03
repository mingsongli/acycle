udplotoptions % call udplotoptions.m to workspace

% plot dimensions in pixels
figw = 560;
axesl = 50;
axesw = 475;
if plotsar == 1
	figh = 700;
	axesb = [275, 46];
	axesh = [375, 215];
else
	figh = 460;
	axesb = 46;
	axesh = 400;
end

% convert pixel dimensions to relative units so plot can be resized
axesl = axesl / figw;
axesb = axesb ./ figh;
axesw = axesw / figw;
axesh = axesh ./ figh;

% center figure on primary monitor
scrnsze = get(0,'monitorPositions');
if size(scrnsze,1) > 1
	i = find(scrnsze(:,1) == 1);
else
	i = 1;
end
figl = (scrnsze(i,3)/2) - figw / 2;
figb = (scrnsze(i,4)/2) - figh / 2;

% plot age model
figure('position',[figl , figb , figw , figh])
h_age = axes('position',[axesl , axesb(1) , axesw , axesh(1)]);
hold(gca,'on')

			% // ---- paste from here into undatableGUI.m
% Plot density cloud
hcloud = gobjects(49,1);
for i = 1:49
	
	hi1sig=shadingmat(:,99-i);
	lo1sig=shadingmat(:,i);
	
	confx=[
		%right to left at top
		lo1sig(1); hi1sig(1);
		%down to bottom
		hi1sig(2:end);
		%left to right at bottom
		lo1sig(end);
		%up to top
		flipud(lo1sig(1:end-1))];
	
	confy=[
		%right to left at top
		depthrange(1,1); depthrange(1,1);
		%down to bottom
		depthrange(2:end,1);
		%left to right at bottom
		depthrange(end,1);
		%up to top
		flipud(depthrange(1:end-1,1))];
	
	hcloud(i) = patch(confx/1000,confy,[1-(i/49) 1-(i/49) 1-(i/49)],'edgecolor','none');
end
plot(summarymat(:,2)/1000,depthrange,'k--') % 95.4 range
plot(summarymat(:,5)/1000,depthrange,'k--') % 95.4 range
plot(summarymat(:,3)/1000,depthrange,'b--') % 68.2 range
plot(summarymat(:,4)/1000,depthrange,'b--') % 68.2 range

plot(summarymat(:,1)/1000,depthrange,'r')
set(gca,'ydir','reverse')

% PLOT PDFs
% Colour schemes
%                    1                   2                       3               4           5        6           7                8                9
datetypes = {'14C marine fossil'; '14C terrestrial fossil'; '14C sediment'; 'Tephra'; 'Tie point'; 'Other'; 'Palaeomagnetism'; 'Paleomagnetism'; 'U/Th'};
colours(:,:,1) = [41  128 185  ; 166 208 236]; % dark blue  ; light blue
colours(:,:,2) = [34  153 85   ; 166 219 175]; % dark green ; light green
colours(:,:,3) = [83  57  47   ; 191 156 145]; % dark brown ; light brown
colours(:,:,4) = [192 57  43   ; 228 148 139]; % dark red   ; light red
colours(:,:,5) = [254 194 0    ; 241 234 143]; % dark yellow; light yellow
colours(:,:,6) = [64  64  64   ; 160 160 160]; % dark grey  ; light grey
colours(:,:,7) = [201 106 18   ; 221 163 108]; % dark orange; light orange
colours(:,:,8) = [201 106 18   ; 221 163 108]; % dark orange; light orange
colours(:,:,9) = [131 39  147  ; 194 128 206]; % dark purple; light purple
colours = colours/255; % RGB to Matlab

d = ylim;
probscale = 0.015;
usedcolours = NaN(size(depth));

% set up order in which to plot dates so that a clould of bulk dates with large uncertainty doesn't obsure tephras etc.
plotorder = [];
plotorder = [plotorder; find(strcmpi(datetype,'14C sediment'))];
plotorder = [plotorder; find(strcmpi(datetype,'14C marine fossil'))];
plotorder = [plotorder; find(strcmpi(datetype,'14C terrestrial fossil'))];
plotorder = [plotorder; find(strcmpi(datetype,'tephra'))];
plotorder = [plotorder; find(strcmpi(datetype,'tie point'))];
plotorder = [plotorder; find(strcmpi(datetype,'other'))];
plotorder = [plotorder; find(strcmpi(datetype,'palaeomagnetism'))];
plotorder = [plotorder; find(strcmpi(datetype,'paleomagnetism'))];
plotorder = [plotorder; find(strcmpi(datetype,'u/th'))];
% in case user made a typo
ndepth = 1:length(depth);
typofields = ndepth(~ismember(ndepth,plotorder));
plotorder = [plotorder; typofields'];

for i = 1:length(depth)
	
	colourind = find(strcmpi(datetype{plotorder(i)},datetypes)==1);
	if isempty(colourind) == 1
		warning(['Date type "',datetype{plotorder(i)},'" unknown. Will use grey for plot colour.'])
		colourind = 6;
	end
	
	usedcolours(i) = colourind; % for legend later
	
	probnow = probtoplot{plotorder(i)};
	
	if ageerr(plotorder(i)) > 0
		
		% 2 sigma shading
		for j = 1:size(p95_4{plotorder(i)},1)
			probindtemp = probnow(probnow(:,1)>p95_4{plotorder(i)}(j,2) & probnow(:,1)<p95_4{plotorder(i)}(j,1),:);
			probx = [probindtemp(:,1)/1000; flipud(probindtemp(:,1)/1000)];
			proby = [probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
			patch(probx,proby,colours(2,:,colourind),'edgecolor','none');
		end
		
		% 1 sigma shading
		for j = 1:size(p68_2{plotorder(i)},1)
			probindtemp = probnow(probnow(:,1)>p68_2{plotorder(i)}(j,2) & probnow(:,1)<p68_2{plotorder(i)}(j,1),:);
			probx = [probindtemp(:,1)/1000; flipud(probindtemp(:,1)/1000)];
			proby = [probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probindtemp(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
			patch(probx,proby,colours(1,:,colourind),'edgecolor','none');
		end
		
		% Outline
		probx = [probnow(:,1)/1000; flipud(probnow(:,1)/1000)];
		proby = [probnow(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1); flipud(-1*probnow(:,2)*((d(2)*probscale)/max(probnow(:,2)))+depth(plotorder(i),1))];
		patch(probx,proby,[1 1 1],'edgecolor','k','facecolor','none','linewidth',.2);
		
	else
		plot(age(plotorder(i))/1000,depth(plotorder(i)),'kd','markeredgecolor',colours(1,:,colourind),'markerfacecolor',colours(1,:,colourind));
	end
	
end
plot(summarymat(:,1)/1000,depthrange,'r-') % median of age model runs (plot again on top of PDFs)
set(gca,'ydir','reverse','tickdir','out','fontsize',12,'box','on')
ylabel(depthlabel)
if plotsar == 0
	xlabel(agelabel)
end
grid on

% plot the depth error bars
for i = 1:length(depth)
	if depth1(i) <= depth2(i)
		plot( [medians(i)/1000 medians(i)/1000] , [depth1(i) depth2(i)], 'k-' )
	elseif depth1(i) > depth2(i)
		plot( [medians(i)/1000 medians(i)/1000] , [depth1(i)+depth2(i) depth1(i)-depth2(i)], 'k-' )
	end
end

set(gca, 'Layer', 'Top')

% title
if guimode == 0
	[~,NAME,~] = fileparts(inputfile);
	NAME = strrep(NAME,'.txt','');
	NAME = strrep(NAME,'_udinput','');
	NAME = strrep(NAME,'_','\_');
	title(NAME);
end

% plot all the agedepth runs (debug mode)
if debugme == 1
	for i = 1:size(agedepmat,3)
		plot(agedepmat(:,1,i)/1000,agedepmat(:,2,i),'r.','markersize',2)
		hold on
	end
end

% set paper size (cm)f
set(gcf,'PaperUnits','centimeters')
set(gcf, 'PaperSize',[plotwidth plotheight])
% put figure in top left of paper
set(gcf,'PaperPosition',[0 0 plotwidth plotheight])
% make background white
set(gcf,'InvertHardcopy','on');
set(gcf,'color',[1 1 1]);

% automatic legend (do last before printing so that it appears in the correct place)
usedcolours = unique(usedcolours);
txtxpos = min(xlim) + 0.97 * abs((max(xlim)-min(xlim)));
txtypos = min(ylim) + 0.03 * abs((max(ylim)-min(ylim)));
txtyinc = 0.04 * abs((max(ylim)-min(ylim)));
if length(usedcolours) > 1
	for i = 1:length(usedcolours)
		if i > 1; txtypos = txtypos + txtyinc; end
		h = text(txtxpos, txtypos, strrep(datetypes{usedcolours(i)},'14C','^1^4C'),'horizontalalignment','right','color',colours(1,:,usedcolours(i)));
		set(h,'fontweight','bold')
	end
end

% print the xfactor and bootpc to the bottom left corner
str = ['xfactor = ',num2str(xfactor,'%.2g'),newline,'bootpc = ',num2str(bootpc,'%.2g')];
settingtext = annotation('textbox',get(gca,'position'),'string',str);
set(settingtext,'linestyle','none')
set(settingtext,'horizontalalignment','left')
set(settingtext,'verticalalignment','bottom')

% set all fonts
set(findall(gcf,'-property','FontSize'),'FontSize',textsize)

				% ----/// paste to here into undatableGUI.m

% plot sediment accumulation rate
if plotsar == 1
	set(h_age,'xaxislocation','top');
	xlabel(agelabel)
	h_sar = axes('position',[axesl , axesb(2) , axesw , axesh(2)]);
	hold(gca,'on')
	if ~isempty(sarshadingmat)
		hcloud2 = gobjects(49,1);
		for i = 1:49
	
			hi1sig = sarshadingmat(:,99-i);
			lo1sig = sarshadingmat(:,i);
			
			confy = [
				%right to left at top
				lo1sig(1); hi1sig(1);
				%down to bottom
				hi1sig(2:end);
				%left to right at bottom
				lo1sig(end);
				%up to top
				flipud(lo1sig(1:end-1))];
			
			confx = [
				%right to left at top
				sarsummarymat(1,2)/1000; sarsummarymat(1,2)/1000;
				%down to bottom
				sarsummarymat(2:end,2)/1000;
				%left to right at bottom
				sarsummarymat(end,2)/1000;
				%up to top
				flipud(sarsummarymat(1:end-1,2))/1000];
			
			hcloud2(i) = patch(confx,confy,[1-(i/49) 1-(i/49) 1-(i/49)],'edgecolor','none');
		end
		stairs(sarsummarymat(:,2)/1000,sarsummarymat(:,4),'k--') % 95.4 range
		stairs(sarsummarymat(:,2)/1000,sarsummarymat(:,7),'k--') % 95.4 range
		stairs(sarsummarymat(:,2)/1000,sarsummarymat(:,5),'b--') % 68.2 range
		stairs(sarsummarymat(:,2)/1000,sarsummarymat(:,6),'b--') % 68.2 range
	end
	stairs(sarsummarymat(:,2)/1000,sarsummarymat(:,3),'r-') % modeled SAR
	set(gca,'xlim',get(h_age,'xlim'),'xtick',get(h_age,'xtick'),'xticklabel',get(h_age,'xticklabel'),'tickdir','out','box','on')
	xlabel(agelabel)
	ylabel(sarlabel)
	grid on

end
set(findall(gcf,'-property','FontSize'),'FontSize',textsize)

% print
if printme == 1
	if vcloud == 0 && plotsar == 1
		plot2raster(h_age, hcloud, 'bottom', 300);
		if ~isempty(sarshadingmat)
			plot2raster(h_sar, hcloud2, 'bottom', 300);
		end
	end
	savename = strrep(inputfile,'.txt','_admodel.pdf');
	[~,NAME,EXT] = fileparts(savename);
	savename = [NAME,EXT];
	savename = [writedir,savename];
	print(gcf, '-dpdf', '-painters', savename);
end