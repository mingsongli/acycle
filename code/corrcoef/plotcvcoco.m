function figs = plotcvcoco(result,varargin)
%PLOTCVCOCO Plot a cvCOCO result in the COCO diagnostic style.
%
% The correlation and significance panels retain both directional curves
% and overlay the existing same-rate bidirectional minimum consensus as a
% black curve. Consensus local/global p curves come from the joint
% full-pipeline Monte Carlo result; they are not post-hoc combinations of
% the directional p values. Their directional values at the observed
% maxima remain pB (A -> B) and pA (B -> A). The default Monte Carlo audit
% shows the same-rate consensus global test used by the black curve.
% A separate pCOCO page uses the Adaptive COCO definition: same-rate
% consensus rho times abs(log10(joint consensus global p)).
%
% PLOTCVCOCO(RESULT,'ShowSpectra',false) omits the depth/spectrum diagnostic.
% PLOTCVCOCO(RESULT,'Tabbed',true) places every requested diagnostic in one
% figure with one tab per page. The default false preserves standalone
% publication/export callers that intentionally request separate figures.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'ShowSpectra',true,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
addParameter(parser,'Tabbed',false,@(x) ...
    (islogical(x) || isnumeric(x)) && isscalar(x) && isfinite(x) && ...
    any(x == [0 1]));
parse(parser,varargin{:});
showSpectra = logical(parser.Results.ShowSpectra);
useTabs = logical(parser.Results.Tabbed);

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
methodName = resultText(result,'publicName', ...
    resultText(result,'name','Blocked cvCOCO'));
if strcmp(methodName,'cvCOCO')
    % Old saved midpoint-split results retain their original metadata, but
    % use the paired public name when plotted by current code.
    methodName = 'Blocked cvCOCO';
end
showConsensusP = hasConsensusPCurves(result);
showConsensusCorrelation = showConsensusP;
if showConsensusP
    validateConsensusResult(result,numel(sr));
end
[foldLabelA,foldLabelB,directionLabelA,directionLabelB] = ...
    resultFoldLabels(result);
[~,targetLegend] = targetLabels(result.targetModel);
if strcmp(result.targetModel,'legacy') && ...
        ~contains(lower(methodName),'legacy')
    methodName = [methodName,' (legacy target)'];
end
if isfield(result,'degradedMode') && isscalar(result.degradedMode) && ...
        logical(result.degradedMode)
    methodName = [methodName,' (partial-orbit exploratory)'];
end
figs = gobjects(0,1);
tabs = gobjects(0);
if useTabs
    figs = figure('Color','w','Name',[methodName,': diagnostics'], ...
        'Units','normalized','Position',[0.29 0.04 0.42 0.90]);
    tabs = uitabgroup(figs);
end

%% Depth-domain halves and their reciprocal held-out spectral validation
if showSpectra
    if useTabs
        plotParent = uitab(tabs,'Title','Data and spectra');
    else
        figs(end+1,1) = figure('Color','w','Name', ...
            [methodName,': depth series and held-out validation spectra'], ...
            'Units','normalized','Position',[0.08 0.06 0.84 0.86]);
        plotParent = figs(end);
    end
    layout = tiledlayout(plotParent,2,2, ...
        'TileSpacing','compact','Padding','compact');
    depthAxisA = nexttile(layout,1);
    plotSegmentData(depthAxisA,result.dataA,foldLabelA);
    set(depthAxisA,'Tag','cvCOCO-depth-A');
    depthAxisB = nexttile(layout,2);
    plotSegmentData(depthAxisB,result.dataB,foldLabelB);
    set(depthAxisB,'Tag','cvCOCO-depth-B');
    spectrumAxisBtoA = nexttile(layout,3);
    plotSpectrumComparison(spectrumAxisBtoA,result.spectra.validateBtoA, ...
        spectrumTitle(directionLabelB,directionLabelA, ...
        result.validateBtoA), ...
        frequencyLimit,targetLegend,true);
    set(spectrumAxisBtoA,'Tag','cvCOCO-spectrum-BtoA');
    spectrumAxisAtoB = nexttile(layout,4);
    plotSpectrumComparison(spectrumAxisAtoB,result.spectra.validateAtoB, ...
        spectrumTitle(directionLabelA,directionLabelB, ...
        result.validateAtoB), ...
        frequencyLimit,targetLegend,false);
    set(spectrumAxisAtoB,'Tag','cvCOCO-spectrum-AtoB');
    title(layout,[methodName,' data and held-out validation spectra']);
end

%% Main result: stacked panels parallel to the original COCO result figure
if useTabs
    plotParent = uitab(tabs,'Title','Correlation and significance');
else
    figs(end+1,1) = figure('Color','w','Name', ...
        [methodName,': correlation and significance'], ...
        'Units','normalized','Position',[0.15 0.02 0.70 0.94]);
    plotParent = figs(end);
end
layout = tiledlayout(plotParent,4,1, ...
    'TileSpacing','compact','Padding','compact');

ax1 = nexttile(layout,1);
set(ax1,'Tag','cvCOCO-correlation');
hold(ax1,'on');

plot(ax1,sr,result.validateBtoA.curve(:),'b-','LineWidth',0.55, ...
    'DisplayName',directionLabelA);
plot(ax1,sr,result.validateAtoB.curve(:),'r-','LineWidth',0.55, ...
    'DisplayName',directionLabelB);
if showConsensusCorrelation
    consensusLine = plot(ax1,sr,result.consensus.curve(:),'k-', ...
        'LineWidth',1.2, ...
        'DisplayName','Consensus');
    set(consensusLine,'Tag','cvCOCO-correlation-consensus');
end

markBest(ax1,result.validateBtoA.bestRate,result.validateBtoA.score,'b', ...
    'cvCOCO-correlation-BtoA-peak');
markBest(ax1,result.validateAtoB.bestRate,result.validateAtoB.score,'r', ...
    'cvCOCO-correlation-AtoB-peak');
if showConsensusCorrelation
    markBest(ax1,result.consensus.bestRate, ...
        result.consensus.bestCorrelation,'k', ...
        'cvCOCO-correlation-consensus-peak');
end

formatRateAxis(ax1,sr,'Correlation coefficient','\rho');
legend(ax1,'Location','best','NumColumns',1,'Orientation','vertical');

ax2 = nexttile(layout,2);
plotPipelinePPanel(ax2,sr,result,directionLabelA,directionLabelB, ...
    showConsensusP);

ax3 = nexttile(layout,3);
plotLocalPPanel(ax3,sr,result,directionLabelA,directionLabelB, ...
    showConsensusP);

ax4 = nexttile(layout,4);
set(ax4,'Tag','COCO-orbit-count');
formatRateAxis(ax4,sr, ...
    'Number of contributing astronomical parameters','#');
ylim(ax4,[0 9.5]);
hold(ax4,'on');
cocoShadeOutsideAllPeriodRange( ...
    ax4,sr,result.allNineRateRangeShared);
plot(ax4,sr,result.orbitCountA(:),'b-','LineWidth',1, ...
    'DisplayName',foldLabelA);
plot(ax4,sr,result.orbitCountB(:),'r--','LineWidth',0.5, ...
    'DisplayName',foldLabelB);
legend(ax4,'Location','best','NumColumns',1,'Orientation','vertical');
xlabel(ax4,'Sedimentation rate (cm/kyr)');
title(layout,[methodName,' bidirectional held-out result']);

%% Adaptive-style pCOCO from the same-rate consensus curve and joint null
if showConsensusP
    if useTabs
        plotParent = uitab(tabs,'Title','pCOCO');
    else
        figs(end+1,1) = figure('Color','w', ...
            'Name',[methodName,': pCOCO'], ...
            'Units','normalized','Position',[0.24 0.12 0.52 0.70]);
        plotParent = figs(end);
    end
    axPcoco = axes(plotParent);
    plotConsensusPcoco(axPcoco,sr,result);
end

%% Consensus and directional nulls use the same outer AR(1) runs
if useTabs
    plotParent = uitab(tabs,'Title','Monte Carlo audit');
else
    figs(end+1,1) = figure('Color','w', ...
        'Name',[methodName,': Monte Carlo audit'], ...
        'Units','normalized','Position',[0.20 0.03 0.60 0.91]);
    plotParent = figs(end);
end
layout = tiledlayout(plotParent,3,1, ...
    'TileSpacing','compact','Padding','compact');
jointAuditAxis = nexttile(layout,1);
if hasConsensusAudit(result)
    plotNullDistribution(jointAuditAxis,result.nullConsensus, ...
        result.scoreConsensus,result.pConsensus, ...
        'Consensus global p','Null consensus maximum');
    set(jointAuditAxis,'Tag','cvCOCO-consensus-global-audit');
else
    % Compatibility fallback for results saved before the same-rate
    % consensus null distribution was added.
    plotNullDistribution(jointAuditAxis,result.nullSymmetric, ...
        result.scoreSymmetric,result.pSym, ...
        'Symmetric joint p','Null symmetric maximum');
    set(jointAuditAxis,'Tag','cvCOCO-symmetric-audit');
end
directionAAuditAxis = nexttile(layout,2);
plotNullDistribution(directionAAuditAxis,result.nullBtoA, ...
    result.validateBtoA.score,result.pA, ...
    sprintf('%s held out; global p; best %.4g cm/kyr', ...
    directionLabelA,result.validateBtoA.bestRate), ...
    'Null directional maximum');
set(directionAAuditAxis,'Tag','cvCOCO-direction-A-global-audit');
directionBAuditAxis = nexttile(layout,3);
plotNullDistribution(directionBAuditAxis,result.nullAtoB, ...
    result.validateAtoB.score,result.pB, ...
    sprintf('%s held out; global p; best %.4g cm/kyr', ...
    directionLabelB,result.validateAtoB.bestRate), ...
    'Null directional maximum');
set(directionBAuditAxis,'Tag','cvCOCO-direction-B-global-audit');
title(layout,[methodName,' Monte Carlo audit']);
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
    legend(ax,'Location','best','NumColumns',1,'Orientation','vertical');
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

function [foldA,foldB,directionA,directionB] = resultFoldLabels(result)
% Preserve the established contiguous-half labels unless a result records
% explicit fold names (for example, {'Odd','Even'} for interleaved cvCOCO).
foldA = 'Segment A';
foldB = 'Segment B';
directionA = 'A';
directionB = 'B';
if ~isstruct(result) || ~isfield(result,'foldLabels')
    return
end
labels = result.foldLabels;
if isstring(labels)
    if numel(labels) ~= 2
        return
    end
    labels = cellstr(labels(:));
elseif iscell(labels)
    if numel(labels) ~= 2
        return
    end
    labels = labels(:);
else
    return
end
for labelIndex = 1:2
    value = labels{labelIndex};
    if ~(ischar(value) || (isstring(value) && isscalar(value)))
        return
    end
    labels{labelIndex} = strtrim(char(string(value)));
    if isempty(labels{labelIndex})
        return
    end
end
foldA = labels{1};
foldB = labels{2};
if strcmpi(foldA,'Segment A') && strcmpi(foldB,'Segment B')
    directionA = 'A';
    directionB = 'B';
else
    directionA = foldA;
    directionB = foldB;
end
end

function tf = hasConsensusPCurves(result)
required = {'consensus','pCurveConsensus','pLocalCurveConsensus', ...
    'pConsensus','nsimValidConsensus'};
tf = isstruct(result) && all(cellfun( ...
    @(name)isfield(result,name),required));
end

function tf = hasConsensusAudit(result)
required = {'nullConsensus','scoreConsensus','pConsensus'};
tf = isstruct(result) && all(cellfun( ...
    @(name)isfield(result,name),required));
if ~tf
    return
end
tf = isnumeric(result.nullConsensus) && ...
    isreal(result.nullConsensus) && isvector(result.nullConsensus) && ...
    isnumeric(result.scoreConsensus) && ...
    isreal(result.scoreConsensus) && isscalar(result.scoreConsensus) && ...
    isnumeric(result.pConsensus) && ...
    isreal(result.pConsensus) && isscalar(result.pConsensus);
end

function validateConsensusResult(result,nRate)
required = {'consensus','pCurveConsensus','pLocalCurveConsensus', ...
    'pConsensus','nsimValidConsensus'};
missing = required(~cellfun(@(name)isfield(result,name),required));
if ~isempty(missing)
    error('plotcvcoco:MissingConsensus', ...
        ['cvCOCO result is missing consensus field(s): ', ...
         '%s. Recalculate the result with the current engine.'], ...
        strjoin(missing,', '));
end
consensusFields = {'curve','bestRate','bestIndex','bestCorrelation', ...
    'pLocalAtBest'};
if ~isstruct(result.consensus) || ~isscalar(result.consensus) || ...
        ~all(isfield(result.consensus,consensusFields)) || ...
        numel(result.consensus.curve) ~= nRate || ...
        ~isnumeric(result.consensus.bestRate) || ...
        ~isscalar(result.consensus.bestRate) || ...
        ~isnumeric(result.consensus.bestCorrelation) || ...
        ~isscalar(result.consensus.bestCorrelation)
    error('plotcvcoco:InvalidConsensus', ...
        ['cvCOCO result.consensus must contain a rate-grid ', ...
         'curve and scalar best-rate statistics.']);
end
curveFields = {'pCurveConsensus','pLocalCurveConsensus'};
for fieldIndex = 1:numel(curveFields)
    fieldName = curveFields{fieldIndex};
    if ~(isnumeric(result.(fieldName)) && isreal(result.(fieldName)) && ...
            numel(result.(fieldName)) == nRate)
        error('plotcvcoco:InvalidConsensus', ...
            ['cvCOCO result.%s must contain one real ', ...
             'value per tested sedimentation rate.'],fieldName);
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

function plotPipelinePPanel( ...
        ax,sr,result,directionA,directionB,showConsensus)
set(ax,'Tag','cvCOCO-global-p');
pAtoB = result.pCurveAtoB(:);
pBtoA = result.pCurveBtoA(:);
pConsensus = nan(size(sr));
nMCValues = [result.nsimValidAtoB,result.nsimValidBtoA,0];
if showConsensus
    pConsensus = result.pCurveConsensus(:);
    nMCValues(end+1) = result.nsimValidConsensus;
end
nMC = max(nMCValues);
if nMC <= 0 || (~any(isfinite(pAtoB)) && ...
        ~any(isfinite(pBtoA)) && ~any(isfinite(pConsensus)))
    axis(ax,'off');
    text(ax,0.5,0.58,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,'Directional full-pipeline p curves are unavailable', ...
        'HorizontalAlignment','center');
    title(ax,'Global p');
    return
end

pFloor = 1/(nMC+1);
scoreAtoB = pToPeakScore(pAtoB,pFloor);
scoreBtoA = pToPeakScore(pBtoA,pFloor);
hold(ax,'on');
lineBtoA = plot(ax,sr,scoreBtoA,'b-','LineWidth',0.6, ...
    'DisplayName',sprintf('%s=%s', ...
    directionalPLabel(directionA,'A'),formatProbability4(result.pA)));
set(lineBtoA,'Tag','cvCOCO-global-p-BtoA');
lineAtoB = plot(ax,sr,scoreAtoB,'r-','LineWidth',0.6, ...
    'DisplayName',sprintf('%s=%s', ...
    directionalPLabel(directionB,'B'),formatProbability4(result.pB)));
set(lineAtoB,'Tag','cvCOCO-global-p-AtoB');
if showConsensus
    scoreConsensus = pToPeakScore(pConsensus,pFloor);
    consensusLine = plot(ax,sr,scoreConsensus,'k-', ...
        'LineWidth',1.2, ...
        'DisplayName',sprintf('p_{cons}=%s', ...
        formatProbability4(result.pConsensus)));
    set(consensusLine,'Tag','cvCOCO-global-p-consensus');
end
markBest(ax,result.validateAtoB.bestRate, ...
    -log10(max(result.pB,pFloor)),'r','cvCOCO-global-p-AtoB-peak');
markBest(ax,result.validateBtoA.bestRate, ...
    -log10(max(result.pA,pFloor)),'b','cvCOCO-global-p-BtoA-peak');

thresholds = [0.50 0.10 0.05 0.02 0.01 0.001];
styles = {'k:', 'k:','k--','k:','k:','k:'};
for ii = 1:numel(thresholds)
    if thresholds(ii) >= pFloor
        plot(ax,sr,repmat(-log10(thresholds(ii)),size(sr)),styles{ii}, ...
            'LineWidth',0.75,'HandleVisibility','off');
    end
end
if showConsensus
    uistack(consensusLine,'top');
    markBest(ax,result.consensus.bestRate, ...
        -log10(max(result.pConsensus,pFloor)),'k', ...
        'cvCOCO-global-p-consensus-peak');
end

formatRateAxis(ax,sr,'Global p','Global p');
setGlobalPLabels(ax,[pAtoB;pBtoA;pConsensus],pFloor);
legend(ax,'Location','best','NumColumns',1,'Orientation','vertical');
end

function plotLocalPPanel( ...
        ax,sr,result,directionA,directionB,showConsensus)
set(ax,'Tag','cvCOCO-local-p');
pAtoB = result.pLocalCurveAtoB(:);
pBtoA = result.pLocalCurveBtoA(:);
pConsensus = nan(size(sr));
nMCValues = [result.nsimValidAtoB,result.nsimValidBtoA,0];
if showConsensus
    pConsensus = result.pLocalCurveConsensus(:);
    nMCValues(end+1) = result.nsimValidConsensus;
end
nMC = max(nMCValues);
if nMC <= 0 || (~any(isfinite(pAtoB)) && ...
        ~any(isfinite(pBtoA)) && ~any(isfinite(pConsensus)))
    axis(ax,'off');
    text(ax,0.5,0.58,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,'Directional local p curves are unavailable', ...
        'HorizontalAlignment','center');
    title(ax,'Local p');
    return
end

pFloor = 1/(nMC+1);
scoreAtoB = pToPeakScore(pAtoB,pFloor);
scoreBtoA = pToPeakScore(pBtoA,pFloor);
hold(ax,'on');
lineBtoA = plot(ax,sr,scoreBtoA,'b-','LineWidth',0.6, ...
    'DisplayName',sprintf('%s=%s', ...
    directionalPLabel(directionA,'A'), ...
    formatProbability4(localPAtBest(pBtoA,result.validateBtoA))));
set(lineBtoA,'Tag','cvCOCO-local-p-BtoA');
lineAtoB = plot(ax,sr,scoreAtoB,'r-','LineWidth',0.6, ...
    'DisplayName',sprintf('%s=%s', ...
    directionalPLabel(directionB,'B'), ...
    formatProbability4(localPAtBest(pAtoB,result.validateAtoB))));
set(lineAtoB,'Tag','cvCOCO-local-p-AtoB');
if showConsensus
    scoreConsensus = pToPeakScore(pConsensus,pFloor);
    consensusLine = plot(ax,sr,scoreConsensus,'k-', ...
        'LineWidth',1.2, ...
        'DisplayName',sprintf( ...
        'p_{cons}=%s',formatProbability4( ...
        result.consensus.pLocalAtBest)));
    set(consensusLine,'Tag','cvCOCO-local-p-consensus');
end

localAtoBAtBest = localPAtBest(pAtoB,result.validateAtoB);
localBtoAAtBest = localPAtBest(pBtoA,result.validateBtoA);
markBest(ax,result.validateAtoB.bestRate, ...
    -log10(max(localAtoBAtBest,pFloor)),'r', ...
    'cvCOCO-local-p-AtoB-peak');
markBest(ax,result.validateBtoA.bestRate, ...
    -log10(max(localBtoAAtBest,pFloor)),'b', ...
    'cvCOCO-local-p-BtoA-peak');

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
if showConsensus
    uistack(consensusLine,'top');
    markBest(ax,result.consensus.bestRate, ...
        -log10(max(result.consensus.pLocalAtBest,pFloor)),'k', ...
        'cvCOCO-local-p-consensus-peak');
end

formatRateAxis(ax,sr,'Local p','Local p');
setLogPLabels(ax,[scoreAtoB;scoreBtoA; ...
    pToPeakScore(pConsensus,pFloor)],pFloor);
legend(ax,'Location','best','NumColumns',1,'Orientation','vertical');
end

function plotConsensusPcoco(ax,sr,result)
pCOCO = consensusPcocoCurve(result,sr);
if ~any(isfinite(pCOCO))
    axis(ax,'off');
    text(ax,0.5,0.58,'Monte Carlo was not run', ...
        'HorizontalAlignment','center','FontWeight','bold');
    text(ax,0.5,0.38,'Consensus pCOCO is unavailable', ...
        'HorizontalAlignment','center');
    title(ax,'pCOCO');
    set(ax,'Tag','cvCOCO-pCOCO-axis');
    return
end
plot(ax,sr,pCOCO,'r-','LineWidth',2, ...
    'Tag','cvCOCO-pCOCO','DisplayName','pCOCO');
xlim(ax,[sr(1) sr(end)] + (sr(1)==sr(end))*[-0.5 0.5]);
xlabel(ax,'Sedimentation rate (cm/kyr)');
ylabel(ax,'pCOCO');
set(ax,'Tag','cvCOCO-pCOCO-axis', ...
    'XMinorTick','on','YMinorTick','on');
box(ax,'on');

[bestPCOCO,bestRate] = finiteCurveMaximum(pCOCO,sr);
if ~isfinite(bestRate)
    return
end
hold(ax,'on');
yl = ylim(ax);
plot(ax,[bestRate bestRate],yl,'r--','LineWidth',0.75, ...
    'HandleVisibility','off','Tag','cvCOCO-pCOCO-best-rate');
xLimits = xlim(ax);
yText = yl(1)+0.9*diff(yl);
if bestRate > mean(xLimits)
    alignment = 'right';
    labelText = sprintf('%.4g cm/kyr ',bestRate);
else
    alignment = 'left';
    labelText = sprintf(' %.4g cm/kyr',bestRate);
end
text(ax,bestRate,yText,labelText,'Color','r','FontSize',10, ...
    'HorizontalAlignment',alignment,'VerticalAlignment','top', ...
    'Tag','cvCOCO-pCOCO-best-rate-label');
plot(ax,bestRate,bestPCOCO,'ro','MarkerSize',4, ...
    'MarkerFaceColor','r','HandleVisibility','off', ...
    'Tag','cvCOCO-pCOCO-peak');
end

function pCOCO = consensusPcocoCurve(result,sr)
rho = result.consensus.curve(:);
p = result.pCurveConsensus(:);
if numel(rho) ~= numel(sr) || numel(p) ~= numel(sr)
    error('plotcvcoco:InvalidConsensusPCOCO', ...
        'Consensus rho/global-p curves must match the sedimentation-rate grid.');
end
pSafe = p;
pSafe(~isfinite(pSafe) | pSafe <= 0) = NaN;
pSafe(pSafe > 1) = 1;
pCOCO = rho.*abs(log10(pSafe));
if isfield(result,'pCOCO')
    saved = result.pCOCO(:);
    if numel(saved) ~= numel(pCOCO) || ...
            ~isequaln(saved,pCOCO)
        error('plotcvcoco:InconsistentPCOCO', ...
            ['Stored pCOCO does not equal consensus rho times ', ...
             'abs(log10(consensus global p)).']);
    end
end
end

function [score,bestRate] = finiteCurveMaximum(curve,sr)
score = NaN;
bestRate = NaN;
finiteIndex = find(isfinite(curve));
if isempty(finiteIndex)
    return
end
[score,relativeIndex] = max(curve(finiteIndex));
bestRate = sr(finiteIndex(relativeIndex));
end

function label = directionalPLabel(directionLabel,compatibilityLabel)
if strcmp(directionLabel,compatibilityLabel)
    label = ['p_',compatibilityLabel];
else
    label = ['p_{',directionLabel,'}'];
end
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
legend(ax,'Location','best','NumColumns',1,'Orientation','vertical');
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

function marker = markBest(ax,rate,score,color,tag)
marker = gobjects(0);
if ~isfinite(rate) || ~isfinite(score)
    return
end
markerSize = 2.5;
marker = plot(ax,rate,score,'o','Color',color, ...
    'MarkerFaceColor',color,'MarkerSize',markerSize, ...
    'HandleVisibility','off');
if nargin >= 5 && ~isempty(tag)
    set(marker,'Tag',tag);
end
end

function textValue = formatProbability4(value)
if ~isscalar(value) || ~isfinite(value)
    textValue = 'NaN';
    return
end
if value == 0
    textValue = '0.000';
    return
end
exponent = floor(log10(abs(value)));
decimalPlaces = max(0,4-exponent-1);
textValue = sprintf(['%0.',num2str(decimalPlaces),'f'],value);
end
