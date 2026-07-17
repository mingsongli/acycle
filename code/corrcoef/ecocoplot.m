function prt_sr = ecocoplot(prt_sr,out_depth,out_ecc,out_ep,out_eci, ...
    out_ecoco,out_ecocorb,out_norbit,plotn,ecoDetails)
%ECOCOPLOT Plot Adaptive or cross-fitted evolutionary COCO maps.
%
% Adaptive eCOCO uses five panels: correlation, same-rate local p,
% sedimentation-rate-search global p, number of contributing orbital
% periods, and the within-window normalized ridge-score background. Ridge
% tracking itself always uses the original unnormalized score. Cross-fitted
% eCOCO uses six panels: forward correlation, backward correlation,
% consensus same-rate local p, consensus SR-global p, consensus orbital
% count, and the within-window normalized consensus score. Each p panel is
% shown directly as -log10(p) with an independent range determined from
% its own finite Monte Carlo results; p values themselves are not
% normalized.
%
% The tenth input is optional for compatibility with older callers. Its
% cross-fitted contract is:
%   ecoDetails.forward.rho/pLocal/pGlobal/nOrbit/score
%   ecoDetails.backward.rho/pLocal/pGlobal/nOrbit/score
%   ecoDetails.consensus.rho/pLocal/pGlobal/nOrbit/score
% A tracked rate may optionally be supplied as
% ecoDetails.trackedSedimentationRate, ecoDetails.trackedRate, or
% ecoDetails.sr_p. Otherwise the final-panel ridge is the finite maximum
% score at each window.

if nargin > 10
    error('ecocoplot:TooManyInputs','Too many input arguments.');
end
if nargin < 8
    error('ecocoplot:TooFewInputs','At least eight inputs are required.');
end
if nargin < 9 || isempty(plotn)
    plotn = 1;
end
if nargin < 10 || isempty(ecoDetails)
    ecoDetails = struct();
end
if ~isstruct(ecoDetails) || ~isscalar(ecoDetails)
    error('ecocoplot:InvalidDetails', ...
        'ECODETAILS must be empty or a scalar structure.');
end
if ~isnumeric(plotn) || ~isscalar(plotn) || ~isfinite(plotn)
    error('ecocoplot:InvalidPlotMode','PLOTN must be a finite scalar.');
end
if plotn == 0
    return
end

prt_sr = prt_sr(:);
out_depth = out_depth(:);
if isempty(prt_sr) || isempty(out_depth) || ...
        any(~isfinite(prt_sr)) || any(~isfinite(out_depth))
    error('ecocoplot:InvalidAxes', ...
        'Sedimentation-rate and depth coordinates must be finite vectors.');
end
nRate = numel(prt_sr);
nWindow = numel(out_depth);

% OUT_ECOCO remains accepted because it is part of the public legacy
% plotting signature. For Adaptive and Cross-fitted eCOCO, OUT_EP carries
% the audited same-rate local p map. Nested consensus results take
% precedence for Cross-fitted eCOCO.
legacyOutputs = {out_ecoco}; %#ok<NASGU>
out_ecc = mapSized(out_ecc,nRate,nWindow);
out_ep = mapSized(out_ep,nRate,nWindow);
out_eci = mapSized(out_eci,nRate,nWindow);
out_ecocorb = mapSized(out_ecocorb,nRate,nWindow);
out_norbit = mapSized(out_norbit,nRate,nWindow);

methodName = lower(string(detailField(ecoDetails,'method','')));
isCrossfit = contains(methodName,'cross') || ...
    (isfield(ecoDetails,'forward') && isfield(ecoDetails,'backward'));
isAdaptive = contains(methodName,'adaptive') || ...
    isfield(ecoDetails,'pLocal');
ridgeScoreRaw = [];
ridgeLocalP = [];
ridgeLocalPThreshold = 0.01;

if isCrossfit
    forwardRho = directionMap(ecoDetails,'forward','rho', ...
        nan(nRate,nWindow),nRate,nWindow);
    backwardRho = directionMap(ecoDetails,'backward','rho', ...
        nan(nRate,nWindow),nRate,nWindow);
    consensusLocalP = directionMap(ecoDetails,'consensus','pLocal', ...
        out_ep,nRate,nWindow);
    consensusGlobalP = directionMap(ecoDetails,'consensus','pGlobal', ...
        out_eci,nRate,nWindow);
    consensusOrbit = directionMap(ecoDetails,'consensus','nOrbit', ...
        out_norbit,nRate,nWindow);
    consensusScore = directionMap(ecoDetails,'consensus','score', ...
        out_ecocorb,nRate,nWindow);
    ridgeScoreRaw = consensusScore;
    ridgeLocalP = consensusLocalP;
    normalizedScore = normalizeScoreByWindow(consensusScore);
    panels = [ ...
        makePanel(forwardRho,'Forward correlation','rho'); ...
        makePanel(backwardRho,'Backward correlation','rho'); ...
        makePanel(consensusLocalP,'Local p','p',NaN,'Local p',0.01); ...
        makePanel(consensusGlobalP,'Global p','p',NaN,'Global p',0.05); ...
        makePanel(consensusOrbit,'Contributing orbital periods','orbit'); ...
        makePanel(normalizedScore,'Ridge score','score-normalized', ...
        NaN,'Window-normalized score')];
    figureTitle = 'Cross-fitted eCOCO';
elseif isAdaptive
    localP = detailMap(ecoDetails,{'pLocal','localP'},out_ep, ...
        nRate,nWindow);
    ridgeScoreRaw = out_ecocorb;
    ridgeLocalP = localP;
    normalizedScore = normalizeScoreByWindow(out_ecocorb);
    panels = [ ...
        makePanel(out_ecc,'Correlation coefficient','rho'); ...
        makePanel(localP,'Local p','p',NaN,'Local p',0.01); ...
        makePanel(out_eci,'Global p','p',NaN,'Global p',0.05); ...
        makePanel(out_norbit,'Contributing orbital periods','orbit'); ...
        makePanel(normalizedScore,'Ridge score','score-normalized', ...
        NaN,'Window-normalized score')];
    figureTitle = 'Adaptive eCOCO';
else
    % Nine-input calls come from the hidden legacy Fast/Accurate branch.
    % Preserve its three-map display and do not relabel the historical
    % analytic OUT_EP matrix as the new Monte Carlo Local p statistic.
    panels = [ ...
        makePanel(out_ecc,'Correlation coefficient','rho'); ...
        makePanel(out_eci,'Global p','p'); ...
        makePanel(out_norbit,'Contributing orbital periods','orbit')];
    figureTitle = 'eCOCO';
end

rhoLimits = sharedLimits(panels,'rho');
pFloor = monteCarloPFloor(ecoDetails);
reverseDepth = plotn < 0;
plotMode = abs(round(plotn));
if plotMode < 1
    plotMode = 1;
end

if plotMode == 1
    fig = figure('Color','w','Name',figureTitle, ...
        'Position',[80 100 max(1180,270*numel(panels)) 600]);
    layout = tiledlayout(fig,1,numel(panels), ...
        'TileSpacing','compact','Padding','compact');
    title(layout,figureTitle,'FontWeight','bold');
    for panelIndex = 1:numel(panels)
        ax = nexttile(layout,panelIndex);
        pLogMaximum = pDisplayMaximum(panels(panelIndex),ecoDetails);
        drawPanel(ax,panels(panelIndex),prt_sr,out_depth,false, ...
            reverseDepth,pLogMaximum,pFloor,rhoLimits,panelIndex == 1);
        if panelIndex == numel(panels) && ~isempty(ridgeScoreRaw)
            overlayRidge(ax,ridgeScoreRaw,prt_sr, ...
                out_depth,ecoDetails,ridgeLocalP,ridgeLocalPThreshold, ...
                false,panels(panelIndex).data);
        end
    end
elseif plotMode == 2
    for panelIndex = 1:numel(panels)
        fig = figure('Color','w','Name', ...
            [figureTitle,' - ',panels(panelIndex).title]);
        ax = axes(fig);
        pLogMaximum = pDisplayMaximum(panels(panelIndex),ecoDetails);
        drawPanel(ax,panels(panelIndex),prt_sr,out_depth,false, ...
            reverseDepth,pLogMaximum,pFloor,rhoLimits,true);
        if panelIndex == numel(panels) && ~isempty(ridgeScoreRaw)
            overlayRidge(ax,ridgeScoreRaw,prt_sr, ...
                out_depth,ecoDetails,ridgeLocalP,ridgeLocalPThreshold, ...
                false,panels(panelIndex).data);
        end
    end
else
    for panelIndex = 1:numel(panels)
        fig = figure('Color','w','Name', ...
            [figureTitle,' - ',panels(panelIndex).title]);
        ax = axes(fig);
        pLogMaximum = pDisplayMaximum(panels(panelIndex),ecoDetails);
        drawPanel(ax,panels(panelIndex),prt_sr,out_depth,true, ...
            reverseDepth,pLogMaximum,pFloor,rhoLimits,true);
        if panelIndex == numel(panels) && ~isempty(ridgeScoreRaw)
            overlayRidge(ax,ridgeScoreRaw,prt_sr, ...
                out_depth,ecoDetails,ridgeLocalP,ridgeLocalPThreshold, ...
                true,panels(panelIndex).data);
        end
    end
end
end

function panel = makePanel(data,titleText,kind,pDisplayMinimum,colorLabel, ...
        significanceThreshold)
if nargin < 4
    pDisplayMinimum = NaN;
end
if nargin < 5
    colorLabel = '';
end
if nargin < 6
    significanceThreshold = NaN;
end
panel = struct('data',data,'title',titleText,'kind',kind, ...
    'pDisplayMinimum',pDisplayMinimum,'colorLabel',colorLabel, ...
    'significanceThreshold',significanceThreshold);
end

function normalized = normalizeScoreByWindow(score)
% Normalize only the plotted background. Ridge tracking is completed from
% the original SCORE map before ECOCOPLOT is called.
normalized = nan(size(score));
for windowIndex = 1:size(score,2)
    column = score(:,windowIndex);
    valid = isfinite(column);
    if ~any(valid)
        continue
    end
    lower = min(column(valid));
    upper = max(column(valid));
    if upper > lower
        normalized(valid,windowIndex) = ...
            (column(valid)-lower)./(upper-lower);
    else
        % A constant column has no within-window score contrast.
        normalized(valid,windowIndex) = 0;
    end
end
end

function value = detailField(details,name,fallback)
value = fallback;
if isfield(details,name) && ~isempty(details.(name))
    value = details.(name);
end
end

function data = directionMap(details,directionName,fieldName,fallback, ...
        nRate,nWindow)
data = fallback;
if isfield(details,directionName) && ...
        isstruct(details.(directionName)) && ...
        isfield(details.(directionName),fieldName) && ...
        ~isempty(details.(directionName).(fieldName))
    data = details.(directionName).(fieldName);
end
data = mapSized(data,nRate,nWindow);
end

function data = detailMap(details,fieldNames,fallback,nRate,nWindow)
data = fallback;
for fieldIndex = 1:numel(fieldNames)
    fieldName = fieldNames{fieldIndex};
    if isfield(details,fieldName) && ~isempty(details.(fieldName))
        data = details.(fieldName);
        break
    end
end
data = mapSized(data,nRate,nWindow);
end

function data = mapSized(data,nRate,nWindow)
if isempty(data)
    data = nan(nRate,nWindow);
    return
end
if ~(isnumeric(data) || islogical(data)) || ~isreal(data)
    data = nan(nRate,nWindow);
    return
end
data = double(data);
if isequal(size(data),[nRate,nWindow])
    return
end
if isequal(size(data),[nWindow,nRate])
    data = data.';
    return
end
data = nan(nRate,nWindow);
end

function maximum = pDisplayMaximum(panel,details)
% Give every p panel its own range. The lower endpoint is a readable
% 1-2-5 value at or below that panel's observed minimum, but never below
% the known plus-one Monte Carlo resolution. Thus colors use the available
% information without implying precision that the simulation did not have.
if ~strcmp(panel.kind,'p')
    maximum = 1;
    return
end
if isfinite(panel.pDisplayMinimum) && panel.pDisplayMinimum > 0 && ...
        panel.pDisplayMinimum < 1
    maximum = -log10(panel.pDisplayMinimum);
    return
end

pFloor = monteCarloPFloor(details);
p = resolvedPValues(panel.data,pFloor);
positive = p(isfinite(p));
minimumP = inf;
if ~isempty(positive)
    minimumP = min(positive);
end
if ~isfinite(minimumP)
    % No supported p values: retain a non-degenerate, conventional scale.
    displayMinimum = 0.1;
else
    displayMinimum = nicePMinimum(minimumP);
    if isfinite(pFloor)
        displayMinimum = max(displayMinimum,pFloor);
    end
    if displayMinimum >= 1
        displayMinimum = 0.1;
    end
end
maximum = -log10(max(displayMinimum,realmin('double')));
end

function pFloor = monteCarloPFloor(details)
pFloor = detailNumeric(details,{'pFloor','monteCarloResolution'},NaN);
if isfinite(pFloor) && pFloor > 0 && pFloor < 1
    return
end
nSim = detailNumeric(details, ...
    {'nsimCompleted','nSimCompleted','nSim','nsim', ...
     'nsimRequested','nSimRequested'},NaN);
if isfinite(nSim) && nSim >= 1
    pFloor = 1/(nSim+1);
else
    pFloor = NaN;
end
end

function resolved = resolvedPValues(raw,pFloor)
resolved = nan(size(raw));
valid = isfinite(raw) & raw > 0 & raw <= 1;
resolved(valid) = raw(valid);
if isfinite(pFloor)
    resolved(valid) = max(resolved(valid),pFloor);
    resolved(isfinite(raw) & raw == 0) = pFloor;
end
end

function value = nicePMinimum(p)
exponent = floor(log10(p));
scale = 10^exponent;
mantissa = p/scale;
if mantissa >= 5
    leading = 5;
elseif mantissa >= 2
    leading = 2;
else
    leading = 1;
end
value = leading*scale;
end

function value = detailNumeric(details,names,fallback)
value = fallback;
for nameIndex = 1:numel(names)
    name = names{nameIndex};
    if isfield(details,name) && isnumeric(details.(name)) && ...
            isscalar(details.(name)) && isfinite(details.(name))
        value = double(details.(name));
        return
    end
end
end

function limits = sharedLimits(panels,kind)
values = zeros(0,1);
for panelIndex = 1:numel(panels)
    if strcmp(panels(panelIndex).kind,kind)
        data = panels(panelIndex).data;
        values = [values;data(isfinite(data))]; %#ok<AGROW>
    end
end
limits = finiteLimits(values,[0 1]);
end

function drawPanel(ax,panel,rates,depths,useSurface,reverseDepth, ...
        pLogMaximum,pFloor,rhoLimits,showDepthLabel)
raw = panel.data;
displayData = raw;
significanceData = raw;
if strcmp(panel.kind,'p')
    if isfinite(panel.pDisplayMinimum) && panel.pDisplayMinimum > 0 && ...
            panel.pDisplayMinimum < 1
        pLogMaximum = -log10(panel.pDisplayMinimum);
    end
    significanceData = resolvedPValues(raw,pFloor);
    displayData = nan(size(raw));
    valid = isfinite(significanceData);
    displayData(valid) = -log10(significanceData(valid));
    displayData(displayData > pLogMaximum) = pLogMaximum;
end

finiteData = displayData(isfinite(displayData));
if isempty(finiteData)
    imagesc(ax,rates,depths,nan(numel(depths),numel(rates)));
    text(ax,mean(rates),mean(depths),'No supported values', ...
        'HorizontalAlignment','center','Color',[0.35 0.35 0.35]);
elseif useSurface
    surf(ax,rates,depths,displayData.','EdgeColor','none');
    view(ax,[12 72]);
else
    z = displayData.';
    supportedRows = any(isfinite(z),2);
    supportedColumns = any(isfinite(z),1);
    hasAdjacentRows = numel(supportedRows) >= 2 && ...
        any(supportedRows(1:end-1) & supportedRows(2:end));
    hasAdjacentColumns = numel(supportedColumns) >= 2 && ...
        any(supportedColumns(1:end-1) & supportedColumns(2:end));
    canContour = numel(rates) >= 2 && numel(depths) >= 2 && ...
        hasAdjacentRows && hasAdjacentColumns && ...
        max(finiteData) > min(finiteData);
    if canContour
        contourf(ax,rates,depths,z,20,'LineStyle','none');
    else
        imageHandle = imagesc(ax,rates,depths,z);
        imageHandle.AlphaData = isfinite(z);
    end
end

colormap(ax,'parula');
color = colorbar(ax,'southoutside');
switch panel.kind
    case 'p'
        clim(ax,[0 pLogMaximum]);
        configurePColorbar(color,pLogMaximum,panel.colorLabel, ...
            panel.significanceThreshold);
    case 'rho'
        clim(ax,rhoLimits);
        color.Label.String = '\rho';
    case 'orbit'
        finiteOrbit = raw(isfinite(raw));
        if isempty(finiteOrbit)
            orbitMaximum = 9;
        else
            orbitMaximum = max(1,ceil(max(finiteOrbit)));
        end
        clim(ax,[0 orbitMaximum]);
        color.Ticks = 0:orbitMaximum;
        color.Label.String = 'Number of periods';
    case 'score-normalized'
        clim(ax,[0 1]);
        color.Label.String = panel.colorLabel;
    otherwise
        clim(ax,finiteLimits(finiteData,[0 1]));
        color.Label.String = 'Score';
end

overlaySignificanceBoundary(ax,panel,rates,depths,displayData,useSurface, ...
    significanceData);

xlabel(ax,'Sedimentation rate (cm/kyr)');
if showDepthLabel
    ylabel(ax,'Depth (m)');
end
title(ax,panel.title,'Interpreter','none');
set(ax,'XMinorTick','on','YMinorTick','on','TickDir','out');
if reverseDepth
    set(ax,'YDir','reverse');
else
    set(ax,'YDir','normal');
end
if numel(rates) > 1
    xlim(ax,[min(rates) max(rates)]);
end
if numel(depths) > 1
    ylim(ax,[min(depths) max(depths)]);
end
end

function configurePColorbar(color,pLogMaximum,labelText,threshold)
displayMinimum = 10^(-pLogMaximum);
decadeLogs = 1:floor(pLogMaximum);
tickLogs = [0,decadeLogs,pLogMaximum];
thresholdLog = NaN;
if isfinite(threshold) && threshold >= displayMinimum && threshold <= 1
    thresholdLog = -log10(threshold);
    tickLogs(end+1) = thresholdLog;
end
% Short, high-p ranges otherwise contain only their endpoints. Add familiar
% 0.5 and 0.2 ticks when they lie inside the displayed interval.
if numel(tickLogs) < 4
    supplemental = -log10([0.5 0.2]);
    tickLogs = [tickLogs,supplemental(supplemental < pLogMaximum)];
end
tickLogs = uniqueSortedTolerance(tickLogs);
if numel(tickLogs) > 6
    targets = linspace(0,pLogMaximum,5);
    if isfinite(thresholdLog)
        targets(end+1) = thresholdLog;
    end
    selected = zeros(size(targets));
    for targetIndex = 1:numel(targets)
        [~,selected(targetIndex)] = min(abs(tickLogs-targets(targetIndex)));
    end
    tickLogs = tickLogs(unique(selected));
    tickLogs = uniqueSortedTolerance([0,tickLogs,pLogMaximum]);
end
% Preserve the exact CLim endpoint. Rounding -log10(0.005) upward by even
% machine epsilon makes MATLAB silently omit that final colorbar label.
tickLogs = min(max(tickLogs,0),pLogMaximum);
tickLogs = uniqueSortedTolerance(tickLogs);
tickLogs(1) = 0;
tickLogs(end) = pLogMaximum;
pValues = 10.^(-tickLogs);
color.Ticks = tickLogs;
color.TickLabels = arrayfun(@(x)sprintf('%.3g',x),pValues, ...
    'UniformOutput',false);
if isempty(labelText)
    labelText = 'SR-global p';
end
color.Label.String = labelText;
end

function values = uniqueSortedTolerance(values)
values = sort(values(:).');
if isempty(values)
    return
end
tolerance = 64*eps(max(1,max(abs(values))));
values = values([true,diff(values) > tolerance]);
end

function overlaySignificanceBoundary(ax,panel,rates,depths, ...
        displayData,useSurface,significanceData)
threshold = panel.significanceThreshold;
if ~strcmp(panel.kind,'p') || ~isfinite(threshold) || ...
        threshold <= 0 || threshold >= 1 || ...
        numel(rates) < 2 || numel(depths) < 2
    return
end
level = -log10(threshold);
z = displayData.';
finiteValues = z(isfinite(z));
finiteRaw = significanceData(isfinite(significanceData));
if isempty(finiteValues) || isempty(finiteRaw) || ...
        ~any(finiteRaw <= threshold) || ~any(finiteRaw > threshold)
    return
end
hold(ax,'on');
if useSurface
    contour3(ax,rates,depths,z,[level level], ...
        'LineColor','k','LineWidth',1.2,'HandleVisibility','off');
else
    contour(ax,rates,depths,z,[level level], ...
        'LineColor','k','LineWidth',1.2,'HandleVisibility','off');
end
end

function limits = finiteLimits(values,fallback)
values = values(isfinite(values));
if isempty(values)
    limits = fallback;
    return
end
lower = min(values);
upper = max(values);
if lower == upper
    delta = max(1,abs(lower))*1e-6;
    lower = lower-delta;
    upper = upper+delta;
end
limits = [lower upper];
end

function overlayRidge(ax,score,rates,depths,details,localP, ...
        localPThreshold,useSurface,displayScore)
[ridgeRate,ridgeDepth] = suppliedRidge(details,depths);
if isempty(ridgeRate)
    ridgeRate = nan(numel(depths),1);
    ridgeDepth = depths;
    for windowIndex = 1:numel(depths)
        column = score(:,windowIndex);
        valid = find(isfinite(column));
        if isempty(valid)
            continue
        end
        [~,relativeIndex] = max(column(valid));
        ridgeRate(windowIndex) = rates(valid(relativeIndex));
    end
end
valid = isfinite(ridgeRate) & isfinite(ridgeDepth);
if ~any(valid)
    return
end
ridgeRate(~valid) = NaN;
ridgeDepth(~valid) = NaN;
hold(ax,'on');
lineArguments = {'Color','r','LineWidth',1.0, ...
    'DisplayName','Tracked ridge'};
ridgeP = ridgeValues(localP,rates,ridgeRate);
significant = valid & isfinite(ridgeP) & ridgeP <= localPThreshold;
notSignificant = valid & ~significant;
baseMarkerDiameter = 3.5;
significantMarkerDiameter = 1.2*baseMarkerDiameter;
if useSurface
    ridgeZ = ridgeDisplayValues(displayScore,rates,ridgeRate);
    finiteZ = ridgeZ(isfinite(ridgeZ));
    if isempty(finiteZ)
        ridgeZ = zeros(size(ridgeRate));
        offset = 0;
    else
        zRange = max(finiteZ)-min(finiteZ);
        offset = 0.01*max(1,zRange);
    end
    ridgeZ = ridgeZ+offset;
    plot3(ax,ridgeRate,ridgeDepth,ridgeZ,'-', ...
        lineArguments{:});
    scatter3(ax,ridgeRate(notSignificant),ridgeDepth(notSignificant), ...
        ridgeZ(notSignificant),baseMarkerDiameter^2,'o', ...
        'MarkerEdgeColor','r','MarkerFaceColor','none','LineWidth',0.6, ...
        'HandleVisibility','off');
    scatter3(ax,ridgeRate(significant),ridgeDepth(significant), ...
        ridgeZ(significant),significantMarkerDiameter^2,'o', ...
        'MarkerEdgeColor','r','MarkerFaceColor','r','LineWidth',0.6, ...
        'HandleVisibility','off');
else
    plot(ax,ridgeRate,ridgeDepth,'-',lineArguments{:});
    scatter(ax,ridgeRate(notSignificant),ridgeDepth(notSignificant), ...
        baseMarkerDiameter^2,'o','MarkerEdgeColor','r', ...
        'MarkerFaceColor','none','LineWidth',0.6,'HandleVisibility','off');
    scatter(ax,ridgeRate(significant),ridgeDepth(significant), ...
        significantMarkerDiameter^2,'o','MarkerEdgeColor','r', ...
        'MarkerFaceColor','r','LineWidth',0.6,'HandleVisibility','off');
end
end

function values = ridgeValues(map,rates,ridgeRate)
values = nan(size(ridgeRate));
if isempty(map)
    return
end
for windowIndex = 1:min(numel(ridgeRate),size(map,2))
    if ~isfinite(ridgeRate(windowIndex))
        continue
    end
    [~,rateIndex] = min(abs(rates-ridgeRate(windowIndex)));
    value = map(rateIndex,windowIndex);
    if isfinite(value)
        values(windowIndex) = value;
    end
end
end

function values = ridgeDisplayValues(score,rates,ridgeRate)
values = nan(size(ridgeRate));
for windowIndex = 1:min(numel(ridgeRate),size(score,2))
    if ~isfinite(ridgeRate(windowIndex))
        continue
    end
    [~,rateIndex] = min(abs(rates-ridgeRate(windowIndex)));
    value = score(rateIndex,windowIndex);
    if isfinite(value)
        values(windowIndex) = value;
    end
end
end

function [rate,depth] = suppliedRidge(details,defaultDepth)
rate = [];
depth = [];
candidate = [];
if isfield(details,'trackedSedimentationRate')
    candidate = details.trackedSedimentationRate;
elseif isfield(details,'trackedRate')
    candidate = details.trackedRate;
elseif isfield(details,'sr_p')
    candidate = details.sr_p;
end
if ~isnumeric(candidate) || isempty(candidate)
    return
end
if isvector(candidate) && numel(candidate) == numel(defaultDepth)
    rate = candidate(:);
    depth = defaultDepth;
elseif size(candidate,2) >= 2
    depth = candidate(:,1);
    rate = candidate(:,2);
end
end
