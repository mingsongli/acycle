function report = run_bispectral_gui_parameter_alert_stress()
%RUN_BISPECTRAL_GUI_PARAMETER_ALERT_STRESS Verify visible correction alerts.
%   REPORT = RUN_BISPECTRAL_GUI_PARAMETER_ALERT_STRESS() opens the real GUI,
%   injects multiple invalid controls without firing their individual edit
%   callbacks, invokes one Run, and verifies that calculation succeeds with
%   corrected values and exactly one visible warning-alert request. The
%   Command Window transcript is also checked for R2025b scene/canvas/peer-
%   tree failures. It never saves files.

packageDirectory = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
addpath(packageDirectory);
pathCleanup = onCleanup(@()path(oldPath));

logFile = [tempname,'.txt'];
diary(logFile);
diaryCleanup = onCleanup(@()stopDiary());
baselineFigures = findall(groot,'Type','figure');
windowCleanup = onCleanup(@()closeCreatedFigures(baselineFigures));
lastwarn('');

n = 128;
t = (0:n-1)';
y = sin(2*pi*t/31)+0.35*cos(2*pi*t/13);
context = struct('current_data',[t y], ...
    'data_name','visible-parameter-alert-stress.txt','unit','kyr');
gui = bispectralGUI(context);
gui.Visible = 'on';
drawnow;
controls = getappdata(gui,'BispectralControls');

% Bypass ValueChanged so one Run must consolidate all corrections and issue
% one alert after analysis rather than one alert for every edited control.
controls.Significance.Value = 'none';
controls.NumSegments.Value = 4.5;
controls.Overlap.Value = -5;
controls.MaxBins.Value = -8;
controls.FrequencyMin.Value = 0.40;
controls.FrequencyMax.Value = 0.50;
controls.Confidence.Value = 99.9;
controls.NumSurrogates.Value = 18.5;
controls.RandomSeed.Value = 1.5;
controls.KeepBispectrum.Value = 0;
controls.KeepBicoherence.Value = -3;
controls.ColorGrid.Value = -12;
controls.ReferencePeriods.Value = '1';
controls.FrequencyPairs.Value = '0.30 0.25';

invokeButton(controls.PreviewButton);
settleGraphics(0.5);
state = getappdata(gui,'BispectralState');

require(state.HasResult,'Run did not produce a cached result.');
require(state.AnalysisCount == 1, ...
    sprintf('AnalysisCount is %d; expected 1.',state.AnalysisCount));
require(~state.IsRunning,'GUI remained in its running state.');
require(state.ParameterCorrectionCount >= 13, ...
    'The injected invalid controls were not consolidated and corrected.');
require(state.ParameterAlertRequestCount == 1, ...
    sprintf('Parameter alert request count is %d; expected exactly 1.', ...
    state.ParameterAlertRequestCount));
require(state.ParameterAlertFailureCount == 0, ...
    'The visible parameter alert call failed.');
require(numel(state.PendingParameterCorrections) >= 13, ...
    'Preview Run consumed correction records before they could be saved.');
require(numel(state.LastResult.GUIParameterCorrections) >= 13, ...
    'The result did not retain every consolidated correction.');
require(isequal(state.PendingParameterCorrections, ...
    state.LastResult.GUIParameterCorrections), ...
    'Preview result and pending-save correction audits disagree.');
require(state.LastResult.Options.PlotColorGrid == 32, ...
    'Corrected colormap grid was not used by the analysis result.');
require(controls.ColorGrid.Value == 32, ...
    'Corrected colormap grid was not restored in the GUI.');
require(controls.Overlap.Value == controls.Defaults.OverlapPercent, ...
    'Corrected overlap was not restored in the GUI.');
require(controls.NumSurrogates.Value == controls.Defaults.NumSurrogates, ...
    'Corrected surrogate count was not restored in the GUI.');
require(controls.KeepBicoherence.Value == ...
        100*controls.Defaults.PlotKeepStrongestBicoherenceFraction, ...
    'Corrected b^2 retain fraction was not restored in the GUI.');
require(strcmp(controls.PreviewButton.Enable,'on') && ...
    strcmp(controls.SaveButton.Enable,'on') && ...
    strcmp(controls.CloseButton.Enable,'on'), ...
    'Run controls were not restored before the alert completed.');

% Teardown is part of the graphics test: peer-tree errors can be emitted
% asynchronously when an alert and its parent UIFigure are destroyed.
closeCreatedFigures(baselineFigures);
clear windowCleanup
settleGraphics(0.5);
[lastWarningMessage,~] = lastwarn;
stopDiary();
clear diaryCleanup
transcript = fileread(logFile);
scenePatterns = { ...
    'an error occurred while drawing the scene', ...
    'graphicsview error', ...
    'the canvas is undefined', ...
    'could not find node in peer tree', ...
    'reparentchildren', ...
    'replacechild'};
lowerTranscript = lower(transcript);
sceneWarningCount = sum(cellfun(@(pattern)count(lowerTranscript,pattern), ...
    scenePatterns));
lastWarnGraphicsCount = sum(cellfun(@(pattern)contains( ...
    lower(lastWarningMessage),pattern),scenePatterns));
require(sceneWarningCount == 0 && lastWarnGraphicsCount == 0, ...
    sprintf(['Detected %d transcript and %d lastwarn graphics scene ', ...
    'warning mention(s).'],sceneWarningCount,lastWarnGraphicsCount));

report = struct( ...
    'MATLABVersion',version, ...
    'AnalysisCount',state.AnalysisCount, ...
    'CorrectionCount',state.ParameterCorrectionCount, ...
    'AlertRequestCount',state.ParameterAlertRequestCount, ...
    'AlertFailureCount',state.ParameterAlertFailureCount, ...
    'SceneWarningCount',sceneWarningCount, ...
    'LastWarnGraphicsCount',lastWarnGraphicsCount, ...
    'CommandWindowLog',logFile);
fprintf(['[Bispectral parameter alert stress] corrections=%d, alert requests=%d, ', ...
    'alert failures=%d, graphics warnings=%d.\n'], ...
    report.CorrectionCount,report.AlertRequestCount,report.AlertFailureCount, ...
    report.SceneWarningCount);

clear pathCleanup
end

function invokeButton(control)
callback = control.ButtonPushedFcn;
callback(control,[]);
end

function require(condition,message)
if ~condition
    error('Acycle:BispectralTest:ParameterAlertStress',message);
end
end

function stopDiary()
try
    diary off
catch
end
end

function closeCreatedFigures(baseline)
current = findall(groot,'Type','figure');
for ii = 1:numel(current)
    if isempty(baseline) || ~any(current(ii) == baseline)
        try
            delete(current(ii));
        catch
        end
    end
end
drawnow;
end

function settleGraphics(seconds)
drawnow;
if seconds > 0
    pause(seconds);
end
drawnow;
end
