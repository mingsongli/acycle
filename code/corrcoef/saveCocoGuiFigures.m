function [saved,publication] = saveCocoGuiFigures(figures,dataFile,varargin)
%SAVECOCOGUIFIGURES Save GUI figures and an optional 88-mm COCO PDF.
%
% Figure names use the data-workbook stem, so their run number stays aligned
% with the numerical output. A COCO run saves only its main tabbed figure as
% FIG/PDF plus one compact 88-mm correlation PDF. eCOCO retains its existing
% behavior of saving every supplied result figure as FIG/PDF.

validateattributes(dataFile,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'dataFile',2);
parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'CocoPublicationTitle','',@(x) ...
    ischar(x) || (isstring(x) && isscalar(x)));
parse(parser,varargin{:});
publicationTitle = strtrim(char(string( ...
    parser.Results.CocoPublicationTitle)));
dataFile = char(string(dataFile));
figures = figures(:);
figures = figures(isgraphics(figures,'figure'));
publication = emptyPublicationResult();
if isempty(figures)
    saved = struct('fig',{},'pdf',{});
    warning('saveCocoGuiFigures:NoFigures', ...
        'The calculation completed, but no result figure was available to save.');
    return
end

% Freeze every currently valid source figure before beginning any of the
% potentially slow PDF exports.  In particular, do not return to a visible
% COCO/eCOCO result window after saving another figure: the user may close
% it as soon as the calculation appears to have finished.
[snapshotFiles,snapshotFolder] = snapshotSourceFigures(figures);
snapshotFolderCleanup = onCleanup(@()removeSnapshotFolder(snapshotFolder));
snapshotFigures = openSnapshotFigures(snapshotFiles);
snapshotFigureCleanup = onCleanup(@()closeFiguresIfValid(snapshotFigures));
cleanSnapshotCloseProtection(snapshotFigures);

if ~isempty(publicationTitle)
    % A COCO calculation may leave auxiliary figures open. The requested
    % four-file output contract keeps only the figure that owns the
    % Correlation and significance page.
    correlationLayout = findCorrelationLayout(snapshotFigures);
    figures = ancestor(correlationLayout,'figure');
else
    figures = orderStandaloneFigures(snapshotFigures);
end
saved = repmat(struct('fig','','pdf',''),numel(figures),1);

[folder,stem] = fileparts(dataFile);
for figureIndex = 1:numel(figures)
    sourceFigure = figures(figureIndex);
    suffix = figureSuffix(sourceFigure,figureIndex);
    outputStem = fullfile(folder,[stem,suffix]);
    figFile = [outputStem,'.fig'];
    pdfFile = [outputStem,'.pdf'];
    savefig(sourceFigure,figFile);
    exportVectorPdf(sourceFigure,pdfFile);
    saved(figureIndex).fig = figFile;
    saved(figureIndex).pdf = pdfFile;
end
if ~isempty(publicationTitle)
    publication = exportCocoPublicationFigure( ...
        figures,dataFile,publicationTitle);
end
end

function [snapshotFiles,snapshotFolder] = snapshotSourceFigures(figures)
snapshotFolder = tempname;
[folderCreated,message] = mkdir(snapshotFolder);
if ~folderCreated
    error('saveCocoGuiFigures:SnapshotFolderCreationFailed', ...
        'Could not create a temporary figure-snapshot folder (%s).', ...
        message);
end
snapshotFiles = cell(numel(figures),1);
try
    for figureIndex = 1:numel(figures)
        sourceFigure = figures(figureIndex);
        if ~isgraphics(sourceFigure,'figure')
            error('saveCocoGuiFigures:SourceFigureDeleted', ...
                'Result figure %d was closed before it could be snapshotted.', ...
                figureIndex);
        end
        snapshotFiles{figureIndex} = fullfile(snapshotFolder, ...
            sprintf('source-figure-%d.fig',figureIndex));
        savefig(sourceFigure,snapshotFiles{figureIndex});
    end
catch exception
    removeSnapshotFolder(snapshotFolder);
    rethrow(exception);
end
end

function figures = openSnapshotFigures(snapshotFiles)
figures = gobjects(numel(snapshotFiles),1);
try
    for figureIndex = 1:numel(snapshotFiles)
        figures(figureIndex) = openfig( ...
            snapshotFiles{figureIndex},'invisible');
    end
catch exception
    closeFiguresIfValid(figures);
    rethrow(exception);
end
end

function cleanSnapshotCloseProtection(figures)
originalCallbackKey = 'AcycleCOCOSaveOriginalCloseRequestFcn';
protectionKey = 'AcycleCOCOSaveCloseProtected';
for figureIndex = 1:numel(figures)
    snapshotFigure = figures(figureIndex);
    if isappdata(snapshotFigure,originalCallbackKey)
        originalCallback = getappdata( ...
            snapshotFigure,originalCallbackKey);
        set(snapshotFigure,'CloseRequestFcn',originalCallback);
        rmappdata(snapshotFigure,originalCallbackKey);
    end
    if isappdata(snapshotFigure,protectionKey)
        rmappdata(snapshotFigure,protectionKey);
    end
end
end

function closeFiguresIfValid(figures)
for figureIndex = 1:numel(figures)
    closeIfValid(figures(figureIndex));
end
end

function removeSnapshotFolder(snapshotFolder)
try
    if isfolder(snapshotFolder)
        rmdir(snapshotFolder,'s');
    end
catch
end
end

function figures = orderStandaloneFigures(figures)
% FINDALL returns newly created figures in graphics-stack order, which can
% place the separately created ridge figure before the four-map overview.
% Keep the overview on the workbook stem and give ridge figures their
% explicit suffix regardless of that transient creation-stack order.
if numel(figures) < 2
    return
end
names = lower(string(arrayfun(@(fig)get(fig,'Name'),figures, ...
    'UniformOutput',false)));
isRidge = contains(names,'ridge score');
[~,order] = sort(isRidge,'ascend');
figures = figures(order);
end

function result = emptyPublicationResult()
result = struct('fig','','pdf','','png','', ...
    'widthMillimeters',NaN,'heightMillimeters',NaN);
end

function result = exportCocoPublicationFigure(figures,dataFile,titleText)
targetWidthCm = 8.8;
targetHeightCm = 11.74;
sourceLayout = findCorrelationLayout(figures);

outputFigure = figure('Visible','off','Color','white', ...
    'Units','centimeters', ...
    'Position',[1 1 targetWidthCm targetHeightCm], ...
    'InvertHardcopy','off');
cleanup = onCleanup(@()closeIfValid(outputFigure));
outputLayout = copyobj(sourceLayout,outputFigure);
formatHalfColumnLayout(outputLayout,titleText);
validatePanelOrder(outputLayout);

set(outputFigure,'PaperUnits','centimeters', ...
    'PaperPosition',[0 0 targetWidthCm targetHeightCm], ...
    'PaperSize',[targetWidthCm targetHeightCm], ...
    'PaperPositionMode','manual');
drawnow;

[folder,stem] = fileparts(dataFile);
outputStem = fullfile(folder, ...
    [stem,'-correlation']);
pdfFile = [outputStem,'.pdf'];
print(outputFigure,pdfFile,'-dpdf','-vector');
setPdfMediaBoxMillimeters( ...
    pdfFile,10*targetWidthCm,10*targetHeightCm);

result = struct('fig','','pdf',pdfFile,'png','', ...
    'widthMillimeters',10*targetWidthCm, ...
    'heightMillimeters',10*targetHeightCm);
end

function setPdfMediaBoxMillimeters(pdfFile,widthMm,heightMm)
setPdfBoxMillimeters(pdfFile,'MediaBox',widthMm,heightMm,true);
% MATLAB PRINT commonly emits an explicit integer CropBox. PDF viewers use
% it in preference to MediaBox, so both boxes must carry the exact size.
setPdfBoxMillimeters(pdfFile,'CropBox',widthMm,heightMm,false);
end

function setPdfBoxMillimeters( ...
        pdfFile,boxName,widthMm,heightMm,isRequired)
fileId = fopen(pdfFile,'r');
if fileId < 0
    error('saveCocoGuiFigures:PdfReadFailed', ...
        'Could not open the publication PDF for size verification.');
end
readCleanup = onCleanup(@()fclose(fileId));
pdfBytes = fread(fileId,Inf,'*uint8');
clear readCleanup
pdfText = char(pdfBytes(:)');
numberPattern = '[-+]?(?:\d+\.?\d*|\.\d+)';
boxPattern = [ ...
    '(/',boxName,'\s*\[\s*',numberPattern,'\s+',numberPattern,'\s+)', ...
    '(',numberPattern,')(\s+)(',numberPattern,')(\s*\])'];
matchStart = regexp(pdfText,boxPattern,'start','once');
matchText = regexp(pdfText,boxPattern,'match','once');
tokens = regexp(matchText,boxPattern,'tokens','once');
if isempty(matchStart) || isempty(tokens) || numel(tokens) ~= 5
    if ~isRequired
        return
    end
    error('saveCocoGuiFigures:PdfPageBoxMissing', ...
        'The publication PDF does not contain one readable %s.',boxName);
end

widthPoints = widthMm*72/25.4;
heightPoints = heightMm*72/25.4;
widthText = sprintf('%.6f',widthPoints);
heightText = sprintf('%.6f',heightPoints);
replacement = [tokens{1},widthText,tokens{3},heightText,tokens{5}];
byteDelta = numel(replacement)-numel(matchText);

% PRINT may serialize MediaBox dimensions either as decimals or as rounded
% integers. When the exact millimetre values need more characters, grow the
% MediaBox and shift every affected traditional PDF cross-reference offset.
% Xref entries are fixed-width ten-digit fields, so their updates do not
% introduce any additional byte displacement.
if byteDelta ~= 0
    mediaBoxByteOffset = matchStart-1;
    xrefEntryStart = regexp(pdfText, ...
        '(?m)^[0-9]{10} [0-9]{5} n','start');
    if isempty(xrefEntryStart)
        error('saveCocoGuiFigures:PdfCrossReferenceMissing', ...
            ['The publication PDF needs a larger %s field, but no ', ...
             'traditional cross-reference table was found.'],boxName);
    end
    for entryIndex = 1:numel(xrefEntryStart)
        entryStart = xrefEntryStart(entryIndex);
        oldOffset = str2double(pdfText(entryStart:entryStart+9));
        if isfinite(oldOffset) && oldOffset > mediaBoxByteOffset
            newOffsetText = sprintf('%010d',oldOffset+byteDelta);
            if numel(newOffsetText) ~= 10
                error('saveCocoGuiFigures:PdfCrossReferenceOverflow', ...
                    'A PDF cross-reference offset exceeded ten digits.');
            end
            pdfText(entryStart:entryStart+9) = newOffsetText;
        end
    end
    [~,~,startXrefExtent] = regexp(pdfText, ...
        'startxref\s+([0-9]+)','start','end','tokenExtents');
    if isempty(startXrefExtent)
        error('saveCocoGuiFigures:PdfStartXrefMissing', ...
            'The publication PDF has no readable startxref pointer.');
    end
    xrefNumberStart = startXrefExtent{end}(1);
    xrefNumberEnd = startXrefExtent{end}(2);
    oldXrefOffset = str2double( ...
        pdfText(xrefNumberStart:xrefNumberEnd));
    if oldXrefOffset > mediaBoxByteOffset
        newXrefOffset = num2str(oldXrefOffset+byteDelta,'%d');
        pdfText = [pdfText(1:xrefNumberStart-1),newXrefOffset, ...
            pdfText(xrefNumberEnd+1:end)];
    end
end

pdfText = [pdfText(1:matchStart-1),replacement, ...
    pdfText(matchStart+numel(matchText):end)];
fileId = fopen(pdfFile,'w');
if fileId < 0
    error('saveCocoGuiFigures:PdfWriteFailed', ...
        'Could not rewrite the publication PDF with its exact page size.');
end
writeCleanup = onCleanup(@()fclose(fileId));
if fwrite(fileId,uint8(pdfText),'uint8') ~= numel(pdfText)
    error('saveCocoGuiFigures:PdfWriteFailed', ...
        'Could not set the publication PDF to its exact page size.');
end
end

function layout = findCorrelationLayout(figures)
for figureIndex = 1:numel(figures)
    tabs = findall(figures(figureIndex),'Type','uitab');
    for tabIndex = 1:numel(tabs)
        if strcmpi(strtrim(char(string(tabs(tabIndex).Title))), ...
                'Correlation and significance')
            candidates = findall(tabs(tabIndex),'-isa', ...
                'matlab.graphics.layout.TiledChartLayout');
            if isscalar(candidates)
                layout = candidates(1);
                return
            end
        end
    end

    correlationAxis = findall(figures(figureIndex),'Type','axes', ...
        '-regexp','Tag','(?i)(?:^|-)COCO-correlation$');
    if isempty(correlationAxis)
        correlationAxis = findall(figures(figureIndex),'Type','axes', ...
            '-regexp','Tag','(?i)cvCOCO-correlation$');
    end
    if isscalar(correlationAxis) && ...
            isa(correlationAxis.Parent, ...
            'matlab.graphics.layout.TiledChartLayout')
        layout = correlationAxis.Parent;
        return
    end
end
error('saveCocoGuiFigures:CorrelationPageMissing', ...
    ['The COCO run did not create one four-panel ', ...
     'Correlation and significance page.']);
end

function formatHalfColumnLayout(layout,titleText)
layout.Padding = 'compact';
layout.TileSpacing = 'compact';
% Keep the method and panel names as graphics metadata for programmatic
% inspection, but do not draw them in the compact publication plate.  The
% four outside panel letters are the only visible headings.
layout.Title.String = titleText;
layout.Title.Visible = 'off';
layout.Title.FontSize = 9;
layout.Title.FontWeight = 'bold';

axesHandles = findall(layout,'Type','axes');
for axisIndex = 1:numel(axesHandles)
    ax = axesHandles(axisIndex);
    ax.FontSize = 7.5;
    ax.Title.Visible = 'off';
    ax.Title.FontSize = 8.5;
    ax.Title.FontWeight = 'bold';
    ax.XLabel.FontSize = 8;
    ax.YLabel.FontSize = 8;
end
legendHandles = findall(layout,'Type','legend');
for legendIndex = 1:numel(legendHandles)
    legendHandles(legendIndex).FontSize = 0.75*7;
end

formatCvCocoContent(layout);
addPanelLabels(layout);
end

function formatCvCocoContent(layout)
axesHandles = findall(layout,'Type','axes');
for axisIndex = 1:numel(axesHandles)
    ax = axesHandles(axisIndex);
    tag = lower(char(string(ax.Tag)));
    isLocalPanel = contains(tag,'local-p');
    isProbabilityPanel = contains(tag,'global-p') || isLocalPanel;
    lines = findall(ax,'Type','line');
    for lineIndex = 1:numel(lines)
        lineHandle = lines(lineIndex);
        displayName = char(string(lineHandle.DisplayName));
        if isLocalPanel
            displayName = regexprep( ...
                displayName,'^\s*local\s+','','ignorecase');
        end
        if ~isProbabilityPanel && ...
                (strcmpi(strtrim(displayName),'Consensus') || ...
                contains(lower(char(string(lineHandle.Tag))), ...
                'correlation-consensus'))
            displayName = 'Cons.';
        end
        if isProbabilityPanel
            displayName = formatProbabilityLabel(displayName);
        end
        lineHandle.DisplayName = displayName;

        lineTag = lower(char(string(lineHandle.Tag)));
        if isBlack(lineHandle.Color) && contains(lineTag,'consensus')
            lineHandle.LineWidth = 1.2;
        end
        if isBlack(lineHandle.Color) && ...
                ~strcmpi(char(string(lineHandle.Marker)),'none')
            lineHandle.MarkerSize = 2.5;
        end
    end
end
end

function addPanelLabels(layout)
axesHandles = findall(layout,'Type','axes');
tiles = arrayfun(@(ax)ax.Layout.Tile,axesHandles);
[~,order] = sort(tiles);
axesHandles = axesHandles(order);
drawnow;
labelX = publicationPanelLabelX(axesHandles);
panelLabels = 'ABCD';
for panelIndex = 1:min(numel(axesHandles),numel(panelLabels))
    ax = axesHandles(panelIndex);
    text(ax,labelX,1.02,panelLabels(panelIndex), ...
        'Units','normalized', ...
        'HorizontalAlignment','left', ...
        'VerticalAlignment','bottom', ...
        'FontName',layout.Title.FontName, ...
        'FontSize',layout.Title.FontSize, ...
        'FontWeight',layout.Title.FontWeight, ...
        'Color','black', ...
        'Clipping','off', ...
        'Tag','COCO-publication-panel-label');
end
end

function labelX = publicationPanelLabelX(axesHandles)
% Align A-D near the leftmost edge of the four y labels.  YLabel extents
% are measured in normalized axes coordinates so one shared x coordinate
% remains correct for every row of the four-panel column.
labelX = -0.12;
for axisIndex = 1:numel(axesHandles)
    yLabel = axesHandles(axisIndex).YLabel;
    originalUnits = yLabel.Units;
    yLabel.Units = 'normalized';
    extent = yLabel.Extent;
    yLabel.Units = originalUnits;
    if numel(extent) >= 4 && all(isfinite(extent))
        labelX = min(labelX,extent(1));
    end
end
end

function tf = isBlack(color)
tf = isnumeric(color) && numel(color) == 3 && ...
    all(abs(double(color(:)')-[0 0 0]) < 1e-12);
end

function label = formatProbabilityLabel(label)
parts = regexp(label, ...
    '^(.*=)([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)$', ...
    'tokens','once');
if isempty(parts)
    return
end
value = str2double(parts{2});
if ~isfinite(value)
    return
end
label = [parts{1},formatProbability4(value)];
end

function textValue = formatProbability4(value)
textValue = sprintf('%.4f',value);
end

function validatePanelOrder(layout)
axesHandles = findall(layout,'Type','axes');
if numel(axesHandles) ~= 4
    error('saveCocoGuiFigures:UnexpectedPanelCount', ...
        'The publication COCO figure must contain exactly four axes.');
end
tiles = arrayfun(@(ax)ax.Layout.Tile,axesHandles);
[~,order] = sort(tiles);
tags = lower(string({axesHandles(order).Tag}));
expected = {'correlation','global-p','local-p','orbit-count'};
for panelIndex = 1:numel(expected)
    if ~contains(tags(panelIndex),expected{panelIndex})
        error('saveCocoGuiFigures:UnexpectedPanelOrder', ...
            'COCO panel %d is not %s.',panelIndex,expected{panelIndex});
    end
end
end

function suffix = figureSuffix(fig,index)
if index == 1
    suffix = '';
    return
end
name = lower(strtrim(char(string(get(fig,'Name')))));
if contains(name,'ridge score')
    suffix = '-Ridge-score';
else
    suffix = sprintf('-figure-%d',index);
end
end

function exportVectorPdf(fig,pdfFile)
tabs = findall(fig,'Type','uitab');
if ~isempty(tabs)
    exportTabbedVectorPdf(flipud(tabs(:)),pdfFile);
    return
end
exportStandaloneVectorPdf(fig,pdfFile);
end

function exportTabbedVectorPdf(tabs,pdfFile)
pageNumber = 0;
for tabIndex = 1:numel(tabs)
    children = flipud(tabs(tabIndex).Children(:));
    children = children(isgraphics(children));
    if isempty(children)
        continue
    end
    exportTarget = tabs(tabIndex);
    % Do not dispatch queued GUI callbacks while ONRUN is still exporting.
    % In particular, a queued second OK click or CloseRequestFcn must not
    % re-enter/destroy eCOCOGUI halfway through this page-export loop.
    drawnow limitrate nocallbacks;
    pageNumber = pageNumber+1;
    arguments = {'ContentType','vector','BackgroundColor','white'};
    if pageNumber > 1
        arguments = [arguments,{'Append',true}]; %#ok<AGROW>
    end
    % Export the existing tab container directly. This preserves layouts,
    % legends, and colorbars even if a reopened FIG stores them as multiple
    % top-level objects. Reparenting copied axes/cameras through COPYOBJ can
    % corrupt MATLAB's SceneTree for Interleaved cvCOCO and emit
    % replaceCamera/replaceChild warnings.
    exportgraphics(exportTarget,pdfFile,arguments{:});
end
if pageNumber == 0
    error('saveCocoGuiFigures:NoExportablePages', ...
        'The tabbed result figure contains no exportable plot pages.');
end
end

function exportStandaloneVectorPdf(fig,pdfFile)
position = getpixelposition(fig);
aspect = position(4)/max(position(3),1);
widthCm = 17.95;
heightCm = max(1,widthCm*aspect);
contentScale = 0.95;
groupedContentScale = getappdata(fig,'eCOCOGroupedContentScale');
if isnumeric(groupedContentScale) && isscalar(groupedContentScale) && ...
        isfinite(groupedContentScale) && ...
        abs(groupedContentScale-0.95) <= 64*eps
    % Current eCOCO grouped figures already own their 95% inset in
    % ECOCOPLOT. Do not apply the same scale again during export. Older
    % standalone FIG files have no marker and retain the compatible
    % export-time 95% inset below.
    contentScale = 1;
end
horizontalMarginCm = 0.5*(1-contentScale)*widthCm;
verticalMarginCm = 0.5*(1-contentScale)*heightCm;
set(fig,'PaperUnits','centimeters', ...
    'PaperPosition',[ ...
        horizontalMarginCm,verticalMarginCm, ...
        contentScale*widthCm,contentScale*heightCm], ...
    'PaperSize',[widthCm,heightCm], ...
    'PaperPositionMode','manual', ...
    'InvertHardcopy','off');
try
    % Retain the editable vector path. Legacy standalone figures are
    % centered at 95% of their former size here; current grouped eCOCO
    % figures already carry that inset in their low-level plot geometry.
    print(fig,pdfFile,'-dpdf','-vector','-r600');
catch printException
    try
        exportgraphics(fig,pdfFile,'ContentType','vector', ...
            'BackgroundColor','white');
    catch exportException
        error('saveCocoGuiFigures:PdfExportFailed', ...
            'Could not save vector PDF (%s; fallback: %s).', ...
            printException.message,exportException.message);
    end
end
end

function closeIfValid(fig)
% DELETE bypasses user/global CloseRequestFcn callbacks. Cleanup of a
% private hidden export figure is unconditional and must never make an
% otherwise successful FIG/PDF export report failure.
try
    if isgraphics(fig,'figure')
        delete(fig);
    end
catch
end
end
