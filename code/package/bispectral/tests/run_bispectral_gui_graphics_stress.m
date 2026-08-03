function report = run_bispectral_gui_graphics_stress(roundCount,settleSeconds)
%RUN_BISPECTRAL_GUI_GRAPHICS_STRESS Exercise visible cached-figure redraws.
%   REPORT = RUN_BISPECTRAL_GUI_GRAPHICS_STRESS() opens the real bispectral
%   GUI and a visible result figure in MATLAB R2025b, performs 20 rounds of
%   cached display edits, and fails if a GraphicsView/peer-tree warning is
%   printed, the result figure disappears, or AnalysisCount changes.
%
%   This is intentionally a manual stress runner rather than a function-
%   based unit test: it opens visible windows and records the MATLAB Command
%   Window transcript. It never invokes Run & Save.

if nargin < 1 || isempty(roundCount)
    roundCount = 20;
end
if nargin < 2 || isempty(settleSeconds)
    settleSeconds = 0.05;
end
validateattributes(roundCount,{'numeric'}, ...
    {'scalar','real','finite','integer','>=',20},mfilename,'roundCount');
validateattributes(settleSeconds,{'numeric'}, ...
    {'scalar','real','finite','nonnegative','<=',1},mfilename,'settleSeconds');

packageDirectory = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
addpath(packageDirectory);
pathCleanup = onCleanup(@()path(oldPath));

logFile = [tempname,'.txt'];
diary(logFile);
diaryCleanup = onCleanup(@()stopDiary());

n = 256;
t = (0:n-1)';
y = cos(2*pi*0.046875*t+0.27) ...
    +0.82*cos(2*pi*0.078125*t-0.31) ...
    +0.68*cos(2*pi*0.125*t-0.04) ...
    +0.04*sin(2*pi*0.01953125*t);
context = struct('current_data',[t y], ...
    'data_name','visible-graphics-stress.txt','unit','kyr');

fprintf('[Bispectral graphics stress] MATLAB %s, rounds=%d, settle=%.3g s\n', ...
    version,roundCount,settleSeconds);
baselineFigures = findall(groot,'Type','figure');
cleanupWindows = onCleanup(@()closeStressWindows(baselineFigures));
baselineManagedFigureCount = countManagedFigures();
gui = bispectralGUI(context);
gui.Visible = 'on';
drawnow;
controls = getappdata(gui,'BispectralControls');

% Keep the numerical setup small and deterministic; only the initial Run
% may calculate. Every operation in the stress loop must use the cache.
controls.Significance.Value = 'none';
invokeValueChanged(controls.Significance);
controls.NumSegments.Value = 8;
invokeValueChanged(controls.NumSegments);
controls.Overlap.Value = 0;
invokeValueChanged(controls.Overlap);
controls.MaxBins.Value = 32;
invokeValueChanged(controls.MaxBins);
controls.FrequencyMin.Value = 0.01;
invokeValueChanged(controls.FrequencyMin);
controls.FrequencyMax.Value = 0.20;
invokeValueChanged(controls.FrequencyMax);
controls.AnnotatePeaks.Value = false;
invokeValueChanged(controls.AnnotatePeaks);
controls.PeriodAxes.Value = true;
invokeValueChanged(controls.PeriodAxes);

invokeButton(controls.PreviewButton);
settleGraphics(settleSeconds);
state = requireHealthyState(gui,1,'initial Run');
baselineAnalysisCount = state.AnalysisCount;
maxManagedFigureCount = countManagedFigures();
expectedManagedFigureCount = baselineManagedFigureCount+1;
if maxManagedFigureCount ~= expectedManagedFigureCount
    error('Acycle:BispectralTest:ManagedFigureLeak', ...
        'Initial Run left %d managed figures; expected %d.', ...
        maxManagedFigureCount,expectedManagedFigureCount);
end
lastWarnMessages = strings(0,1);
actionCount = 0;
minimumMapColorFraction = Inf;

periodValues = { ...
    '8 10 12.5','9 14 20','7.5 11 16','10 13 25'};
pairValues = { ...
    '0.040 0.060; 0.075,0.050', ...
    '0.055, 0.085; 0.110 0.045', ...
    '0.030 0.095; 0.065,0.070', ...
    '0.045,0.115; 0.090 0.035'};
quantities = {'overview','bicoherence-squared', ...
    'bispectrum-magnitude','biphase'};
colorGridValues = [16 24 32 48];

for roundIndex = 1:roundCount
    cycleIndex = mod(roundIndex-1,4)+1;
    controls.ReferencePeriods.Value = periodValues{cycleIndex};
    [~,message] = exerciseControl(gui,controls.ReferencePeriods, ...
        settleSeconds,baselineAnalysisCount,'ReferencePeriods');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    controls.FrequencyPairs.Value = pairValues{cycleIndex};
    [~,message] = exerciseControl(gui,controls.FrequencyPairs, ...
        settleSeconds,baselineAnalysisCount,'FrequencyPairs');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    controls.KeepBispectrum.Value = 10+mod(13*roundIndex,81);
    [~,message] = exerciseControl(gui,controls.KeepBispectrum, ...
        settleSeconds,baselineAnalysisCount,'Retain |B|');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    controls.KeepBicoherence.Value = 10+mod(17*roundIndex,81);
    [~,message] = exerciseControl(gui,controls.KeepBicoherence, ...
        settleSeconds,baselineAnalysisCount,'Retain b^2');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    controls.ColorGrid.Value = colorGridValues(cycleIndex);
    [~,message] = exerciseControl(gui,controls.ColorGrid, ...
        settleSeconds,baselineAnalysisCount,'Colormap grid');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    controls.PlotQuantity.Value = quantities{cycleIndex};
    [state,message] = exerciseControl(gui,controls.PlotQuantity, ...
        settleSeconds,baselineAnalysisCount,'Figure');
    actionCount = actionCount+1;
    lastWarnMessages = appendMessage(lastWarnMessages,message);

    renderSettings = getappdata(state.LastFigure,'BispectralRenderSettings');
    if ~strcmp(renderSettings.Quantity,quantities{cycleIndex})
        error('Acycle:BispectralTest:StaleRenderedQuantity', ...
            'Round %d retained stale quantity %s instead of %s.', ...
            roundIndex,renderSettings.Quantity,quantities{cycleIndex});
    end
    minimumMapColorFraction = min(minimumMapColorFraction, ...
        renderedMapColorFraction(state));
    maxManagedFigureCount = max(maxManagedFigureCount,countManagedFigures());
    if countManagedFigures() ~= expectedManagedFigureCount
        error('Acycle:BispectralTest:ManagedFigureLeak', ...
            'Round %d did not leave exactly one new managed result figure.', ...
            roundIndex);
    end
    fprintf('[Bispectral graphics stress] completed round %d/%d\n', ...
        roundIndex,roundCount);
end

finalState = requireHealthyState(gui,baselineAnalysisCount,'final redraw');
finalFigureWasValid = isgraphics(finalState.LastFigure,'figure') && ...
    strcmp(finalState.LastFigure.Visible,'on');

% Include teardown in the transcript because deletion itself can expose a
% peer-tree race. The already-recorded validity result covers the live plot.
closeStressWindows(baselineFigures);
settleGraphics(max(0.25,settleSeconds));
diary off;
logText = fileread(logFile);

sceneWarningCount = numel(regexp(logText, ...
    '(?m)^Warning:\s+An error occurred while drawing the scene:', 'match'));
canvasWarningCount = numel(regexpi(logText,'canvas\s+is\s+undefined','match'));
peerTreeWarningCount = numel(regexpi(logText,'peer\s+tree','match'));
graphicsViewCount = numel(regexpi(logText,'GraphicsView','match'));
reparentChildrenCount = numel(regexpi(logText,'reparentChildren','match'));
replaceChildCount = numel(regexpi(logText,'replaceChild','match'));
lastWarnGraphicsCount = sum(contains(lower(lastWarnMessages), ...
    ["graphicsview","peer tree","canvas is undefined", ...
    "reparentchildren","replacechild"]));
graphicsWarningCount = max([sceneWarningCount,canvasWarningCount, ...
    peerTreeWarningCount,graphicsViewCount,reparentChildrenCount, ...
    replaceChildCount,lastWarnGraphicsCount]);

report = struct( ...
    'MATLABVersion',version, ...
    'Rounds',roundCount, ...
    'DisplayActions',actionCount, ...
    'AnalysisCountBefore',baselineAnalysisCount, ...
    'AnalysisCountAfter',finalState.AnalysisCount, ...
    'FinalFigureWasValid',finalFigureWasValid, ...
    'BaselineManagedFigureCount',baselineManagedFigureCount, ...
    'MaximumManagedFigureCount',maxManagedFigureCount, ...
    'MinimumRenderedMapColorFraction',minimumMapColorFraction, ...
    'SceneWarningCount',sceneWarningCount, ...
    'CanvasWarningCount',canvasWarningCount, ...
    'PeerTreeWarningCount',peerTreeWarningCount, ...
    'GraphicsViewMentionCount',graphicsViewCount, ...
    'ReparentChildrenMentionCount',reparentChildrenCount, ...
    'ReplaceChildMentionCount',replaceChildCount, ...
    'LastWarnGraphicsCount',lastWarnGraphicsCount, ...
    'GraphicsWarningCount',graphicsWarningCount, ...
    'CommandWindowLog',logFile);

fprintf(['[Bispectral graphics stress] %d rounds, %d cached redraws, ', ...
    'AnalysisCount %d -> %d, graphics warnings=%d.\n'], ...
    report.Rounds,report.DisplayActions,report.AnalysisCountBefore, ...
    report.AnalysisCountAfter,report.GraphicsWarningCount);

if report.AnalysisCountAfter ~= report.AnalysisCountBefore
    error('Acycle:BispectralTest:UnexpectedRecalculation', ...
        'Cached display edits changed AnalysisCount from %d to %d.', ...
        report.AnalysisCountBefore,report.AnalysisCountAfter);
end
if ~report.FinalFigureWasValid
    error('Acycle:BispectralTest:MissingResultFigure', ...
        'The final visible result figure was missing or hidden.');
end
if report.GraphicsWarningCount > 0
    error('Acycle:BispectralTest:GraphicsViewWarning', ...
        ['Detected %d GraphicsView/canvas/peer-tree warning(s). ', ...
         'Inspect %s.'],report.GraphicsWarningCount,report.CommandWindowLog);
end
end

function fraction = renderedMapColorFraction(state)
if isfield(state.LastPlotHandles,'Bispectrum')
    mapAxis = state.LastPlotHandles.Bispectrum;
elseif isfield(state.LastPlotHandles,'Map')
    mapAxis = state.LastPlotHandles.Map;
else
    error('Acycle:BispectralTest:MissingMapAxis', ...
        'The latest plot handles contain no map axis.');
end
frame = getframe(mapAxis);
rgb = double(frame.cdata);
if isempty(rgb) || size(rgb,3) ~= 3
    error('Acycle:BispectralTest:EmptyRenderedFrame', ...
        'The visible map axis returned an empty rendered frame.');
end
channelSpread = max(rgb,[],3)-min(rgb,[],3);
fraction = nnz(channelSpread > 3)/numel(channelSpread);
if ~(isfinite(fraction) && fraction > 0.002)
    error('Acycle:BispectralTest:BlankRenderedMap', ...
        'Only %.4g of rendered map pixels contained color.',fraction);
end
end

function [state,lastWarningMessage] = exerciseControl( ...
        gui,control,settleSeconds,expectedAnalysisCount,label)
lastwarn('','');
invokeValueChanged(control);
settleGraphics(settleSeconds);
[lastWarningMessage,~] = lastwarn;
state = requireHealthyState(gui,expectedAnalysisCount,label);
end

function state = requireHealthyState(gui,expectedAnalysisCount,label)
if ~isgraphics(gui,'figure')
    error('Acycle:BispectralTest:MissingGUI', ...
        'The GUI disappeared during %s.',label);
end
state = getappdata(gui,'BispectralState');
if ~isstruct(state) || ~state.HasResult || state.IsRendering
    error('Acycle:BispectralTest:InvalidGUIState', ...
        'The cached GUI state is incomplete after %s.',label);
end
if state.AnalysisCount ~= expectedAnalysisCount
    error('Acycle:BispectralTest:UnexpectedRecalculation', ...
        '%s changed AnalysisCount from %d to %d.', ...
        label,expectedAnalysisCount,state.AnalysisCount);
end
if ~isgraphics(state.LastFigure,'figure') || ...
        ~strcmp(state.LastFigure.Visible,'on')
    error('Acycle:BispectralTest:MissingResultFigure', ...
        'The visible result figure disappeared after %s.',label);
end
if ~isappdata(state.LastFigure,'BispectralPlotComplete') || ...
        ~isequal(getappdata(state.LastFigure,'BispectralPlotComplete'),true)
    error('Acycle:BispectralTest:IncompleteResultFigure', ...
        'The result figure was incomplete after %s.',label);
end
surfaceHandles = findobj(state.LastFigure,'Type','surface');
if isempty(surfaceHandles) || any(~isgraphics(surfaceHandles))
    error('Acycle:BispectralTest:MissingMapSurface', ...
        'No live pcolor surface remained after %s.',label);
end
end

function count = countManagedFigures()
figures = findall(groot,'Type','figure');
managed = false(size(figures));
for index = 1:numel(figures)
    managed(index) = isappdata(figures(index),'BispectralRenderSettings');
end
count = nnz(managed);
end

function values = appendMessage(values,message)
if ~isempty(message)
    values(end+1,1) = string(message);
end
end

function settleGraphics(seconds)
drawnow;
if seconds > 0
    pause(seconds);
end
drawnow;
end

function invokeValueChanged(control)
callback = control.ValueChangedFcn;
callback(control,[]);
end

function invokeButton(control)
callback = control.ButtonPushedFcn;
callback(control,[]);
end

function closeStressWindows(baselineFigures)
figures = findall(groot,'Type','figure');
baselineFigures = baselineFigures(isgraphics(baselineFigures,'figure'));
for index = 1:numel(figures)
    existedBeforeTest = ~isempty(baselineFigures) && ...
        any(figures(index) == baselineFigures);
    belongsToStressRun = strcmp(get(figures(index),'Tag'),'bispectralGUI') || ...
        isappdata(figures(index),'BispectralRenderSettings') || ...
        isappdata(figures(index),'BispectralPlotComplete');
    if ~existedBeforeTest && belongsToStressRun && isgraphics(figures(index))
        delete(figures(index));
    end
end
drawnow;
end

function stopDiary()
try
    diary off;
catch
end
end
