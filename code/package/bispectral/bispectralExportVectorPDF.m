function bispectralExportVectorPDF(fig,pdfPath)
%BISPECTRALEXPORTVECTORPDF Export a strictly vector bispectral PDF.
%   The interactive figure and FIG archive retain their interpolated PCOLOR
%   surfaces. A private figure copy is converted to filled vector contours
%   and patch-based colorbars solely for PDF export. The completed PDF is
%   rejected if its object dictionaries still contain an Image XObject.

if isempty(fig) || ~isgraphics(fig,'figure')
    error('Acycle:Bispectral:InvalidFigure', ...
        'A valid figure is required for vector PDF export.');
end
if ~(ischar(pdfPath) || (isstring(pdfPath) && isscalar(pdfPath)))
    error('Acycle:Bispectral:InvalidPDFPath', ...
        'The PDF path must be a character vector or string scalar.');
end
pdfPath = char(pdfPath);
[pdfDirectory,~,extension] = fileparts(pdfPath);
if ~strcmpi(extension,'.pdf')
    error('Acycle:Bispectral:InvalidPDFPath', ...
        'The vector export path must end in .pdf.');
end
if ~isempty(pdfDirectory) && ~isfolder(pdfDirectory)
    error('Acycle:Bispectral:MissingPDFDirectory', ...
        'The PDF output directory does not exist: %s',pdfDirectory);
end

exportFigure = copyobj(fig,groot);
if isempty(exportFigure) || ~isgraphics(exportFigure,'figure')
    error('Acycle:Bispectral:CopyFigureForExport', ...
        'MATLAB could not create the private vector-export figure.');
end
figureCleanup = onCleanup(@()deleteExportFigure(exportFigure));
exportFigure.Visible = 'off';
exportFigure.SizeChangedFcn = [];
if isappdata(exportFigure,'BispectralLayoutReady')
    setappdata(exportFigure,'BispectralLayoutReady',false);
end
drawnow nocallbacks

mapAxes = replaceMapSurfaces(exportFigure);
replaceColorbars(exportFigure,mapAxes);
drawnow nocallbacks

warningIdentifier = 'MATLAB:print:ContentTypeImageSuggested';
warningState = warning('query',warningIdentifier);
warningCleanup = onCleanup(@()warning(warningState));
warning('off',warningIdentifier);
exportgraphics(exportFigure,pdfPath,'ContentType','vector');
clear warningCleanup

if ~isfile(pdfPath) || dir(pdfPath).bytes == 0
    error('Acycle:Bispectral:EmptyVectorPDF', ...
        'MATLAB did not create a nonempty vector PDF: %s',pdfPath);
end
assertNoImageXObject(pdfPath);
deleteExportFigure(exportFigure);
clear figureCleanup
end

function mapAxes = replaceMapSurfaces(fig)
surfaces = findall(fig,'Type','surface','Tag','bispectralColorSurface');
mapAxes = gobjects(0,1);
for surfaceIndex = 1:numel(surfaces)
    surfaceHandle = surfaces(surfaceIndex);
    ax = ancestor(surfaceHandle,'axes');
    if isempty(ax) || ~isgraphics(ax,'axes')
        continue
    end
    if isempty(mapAxes) || ~any(mapAxes == ax)
        mapAxes(end+1,1) = ax; %#ok<AGROW>
    end

    x = double(surfaceHandle.XData);
    y = double(surfaceHandle.YData);
    z = double(surfaceHandle.CData);
    alpha = surfaceHandle.AlphaData;
    if isnumeric(alpha)
        if isscalar(alpha)
            if ~(isfinite(alpha) && alpha > 0)
                z(:) = NaN;
            end
        elseif isequal(size(alpha),size(z))
            z(~isfinite(alpha) | alpha <= 0) = NaN;
        end
    end

    colorLimits = clim(ax);
    colorCount = size(colormap(ax),1);
    levels = linspace(colorLimits(1),colorLimits(2),colorCount+1);
    xLimits = xlim(ax);
    yLimits = ylim(ax);
    aspectRatio = ax.PlotBoxAspectRatio;
    aspectMode = ax.PlotBoxAspectRatioMode;
    wasHeld = ishold(ax);
    hold(ax,'on');
    vectorMap = [];
    if any(isfinite(z(:)))
        [~,vectorMap] = contourf(ax,x,y,z,levels, ...
            'LineStyle','none','HandleVisibility','off');
        vectorMap.Tag = 'bispectralVectorColorMap';
    end
    delete(surfaceHandle);
    if ~isempty(vectorMap) && isgraphics(vectorMap)
        uistack(vectorMap,'bottom');
    end
    xlim(ax,xLimits);
    ylim(ax,yLimits);
    clim(ax,colorLimits);
    ax.PlotBoxAspectRatio = aspectRatio;
    ax.PlotBoxAspectRatioMode = aspectMode;
    if ~wasHeld
        hold(ax,'off');
    end
end
end

function replaceColorbars(fig,mapAxes)
colorbars = findall(fig,'Type','colorbar','Tag','bispectralColorbar');
if isempty(colorbars)
    return
end

% Deleting a MATLAB colorbar can expand its peer axes. Record every axes
% position first and restore it after all native colorbars are removed.
axesHandles = findall(fig,'Type','axes');
axesPositions = cell(numel(axesHandles),1);
for axisIndex = 1:numel(axesHandles)
    axesHandles(axisIndex).Units = 'normalized';
    axesPositions{axisIndex} = axesHandles(axisIndex).Position;
end

records = repmat(emptyColorbarRecord(),numel(colorbars),1);
for colorbarIndex = 1:numel(colorbars)
    cb = colorbars(colorbarIndex);
    cb.Units = 'normalized';
    records(colorbarIndex) = captureColorbar(cb,mapAxes);
end
delete(colorbars);
for axisIndex = 1:numel(axesHandles)
    if isgraphics(axesHandles(axisIndex),'axes')
        axesHandles(axisIndex).Position = axesPositions{axisIndex};
    end
end
for colorbarIndex = 1:numel(records)
    drawVectorColorbar(fig,records(colorbarIndex));
end
end

function record = emptyColorbarRecord()
record = struct('Position',[0 0 1 0.03],'Limits',[0 1], ...
    'Ticks',[],'TickLabels',{{}},'TickLabelInterpreter','tex', ...
    'FontName','Helvetica','FontSize',10,'Color',[0.15 0.15 0.15], ...
    'LineWidth',0.5,'TickDirection','out','LabelString','', ...
    'LabelInterpreter','tex','LabelFontName','Helvetica', ...
    'LabelFontSize',10,'Colormap',gray(2));
end

function record = captureColorbar(cb,mapAxes)
record = emptyColorbarRecord();
record.Position = cb.Position;
record.Limits = cb.Limits;
record.Ticks = cb.Ticks;
record.TickLabels = normalizeTickLabels(cb.TickLabels);
record.TickLabelInterpreter = cb.TickLabelInterpreter;
record.FontName = cb.FontName;
record.FontSize = max(6,cb.FontSize);
record.Color = cb.Color;
record.LineWidth = cb.LineWidth;
record.TickDirection = cb.TickDirection;
record.LabelString = cb.Label.String;
record.LabelInterpreter = cb.Label.Interpreter;
record.LabelFontName = cb.Label.FontName;
record.LabelFontSize = max(6,cb.Label.FontSize);
record.Colormap = matchingColormap(record.Position,mapAxes);
end

function labels = normalizeTickLabels(labels)
if ischar(labels)
    labels = cellstr(labels);
elseif isstring(labels)
    labels = cellstr(labels(:));
elseif isempty(labels)
    labels = {};
end
end

function map = matchingColormap(colorbarPosition,mapAxes)
if isempty(mapAxes)
    map = gray(32);
    return
end
barCenter = colorbarPosition(1)+colorbarPosition(3)/2;
distances = inf(numel(mapAxes),1);
for axisIndex = 1:numel(mapAxes)
    if isgraphics(mapAxes(axisIndex),'axes')
        mapAxes(axisIndex).Units = 'normalized';
        position = mapAxes(axisIndex).Position;
        distances(axisIndex) = abs(barCenter-(position(1)+position(3)/2));
    end
end
[~,nearest] = min(distances);
map = colormap(mapAxes(nearest));
end

function drawVectorColorbar(fig,record)
ax = axes(fig,'Units','normalized','Position',record.Position, ...
    'Tag','bispectralVectorColorbar','Color','none', ...
    'FontUnits','points','FontName',record.FontName, ...
    'FontSize',record.FontSize,'XColor',record.Color, ...
    'YColor',record.Color,'LineWidth',record.LineWidth, ...
    'TickDir',record.TickDirection,'Box','on','Layer','top', ...
    'XAxisLocation','bottom','YTick',[],'YTickLabel',{});
hold(ax,'on');
edges = linspace(record.Limits(1),record.Limits(2), ...
    size(record.Colormap,1)+1);
for colorIndex = 1:size(record.Colormap,1)
    patch(ax,edges([colorIndex colorIndex+1 colorIndex+1 colorIndex]), ...
        [0 0 1 1],record.Colormap(colorIndex,:), ...
        'EdgeColor','none','HandleVisibility','off', ...
        'HitTest','off','PickableParts','none');
end
xlim(ax,record.Limits);
ylim(ax,[0 1]);
ax.XTick = record.Ticks;
if ~isempty(record.TickLabels)
    ax.XTickLabel = record.TickLabels;
end
ax.TickLabelInterpreter = record.TickLabelInterpreter;
text(ax,-0.025,0.5,record.LabelString,'Units','normalized', ...
    'HorizontalAlignment','right','VerticalAlignment','middle', ...
    'Rotation',0,'FontUnits','points','FontName',record.LabelFontName, ...
    'FontSize',record.LabelFontSize, ...
    'Interpreter',record.LabelInterpreter,'Clipping','off', ...
    'HitTest','off','PickableParts','none','HandleVisibility','off', ...
    'Tag','bispectralVectorColorbarLabel');
end

function assertNoImageXObject(pdfPath)
fileId = fopen(pdfPath,'r');
if fileId < 0
    error('Acycle:Bispectral:ReadVectorPDF', ...
        'Could not inspect the exported PDF: %s',pdfPath);
end
fileCleanup = onCleanup(@()fclose(fileId));
bytes = fread(fileId,Inf,'*uint8')';
clear fileCleanup
pdfText = char(bytes);
if ~isempty(regexp(pdfText,'/Subtype\s*/Image\b','once'))
    error('Acycle:Bispectral:RasterContentInVectorPDF', ...
        ['The PDF still contains an Image XObject. The result was not ', ...
         'accepted as a strictly vector figure: %s'],pdfPath);
end
end

function deleteExportFigure(fig)
if ~isempty(fig) && isgraphics(fig,'figure')
    delete(fig);
end
end
