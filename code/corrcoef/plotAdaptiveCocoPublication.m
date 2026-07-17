function figs = plotAdaptiveCocoPublication(corrCI,corrH0,details,report,varargin)
%PLOTADAPTIVECOCOPUBLICATION Publication figures for non-GUI Adaptive COCO.
%
% FIGS = PLOTADAPTIVECOCOPUBLICATION(CORRCI,CORRH0,DETAILS,REPORT)
% creates a four-panel rate-curve figure and a separate Monte Carlo audit
% figure.  Formal significance is shown as -log10(p), so smaller p-values
% form visually higher peaks while tick labels remain in p-value units.

parser = inputParser;
parser.FunctionName = mfilename;
addParameter(parser,'TitlePrefix','Adaptive COCO',@(x) ...
    ischar(x) || (isstring(x) && isscalar(x)));
addParameter(parser,'Visible','on',@(x) ischar(x) || ...
    (isstring(x) && isscalar(x)));
parse(parser,varargin{:});
titlePrefix = char(string(parser.Results.TitlePrefix));
visibility = validatestring(char(parser.Results.Visible),{'on','off'});

validateattributes(corrCI,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'corrCI',1);
validateattributes(corrH0,{'numeric'},{'2d','real','nonempty'}, ...
    mfilename,'corrH0',2);
if size(corrCI,2) < 4 || size(corrH0,2) < 3 || ...
        size(corrCI,1) ~= size(corrH0,1)
    error('plotAdaptiveCocoPublication:InvalidCurves', ...
        'Adaptive curve arrays have inconsistent or incomplete columns.');
end
if ~isstruct(details) || ~isfield(details,'nullMax') || ...
        ~isstruct(report) || ~isfield(report,'bestCorrelation') || ...
        ~isfield(report,'minimumGlobalP')
    error('plotAdaptiveCocoPublication:InvalidAudit', ...
        'Adaptive DETAILS and REPORT structures are incomplete.');
end

rate = corrCI(:,1);
rho = corrCI(:,2);
pGlobal = corrH0(:,1);
pLocal = corrH0(:,3);
nPeriod = corrH0(:,2);
nValid = numel(details.nullMax);
pFloor = 1/max(1,nValid+1);

figs = gobjects(2,1);
figs(1) = figure('Color','w','Visible',visibility, ...
    'Name',[titlePrefix,': rate curves']);
layout = tiledlayout(figs(1),4,1,'TileSpacing','compact','Padding','compact');

ax = nexttile(layout,1);
plot(ax,rate,rho,'r-','LineWidth',1.25);
hold(ax,'on');
plot(ax,report.bestRate,report.bestCorrelation,'ro', ...
    'MarkerFaceColor','r','MarkerSize',4);
formatRateAxis(ax,rate,'Adaptive spectral correlation','\rho');

ax = nexttile(layout,2);
plotPAsPeak(ax,rate,pGlobal,pFloor,0.05, ...
    'Global max-statistic p-value',true);

ax = nexttile(layout,3);
plotPAsPeak(ax,rate,pLocal,pFloor,0.01, ...
    'Local p-value (descriptive diagnostic only)',false);

ax = nexttile(layout,4);
stairs(ax,rate,nPeriod,'b-','LineWidth',1.25);
formatRateAxis(ax,rate,'Frequency-resolved participating periods','#');
ylim(ax,[0,max(9.5,max(nPeriod(isfinite(nPeriod)))+0.5)]);
xlabel(ax,'Sedimentation rate (cm/kyr)');
title(layout,sprintf('%s (exploratory; global p = %.4g)', ...
    titlePrefix,report.minimumGlobalP));

figs(2) = figure('Color','w','Visible',visibility, ...
    'Name',[titlePrefix,': Monte Carlo audit']);
ax = axes(figs(2));
nullMax = details.nullMax(:);
histogram(ax,nullMax,'Normalization','probability', ...
    'FaceColor',[0.72 0.78 0.86],'EdgeColor',[0.25 0.30 0.38]);
hold(ax,'on');
xline(ax,report.bestCorrelation,'r-','LineWidth',1.8, ...
    'Label',sprintf('Observed max \rho = %.4g',report.bestCorrelation), ...
    'LabelOrientation','horizontal','LabelVerticalAlignment','middle');
xlabel(ax,'Maximum Adaptive COCO correlation over the rate grid');
ylabel(ax,'Relative frequency');
title(ax,wrapTitleText([titlePrefix,' Monte Carlo audit'],58));
subtitle(ax,{sprintf( ...
    'Stationary AR(1) full-search null: global p = %.4g; N = %d', ...
    report.minimumGlobalP,nValid), ...
    sprintf('Best rate %.4g cm/kyr; fitted \rho_{AR(1)} = %.4g', ...
    report.bestRate,details.rhoM)});
grid(ax,'on');
box(ax,'on');
set(ax,'XMinorTick','on','YMinorTick','on');
end

function plotPAsPeak( ...
        ax,rate,p,pFloor,threshold,titleText,isGlobalPanel)
score = nan(size(p));
valid = isfinite(p) & p > 0;
score(valid) = -log10(max(p(valid),pFloor));
plot(ax,rate,score,'r-','LineWidth',1.25);
hold(ax,'on');
if threshold >= pFloor
    % Keep the reference line without an in-panel p=... annotation. The
    % corresponding value remains available from the p-value y ticks.
    yline(ax,-log10(threshold),'k--','LineWidth',0.9);
end
formatRateAxis(ax,rate,titleText,'p');
finiteScore = score(isfinite(score));
defaultGlobalMinimumP = 0.002;
hasVerySmallGlobalP = isGlobalPanel && ...
    any(p(valid) < defaultGlobalMinimumP);
if isGlobalPanel && ~hasVerySmallGlobalP
    % The routine plots -log10(p), hence p=1 is the lower edge and
    % p=0.002 is the upper edge. Extend beyond this only when the computed
    % global curve actually contains a smaller p-value.
    bottom = 0;
    top = -log10(defaultGlobalMinimumP);
else
    bottom = -log10(1.01);
    if isempty(finiteScore)
        top = max(0.5,-log10(pFloor));
    else
        top = max([finiteScore(:);-log10(pFloor);0.5]);
    end
    top = top+0.08*max(0.5,top-bottom);
end
ylim(ax,[bottom,top]);
pTicks = [1 0.1 0.05 0.02 0.01 0.002 0.001 0.0002 0.0001];
yLimits = ylim(ax);
pTicks = pTicks(pTicks >= pFloor & -log10(pTicks) <= yLimits(2));
if (isempty(pTicks) || pFloor < min(pTicks)) && ...
        -log10(pFloor) <= yLimits(2)
    pTicks(end+1) = pFloor;
end
pTicks = unique(pTicks,'stable');
if isempty(pTicks)
    pTicks = pFloor;
end
yticks(ax,-log10(pTicks));
yticklabels(ax,arrayfun(@formatP,pTicks,'UniformOutput',false));
if isGlobalPanel
    set(ax,'Tag','AdaptiveCOCO-global-p');
else
    set(ax,'Tag','AdaptiveCOCO-local-p');
end
end

function lines = wrapTitleText(textValue,maximumCharacters)
words = regexp(strtrim(textValue),'\s+','split');
lines = cell(0,1);
current = '';
for ii = 1:numel(words)
    candidate = words{ii};
    if ~isempty(current)
        candidate = [current,' ',candidate]; %#ok<AGROW>
    end
    if isempty(current) || numel(candidate) <= maximumCharacters
        current = candidate;
    else
        lines{end+1,1} = current; %#ok<AGROW>
        current = words{ii};
    end
end
if ~isempty(current)
    lines{end+1,1} = current;
end
if isempty(lines)
    lines = {''};
end
end

function textValue = formatP(p)
if p >= 0.001
    textValue = sprintf('%.3g',p);
else
    textValue = sprintf('%.1e',p);
end
end

function formatRateAxis(ax,rate,titleText,yLabelText)
xlim(ax,[rate(1),rate(end)]);
title(ax,titleText);
ylabel(ax,yLabelText);
set(ax,'XMinorTick','on','YMinorTick','on');
grid(ax,'on');
box(ax,'on');
end
