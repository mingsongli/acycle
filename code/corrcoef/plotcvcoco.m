function figs = plotcvcoco(result,varargin)
%PLOTCVCOCO Plot a cvCOCO result in the COCO diagnostic style.
%
% The main significance panel shows two directional, full-pipeline
% max-statistic p curves. Their values at the observed directional maxima
% are pB (A -> B) and pA (B -> A). The confirmatory robustness gate is
% pRobust = max(pA,pB); pSym is retained as a secondary joint statistic.
% A separate local-p panel shows same-rate, validation-search-uncorrected
% directional p curves as descriptive diagnostics only.
%
% PLOTCVCOCO(RESULT,'ShowSpectra',false) omits the depth/spectrum figure
% while retaining the correlation/significance and Monte Carlo figures.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'ShowSpectra',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
parse(parser,varargin{:});
showSpectra = logical(parser.Results.ShowSpectra);

required = {'srGrid','trainA','trainB','validateAtoB','validateBtoA', ...
    'dataA','dataB','spectra','orbitPeriods','groupNames', ...
    'targetModel','config', ...
    'validRateMaskA','validRateMaskB','orbitCountA','orbitCountB', ...
    'allNineRateRangeShared', ...
    'scoreSymmetric','scoreMean','nullSymmetric','nullAtoB','nullBtoA', ...
    'pSym','pA','pB','pCurveAtoB','pCurveBtoA', ...
    'pLocalCurveAtoB','pLocalCurveBtoA', ...
    'nsimCompleted','nsimValid','nsimValidAtoB','nsimValidBtoA'};
missing = required(~cellfun(@(name)isfield(result,name),required));
if ~isempty(missing)
    error('plotcvcoco:InvalidResult', ...
        'Missing cvCOCO result field(s): %s.',strjoin(missing,', '));
end

sr = result.srGrid(:);
frequencyLimit = resultFrequencyLimit(result);
figs = gobjects(0,1);
methodName = resultText(result,'name','cvCOCO');
[~,targetLegend] = targetLabels(result.targetModel);
if strcmp(result.targetModel,'legacy') && ...
        ~contains(lower(methodName),'legacy')
    methodName = [methodName,' (legacy target)'];
end

%% Depth-domain halves and their reciprocal held-out spectral validation
if showSpectra
    figs(end+1,1) = figure('Color','w','Name', ...
        [methodName,': depth series and held-out validation spectra'], ...
        'Units','normalized','Position',[0.08 0.06 0.84 0.86]);
    layout = tiledlayout(figs(end),2,2, ...
        'TileSpacing','compact','Padding','compact');
    depthAxisA = nexttile(layout,1);
    plotSegmentData(depthAxisA,result.dataA,'Segment A');
    set(depthAxisA,'Tag','cvCOCO-depth-A');
    depthAxisB = nexttile(layout,2);
    plotSegmentData(depthAxisB,result.dataB,'Segment B');
    set(depthAxisB,'Tag','cvCOCO-depth-B');
    spectrumAxisBtoA = nexttile(layout,3);
    plotSpectrumComparison(spectrumAxisBtoA,result.spectra.validateBtoA, ...
        spectrumTitle('B','A',result.validateBtoA), ...
        frequencyLimit,targetLegend,true);
    set(spectrumAxisBtoA,'Tag','cvCOCO-spectrum-BtoA');
    spectrumAxisAtoB = nexttile(layout,4);
    plotSpectrumComparison(spectrumAxisAtoB,result.spectra.validateAtoB, ...
        spectrumTitle('A','B',result.validateAtoB), ...
        frequencyLimit,targetLegend,false);
    set(spectrumAxisAtoB,'Tag','cvCOCO-spectrum-AtoB');
    title(layout,[methodName,' data and held-out validation spectra']);
end

%% Main result: stacked panels parallel to the original COCO result figure
figs(end+1,1) = figure('Color','w','Name', ...
    [methodName,': correlation and significance'], ...
    'Units','normalized','Position',[0.15 0.02 0.70 0.94]);
layout = tiledlayout(figs(end),4,1, ...
    'TileSpacing','compact','Padding','compact');

ax1 = nexttile(layout,1);
hold(ax1,'on');

plot(ax1,sr,result.validateBtoA.curve(:),'b-','LineWidth',1.1, ...
    'DisplayName','B train \rightarrow A validate');
plot(ax1,sr,result.validateAtoB.curve(:),'r-','LineWidth',1.1, ...
    'DisplayName','A train \rightarrow B validate');

markBest(ax1,result.validateBtoA.bestRate,result.validateBtoA.score,'b');
markBest(ax1,result.validateAtoB.bestRate,result.validateAtoB.score,'r');

formatRateAxis(ax1,sr,'Held-out frozen-target correlation coefficient','\rho');
legend(ax1,'Location','best','NumColumns',2);

ax2 = nexttile(layout,2);
plotPipelinePPanel(ax2,sr,result);

ax3 = nexttile(layout,3);
plotLocalPPanel(ax3,sr,result);

ax4 = nexttile(layout,4);
formatRateAxis(ax4,sr,'Resolvable orbital-period count','#');
ylim(ax4,[0 9.5]);
hold(ax4,'on');
shadeOutsideAllNineRange(ax4,sr,result.allNineRateRangeShared);
plot(ax4,sr,result.orbitCountA(:),'b-','LineWidth',2, ...
    'DisplayName','Segment A');
plot(ax4,sr,result.orbitCountB(:),'r--','LineWidth',1, ...
    'DisplayName','Segment B');
legend(ax4,'Location','best','NumColumns',2);
xlabel(ax4,'Sedimentation rate (cm/kyr)');
title(layout,[methodName,' bidirectional held-out result']);

%% Directional and secondary symmetric nulls use the same outer AR(1) runs
figs(end+1,1) = figure('Color','w','Name',[methodName,': Monte Carlo audit'], ...
    'Units','normalized','Position',[0.20 0.03 0.60 0.91]);
layout = tiledlayout(figs(end),3,1, ...
    'TileSpacing','compact','Padding','compact');
plotNullDistribution(nexttile(layout,1),result.nullSymmetric, ...
    result.scoreSymmetric,result.pSym, ...
    'Secondary symmetric joint test','Null T_{sym}');
plotNullDistribution(nexttile(layout,2),result.nullBtoA, ...
    result.validateBtoA.score,result.pA, ...
    sprintf('B \\rightarrow A: A held out; best rate %.4g cm/kyr', ...
    result.validateBtoA.bestRate),'Null maximum S_{B\rightarrowA}');
plotNullDistribution(nexttile(layout,3),result.nullAtoB, ...
    result.validateAtoB.score,result.pB, ...
    sprintf('A \\rightarrow B: B held out; best rate %.4g cm/kyr', ...
    result.validateAtoB.bestRate),'Null maximum S_{A\rightarrowB}');
title(layout,[methodName,' stationary AR(1) full-pipeline audit']);
end

function shadeOutsideAllNineRange(ax,sr,strictRange)
if isempty(sr) || numel(strictRange) ~= 2 || any(~isfinite(strictRange))
    return
end
xLimits = [sr(1),sr(end)] + (sr(1)==sr(end))*[-0.5 0.5];
yLimits = ylim(ax);
lower = strictRange(1);
upper = strictRange(2);
regions = zeros(0,2);
if lower >= upper
    regions = xLimits;
else
    if lower > xLimits(1)
        regions(end+1,:) = [xLimits(1),min(lower,xLimits(2))];
    end
    if upper < xLimits(2)
        regions(end+1,:) = [max(upper,xLimits(1)),xLimits(2)];
    end
end
for ii = 1:size(regions,1)
    if regions(ii,2) <= regions(ii,1)
        continue
    end
    visibility = 'off';
    displayName = '';
    if ii == 1
        visibility = 'on';
        displayName = 'Outside shared 9-period range';
    end
    patch(ax,regions(ii,[1 2 2 1]),yLimits([1 1 2 2]), ...
        [0.88 0.88 0.88],'EdgeColor','none','FaceAlpha',0.55, ...
        'HandleVisibility',visibility,'DisplayName',displayName);
end
end

function plotSegmentData(ax,data,label)
plot(ax,data(:,1),data(:,2),'k-','LineWidth',0.9);
xlabel(ax,'Depth (m)');
ylabel(ax,'Proxy value');
title(ax,sprintf('%s depth series',label));
set(ax,'XMinorTick','on','YMinorTick','on');
grid(ax,'on');
box(ax,'on');
end

function plotSpectrumComparison(ax,diagnostic,titleText,frequencyLimit, ...
        targetLegend,showLegend)
if isempty(diagnostic.frequency)
    showUnavailable(ax,titleText);
    return
end
dataPower = normalizeVisiblePower( ...
    diagnostic.frequency,diagnostic.dataPower,frequencyLimit);
targetPower = normalizeVisiblePower( ...
    diagnostic.frequency,diagnostic.targetPower,frequencyLimit);
plot(ax,diagnostic.frequency,dataPower,'k-','LineWidth',1, ...
    'DisplayName','Validation data');
hold(ax,'on');
plot(ax,diagnostic.frequency,targetPower,'r-','LineWidth',1, ...
    'DisplayName',targetLegend);
formatSpectrumAxis(ax,titleText,frequencyLimit);
if showLegend
    legend(ax,'Location','best');
end
xlabel(ax,'Frequency (cycle/kyr)');
ylabel(ax,'Normalized power');
end

function value = resultText(result,fieldName,fallback)
value = fallback;
if isfield(result,fieldName)
    candidate = result.(fieldName);
    if (ischar(candidate) && ~isempty(candidate)) || ...
            (isstring(candidate) && isscalar(candidate) && strlength(candidate) > 0)
        value = char(candidate);
    end
end
end

function [description,legendText] = targetLabels(targetModel)
targetModel = validatestring(targetModel, ...
    {'four-group','four-group-coherent-nine', ...
     'rayleigh-peak-coherent-nine','legacy'}, ...
    mfilename,'result.targetModel');
switch targetModel
    case 'four-group'
        description = 'phase-averaged four-group target';
        legendText = 'Frozen phase-averaged four-group target';
    case 'four-group-coherent-nine'
        description = 'method-B four-group-trained coherent nine-term target';
        legendText = 'Frozen coherent 9-period target';
    case 'rayleigh-peak-coherent-nine'
        description = ...
            'method-A per-orbit Rayleigh-peak coherent nine-term target';
        legendText = 'Frozen nine-amplitude coherent target (cvCOCO9A)';
    case 'legacy'
        description = 'legacy coherent nine-term target';
        legendText = 'Frozen legacy coherent nine-term target';
end
end

function textValue = spectrumTitle(trainLabel,validationLabel,validation)
participation = '';
if isfield(validation,'participatingPeriodCount') && ...
        isnumeric(validation.participatingPeriodCount) && ...
        isscalar(validation.participatingPeriodCount) && ...
        isfinite(validation.participatingPeriodCount)
    participation = sprintf('; %d/9 periods', ...
        round(validation.participatingPeriodCount));
end
textValue = sprintf([ ...
    '%s train \\rightarrow %s held out at %.4g cm/kyr\n', ...
    '\\rho = %.4g%s'],trainLabel,validationLabel, ...
    validation.bestRate,validation.score,participation);
end

function formatSpectrumAxis(ax,titleText,frequencyLimit)
xlim(ax,[0 frequencyLimit]);
ylim(ax,[0 1.05]);
title(ax,titleText);
set(ax,'XMinorTick','on','YMinorTick','on');
box(ax,'on');
end

function showUnavailable(ax,titleText)
axis(ax,'off');
text(ax,0.5,0.5,'Spectrum unavailable for the selected rate grid', ...
    'HorizontalAlignment','center');
title(ax,titleText);
end

function formatRateAxis(ax,sr,titleText,yLabelText)
if ~isempty(sr)
    xlim(ax,[sr(1) sr(end)] + (sr(1)==sr(end))*[-0.5 0.5]);
end
ylabel(ax,yLabelText);
title(ax,titleText);
set(ax,'XMinorTick','on','YMinorTick','on');
grid(ax,'on');
box(ax,'on');
end

function plotPipelinePPanel(ax,sr,result)
set(ax,'Tag','cvCOCO-global-p');
pAtoB = result.pCurveAtoB(:);
pBtoA = result.pCurveBtoA(:);
nMC = max([result.nsimValidAtoB,result.nsimValidBtoA,0]);
if nMC <= 0 || (~any(isfinite(pAtoB)) && ~any(isfinite(pBtoA)))
    axis(ax,'off');
    text(ax,0.5,0.58,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,'Directional full-pipeline p curves are unavailable', ...
        'HorizontalAlignment','center');
    title(ax,'Full-pipeline significance');
    return
end

pFloor = 1/(nMC+1);
scoreAtoB = pToPeakScore(pAtoB,pFloor);
scoreBtoA = pToPeakScore(pBtoA,pFloor);
hold(ax,'on');
lineBtoA = plot(ax,sr,scoreBtoA,'b-','LineWidth',1.2, ...
    'DisplayName',sprintf('A held out; p_A=%.4g',result.pA));
set(lineBtoA,'Tag','cvCOCO-global-p-BtoA');
lineAtoB = plot(ax,sr,scoreAtoB,'r-','LineWidth',1.2, ...
    'DisplayName',sprintf('B held out; p_B=%.4g',result.pB));
set(lineAtoB,'Tag','cvCOCO-global-p-AtoB');
markBest(ax,result.validateAtoB.bestRate, ...
    -log10(max(result.pB,pFloor)),'r');
markBest(ax,result.validateBtoA.bestRate, ...
    -log10(max(result.pA,pFloor)),'b');

thresholds = [0.50 0.10 0.05 0.02 0.01 0.001];
styles = {'k:', 'k:','k--','k:','k:','k:'};
for ii = 1:numel(thresholds)
    if thresholds(ii) >= pFloor
        plot(ax,sr,repmat(-log10(thresholds(ii)),size(sr)),styles{ii}, ...
            'LineWidth',0.75,'HandleVisibility','off');
    end
end

pRobust = max(result.pA,result.pB);
formatRateAxis(ax,sr,sprintf( ...
    'Directional global p (p_{robust}=%.4g)',pRobust),'Global p');
setGlobalPLabels(ax,[pAtoB;pBtoA],pFloor);
legend(ax,'Location','best','NumColumns',2);
end

function plotLocalPPanel(ax,sr,result)
set(ax,'Tag','cvCOCO-local-p');
pAtoB = result.pLocalCurveAtoB(:);
pBtoA = result.pLocalCurveBtoA(:);
nMC = max([result.nsimValidAtoB,result.nsimValidBtoA,0]);
if nMC <= 0 || (~any(isfinite(pAtoB)) && ~any(isfinite(pBtoA)))
    axis(ax,'off');
    text(ax,0.5,0.58,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,'Directional local p curves are unavailable', ...
        'HorizontalAlignment','center');
    title(ax,'Directional local p-value (descriptive diagnostic only)');
    return
end

pFloor = 1/(nMC+1);
scoreAtoB = pToPeakScore(pAtoB,pFloor);
scoreBtoA = pToPeakScore(pBtoA,pFloor);
hold(ax,'on');
lineBtoA = plot(ax,sr,scoreBtoA,'b-','LineWidth',1.2, ...
    'DisplayName',sprintf( ...
    'Segment A held out (B train \\rightarrow A); local p at peak=%.4g', ...
    localPAtBest(pBtoA,result.validateBtoA)));
set(lineBtoA,'Tag','cvCOCO-local-p-BtoA');
lineAtoB = plot(ax,sr,scoreAtoB,'r-','LineWidth',1.2, ...
    'DisplayName',sprintf( ...
    'Segment B held out (A train \\rightarrow B); local p at peak=%.4g', ...
    localPAtBest(pAtoB,result.validateAtoB)));
set(lineAtoB,'Tag','cvCOCO-local-p-AtoB');

localAtoBAtBest = localPAtBest(pAtoB,result.validateAtoB);
localBtoAAtBest = localPAtBest(pBtoA,result.validateBtoA);
markBest(ax,result.validateAtoB.bestRate, ...
    -log10(max(localAtoBAtBest,pFloor)),'r');
markBest(ax,result.validateBtoA.bestRate, ...
    -log10(max(localBtoAAtBest,pFloor)),'b');

thresholds = [0.10 0.05 0.02 0.01 0.001];
for ii = 1:numel(thresholds)
    if thresholds(ii) < pFloor
        continue
    end
    style = 'k:';
    width = 0.75;
    if thresholds(ii) == 0.01
        style = 'k--';
        width = 0.9;
    end
    plot(ax,sr,repmat(-log10(thresholds(ii)),size(sr)),style, ...
        'LineWidth',width,'HandleVisibility','off');
end

formatRateAxis(ax,sr, ...
    'Directional local p-value (same-rate; descriptive diagnostic only)', ...
    'Local p');
setLogPLabels(ax,[scoreAtoB;scoreBtoA],pFloor);
legend(ax,'Location','best','NumColumns',2);
end

function value = localPAtBest(pCurve,validation)
value = NaN;
if ~isstruct(validation) || ~isfield(validation,'bestIndex') || ...
        ~isnumeric(validation.bestIndex) || ...
        ~isscalar(validation.bestIndex) || ~isfinite(validation.bestIndex)
    return
end
index = validation.bestIndex;
if index == fix(index) && index >= 1 && index <= numel(pCurve)
    value = pCurve(index);
end
end

function score = pToPeakScore(p,pFloor)
score = nan(size(p));
ok = isfinite(p) & p > 0;
score(ok) = -log10(max(p(ok),pFloor));
end

function setLogPLabels(ax,score,pFloor)
score = score(isfinite(score));
yBottom = -log10(1.01);
if isempty(score)
    yTop = -log10(pFloor);
else
    yTop = max([score(:);-log10(pFloor)]);
end

if ~isfinite(yTop) || yTop <= 0
    yTop = yBottom+0.5;
end
yTop = max(yTop,yBottom+0.5);
yRange = max(yTop-yBottom,0.5);
ylim(ax,[yBottom,yTop+0.12*yRange]);

% Match the deliberately sparse labels used by Adaptive COCO.  Adding
% every 2x/5x tick below 0.002 makes labels overlap in this shorter panel;
% the curve and its Monte Carlo resolution are unchanged.
pTicks = [1 0.1 0.05 0.02 0.01 0.002 0.001];
pTicks = pTicks(pTicks >= pFloor & -log10(pTicks) <= yTop+0.12*yRange);
set(ax,'YDir','normal','YTick',-log10(pTicks), ...
    'YTickLabel',compose('%.4g',pTicks),'YMinorTick','off');
end

function setGlobalPLabels(ax,p,pFloor)
% Use the publication-scale 1--0.002 view unless the observed global-p
% curves require the smaller-value range supported by the Monte Carlo run.
defaultMinimumP = 0.002;
p = p(isfinite(p) & p > 0);
if isempty(p) || min(p) >= defaultMinimumP
    pTicks = [1 0.1 0.05 0.02 0.01 defaultMinimumP];
    ylim(ax,[0 -log10(defaultMinimumP)]);
    set(ax,'YDir','normal','YTick',-log10(pTicks), ...
        'YTickLabel',compose('%.4g',pTicks),'YMinorTick','off');
    return
end
setLogPLabels(ax,-log10(max(p,pFloor)),pFloor);
end

function plotNullDistribution(ax,nullScores,observed,pValue,titleText,xLabelText)
nullScores = nullScores(:);
nullScores = nullScores(isfinite(nullScores));
if isempty(nullScores)
    axis(ax,'off');
    text(ax,0.5,0.6,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,sprintf('Observed statistic = %.4g',observed), ...
        'HorizontalAlignment','center');
    title(ax,titleText);
    return
end
histogram(ax,nullScores,'Normalization','probability', ...
    'FaceColor',[0.65 0.70 0.78],'EdgeColor','none', ...
    'DisplayName','Stationary AR(1) null');
hold(ax,'on');
yl = ylim(ax);
plot(ax,[observed observed],yl,'r-','LineWidth',1.8, ...
    'DisplayName','Observed statistic');
ylim(ax,yl);
xlabel(ax,xLabelText);
ylabel(ax,'Proportion');
title(ax,sprintf('%s\np=%.4g, N=%d',titleText,pValue,numel(nullScores)));
legend(ax,'Location','best');
grid(ax,'on');
box(ax,'on');
end

function y = normalizeVisiblePower(x,y,frequencyLimit)
x = x(:);
y = y(:);
ok = isfinite(x) & isfinite(y) & x >= 0 & x <= frequencyLimit;
scale = max(y(ok));
if isempty(scale) || ~isfinite(scale) || scale <= 0
    scale = max(y(isfinite(y)));
end
if isempty(scale) || ~isfinite(scale) || scale <= 0
    scale = 1;
end
y = y./scale;
end

function limit = resultFrequencyLimit(result)
if ~isstruct(result.config) || ...
        ~isfield(result.config,'maximumTemporalFrequency')
    error('plotcvcoco:MissingMaximumFrequency', ...
        ['The result does not record config.maximumTemporalFrequency; ', ...
         'the plotted interval cannot be guaranteed to match the ', ...
         'correlation interval. Re-run cvCOCO with the current engine.']);
end
limit = result.config.maximumTemporalFrequency;
if ~isnumeric(limit) || ~isscalar(limit) || ~isreal(limit) || ...
        ~isfinite(limit) || limit <= 0
    error('plotcvcoco:InvalidMaximumFrequency', ...
        'config.maximumTemporalFrequency must be a positive finite scalar.');
end
end

function markBest(ax,rate,score,color)
if ~isfinite(rate) || ~isfinite(score)
    return
end
plot(ax,rate,score,'o','Color',color,'MarkerFaceColor',color, ...
    'MarkerSize',5,'HandleVisibility','off');
end
