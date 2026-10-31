function varargout = multivariateGUI(context,method,dataMatrix,axisValues,seriesNames,baseName)
%MULTIVARIATEGUI Distance-based multivariate analysis for Acycle.
%   MULTIVARIATEGUI(CONTEXT,METHOD,DATAMATRIX,AXISVALUES,SERIESNAMES,BASENAME)
%   opens the PCoA / ANOSIM / PERMANOVA dialog.
%
%   CONTEXT is the main-window handles struct (used for the file-list
%   refresh and the working directory). METHOD selects the initially
%   active method: 'pcoa', 'anosim', or 'permanova'. DATAMATRIX is the
%   n-by-p stacked series matrix (rows = horizons/samples, columns =
%   series/variables, from multivariateLoadSelection), AXISVALUES the
%   common depth/time column, SERIESNAMES the series display names, and
%   BASENAME the export file base (first selected series).
%
%   The numerical kernels (multivariateDistanceMatrix, multivariatePcoa,
%   multivariateAnosim, multivariatePermanova) are ported from PaleoAST,
%   where they are cross-validated against R (vegan::vegdist,
%   vegan::anosim, vegan::adonis2).

if nargin < 2 || isempty(method)
    method = 'pcoa';
end
if nargin < 6 || isempty(baseName)
    baseName = 'data';
end
if nargin < 3
    error('Acycle:Multivariate:MissingData', ...
        'multivariateGUI requires a stacked data matrix; load a selection first.');
end

S = initState(context,method,dataMatrix,axisValues,seriesNames,baseName);
S = createUI(S);
updateDataLabels(S);
setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);

if nargout > 0
    varargout{1} = S.UIFigure;
end
end


function S = initState(context,method,dataMatrix,axisValues,seriesNames,baseName)
S = struct();
S.ctx = context;
S.bg = [0.94 0.94 0.94];
S.blue = [0.08 0.02 0.95];
S.red = [0.8 0 0];
S.method = validateMethod(method);
S.dataMatrix = double(dataMatrix);
S.axisValues = double(axisValues(:));
S.seriesNames = seriesNames;
S.baseName = baseName;
S.unit = '';
if isfield(context,'unit') && ~isempty(context.unit)
    S.unit = char(context.unit);
end
S.run = struct();
end


function method = validateMethod(method)
if isstring(method)
    method = char(method);
end
switch lower(method)
    case {'pcoa','ordination'}
        method = 'pcoa';
    case 'anosim'
        method = 'anosim';
    case 'permanova'
        method = 'permanova';
    otherwise
        method = 'pcoa';
end
end


function S = createUI(S)
S.UIFigure = uifigure('Name','Acycle: Multivariate Analysis (PCoA / ANOSIM / PERMANOVA)', ...
    'Color',S.bg,'Position',[80 60 1180 740],'Resize','off');

% ---- left column -----------------------------------------------------
uilabel(S.UIFigure,'Position',[15 700 1150 30],'Text', ...
    'Distance-based multivariate analysis of selected series', ...
    'FontSize',15,'FontWeight','bold','HorizontalAlignment','left', ...
    'BackgroundColor',S.bg);

uieditfield(S.UIFigure,'text','Editable','off','Position',[15 674 1150 22], ...
    'Value','PCoA: Gower 1966 | ANOSIM: Clarke 1993 | PERMANOVA: Anderson 2001 | ', ...
    'p-values: Phipson & Smyth 2010','BackgroundColor',S.bg);

% Method
S.PMethod = uipanel(S.UIFigure,'Title','Method','Position',[15 552 320 114],'BackgroundColor',S.bg);
% The SelectionChangedFcn is attached only after the initial selection is
% made, so programmatic selection does not fire it during build-out.
S.BGMethod = uibuttongroup(S.PMethod,'BorderType','none','BackgroundColor',S.bg, ...
    'Units','pixels','Position',[1 1 316 88]);
S.RPcoa = uiradiobutton(S.BGMethod,'Text','PCoA ordination (principal coordinates)', ...
    'Tag','pcoa','Position',[12 64 292 18],'BackgroundColor',S.bg);
S.RAnosim = uiradiobutton(S.BGMethod,'Text','ANOSIM (rank test between groups)', ...
    'Tag','anosim','Position',[12 38 292 18],'BackgroundColor',S.bg);
S.RPermanova = uiradiobutton(S.BGMethod,'Text','PERMANOVA (pseudo-F between groups)', ...
    'Tag','permanova','Position',[12 12 292 18],'BackgroundColor',S.bg);
switch S.method
    case 'pcoa'
        S.BGMethod.SelectedObject = S.RPcoa;
    case 'anosim'
        S.BGMethod.SelectedObject = S.RAnosim;
    case 'permanova'
        S.BGMethod.SelectedObject = S.RPermanova;
end
S.BGMethod.SelectionChangedFcn = @(src,evt)onMethodChange(src);
if strcmp(S.method,'pcoa')
    methodNote = 'Optional for PCoA (colors the ordination).';
else
    methodNote = 'The test permutes these group labels.';
end

% Data summary
S.PData = uipanel(S.UIFigure,'Title','Data (rows = samples, columns = series)', ...
    'Position',[15 420 320 124],'BackgroundColor',S.bg);
S.LDataSummary = uilabel(S.PData,'Position',[12 80 296 16],'Text','', ...
    'BackgroundColor',S.bg,'FontWeight','bold');
S.LAxisRange = uilabel(S.PData,'Position',[12 60 296 16],'Text','', ...
    'BackgroundColor',S.bg);
S.TSeriesNames = uitextarea(S.PData,'Position',[12 8 296 48],'Editable','off', ...
    'BackgroundColor',[1 1 1]);

% Distance metric
S.PDistance = uipanel(S.UIFigure,'Title','Distance metric','Position',[15 312 320 100], ...
    'BackgroundColor',S.bg);
uilabel(S.PDistance,'Position',[12 52 120 18],'Text','Metric','BackgroundColor',S.bg);
S.DMetric = uidropdown(S.PDistance, ...
    'Items',{'Euclidean','Bray-Curtis','Jaccard','Manhattan'}, ...
    'Value','Euclidean','Position',[140 48 160 22], ...
    'ValueChangedFcn',@(src,evt)onMetricChange(src));
S.CStandardize = uicheckbox(S.PDistance,'Text','Standardize variables (z-score)', ...
    'Value',true,'Position',[12 26 250 18],'BackgroundColor',S.bg);
uilabel(S.PDistance,'Position',[12 4 296 16], ...
    'Text','Z-score each series before the distance is computed.', ...
    'FontSize',9,'FontColor',[0.35 0.35 0.35],'BackgroundColor',S.bg);

% Groups
S.PGroups = uipanel(S.UIFigure,'Title','Groups (depth/time boundaries)', ...
    'Position',[15 172 320 132],'BackgroundColor',S.bg);
uilabel(S.PGroups,'Position',[12 86 200 16],'Text','Boundaries (ascending)','BackgroundColor',S.bg);
S.EBoundaries = uieditfield(S.PGroups,'text','Value','','Position',[12 62 296 22], ...
    'Tooltip','Split the depth/time axis into groups, e.g. "25 40" makes G1 < 25 <= G2 < 40 <= G3');
uilabel(S.PGroups,'Position',[12 40 296 16],'Text', ...
    'Required for ANOSIM / PERMANOVA (>= 2 groups).','BackgroundColor',S.bg);
S.LGroupNote = uilabel(S.PGroups,'Position',[12 22 296 14],'Text',methodNote, ...
    'FontSize',9,'FontColor',[0.35 0.35 0.35],'BackgroundColor',S.bg);
S.LGroupSummary = uilabel(S.PGroups,'Position',[12 4 296 14],'Text','', ...
    'FontSize',9,'FontColor',[0 0 0.6],'BackgroundColor',S.bg);

% Settings
S.PSettings = uipanel(S.UIFigure,'Title','Test settings','Position',[15 64 320 100], ...
    'BackgroundColor',S.bg);
uilabel(S.PSettings,'Position',[12 52 150 16],'Text','Permutations','BackgroundColor',S.bg);
S.EPermutations = uieditfield(S.PSettings,'text','Value','999','Position',[170 48 130 22]);
uilabel(S.PSettings,'Position',[12 26 150 16],'Text','Random seed (empty = auto)','BackgroundColor',S.bg);
S.ESeed = uieditfield(S.PSettings,'text','Value','','Position',[170 22 130 22]);
uilabel(S.PSettings,'Position',[12 2 150 16],'Text','PCoA neg. eig. correction','BackgroundColor',S.bg);
S.DCorrection = uidropdown(S.PSettings,'Items',{'cmdscale','lingoes'}, ...
    'Value','cmdscale','Position',[170 0 130 22]);

% Run + status
S.BRun = uibutton(S.UIFigure,'push','Text','Run analysis', ...
    'Position',[15 20 150 34],'BackgroundColor',S.blue,'FontColor','white', ...
    'FontWeight','bold','ButtonPushedFcn',@(src,evt)onRun(src));
S.BSaveData = uibutton(S.UIFigure,'push','Text','Save data', ...
    'Position',[175 20 78 34],'ButtonPushedFcn',@(src,evt)onSaveData(src));
S.BSaveFig = uibutton(S.UIFigure,'push','Text','Save figure', ...
    'Position',[257 20 78 34],'ButtonPushedFcn',@(src,evt)onSaveFigure(src));
S.LStatus = uilabel(S.UIFigure,'Position',[15 2 320 16],'Text','Ready.', ...
    'FontSize',9,'FontColor',[0 0 0.6],'BackgroundColor',S.bg);

% ---- right column ----------------------------------------------------
S.AxOrdination = uiaxes(S.UIFigure,'Position',[355 392 395 268]);
title(S.AxOrdination,'Ordination (PC1 vs PC2)');
xlabel(S.AxOrdination,'PC1'); ylabel(S.AxOrdination,'PC2');
grid(S.AxOrdination,'on'); box(S.AxOrdination,'on');

S.AxSecondary = uiaxes(S.UIFigure,'Position',[760 392 405 268]);
title(S.AxSecondary,'Scree / null distribution');
grid(S.AxSecondary,'on'); box(S.AxSecondary,'on');

uilabel(S.UIFigure,'Position',[355 366 810 20],'Text','Results', ...
    'FontWeight','bold','FontSize',12,'BackgroundColor',S.bg);
S.TReport = uitextarea(S.UIFigure,'Position',[355 60 810 300], ...
    'Editable','off','FontName','FixedWidth');

setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
end


function updateDataLabels(S)
n = size(S.dataMatrix,1);
p = size(S.dataMatrix,2);
S.LDataSummary.Text = sprintf('%d series, %d samples (rows)',p,n);
if isempty(S.unit)
    S.LAxisRange.Text = sprintf('Axis range: [%.6g, %.6g]', ...
        min(S.axisValues),max(S.axisValues));
else
    S.LAxisRange.Text = sprintf('Axis range: [%.6g, %.6g] %s', ...
        min(S.axisValues),max(S.axisValues),S.unit);
end
if p <= 12
    S.TSeriesNames.Value = strjoin(S.seriesNames,newline);
else
    S.TSeriesNames.Value = strjoin([S.seriesNames(1:11),{sprintf('... %d more',p-12)}],newline);
end
end


function S = getState(handleObject)
fig = ancestor(handleObject,'figure');
S = getappdata(fig,'MULTIVARIATE_STATE');
end


function onMethodChange(src)
S = getState(src);
selected = S.BGMethod.SelectedObject;
if isempty(selected)
    return
end
S.method = selected.Tag;
if strcmp(S.method,'pcoa')
    S.LGroupNote.Text = 'Optional for PCoA (colors the ordination).';
else
    S.LGroupNote.Text = 'The test permutes these group labels.';
end
setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
end


function onMetricChange(src)
S = getState(src);
% Sensible standardization defaults: metrics that normalize or binarize
% on their own do not want z-scored input.
switch S.DMetric.Value
    case {'Bray-Curtis','Jaccard'}
        S.CStandardize.Value = false;
    otherwise
        S.CStandardize.Value = true;
end
setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
end


function onRun(src)
S = getState(src);
try
    S.LStatus.Text = 'Computing...';
    drawnow;

    [metric,standardize] = readDistanceInputs(S);
    needsGroups = ~strcmp(S.method,'pcoa');
    [groups,groupNames] = readGroups(S,needsGroups);
    if needsGroups
        nPermutations = readPermutations(S);
        randomSeed = readSeed(S);
    else
        nPermutations = 0;
        randomSeed = [];
    end

    % Snapshot the exact inputs used by this run so the exported
    % parameter table cannot drift from the live dialog fields.
    S.run.inputs = struct('method',S.method,'metric',metric, ...
        'standardize',logical(standardize),'permutations',nPermutations, ...
        'boundariesText',S.EBoundaries.Value,'seedText',S.ESeed.Value, ...
        'correction',S.DCorrection.Value);

    distanceMatrix = multivariateDistanceMatrix(S.dataMatrix,metric,standardize);

    switch S.method
        case 'pcoa'
            S = runPcoa(S,distanceMatrix,groups,groupNames);
        case 'anosim'
            result = multivariateAnosim(distanceMatrix,groups, ...
                'Permutations',nPermutations,'RandomSeed',randomSeed);
            S = runGroupTest(S,distanceMatrix,groups,groupNames,result,'anosim');
        case 'permanova'
            result = multivariatePermanova(distanceMatrix,groups, ...
                'Permutations',nPermutations,'RandomSeed',randomSeed);
            S = runGroupTest(S,distanceMatrix,groups,groupNames,result,'permanova');
    end

    setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
    S.LStatus.Text = 'Done. Use "Save data" to export results.';
catch ME
    % S was not mutated on this path; leave any previous run state intact.
    S.LStatus.Text = 'Failed.';
    uialert(S.UIFigure,ME.message,'Multivariate Analysis','Icon','warning');
end
end


function [metric,standardize] = readDistanceInputs(S)
switch S.DMetric.Value
    case 'Euclidean'
        metric = 'euclidean';
    case 'Bray-Curtis'
        metric = 'braycurtis';
    case 'Jaccard'
        metric = 'jaccard';
    case 'Manhattan'
        metric = 'manhattan';
    otherwise
        metric = 'euclidean';
end
standardize = S.CStandardize.Value;
end


function nPermutations = readPermutations(S)
nPermutations = str2double(S.EPermutations.Value);
if isnan(nPermutations) || nPermutations < 1 || nPermutations ~= round(nPermutations)
    error('Acycle:Multivariate:InvalidPermutationsInput', ...
        'The number of permutations must be a positive integer.');
end
if nPermutations > 100000
    error('Acycle:Multivariate:TooManyPermutations', ...
        'Use at most 100000 permutations.');
end
end


function randomSeed = readSeed(S)
seedValue = str2double(S.ESeed.Value);
if isnan(seedValue)
    randomSeed = [];
else
    if seedValue < 0 || seedValue ~= round(seedValue)
        error('Acycle:Multivariate:InvalidSeedInput', ...
            'The random seed must be a non-negative integer (leave empty for a random seed).');
    end
    randomSeed = seedValue;
end
end


function [groups,groupNames] = readGroups(S,required)
boundariesText = S.EBoundaries.Value;
if isempty(strtrim(boundariesText))
    if required
        error('Acycle:Multivariate:NoBoundaries', ...
            ['Enter ascending depth/time boundaries that define the ', ...
             'groups, e.g. "25 40".']);
    end
    groups = [];
    groupNames = {};
    S.LGroupSummary.Text = 'Single group (no boundaries).';
    return
end
[groupIndex,groupNames] = multivariateGroupLabels(S.axisValues,boundariesText);
counts = histcounts(groupIndex,0.5:max(groupIndex)+0.5);
S.LGroupSummary.Text = sprintf('Groups: %s', ...
    strjoin(arrayfun(@(k)sprintf('G%d=%d',k,counts(k)),1:max(groupIndex), ...
    'UniformOutput',false),' '));
if ~required && max(groupIndex) < 2
    groups = [];
    groupNames = {};
    S.LGroupSummary.Text = 'Single group (boundaries cover no split).';
else
    groups = groupIndex;
end
end


function S = runPcoa(S,distanceMatrix,groups,groupNames)
result = multivariatePcoa(distanceMatrix,'Correction',S.DCorrection.Value);
S.run.method = 'pcoa';
S.run.result = result;
S.run.distanceMatrix = distanceMatrix;
S.run.groups = groups;
S.run.groupNames = groupNames;
S.run.metricUsed = currentMetricName(S);
S.run.nullValues = [];
plotOrdination(S,result,groups,groupNames);
plotScree(S,result);
S.TReport.Value = buildPcoaReport(S,result);
disp('>>  Multivariate analysis (PCoA): done. Use Save data to export files.');
end


function S = runGroupTest(S,distanceMatrix,groups,groupNames,result,kind)
ordinateResult = multivariatePcoa(distanceMatrix);
S.run.method = kind;
S.run.result = result;
S.run.ordinateResult = ordinateResult;
S.run.distanceMatrix = distanceMatrix;
S.run.groups = groups;
S.run.groupNames = groupNames;
S.run.metricUsed = currentMetricName(S);
S.run.nullValues = result.nullDistribution;
plotOrdination(S,ordinateResult,groups,groupNames);
plotNullDistribution(S,result.nullDistribution,result,kind);
if strcmp(kind,'anosim')
    S.TReport.Value = buildAnosimReport(S,result);
else
    S.TReport.Value = buildPermanovaReport(S,result);
end
disp('>>  Multivariate analysis: done. Use Save data to export files.');
end


function name = currentMetricName(S)
switch S.DMetric.Value
    case 'Euclidean'
        name = 'euclidean';
    case 'Bray-Curtis'
        name = 'braycurtis';
    case 'Jaccard'
        name = 'jaccard';
    case 'Manhattan'
        name = 'manhattan';
    otherwise
        name = 'euclidean';
end
end


function plotOrdination(S,ordinateResult,groups,groupNames)
ax = S.AxOrdination;
cla(ax,'reset');
hold(ax,'on');
coords = ordinateResult.coordinates;
k = size(coords,2);
if k >= 2
    xValues = coords(:,1);
    yValues = coords(:,2);
else
    xValues = coords(:,1);
    yValues = zeros(size(xValues));
end
prop1 = ordinateResult.proportionExplained(1);
if k >= 2
    prop2 = ordinateResult.proportionExplained(2);
else
    prop2 = 0;
end
if isempty(groups)
    scatter(ax,xValues,yValues,28,[0.16 0.32 0.75],'filled');
else
    colors = lines(max(groups));
    for g = 1:max(groups)
        idx = groups == g;
        name = 'G?';
        if g <= numel(groupNames)
            name = groupNames{g};
        end
        scatter(ax,xValues(idx),yValues(idx),28,colors(g,:),'filled', ...
            'DisplayName',sprintf('%s (n=%d)',name,sum(idx)));
    end
    try
        legend(ax,'show','Location','best','Box','off');
    catch
    end
end
hold(ax,'off');
xlabel(ax,sprintf('PC1 (%.1f%%)',prop1));
ylabel(ax,sprintf('PC2 (%.1f%%)',prop2));
title(ax,'Ordination (PC1 vs PC2)');
end


function plotScree(S,ordinateResult)
ax = S.AxSecondary;
cla(ax,'reset');
eigenvalues = ordinateResult.eigenvalues;
k = numel(eigenvalues);
yyaxis(ax,'left');
bar(ax,1:k,eigenvalues,0.6,'FaceColor',[0.2 0.4 0.75]);
ylabel(ax,'Eigenvalue');
yyaxis(ax,'right');
plot(ax,1:k,ordinateResult.cumulativeProportion,'-o','LineWidth',1.2, ...
    'Color',[0.85 0.33 0.1],'MarkerFaceColor',[0.85 0.33 0.1]);
ylabel(ax,'Cumulative %');
ax.YAxis(2).Limits = [0 100];
xlabel(ax,'Principal coordinate');
title(ax,'Scree plot (line: cumulative %)');
if k <= 30
    ax.XTick = 1:k;
end
end


function plotNullDistribution(S,nullValues,result,kind)
ax = S.AxSecondary;
cla(ax,'reset');
if strcmp(kind,'anosim')
    observed = result.statistic;
    statisticLabel = 'ANOSIM R';
else
    observed = result.fStatistic;
    statisticLabel = 'PERMANOVA F';
end
if isempty(nullValues) || ~any(isfinite(nullValues))
    text(ax,0.5,0.5,sprintf('%s = %.4f\n(p = %.4f)', ...
        statisticLabel,observed,result.pValue),'HorizontalAlignment','center', ...
        'Units','normalized');
    title(ax,sprintf('Observed %s',statisticLabel));
    return
end
histogram(ax,nullValues(isfinite(nullValues)),30, ...
    'FaceColor',[0.55 0.65 0.85],'EdgeColor','none');
hold(ax,'on');
% The observed statistic can sit outside the null range; widen the x-limits
% so the marker line and label stay visible.
yl = ax.YLim;
xl = ax.XLim;
lowerLimit = min(xl(1),observed);
upperLimit = max(xl(2),observed);
span = max(upperLimit - lowerLimit,eps);
ax.XLim = [lowerLimit - 0.02*span,upperLimit + 0.10*span];
yl = ax.YLim;
plot(ax,[observed observed],yl,'-','Color',S.red,'LineWidth',1.6);
text(ax,observed,yl(2)*0.95,sprintf('  observed = %.4f',observed), ...
    'Color',S.red,'FontSize',9);
hold(ax,'off');
xlabel(ax,statisticLabel);
ylabel(ax,'Permutations');
title(ax,sprintf('Null distribution (%d label permutations)',result.permutations));
end


function groupCountsText = formatGroupCounts(groupCounts)
parts = cell(size(groupCounts,1),1);
for k = 1:size(groupCounts,1)
    parts{k} = sprintf('G%d=%d',groupCounts(k,1),groupCounts(k,2));
end
groupCountsText = strjoin(parts,'  ');
end


function report = buildPcoaReport(S,result)
lines = {};
lines{end+1} = 'Principal Coordinate Analysis (PCoA)';
lines{end+1} = '===================================';
lines{end+1} = sprintf('Samples: %d      Metric: %s      Correction: %s', ...
    size(result.distanceMatrix,1),currentMetricName(S),result.correction);
lines{end+1} = sprintf('Negative eigenvalue sum: %.6g',result.negativeEigenvalueSum);
lines{end+1} = '';
lines{end+1} = 'Coord | Eigenvalue |  Percent | Cumulative';
lines{end+1} = '------------------------------------------';
for k = 1:min(10,numel(result.eigenvalues))
    lines{end+1} = sprintf('PC%3d | %10.4f | %8.3f | %8.3f', ...
        k,result.eigenvalues(k),result.proportionExplained(k), ...
        result.cumulativeProportion(k));
end
lines{end+1} = '';
if result.negativeEigenvalueSum < 0
    lines{end+1} = 'Negative eigenvalues indicate non-Euclidean distance';
    lines{end+1} = 'structure (common for Bray-Curtis/Jaccard). Their axes';
    lines{end+1} = 'are excluded from the coordinates (R cmdscale default),';
    lines{end+1} = 'or use the lingoes correction to shift them away.';
else
    lines{end+1} = 'All eigenvalues are non-negative (Euclidean-embeddable).';
end
report = strjoin(lines,newline);
end


function report = buildAnosimReport(S,result)
lines = {};
lines{end+1} = 'Analysis of Similarities (ANOSIM)';
lines{end+1} = '=================================';
lines{end+1} = sprintf('Samples: %d      Groups: %d      Metric: %s', ...
    result.nSamples,result.nGroups,currentMetricName(S));
lines{end+1} = sprintf('Group sizes: %s',formatGroupCounts(result.groupCounts));
lines{end+1} = '';
lines{end+1} = sprintf('R (raw, Clarke 1993)     : %.4f',result.statistic);
lines{end+1} = sprintf('R (PAI-corrected)        : %.4f',result.rPai);
lines{end+1} = sprintf('p-value (permutation)    : %.4f',result.pValue);
lines{end+1} = sprintf('Permutations             : %d      seed: %d', ...
    result.permutations,result.randomSeed);
lines{end+1} = sprintf('Mean rank within groups  : %.2f',result.meanRankWithin);
lines{end+1} = sprintf('Mean rank between groups : %.2f',result.meanRankBetween);
lines{end+1} = '';
lines{end+1} = 'Interpretation: R close to 1 = between-group dissimilarities';
lines{end+1} = 'exceed within-group dissimilarities (groups distinct).';
lines{end+1} = 'R close to 0 = no grouping structure; R < 0 = groups more';
lines{end+1} = 'similar across groups than within.';
lines{end+1} = '';
lines{end+1} = 'Note: samples along a depth/time axis are serially';
lines{end+1} = 'autocorrelated; treat p-values as exploratory.';
report = strjoin(lines,newline);
end


function report = buildPermanovaReport(S,result)
lines = {};
lines{end+1} = 'Permutational Multivariate Analysis of Variance (PERMANOVA)';
lines{end+1} = '===========================================================';
lines{end+1} = sprintf('Samples: %d      Groups: %d      Metric: %s', ...
    result.nSamples,result.nGroups,currentMetricName(S));
lines{end+1} = sprintf('Group sizes: %s',formatGroupCounts(result.groupCounts));
lines{end+1} = '';
lines{end+1} = sprintf('F (pseudo-F)             : %.4f',result.fStatistic);
lines{end+1} = sprintf('p-value (permutation)    : %.4f',result.pValue);
lines{end+1} = sprintf('Permutations             : %d      seed: %d', ...
    result.permutations,result.randomSeed);
lines{end+1} = '';
lines{end+1} = sprintf('SS between groups        : %.4f   df: %d', ...
    result.ssBetween,result.dfBetween);
lines{end+1} = sprintf('SS within groups         : %.4f   df: %d', ...
    result.ssWithin,result.dfWithin);
lines{end+1} = sprintf('SS total                 : %.4f',result.ssTotal);
lines{end+1} = sprintf('R^2 (SS_B / SS_T)        : %.4f',result.rSquared);
lines{end+1} = '';
lines{end+1} = 'Interpretation: large F with small p = group centroids';
lines{end+1} = 'differ in multivariate space (Anderson 2001).';
lines{end+1} = '';
lines{end+1} = 'Note: samples along a depth/time axis are serially';
lines{end+1} = 'autocorrelated; treat p-values as exploratory.';
report = strjoin(lines,newline);
end


function onSaveData(src)
S = getState(src);
if ~isfield(S,'run') || ~isfield(S.run,'method') || isempty(S.run.method)
    uialert(S.UIFigure,'Run an analysis first.','Multivariate Analysis','Icon','warning');
    return
end
try
    CDac_pwd;   % cd to Acycle working directory; stashes pre_dirML
    writeResultFiles(S);
    refreshMainList(S);
    if exist('pre_dirML','var')
        cd(pre_dirML);
    end
    S.LStatus.Text = 'Data saved.';
    disp('>>  Multivariate analysis: files written to the Acycle working directory.');
catch ME
    if exist('pre_dirML','var')
        cd(pre_dirML);
    end
    S.LStatus.Text = 'Saving failed.';
    uialert(S.UIFigure,ME.message,'Multivariate Analysis','Icon','warning');
end
setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
end


function onSaveFigure(src)
S = getState(src);
if ~isfield(S,'run') || ~isfield(S.run,'method') || isempty(S.run.method)
    uialert(S.UIFigure,'Run an analysis first.','Multivariate Analysis','Icon','warning');
    return
end
try
    [file,path] = uiputfile({'*.pdf','PDF (vector)';'*.fig','MATLAB figure'}, ...
        'Save multivariate figure',[S.baseName '-MV-figure.pdf']);
    if isequal(file,0)
        return
    end
    fig = buildExportFigure(S);
    target = fullfile(path,file);
    if endsWith(file,'.fig','IgnoreCase',true)
        savefig(fig,target);
    else
        exportgraphics(fig,target,'ContentType','vector');
    end
    close(fig);
    S.LStatus.Text = 'Figure saved.';
catch ME
    S.LStatus.Text = 'Saving figure failed.';
    uialert(S.UIFigure,ME.message,'Multivariate Analysis','Icon','warning');
end
setappdata(S.UIFigure,'MULTIVARIATE_STATE',S);
end


function writeResultFiles(S)
prefix = S.baseName;
if size(S.dataMatrix,2) > 1
    prefix = [prefix '-w-others'];
end
run = S.run;
n = size(S.dataMatrix,1);

% Group assignment file: axis + group index (always written so the
% grouping can be verified downstream).
if isempty(run.groups)
    groupColumn = ones(n,1);
else
    groupColumn = run.groups;
end
dlmwrite(exportPath(sprintf('%s-MV-groups.txt',prefix)), ...
    [S.axisValues,groupColumn],'delimiter',' ','precision',9);

% Distance matrix (cap the file size for very long records).
if n <= 2000
    dlmwrite(exportPath(sprintf('%s-MV-distance.txt',prefix)), ...
        run.distanceMatrix,'delimiter',' ','precision',9);
end

switch run.method
    case 'pcoa'
        result = run.result;
        rowCount = size(result.coordinates,1);
        coordinates = [S.axisValues(1:rowCount),result.coordinates];
        dlmwrite(exportPath(sprintf('%s-MV-PCoA-coordinates.txt',prefix)), ...
            coordinates,'delimiter',' ','precision',9);
        dlmwrite(exportPath(sprintf('%s-MV-PCoA-eigenvalues.txt',prefix)), ...
            [result.eigenvalues,result.proportionExplained, ...
             result.cumulativeProportion],'delimiter',' ','precision',9);
        writeReport(exportPath(sprintf('%s-MV-PCoA-results.txt',prefix)), ...
            S.TReport.Value);
    case 'anosim'
        result = run.result;
        dlmwrite(exportPath(sprintf('%s-MV-ANOSIM-null.txt',prefix)), ...
            [run.nullValues(:);result.statistic],'delimiter',' ','precision',9);
        writeReport(exportPath(sprintf('%s-MV-ANOSIM-results.txt',prefix)), ...
            S.TReport.Value);
    case 'permanova'
        result = run.result;
        dlmwrite(exportPath(sprintf('%s-MV-PERMANOVA-null.txt',prefix)), ...
            [run.nullValues(:);result.fStatistic],'delimiter',' ','precision',9);
        writeReport(exportPath(sprintf('%s-MV-PERMANOVA-results.txt',prefix)), ...
            S.TReport.Value);
end

writeParameterTable(S,prefix);
end


function path = exportPath(name)
if exist(name,'file') == 2
    [~,base,extension] = fileparts(name);
    path = sprintf('%s-%s%s',base,datestr(now,'yyyymmddTHHMMSS'),extension);
else
    path = name;
end
end


function writeReport(path,reportText)
fid = fopen(path,'w');
if fid == -1
    error('Acycle:Multivariate:WriteFailed','Could not open "%s" for writing.',path);
end
cleanup = onCleanup(@() fclose(fid));
fprintf(fid,'%s\r\n',strrep(reportText,newline,sprintf('\r\n')));
end


function writeParameterTable(S,prefix)
n = size(S.dataMatrix,1);
p = size(S.dataMatrix,2);
inputs = S.run.inputs;
parameterGrid = cell(14,6);
parameterGrid(1,1) = {'Detailed Parameters Used in Data Processing by Acycle'};
parameterGrid(2,:) = {'Parameter','Value','','Parameter','Value',''};
parameterGrid(3,:) = {'Analysis','Multivariate (distance-based)','','Series analyzed (columns)',p,''};
parameterGrid(4,:) = {'Method',capitalize(inputs.method),'','Samples (rows)',n,''};
parameterGrid(5,:) = {'Distance metric',inputs.metric,'','Standardized (z-score)',num2str(inputs.standardize),''};
parameterGrid(6,:) = {'Group boundaries',inputs.boundariesText,'','Groups defined',num2str(numel(S.run.groupNames)),''};
if strcmp(inputs.method,'pcoa')
    parameterGrid(7,:) = {'Eigenvalue correction',inputs.correction,'','Permutations','-',''};
else
    parameterGrid(7,:) = {'Eigenvalue correction','-','','Permutations',num2str(S.run.result.permutations),''};
end
if isfield(S.run.result,'randomSeed')
    seedText = num2str(S.run.result.randomSeed);
else
    seedText = '-';
end
% Component count comes from the ordination: for PCoA the result itself,
% for ANOSIM/PERMANOVA the companion ordination used for the plot.
if isfield(S.run,'ordinateResult')
    componentText = num2str(size(S.run.ordinateResult.coordinates,2));
elseif strcmp(S.run.method,'pcoa')
    componentText = num2str(size(S.run.result.coordinates,2));
else
    componentText = '0';
end
parameterGrid(8,:) = {'Random seed',seedText,'','PCoA components exported',componentText,''};
parameterGrid(9,:) = {'Statistical software','Acycle (MATLAB)','','Algorithm source','PaleoAST (R-validated)',''};
parameterGrid(10,:) = {'References','','','','',''};
parameterGrid(11,:) = {'  Gower (1966) Some distance properties of latent root','','','','',''};
parameterGrid(12,:) = {'  Clarke (1993) Non-parametric multivariate analyses','','','','',''};
parameterGrid(13,:) = {'  Anderson (2001) Austral Ecology 26: 32-46','','','','',''};
parameterGrid(14,:) = {'  Phipson & Smyth (2010) Statistical Applications in','','','','',''};
writecell(parameterGrid,exportPath(sprintf('%s-MV-parameters.xls',prefix)), ...
    'Sheet','Multivariate','WriteVariableNames',false);
end


function text = capitalize(text)
if isempty(text)
    return
end
text = [upper(text(1)),text(2:end)];
end


function fig = buildExportFigure(S)
fig = figure('Visible','off','Color','w','Position',[100 100 1000 420]);
tiledlayout(fig,1,2,'TileSpacing','compact','Padding','compact');

nexttile;
hold('on');
if strcmp(S.run.method,'pcoa')
    coords = S.run.result.coordinates;
else
    coords = S.run.ordinateResult.coordinates;
end
k = size(coords,2);
if k >= 2
    xValues = coords(:,1); yValues = coords(:,2);
else
    xValues = coords(:,1); yValues = zeros(size(xValues));
end
if isempty(S.run.groups)
    scatter(xValues,yValues,28,[0.16 0.32 0.75],'filled');
else
    colors = lines(max(S.run.groups));
    for g = 1:max(S.run.groups)
        idx = S.run.groups == g;
        name = 'G?';
        if g <= numel(S.run.groupNames)
            name = S.run.groupNames{g};
        end
        scatter(xValues(idx),yValues(idx),28,colors(g,:),'filled', ...
            'DisplayName',sprintf('%s (n=%d)',name,sum(idx)));
    end
    legend('show','Location','best','Box','off');
end
hold('off');
xlabel('PC1'); ylabel('PC2');
title('Ordination (PC1 vs PC2)');

nexttile;
if strcmp(S.run.method,'pcoa')
    result = S.run.result;
    kk = numel(result.eigenvalues);
    yyaxis left;
    bar(1:kk,result.eigenvalues,0.6,'FaceColor',[0.2 0.4 0.75]);
    ylabel('Eigenvalue');
    yyaxis right;
    plot(1:kk,result.cumulativeProportion,'-o','LineWidth',1.2, ...
        'Color',[0.85 0.33 0.1],'MarkerFaceColor',[0.85 0.33 0.1]);
    ylabel('Cumulative %');
    ylim([0 100]);
    xlabel('Principal coordinate');
    title('Scree plot (line: cumulative %)');
else
    nullValues = S.run.nullValues;
    if strcmp(S.run.method,'anosim')
        observed = S.run.result.statistic;
        label = 'ANOSIM R';
    else
        observed = S.run.result.fStatistic;
        label = 'PERMANOVA F';
    end
    histogram(nullValues(isfinite(nullValues)),30, ...
        'FaceColor',[0.55 0.65 0.85],'EdgeColor','none');
    hold('on');
    yl = ylim;
    plot([observed observed],yl,'-','Color',[0.8 0 0],'LineWidth',1.6);
    hold('off');
    xlabel(label); ylabel('Permutations');
    title(sprintf('Null distribution (p = %.4f)',S.run.result.pValue));
end
end


function refreshMainList(S)
workDir = pwd;
try
    ac_working_directory('set',workDir);
catch
end
try
    ac_refresh_main_list(S.ctx.listbox_acmain,workDir);
catch
    % Best effort: the main list refresh must never break saving.
end
end
