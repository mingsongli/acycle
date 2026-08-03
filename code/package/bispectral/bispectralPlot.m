function [fig,plotHandles] = bispectralPlot(result,varargin)
%BISPECTRALPLOT Publication-style Acycle bispectral figure.
%   BISPECTRALPLOT(RESULT) makes an overview with two aligned log-power
%   spectra above bispectrum magnitude and squared bicoherence.
%   All colored results are rendered with PCOLOR on an explicit frequency
%   mesh, interpolated shading, and a fixed 1:1 x/y axis ratio.

legacyKeepFraction = resultOption(result,'PlotKeepStrongestFraction',0.2);
settings = struct( ...
    'Quantity',result.Options.PlotQuantity, ...
    'KeepStrongestFraction',[], ...
    'BispectrumKeepStrongestFraction',resultOption(result, ...
        'PlotKeepStrongestBispectrumFraction',legacyKeepFraction), ...
    'BicoherenceKeepStrongestFraction',resultOption(result, ...
        'PlotKeepStrongestBicoherenceFraction',legacyKeepFraction), ...
    'ColorGrid',resultOption(result,'PlotColorGrid',32), ...
    'FrequencyMinimum',resultOption(result,'FrequencyMin',0), ...
    'FrequencyMaximum',resultOption(result,'FrequencyMax',[]), ...
    'ReferencePeriods',resultOption(result,'PlotReferencePeriods',[]), ...
    'FrequencyPairs',resultOption(result,'PlotFrequencyPairs',zeros(0,2)), ...
    'ShowPeriodAxes',result.Options.ShowPeriodAxes, ...
    'PeakCount',result.Options.PlotPeakCount, ...
    'ShowSignificance',true, ...
    'Title','', ...
    'Visible','on');
settings = parseSettings(settings,varargin{:});
if ~isempty(settings.KeepStrongestFraction)
    settings.BispectrumKeepStrongestFraction = settings.KeepStrongestFraction;
    settings.BicoherenceKeepStrongestFraction = settings.KeepStrongestFraction;
end
keepSettings = {'BispectrumKeepStrongestFraction', ...
    'BicoherenceKeepStrongestFraction'};
for ii = 1:numel(keepSettings)
    value = settings.(keepSettings{ii});
    if ~(isscalar(value) && isnumeric(value) && isfinite(value) && ...
            value > 0 && value <= 1)
        error('Acycle:Bispectral:InvalidPlotKeepStrongest', ...
            '%s must lie in (0,1].',keepSettings{ii});
    end
end
if ~(isscalar(settings.ColorGrid) && isnumeric(settings.ColorGrid) && ...
        isfinite(settings.ColorGrid) && settings.ColorGrid >= 4 && ...
        settings.ColorGrid <= 256 && settings.ColorGrid == round(settings.ColorGrid))
    error('Acycle:Bispectral:InvalidPlotColorGrid', ...
        'ColorGrid must be an integer from 4 through 256.');
end
if ~(isscalar(settings.FrequencyMinimum) && isnumeric(settings.FrequencyMinimum) && ...
        isfinite(settings.FrequencyMinimum) && settings.FrequencyMinimum >= 0)
    error('Acycle:Bispectral:InvalidPlotFrequencyRange', ...
        'FrequencyMinimum must be a finite nonnegative scalar.');
end
if ~isempty(settings.FrequencyMaximum) && ...
        ~(isscalar(settings.FrequencyMaximum) && isnumeric(settings.FrequencyMaximum) && ...
        isfinite(settings.FrequencyMaximum) && settings.FrequencyMaximum > 0)
    error('Acycle:Bispectral:InvalidPlotFrequencyRange', ...
        'FrequencyMaximum must be empty or a positive finite scalar.');
end
validPeriods = isempty(settings.ReferencePeriods) || ...
    (isnumeric(settings.ReferencePeriods) && isvector(settings.ReferencePeriods) && ...
    all(isfinite(settings.ReferencePeriods(:))) && ...
    all(settings.ReferencePeriods(:) > 0));
if ~validPeriods
    error('Acycle:Bispectral:InvalidPlotReferencePeriods', ...
        'ReferencePeriods must be empty or a vector of positive finite periods.');
end
settings.ReferencePeriods = unique(double(settings.ReferencePeriods(:))','stable');
validPairs = isnumeric(settings.FrequencyPairs) && ...
    isreal(settings.FrequencyPairs) && (isempty(settings.FrequencyPairs) || ...
    (ismatrix(settings.FrequencyPairs) && size(settings.FrequencyPairs,2) == 2 && ...
    all(isfinite(settings.FrequencyPairs(:))) && ...
    all(settings.FrequencyPairs(:) > 0)));
if ~validPairs
    error('Acycle:Bispectral:InvalidPlotFrequencyPairs', ...
        'FrequencyPairs must be empty or an N-by-2 matrix of positive finite frequencies.');
end
if isempty(settings.FrequencyPairs)
    settings.FrequencyPairs = zeros(0,2);
else
    settings.FrequencyPairs = unique(double(settings.FrequencyPairs),'rows','stable');
end
quantity = canonicalQuantity(settings.Quantity);
[plotMinimum,plotMaximum] = plotFrequencyLimits(result,settings);
name = displayName(result);
if isempty(settings.Title)
    figureTitle = sprintf('%s: bispectral analysis',name);
else
    figureTitle = char(settings.Title);
end
mtmMetadata = struct('Method','2pi MTM (Thomson)', ...
    'TimeBandwidth',2,'TaperCount',3,'PaddingFactor',5, ...
    'NFFT',NaN,'InputLength',NaN,'MeanRemoved',false, ...
    'FrequencyCoordinate','cycles per coordinate unit');
powerHeadroomFraction = 0.20;
powerYLimits = [];
powerYTicks = [];
minimumFontSizePoints = 6;

if strcmp(quantity,'overview')
    fig = figure('Color','w','Name',figureTitle,'NumberTitle','off', ...
        'Visible','off','Position',[80 45 1180 830], ...
        'PaperPositionMode','auto');
    setappdata(fig,'BispectralPlotComplete',false);
    setappdata(fig,'BispectralLayoutReady',false);
    cleanupFigure = onCleanup(@()deleteIncompleteFigure(fig));
    annotation(fig,'textbox',[0.075 0.952 0.86 0.035], ...
        'String',figureTitle,'EdgeColor','none', ...
        'HorizontalAlignment','center','VerticalAlignment','middle', ...
        'FontWeight','bold','FontSize',12.5,'Interpreter','none');

    bispectrumSettings = settings;
    bispectrumSettings.KeepStrongestFraction = ...
        settings.BispectrumKeepStrongestFraction;
    bicoherenceSettings = settings;
    bicoherenceSettings.KeepStrongestFraction = ...
        settings.BicoherenceKeepStrongestFraction;

    axBispectrum = axes(fig,'Units','normalized', ...
        'Position',[0.075 0.12 0.38 0.555]);
    map1 = drawMap(axBispectrum,result,'bispectrum-magnitude',bispectrumSettings);

    axBicoherence = axes(fig,'Units','normalized', ...
        'Position',[0.535 0.12 0.38 0.555]);
    map2 = drawMap(axBicoherence,result,'bicoherence-squared',bicoherenceSettings);

    leftMapPosition = axBispectrum.Position;
    rightMapPosition = axBicoherence.Position;
    [mtmFrequency,mtmPower,mtmMetadata] = multitaperPowerSpectrum(result);
    powerYLimits = visibleLogPowerLimits(mtmFrequency,mtmPower, ...
        [plotMinimum plotMaximum],powerHeadroomFraction);
    powerYTicks = logPowerTicks(powerYLimits,3);
    axPowerLeft = axes(fig,'Units','normalized','Position', ...
        [leftMapPosition(1) 0.755 leftMapPosition(3) 0.14]);
    drawLogPowerSpectrum(axPowerLeft,mtmFrequency,mtmPower, ...
        'Complex bispectrum amplitude, |B|',powerYLimits,powerYTicks);
    axPowerRight = axes(fig,'Units','normalized','Position', ...
        [rightMapPosition(1) 0.755 rightMapPosition(3) 0.14]);
    drawLogPowerSpectrum(axPowerRight,mtmFrequency,mtmPower, ...
        'Magnitude-squared bicoherence, b^2',powerYLimits,powerYTicks);
    linkedAxes = [axPowerLeft,axPowerRight,axBispectrum,axBicoherence, ...
        map1.PeriodAxes,map2.PeriodAxes];
    linkaxes(linkedAxes,'x');
    xlim(axPowerLeft,[plotMinimum,plotMaximum]);

    layout = struct('Maps',{{axBispectrum,axBicoherence}}, ...
        'Powers',{{axPowerLeft,axPowerRight}}, ...
        'PeriodAxes',{{map1.PeriodAxes,map2.PeriodAxes}});
    setappdata(fig,'BispectralLayout',layout);

    addMethodCaption(fig,result,settings);
    plotHandles = struct('Power',axPowerLeft, ...
        'PowerLeft',axPowerLeft,'PowerRight',axPowerRight, ...
        'PowerAxes',[axPowerLeft axPowerRight], ...
        'BispectrumPower',axPowerLeft,'BicoherencePower',axPowerRight, ...
        'Bispectrum',axBispectrum,'Bicoherence',axBicoherence, ...
        'BispectrumMap',map1,'BicoherenceMap',map2, ...
        'ReferenceLines',[map1.ReferenceLines;map2.ReferenceLines], ...
        'ReferenceLabels',[map1.ReferenceLabels;map2.ReferenceLabels], ...
        'FrequencyPairLines',[map1.FrequencyPairLines;map2.FrequencyPairLines], ...
        'FrequencyPairLabels',[map1.FrequencyPairLabels;map2.FrequencyPairLabels], ...
        'PowerSpectrumMetadata',mtmMetadata, ...
        'PeriodAxes',[map1.PeriodAxes,map2.PeriodAxes]);
else
    fig = figure('Color','w','Name',figureTitle,'NumberTitle','off', ...
        'Visible','off','Position',[120 70 820 760], ...
        'PaperPositionMode','auto');
    setappdata(fig,'BispectralPlotComplete',false);
    setappdata(fig,'BispectralLayoutReady',false);
    cleanupFigure = onCleanup(@()deleteIncompleteFigure(fig));
    ax = axes(fig,'Units','normalized','Position',[0.12 0.14 0.70 0.66]);
    mapSettings = settings;
    if any(strcmp(quantity,{'bispectrum-magnitude','bispectrum-real', ...
            'bispectrum-imaginary'}))
        mapSettings.KeepStrongestFraction = ...
            settings.BispectrumKeepStrongestFraction;
    else
        mapSettings.KeepStrongestFraction = ...
            settings.BicoherenceKeepStrongestFraction;
    end
    map = drawMap(ax,result,quantity,mapSettings);
    setMapTitle(ax,sprintf('%s: %s',name,map.Title));
    if ~isempty(map.PeriodAxes)
        linkaxes([ax,map.PeriodAxes],'x');
    end
    layout = struct('Maps',{{ax}},'Powers',{{[]}}, ...
        'PeriodAxes',{{map.PeriodAxes}});
    setappdata(fig,'BispectralLayout',layout);
    addMethodCaption(fig,result,settings);
    plotHandles = struct('Map',ax,'Surface',map.Image, ...
        'Colorbar',map.Colorbar, ...
        'ValueContour',map.ValueContour, ...
        'SignificanceContour',map.SignificanceContour, ...
        'ReferenceLines',map.ReferenceLines, ...
        'ReferenceLabels',map.ReferenceLabels, ...
        'FrequencyPairLines',map.FrequencyPairLines, ...
        'FrequencyPairLabels',map.FrequencyPairLabels, ...
        'PeriodAxes',map.PeriodAxes);
end

renderSettings = struct( ...
    'Quantity',quantity, ...
    'FrequencyMinimum',plotMinimum, ...
    'FrequencyMaximum',plotMaximum, ...
    'BispectrumKeepStrongestFraction',settings.BispectrumKeepStrongestFraction, ...
    'BicoherenceKeepStrongestFraction',settings.BicoherenceKeepStrongestFraction, ...
    'ColorGrid',settings.ColorGrid, ...
    'ReferencePeriods',settings.ReferencePeriods, ...
    'FrequencyPairs',settings.FrequencyPairs, ...
    'PowerSpectrumMethod',mtmMetadata.Method, ...
    'PowerSpectrumTimeBandwidth',mtmMetadata.TimeBandwidth, ...
    'PowerSpectrumTaperCount',mtmMetadata.TaperCount, ...
    'PowerSpectrumPaddingFactor',mtmMetadata.PaddingFactor, ...
    'PowerSpectrumNFFT',mtmMetadata.NFFT, ...
    'PowerSpectrumInputLength',mtmMetadata.InputLength, ...
    'PowerSpectrumMeanRemoved',mtmMetadata.MeanRemoved, ...
    'PowerSpectrumFrequencyCoordinate',mtmMetadata.FrequencyCoordinate, ...
    'PowerSpectrumDisplayed',strcmp(quantity,'overview'), ...
    'PowerSpectrumHeadroomFraction',powerHeadroomFraction, ...
    'PowerSpectrumYLimits',powerYLimits, ...
    'PowerSpectrumYTicks',powerYTicks, ...
    'MinimumFontSizePoints',minimumFontSizePoints, ...
    'PeakCount',max(0,round(settings.PeakCount)), ...
    'ShowPeriodAxes',logical(settings.ShowPeriodAxes), ...
    'ShowSignificance',logical(settings.ShowSignificance), ...
    'Title',figureTitle);
setappdata(fig,'BispectralRenderSettings',renderSettings);
enforceMinimumFontSize(fig,minimumFontSizePoints);
drawnow nocallbacks
fig.Visible = settings.Visible;
drawnow nocallbacks
setappdata(fig,'BispectralLayoutReady',true);
installFigureLayoutSynchronization(fig);
synchronizeFigureLayout(fig,[]);
setappdata(fig,'BispectralPlotComplete',true);
end

function deleteIncompleteFigure(fig)
if ~isgraphics(fig,'figure')
    return
end
complete = isappdata(fig,'BispectralPlotComplete') && ...
    isequal(getappdata(fig,'BispectralPlotComplete'),true);
if ~complete
    setappdata(fig,'BispectralLayoutReady',false);
    delete(fig);
end
end

function synchronizeFigureLayout(fig,~)
if ~isgraphics(fig,'figure') || ~isappdata(fig,'BispectralLayout') || ...
        ~isappdata(fig,'BispectralLayoutReady') || ...
        ~getappdata(fig,'BispectralLayoutReady')
    return
end
if isappdata(fig,'BispectralLayoutSyncRunning') && ...
        getappdata(fig,'BispectralLayoutSyncRunning')
    return
end
setappdata(fig,'BispectralLayoutSyncRunning',true);
cleanupSync = onCleanup(@()releaseLayoutSync(fig));
layout = getappdata(fig,'BispectralLayout');
for ii = 1:numel(layout.Maps)
    mapAxis = layout.Maps{ii};
    if ~isgraphics(mapAxis,'axes')
        continue
    end
    plotBox = actualPlotBoxPixels(mapAxis);
    figurePixels = getpixelposition(fig);
    figureWidth = figurePixels(3);
    if ~(figureWidth > 0)
        continue
    end
    powerAxis = layout.Powers{ii};
    if isgraphics(powerAxis,'axes')
        powerAxis.PositionConstraint = 'innerposition';
        if ~isappdata(powerAxis,'BispectralNormalizedVertical')
            originalUnits = powerAxis.Units;
            powerAxis.Units = 'normalized';
            normalizedPosition = powerAxis.Position;
            setappdata(powerAxis,'BispectralNormalizedVertical', ...
                normalizedPosition([2 4]));
            powerAxis.Units = originalUnits;
        end
        vertical = getappdata(powerAxis,'BispectralNormalizedVertical');
        powerAxis.Units = 'normalized';
        position = [(plotBox(1)-1)/figureWidth,vertical(1), ...
            plotBox(3)/figureWidth,vertical(2)];
        powerAxis.Position = position;
    end
    periodAxis = layout.PeriodAxes{ii};
    if isgraphics(periodAxis,'axes')
        periodAxis.PositionConstraint = 'innerposition';
        periodAxis.Units = mapAxis.Units;
        periodAxis.Position = mapAxis.Position;
        periodAxis.PlotBoxAspectRatioMode = 'manual';
        periodAxis.PlotBoxAspectRatio = mapAxis.PlotBoxAspectRatio;
        periodAxis.XLim = mapAxis.XLim;
        periodAxis.YLim = mapAxis.YLim;
    end
end
end

function releaseLayoutSync(fig)
if isgraphics(fig,'figure')
    setappdata(fig,'BispectralLayoutSyncRunning',false);
end
end

function installFigureLayoutSynchronization(fig)
fig.SizeChangedFcn = @synchronizeFigureLayout;
end

function [frequency,power,metadata] = multitaperPowerSpectrum(result)
if ~isfield(result,'ProcessedData') || size(result.ProcessedData,2) < 2
    error('Acycle:Bispectral:MissingProcessedData', ...
        'The overview 2pi MTM spectrum requires result.ProcessedData.');
end
y = double(result.ProcessedData(:,2));
y = y-mean(y);
n = numel(y);
nfft = 5*n;
if exist('pmtm','file') ~= 2
    error('Acycle:Bispectral:MissingPMTM', ...
        ['The overview requires PMTM from Signal Processing Toolbox ', ...
         '(2pi MTM, NW=2, K=3, NFFT=5N).']);
end
[power,angularFrequency] = pmtm(y,2,nfft);
dt = double(result.Meta.SampleInterval);
frequency = double(angularFrequency(:))/(2*pi*dt);
power = double(power(:));
metadata = struct('Method','2pi MTM (Thomson)', ...
    'TimeBandwidth',2,'TaperCount',3,'PaddingFactor',5, ...
    'NFFT',nfft,'InputLength',n,'MeanRemoved',true, ...
    'FrequencyCoordinate','cycles per coordinate unit');
end

function drawLogPowerSpectrum(ax,frequency,power,mapTitle,yLimits,yTicks)
displayPower = power;
displayPower(~isfinite(displayPower) | displayPower <= 0) = NaN;
plot(ax,frequency,displayPower,'k-','LineWidth',1.0);
set(ax,'YScale','log');
styleAxis(ax);
xlabel(ax,'');
ylabel(ax,'2\pi MTM power','Interpreter','tex');
heading = title(ax,mapTitle,'FontWeight','normal','FontSize',11, ...
    'Interpreter','none');
heading.Units = 'normalized';
heading.Position = [0.5 1.06 0];
heading.VerticalAlignment = 'bottom';
ylim(ax,yLimits);
ax.YTick = yTicks;
ax.YTickLabel = arrayfun(@(value)sprintf('%.3g',value),yTicks, ...
    'UniformOutput',false);
end

function limits = visibleLogPowerLimits(frequency,power,frequencyLimits,headroom)
visible = isfinite(frequency) & frequency >= frequencyLimits(1) & ...
    frequency <= frequencyLimits(2) & isfinite(power) & power > 0;
positive = double(power(visible));
if isempty(positive)
    limits = [1e-12 1];
    return
end
lower = min(positive);
peak = max(positive);
if peak <= lower*(1+64*eps)
    upper = lower*10;
else
    logLower = log(lower);
    logUpper = logLower+(log(peak)-logLower)/(1-headroom);
    upper = exp(min(logUpper,log(realmax)));
end
if ~(isfinite(upper) && upper > lower)
    upper = lower*(1+sqrt(eps));
end
limits = [lower upper];
end

function ticks = logPowerTicks(limits,count)
ticks = exp(linspace(log(limits(1)),log(limits(2)),count));
ticks([1 end]) = limits;
end

function mapInfo = drawMap(ax,result,quantity,settings)
ax.Tag = 'bispectralMapAxes';
f = result.Frequency(:);
[plotMinimum,plotMaximum] = plotFrequencyLimits(result,settings);
[originalF1,originalF2] = meshgrid(f,f);
visibleOriginal = originalF1 >= plotMinimum & originalF1 <= plotMaximum & ...
    originalF2 >= plotMinimum & originalF2 <= plotMaximum;
switch quantity
    case 'bicoherence-squared'
        z = result.BicoherenceSquared;
        maskMetric = result.BicoherenceSquared;
        rescaleRetainedColors = true;
        colorLabel = 'b^2';
        titleText = 'Magnitude-squared bicoherence, b^2';
        limits = [0 1];
        cmap = divergingMap(settings.ColorGrid);
    case 'bispectrum-magnitude'
        raw = result.BispectrumMagnitude;
        finitePositive = raw(isfinite(raw) & raw > 0);
        if isempty(finitePositive)
            floorValue = realmin;
        else
            floorValue = max(realmin,min(finitePositive)*0.1);
        end
        % Preserve NaNs outside the nonredundant principal domain. MATLAB's
        % element-wise MAX omits NaNs, which would otherwise replace that
        % empty triangle with floorValue and paint it the lowest map color.
        z = nan(size(raw));
        validMagnitude = isfinite(raw);
        z(validMagnitude) = log10(max(raw(validMagnitude),floorValue));
        maskMetric = z;
        rescaleRetainedColors = true;
        colorLabel = 'log_{10}|B|';
        titleText = 'Bispectrum magnitude, log_{10}|B|';
        limits = robustLimits(z);
        cmap = divergingMap(settings.ColorGrid);
    case 'bispectrum-real'
        z = result.BispectrumReal;
        maskMetric = abs(result.Bispectrum);
        rescaleRetainedColors = false;
        colorLabel = 'Re(B)';
        titleText = 'Real bispectrum';
        limits = symmetricLimits(z);
        cmap = divergingMap(settings.ColorGrid);
    case 'bispectrum-imaginary'
        z = result.BispectrumImaginary;
        maskMetric = abs(result.Bispectrum);
        rescaleRetainedColors = false;
        colorLabel = 'Im(B)';
        titleText = 'Imaginary bispectrum';
        limits = symmetricLimits(z);
        cmap = divergingMap(settings.ColorGrid);
    case 'biphase'
        z = result.Biphase;
        maskMetric = result.BicoherenceSquared;
        rescaleRetainedColors = false;
        colorLabel = 'Biphase (rad)';
        titleText = 'Biphase';
        limits = [-pi pi];
        cmap = divergingMap(settings.ColorGrid);
    otherwise
        error('Acycle:Bispectral:InvalidPlotQuantity','Unsupported plot quantity.');
end

originalZ = z;
originalMaskMetric = maskMetric;
keepCutoff = -Inf;
alphaTransitionUpper = -Inf;
displayLimits = limits;
if settings.KeepStrongestFraction < 1
    validMetric = isfinite(originalZ) & isfinite(originalMaskMetric) & ...
        visibleOriginal;
    finiteValues = sort(originalMaskMetric(validMetric));
    if ~isempty(finiteValues)
        firstKept = max(1,min(numel(finiteValues), ...
            floor((1-settings.KeepStrongestFraction)*numel(finiteValues))+1));
        keepCutoff = finiteValues(firstKept);
        if rescaleRetainedColors
            retainedColors = originalZ(validMetric & originalMaskMetric >= keepCutoff);
            displayLimits = upperAnchoredLimits( ...
                min(retainedColors),max(retainedColors));
            cmap = positiveMap(settings.ColorGrid);
        end
        retainedCount = numel(finiteValues)-firstKept+1;
        transitionIndex = min(numel(finiteValues), ...
            firstKept+max(1,round(0.1*retainedCount))-1);
        alphaTransitionUpper = finiteValues(transitionIndex);
    end
end

[f1Grid,f2Grid,z] = interpolatedDisplayMesh( ...
    f,originalZ,strcmp(quantity,'biphase'));
[~,~,maskMetricDisplay] = interpolatedDisplayMesh( ...
    f,originalMaskMetric,false);
pcolorHandle = pcolor(ax,f1Grid,f2Grid,z);
shading(ax,'interp');
set(pcolorHandle,'EdgeColor','none','FaceLighting','none', ...
    'Tag','bispectralColorSurface');
alphaData = [];
if isfinite(keepCutoff)
    alphaData = retainedAlpha( ...
        maskMetricDisplay,keepCutoff,alphaTransitionUpper);
    set(pcolorHandle,'AlphaData',alphaData, ...
        'AlphaDataMapping','none','FaceAlpha','interp');
end
view(ax,2);
set(ax,'YDir','normal','Color','w');
xlim(ax,[plotMinimum,plotMaximum]);
ylim(ax,[plotMinimum,plotMaximum]);
pbaspect(ax,[1 1 1]);
clim(ax,displayLimits);
colormap(ax,cmap);
hold(ax,'on');
valueContour = [];
contourLevels = interiorLevels(displayLimits,5);
contourZ = z;
if ~isempty(alphaData)
    contourZ(alphaData <= 0) = NaN;
end
if ~isempty(contourLevels) && any(isfinite(contourZ(:)))
    [~,valueContour] = contour(ax,f1Grid,f2Grid,contourZ,contourLevels, ...
        'LineColor',[0.30 0.24 0.20],'LineWidth',0.45, ...
        'HandleVisibility','off');
end

significanceContour = [];
hasCalculatedInference = isfield(result,'Significance') && ...
    isfield(result.Significance,'Method') && ...
    ~any(strcmp(result.Significance.Method,{'none','off',''}));
if settings.ShowSignificance && hasCalculatedInference && ...
        isfield(result,'SignificantMask') && ...
        isequal(size(result.SignificantMask),size(result.ValidMask)) && ...
        any(result.SignificantMask(:))
    significanceProjection = projectedSignificance( ...
        f,result.SignificantMask,result.ValidMask,f1Grid,f2Grid);
    [~,significanceContour] = contour(ax,f1Grid,f2Grid, ...
        significanceProjection,[0.5 0.5], ...
        'LineColor','k','LineWidth',2.0,'HandleVisibility','off');
end

if settings.PeakCount > 0 && strcmp(quantity,'bicoherence-squared')
    retainedOriginal = isfinite(originalMaskMetric) & ...
        originalMaskMetric >= keepCutoff;
    annotatePeaks(ax,result,round(settings.PeakCount),retainedOriginal);
end

[referenceLines,referenceLabels] = addReferencePeriodLines( ...
    ax,result,settings.ReferencePeriods);
[frequencyPairLines,frequencyPairLabels] = addFrequencyPairGuides( ...
    ax,settings.FrequencyPairs);

styleAxis(ax);
xlabel(ax,['f_1, ',frequencyLabel(result)],'Interpreter','tex');
ylabel(ax,['f_2, ',frequencyLabel(result)],'Interpreter','tex');
cb = colorbar(ax,'southoutside');
cb.Tag = 'bispectralColorbar';
cb.Label.String = colorLabel;
cb.Label.Units = 'normalized';
cb.Label.Position = [-0.025 0.5 0];
cb.Label.Rotation = 0;
cb.Label.HorizontalAlignment = 'right';
cb.Label.VerticalAlignment = 'middle';
cb.Label.FontSize = 10;
cb.FontSize = 10;
cb.TickDirection = 'out';
periodAxes = [];
if settings.ShowPeriodAxes
    periodAxes = addPeriodAxes(ax,result);
end
mapInfo = struct('Image',pcolorHandle,'Colorbar',cb, ...
    'ValueContour',valueContour, ...
    'SignificanceContour',significanceContour, ...
    'ReferenceLines',referenceLines,'ReferenceLabels',referenceLabels, ...
    'FrequencyPairLines',frequencyPairLines, ...
    'FrequencyPairLabels',frequencyPairLabels, ...
    'MeshX',f1Grid,'MeshY',f2Grid, ...
    'KeepCutoff',keepCutoff, ...
    'AlphaTransitionUpper',alphaTransitionUpper, ...
    'PeriodAxes',periodAxes,'Title',titleText);
end

function [minimum,maximum] = plotFrequencyLimits(result,settings)
f = result.Frequency(:);
minimum = f(1);
maximum = f(end);
if ~isempty(settings.FrequencyMinimum)
    minimum = max(minimum,double(settings.FrequencyMinimum));
end
if ~isempty(settings.FrequencyMaximum)
    maximum = min(maximum,double(settings.FrequencyMaximum));
end
if ~(isfinite(minimum) && isfinite(maximum) && maximum > minimum)
    error('Acycle:Bispectral:InvalidPlotFrequencyRange', ...
        ['The plotted frequency range must overlap the computed domain and ', ...
         'have maximum frequency greater than minimum frequency.']);
end
end

function [lineHandles,labelHandles] = addReferencePeriodLines(ax,result,periods)
lineHandles = gobjects(numel(periods),1);
labelHandles = gobjects(numel(periods),1);
drawnCount = 0;
if isempty(periods)
    return
end
f = result.Frequency(:);
[f1,f2] = meshgrid(f,f);
if isfield(result,'PrincipalDomainMask')
    principalMask = result.PrincipalDomainMask;
else
    principalMask = result.ValidMask;
end
domainSums = f1(principalMask)+f2(principalMask);
domainSums = domainSums(isfinite(domainSums));
if isempty(domainSums)
    return
end
maximumSum = max(domainSums);
xLimits = ax.XLim;
yLimits = ax.YLim;
for ii = 1:numel(periods)
    period = periods(ii);
    sumFrequency = 1/period;
    tolerance = 64*eps(max(1,maximumSum));
    if sumFrequency > maximumSum+tolerance
        continue
    end
    xLow = max([xLimits(1),f(1),sumFrequency-yLimits(2),sumFrequency/2]);
    xHigh = min([xLimits(2),f(end),sumFrequency-yLimits(1),sumFrequency-f(1)]);
    if ~(isfinite(xLow) && isfinite(xHigh) && xHigh-xLow > tolerance)
        continue
    end
    x = [xLow xHigh];
    y = sumFrequency-x;
    drawnCount = drawnCount+1;
    lineHandles(drawnCount,1) = plot(ax,x,y,'--', ...
        'Color',[0.12 0.12 0.12],'LineWidth',0.7, ...
        'HitTest','off','PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralReferencePeriodLine');
    labelX = xLow-0.012*diff(xLimits);
    labelY = y(1)+0.012*diff(yLimits);
    label = sprintf('%.4g',period);
    labelHandles(drawnCount,1) = text(ax,labelX,labelY,label, ...
        'Rotation',0,'FontSize',9,'Color',[0.08 0.08 0.08], ...
        'HorizontalAlignment','right','VerticalAlignment','bottom', ...
        'Clipping','off','Interpreter','none','HitTest','off', ...
        'PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralReferencePeriodLabel');
end
lineHandles = lineHandles(1:drawnCount);
labelHandles = labelHandles(1:drawnCount);
end

function [lineHandles,labelHandles] = addFrequencyPairGuides(ax,pairs)
lineHandles = gobjects(2*size(pairs,1),1);
labelHandles = gobjects(2*size(pairs,1),1);
drawnCount = 0;
if isempty(pairs)
    return
end
xLimits = ax.XLim;
yLimits = ax.YLim;
xRange = diff(xLimits);
yRange = diff(yLimits);
tolerance = 64*eps(max([1 abs(xLimits) abs(yLimits)]));
for ii = 1:size(pairs,1)
    f1 = pairs(ii,1);
    f2 = pairs(ii,2);
    visible = f1 >= xLimits(1)-tolerance && f1 <= xLimits(2)+tolerance && ...
        f2 >= yLimits(1)-tolerance && f2 <= yLimits(2)+tolerance;
    if ~visible
        continue
    end
    firstLine = drawnCount+1;
    lineHandles(firstLine,1) = plot(ax,[f1 f1],yLimits,':', ...
        'Color',[0.38 0.38 0.38],'LineWidth',0.2, ...
        'HitTest','off','PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralFrequencyPairVertical');
    lineHandles(firstLine+1,1) = plot(ax,xLimits,[f2 f2],':', ...
        'Color',[0.38 0.38 0.38],'LineWidth',0.2, ...
        'HitTest','off','PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralFrequencyPairHorizontal');
    xNormalized = (f1-xLimits(1))/xRange;
    yNormalized = (f2-yLimits(1))/yRange;
    verticalLabel = text(ax,xNormalized,1.0585, ...
        sprintf('%.4g',1/f1),'Units','normalized', ...
        'FontSize',9,'Color',[0.25 0.25 0.25], ...
        'HorizontalAlignment','center','VerticalAlignment','bottom', ...
        'Clipping','off','Interpreter','none','HitTest','off', ...
        'PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralFrequencyPairVerticalLabel');
    labelHandles(firstLine,1) = verticalLabel;
    labelHandles(firstLine+1,1) = text(ax,1.025,yNormalized, ...
        sprintf('%.4g',1/f2),'Units','normalized', ...
        'FontSize',9,'Color',[0.25 0.25 0.25], ...
        'HorizontalAlignment','left','VerticalAlignment','middle', ...
        'Clipping','off','Interpreter','none','HitTest','off', ...
        'PickableParts','none','HandleVisibility','off', ...
        'Tag','bispectralFrequencyPairHorizontalLabel');
    drawnCount = drawnCount+2;
end
lineHandles = lineHandles(1:drawnCount);
labelHandles = labelHandles(1:drawnCount);
end

function annotatePeaks(ax,result,count,displayMask)
z = result.BicoherenceSquared;
candidateMask = result.ValidMask & isfinite(z) & displayMask;
[f1Grid,f2Grid] = meshgrid(result.Frequency(:),result.Frequency(:));
candidateMask = candidateMask & ...
    f1Grid >= ax.XLim(1) & f1Grid <= ax.XLim(2) & ...
    f2Grid >= ax.YLim(1) & f2Grid <= ax.YLim(2);
hasInference = ~any(strcmp(result.Significance.Method,{'none','off',''}));
if hasInference
    candidateMask = candidateMask & result.SignificantMask;
end
indices = find(candidateMask);
if isempty(indices)
    return
end
[~,order] = sort(z(indices),'descend');
indices = indices(order);
[rows,columns] = ind2sub(size(z),indices);
chosen = zeros(0,2);
minimumSeparation = 0.18;
chosenNormalized = zeros(0,2);
for ii = 1:numel(indices)
    point = [rows(ii),columns(ii)];
    f1 = result.Frequency(point(2));
    f2 = result.Frequency(point(1));
    normalizedPoint = [(f1-ax.XLim(1))/diff(ax.XLim), ...
        (f2-ax.YLim(1))/diff(ax.YLim)];
    if isempty(chosenNormalized) || all(sqrt(sum( ...
            (chosenNormalized-normalizedPoint).^2,2)) >= minimumSeparation)
        chosen(end+1,:) = point; %#ok<AGROW>
        chosenNormalized(end+1,:) = normalizedPoint; %#ok<AGROW>
        plot(ax,f1,f2,'ko','MarkerFaceColor','w','MarkerSize',4, ...
            'LineWidth',0.8,'HandleVisibility','off');
        text(ax,f1,f2,sprintf('  %.3g, %.3g',f1,f2), ...
            'FontSize',9,'Color','k','VerticalAlignment','bottom', ...
            'Clipping','on','Interpreter','none');
        if size(chosen,1) >= count
            break
        end
    end
end
end

function overlay = addPeriodAxes(ax,result)
f = result.Frequency(:);
positive = f(f > 0);
if numel(positive) < 2
    overlay = [];
    return
end
ticks = unique(linspace(ax.XLim(1),ax.XLim(2),5));
ticks = ticks(isfinite(ticks) & ticks > 0);
if isempty(ticks)
    overlay = [];
    return
end
labels = arrayfun(@(value)sprintf('%.3g',1/value),ticks,'UniformOutput',false);
overlay = axes(ancestor(ax,'figure'),'Units',ax.Units,'Position',ax.Position, ...
    'Color','none', ...
    'XAxisLocation','top','YAxisLocation','right','XLim',ax.XLim,'YLim',ax.YLim, ...
    'XTick',ticks,'YTick',[],'XTickLabel',labels,'YTickLabel',{}, ...
    'Box','off','TickDir','out','FontSize',9.5,'HitTest','off');
overlay.PositionConstraint = 'innerposition';
overlay.PlotBoxAspectRatioMode = 'manual';
overlay.PlotBoxAspectRatio = ax.PlotBoxAspectRatio;
overlay.XColor = [0.32 0.32 0.32];
overlay.YColor = 'none';
% Keep the title just outside the upper-right corner, but below the top
% axis.  This separates it vertically from the rightmost period tick label.
text(overlay,1.04,0.985,sprintf('Period (%s)',result.CoordinateUnit), ...
    'Units','normalized','HorizontalAlignment','left','VerticalAlignment','top', ...
    'FontSize',9.5,'Color',[0.32 0.32 0.32],'Interpreter','none', ...
    'Clipping','off','HitTest','off','PickableParts','none', ...
    'Tag','bispectralPeriodAxisTitle');
end

function position = actualPlotBoxPixels(ax)
% Axes with pbaspect can have a plot box smaller than ax.Position. Align
% the period overlay to that rendered box rather than to its empty margin.
position = getpixelposition(ax,true);
ratio = ax.PlotBoxAspectRatio(1)/ax.PlotBoxAspectRatio(2);
if ~(isfinite(ratio) && ratio > 0) || position(3) <= 0 || position(4) <= 0
    return
end
outerRatio = position(3)/position(4);
if outerRatio > ratio
    newWidth = position(4)*ratio;
    position(1) = position(1)+(position(3)-newWidth)/2;
    position(3) = newWidth;
else
    newHeight = position(3)/ratio;
    position(2) = position(2)+(position(4)-newHeight)/2;
    position(4) = newHeight;
end
end

function setMapTitle(ax,textValue)
heading = title(ax,textValue,'Interpreter','none','FontWeight','bold', ...
    'FontSize',11);
heading.Units = 'normalized';
heading.Position = [0.5 1.19 0];
heading.VerticalAlignment = 'bottom';
end

function addMethodCaption(fig,result,settings)
meta = result.Meta;
sig = result.Significance;
if strcmp(meta.Estimator,'wosa')
    estimatorText = sprintf('WOSA: %d segments, L=%d, %.1f%% overlap, %s', ...
        meta.SegmentCount,meta.SegmentLength,meta.ActualMedianOverlapPercent,meta.Window);
else
    estimatorText = sprintf('Frequency-smoothed direct: %d-point hex kernel, %s', ...
        size(meta.SmoothingOffsets,1),meta.Window);
end
if settings.ShowSignificance
    inferenceText = significanceLabel(sig);
else
    inferenceText = 'significance display: none';
end
if strcmp(canonicalQuantity(settings.Quantity),'overview')
    estimatorText = sprintf('%s | power: 2pi MTM, NW=2, K=3, NFFT=5N', ...
        estimatorText);
end
caption = sprintf(['%s | dt=%.5g | df_R=%.5g | %s\n', ...
    '%s High b^2 indicates phase coupling, not causality.'], ...
    estimatorText,meta.SampleInterval,meta.RayleighResolution, ...
    inferenceText,significanceContourLabel(result,settings));
annotation(fig,'textbox',[0.075 0.055 0.87 0.062],'String',caption, ...
    'EdgeColor','none','HorizontalAlignment','center','FontSize',10, ...
    'Color',[0.22 0.22 0.22],'Interpreter','none');
end

function label = significanceContourLabel(result,settings)
if ~settings.ShowSignificance && ...
        ~any(strcmp(result.Significance.Method,{'none','off',''}))
    label = 'Cached inference retained; significance contour is hidden.';
elseif any(strcmp(result.Significance.Method,{'none','off',''}))
    label = 'No significance inference requested.';
elseif anyVisibleSignificance(result,settings)
    label = 'Thick black contour encloses significant triads.';
elseif any(result.SignificantMask(:))
    label = 'Significant triads exist outside the plotted frequency range.';
else
    label = 'No triad crossed the selected significance threshold.';
end
end

function value = resultOption(result,name,fallback)
value = fallback;
if isfield(result,'Options') && isfield(result.Options,name)
    value = result.Options.(name);
end
end

function yes = anyVisibleSignificance(result,settings)
f = result.Frequency(:);
[f1,f2] = meshgrid(f,f);
[minimum,maximum] = plotFrequencyLimits(result,settings);
visible = f1 >= minimum & f1 <= maximum & f2 >= minimum & f2 <= maximum;
yes = any(result.SignificantMask(:) & visible(:));
end

function label = significanceLabel(significance)
switch significance.Method
    case {'none','off',''}
        label = 'significance: none';
    case 'analytical'
        label = sprintf('pointwise Beta reference %.1f%%',100*significance.ConfidenceLevel);
    case 'surrogate-pointwise'
        label = sprintf('%d %s pointwise surrogates, %.1f%%', ...
            significance.NumSurrogates,upper(significance.SurrogateType), ...
            100*significance.ConfidenceLevel);
    case 'surrogate-global'
        label = sprintf('%d %s max-stat FWER surrogates, %.1f%%', ...
            significance.NumSurrogates,upper(significance.SurrogateType), ...
            100*significance.ConfidenceLevel);
    otherwise
        label = significance.Method;
end
end

function name = displayName(result)
name = strtrim(char(result.InputName));
if isempty(name)
    name = 'Data';
else
    [~,base,extension] = fileparts(name);
    knownDataExtensions = {'.txt','.csv','.dat','.out','.res','.tab', ...
        '.mat','.xlsx','.xls'};
    if any(strcmpi(extension,knownDataExtensions))
        name = base;
    else
        name = [base,extension];
    end
end
end

function text = frequencyLabel(result)
unit = strtrim(char(result.CoordinateUnit));
if isempty(unit)
    unit = 'unit';
end
text = sprintf('frequency (%s^{-1})',unit);
end

function styleAxis(ax)
set(ax,'Box','on','TickDir','out','LineWidth',0.85,'FontName','Helvetica', ...
    'FontSize',11,'Layer','top','XMinorTick','on','YMinorTick','on');
end

function enforceMinimumFontSize(fig,minimumPoints)
objects = findall(fig,'-property','FontSize');
for ii = 1:numel(objects)
    object = objects(ii);
    try
        if isprop(object,'FontUnits')
            object.FontUnits = 'points';
        end
        if isfinite(object.FontSize) && object.FontSize < minimumPoints
            object.FontSize = minimumPoints;
        end
    catch
        % Some undocumented graphics peers expose a transient FontSize
        % property while the scene is being assembled. They do not own
        % visible text, so leave them unchanged instead of destabilizing
        % the R2025b graphics tree.
    end
end
end

function limits = robustLimits(z)
values = sort(z(isfinite(z)));
if isempty(values)
    limits = [0 1];
    return
end
lo = values(max(1,round(0.01*numel(values))));
hi = values(max(1,round(0.995*numel(values))));
if ~(isfinite(lo) && isfinite(hi) && hi > lo)
    delta = max(1,abs(lo))*1e-6;
    limits = [lo-delta,lo+delta];
else
    limits = [lo hi];
end
end

function limits = symmetricLimits(z)
values = abs(z(isfinite(z)));
if isempty(values)
    maximum = 1;
else
    values = sort(values);
    maximum = values(max(1,round(0.995*numel(values))));
    if ~(isfinite(maximum) && maximum > 0)
        maximum = 1;
    end
end
limits = [-maximum maximum];
end

function [f1Grid,f2Grid,zDisplay] = interpolatedDisplayMesh(f,z,isCircular)
% Refine only the rendering grid. Numerical estimates, masks, inference,
% and saved matrices remain on the original FFT-frequency grid.
n = numel(f);
% Cap only additional rendering refinement. Never use fewer display nodes
% than computed FFT-frequency nodes, because that could erase narrow peaks
% or coarsen an already-decided significance boundary.
displayCount = max(n,min(801,4*(n-1)+1));
displayFrequency = linspace(f(1),f(end),displayCount);
[f1Grid,f2Grid] = meshgrid(displayFrequency,displayFrequency);
if displayCount == n && isequal(displayFrequency(:),f(:))
    zDisplay = z;
    return
end
if isCircular
    cosine = nan(size(z));
    sine = nan(size(z));
    valid = isfinite(z);
    cosine(valid) = cos(z(valid));
    sine(valid) = sin(z(valid));
    cosineDisplay = interp2(f,f,cosine,f1Grid,f2Grid,'linear');
    sineDisplay = interp2(f,f,sine,f1Grid,f2Grid,'linear');
    resultantLength = hypot(cosineDisplay,sineDisplay);
    zDisplay = atan2(sineDisplay,cosineDisplay);
    zDisplay(~isfinite(resultantLength) | resultantLength <= 32*eps) = NaN;
else
    zDisplay = interp2(f,f,z,f1Grid,f2Grid,'linear');
end
end

function projection = projectedSignificance(f,significant,valid,f1Grid,f2Grid)
% Project the already-decided logical significance mask onto the exact
% display mesh. This smooths only the rendered boundary; it does not
% interpolate p-values or create new significant FFT-frequency triads.
source = nan(size(significant));
source(valid) = double(significant(valid));
projection = interp2(f,f,source,f1Grid,f2Grid,'linear');
end

function levels = interiorLevels(limits,count)
if ~(numel(limits) == 2 && all(isfinite(limits)) && limits(2) > limits(1))
    levels = [];
    return
end
levels = linspace(limits(1),limits(2),count+2);
levels = levels(2:end-1);
end

function alpha = retainedAlpha(z,cutoff,transitionUpper)
% Keep the complete interpolated color field intact and hide weak values
% in a separate transparency layer. Interpolated face alpha avoids the
% block boundaries produced when low CData vertices are replaced by NaN.
alpha = zeros(size(z));
valid = isfinite(z) & z >= cutoff;
if isfinite(transitionUpper) && transitionUpper > cutoff
    alpha(valid) = min(1,max(0, ...
        (z(valid)-cutoff)/(transitionUpper-cutoff)));
else
    alpha(valid) = 1;
end
end

function limits = upperAnchoredLimits(lower,upper)
% Keep the largest displayed value at the red endpoint even for a
% constant-valued retained set.
if isfinite(lower) && isfinite(upper) && upper > lower
    limits = [lower upper];
    return
end
anchor = upper;
if ~isfinite(anchor)
    anchor = lower;
end
if ~isfinite(anchor)
    anchor = 0;
end
delta = max(1,abs(anchor))*1e-6;
limits = [anchor-delta anchor];
end

function map = positiveMap(n)
anchors = [
    1.00 1.00 1.00
    0.98 0.82 0.72
    0.92 0.38 0.20
    0.65 0.08 0.08];
map = interp1(linspace(0,1,size(anchors,1)), ...
    anchors,linspace(0,1,n),'linear');
end

function map = divergingMap(n)
anchors = [0.10 0.24 0.62; 0.42 0.68 0.84; 1 1 1; ...
    0.95 0.58 0.38; 0.65 0.08 0.08];
map = interp1(linspace(0,1,size(anchors,1)),anchors,linspace(0,1,n),'linear');
end

function quantity = canonicalQuantity(value)
value = lower(strtrim(char(value)));
if any(strcmp(value,{'overview','summary'}))
    quantity = 'overview';
elseif any(strcmp(value,{'bicoherence-squared','squared bicoherence','bicoh2','b^2'}))
    quantity = 'bicoherence-squared';
elseif any(strcmp(value,{'bispectrum-magnitude','bispectrum magnitude','magnitude','abs'}))
    quantity = 'bispectrum-magnitude';
elseif any(strcmp(value,{'bispectrum-real','real','real bispectrum'}))
    quantity = 'bispectrum-real';
elseif any(strcmp(value,{'bispectrum-imaginary','imaginary','imaginary bispectrum','imag'}))
    quantity = 'bispectrum-imaginary';
elseif any(strcmp(value,{'biphase','phase'}))
    quantity = 'biphase';
else
    error('Acycle:Bispectral:InvalidPlotQuantity','Unknown PlotQuantity: %s.',value);
end
end

function settings = parseSettings(settings,varargin)
if isempty(varargin)
    return
end
if isscalar(varargin) && isstruct(varargin{1})
    supplied = varargin{1};
    names = fieldnames(supplied);
    for ii = 1:numel(names)
        if isfield(settings,names{ii})
            settings.(names{ii}) = supplied.(names{ii});
        end
    end
    return
end
if mod(numel(varargin),2) ~= 0
    error('Acycle:Bispectral:InvalidPlotOptions','Plot options must be name/value pairs.');
end
names = fieldnames(settings);
for ii = 1:2:numel(varargin)
    index = find(strcmpi(char(varargin{ii}),names),1);
    if isempty(index)
        error('Acycle:Bispectral:UnknownPlotOption','Unknown plot option: %s.',char(varargin{ii}));
    end
    settings.(names{index}) = varargin{ii+1};
end
end
