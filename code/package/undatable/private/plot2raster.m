function himg = plot2raster(axH, rastH, stacloc, rastres)
% plot2raster(axH, rastH, stacloc, resolution)
%
% Convert some plot element(s) in an axis to raster iamge, while keeping
% the other plot elements (lines, text, etc) as vector. Useful when saving
% a figure as a PDF and you don't want huge file size due to some surf plot
% (for example) saving as vector.
%
% Input variables
% --------------------------------
% axH     = Handle to the axis you want to work with (e.g., gca or whatever)
% rastH   = Handle of the plot (or gobjects array of plots) in axH that you want
%			rasterised. The vector versions of rastH will be made invisible.        
% stacloc = Where to place the rasterised plot in the stack. 'bottom' or 'top'
% rastres = Resolution of the rasterised plot in dpi.
%
% Output variable
% --------------------------------
% himg    = Output handle to the rasterised plot(s).
%
% B.C. Lougheed / bryan.lougheed@geo.uu.se / 2019-05-03 / R2017b
% Based on vecrast.m by T. Michelis on Matlab File Exchange

% Ensure figure has finished drawing
%drawnow;
xlims = get(axH,'xlim');
ylims = get(axH,'ylim');

% create a temporary invisible figure of perfect size for the raster stuff
axpos = getpixelposition(axH); % get original axis pixel position
rastfig = figure('position', axpos, 'visible', 'off'); % open new invisible figure window exact same position as original axis
pasteax = copyobj(axH, rastfig); % temp axis for pasting
cla % clear it
% Copy the desired rastH object(s) into the temporary invisible figure
for i = 1:numel(rastH)
	copyobj(rastH(i), pasteax);
end
set(pasteax,'position',[0 0 1 1]) % fill axis to the full figure window
axis off % turn off lines and tick marks
title('')
set(pasteax,'xlim',xlims);
set(pasteax,'ylim',ylims);
filename = ['_plot2rastertemp',num2str(round(rand*10^10)),'.png']; % save png file. unique name in case running in parrallel
print(rastfig, filename, '-dpng', ['-r',num2str(rastres)]);
close(rastfig) % close raster figure window

% Now disable the vector plot objects in the original axH
set(rastH,'visible','off')

% Insert the PNG file into ghost axis underneath the original axis
figure(get(axH,'parent')) % back to the original figure
ghostax = axes('position',get(axH,'position'));
[A, ~, alpha] = imread(filename);
himg = image(xlims, ylims, A);
if isempty(alpha) == 0
 	set(himg, 'alphaData', alpha);
end
uistack(ghostax, stacloc);
set(ghostax,'xlim',xlims);
set(ghostax,'ylim',ylims);
axis off
if strcmpi(stacloc,'bottom') == 1
	set(axH,'color','none') % make the original axis transparent so that the png file shows through
end
delete(filename); % delete the temp file
set(axH,'xlim',xlims);
set(axH,'ylim',ylims);
figure(get(axH,'parent')) % go back to the main figure

