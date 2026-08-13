function tests = test_evofft_gui_display_regressions
%TEST_EVOFFT_GUI_DISPLAY_REGRESSIONS Display-only evofft GUI regressions.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFolder = fileparts(mfilename('fullpath'));
seriesFolder = fileparts(testFolder);
codeFolder = fileparts(seriesFolder);
oldPath = path;
oldVisibility = get(groot,'DefaultFigureVisible');
addpath(genpath(codeFolder));
set(groot,'DefaultFigureVisible','off');
testCase.addTeardown(@()path(oldPath));
testCase.addTeardown(@()set(groot, ...
    'DefaultFigureVisible',oldVisibility));
end

function setup(testCase)
testCase.TestData.figuresBefore = findall(groot,'Type','figure');
testCase.TestData.baseVariables = snapshotBaseVariables({'s','x','y'});
end

function teardown(testCase)
figuresAfter = findall(groot,'Type','figure');
created = setdiff(figuresAfter,testCase.TestData.figuresBefore);
created = created(isgraphics(created));
if ~isempty(created)
    delete(created);
end
restoreBaseVariables(testCase.TestData.baseVariables);
end

function testFmaxChangeLeavesSeriesAxisLimitsUntouched(testCase)
app = createTestApp(testCase);

result = runEvofft(app);
seriesAxis = resultAxis(result,'evofft-series');
spectrumAxis = resultAxis(result,'evofft-spectrum');
seriesLimitsBefore = seriesAxis.XLim;

setEditValue(app.EditFmax,0.25);

verifyEqual(testCase,app.GroupFmax.SelectedObject,app.RadioInput);
verifyEqual(testCase,seriesAxis.XLim,seriesLimitsBefore,'AbsTol',0, ...
    'A display fmax change must not replace the series-amplitude limits.');
verifyEqual(testCase,spectrumAxis.XLim,[0 0.25],'AbsTol',1e-12);
end

function testDefaultFlipYReversesSeriesAndSpectrumAxes(testCase)
app = createTestApp(testCase);

verifyTrue(testCase,app.CheckFlipY.Value, ...
    'The v2.8 default is to flip the coordinate axis.');
result = runEvofft(app);

seriesAxis = resultAxis(result,'evofft-series');
spectrumAxis = resultAxis(result,'evofft-spectrum');
verifyEqual(testCase,string(seriesAxis.YDir),"reverse");
verifyEqual(testCase,string(spectrumAxis.YDir),"reverse");
end

function testV28FftMethodsRemainAvailableAndDispatchDifferently(testCase)
app = createTestApp(testCase);
verifyTrue(testCase,any(strcmp(app.DropMethod.Items, ...
    'Fast Fourier transform (LAH)')));
verifyTrue(testCase,any(strcmp(app.DropMethod.Items, ...
    'Fast Fourier transform (MatLab)')));

lahResult = runEvofft(app);
lahGrid = evalin('base','x');
delete(lahResult);

app.DropMethod.Value = 'Fast Fourier transform (MatLab)';
invokeUiCallback(app.DropMethod,'ValueChangedFcn');
matlabResult = runEvofft(app);
matlabGrid = evalin('base','x');

verifyTrue(testCase,isgraphics(matlabResult,'figure'));
verifyNotEqual(testCase,numel(matlabGrid),numel(lahGrid), ...
    ['The restored MATLAB FFT choice must dispatch to evofftML rather ', ...
     'than silently falling through to the LAH implementation.']);
end

function testSlidingWindowRestoresV28AutomaticStepAdjustment(testCase)
coordinate = (0:1000)';
signal = sin(2*pi*coordinate/37);
app = evofftGUI(struct('current_data',[coordinate,signal], ...
    'data_name','evofft-window-step.txt','unit','kyr','unit_type',2));
testCase.addTeardown(@()deleteApp(app));
app.UIFigure.Visible = 'off';

setEditValue(app.EditStep,0.25);
setEditValue(app.EditWindow,100);

verifyEqual(testCase,numericEditValue(app.EditStep),1.8, ...
    'AbsTol',1e-12, ...
    ['Changing the sliding window must restore the v2.8 automatic step ', ...
     'that limits the calculation to about 500 windows.']);
end

function testLogFrequencyPreservesFminGridAndAlignedAxes(testCase)
app = createTestApp(testCase);
app.CheckMTMRed.Value = true;

linearResult = runEvofft(app);
linearGrid = evalin('base','x');
verifyEqual(testCase,numericEditValue(app.EditFmin),0,'AbsTol',0);

setCheckboxValue(app.CheckLogFreq,true);

verifyEqual(testCase,numericEditValue(app.EditFmin),0,'AbsTol',0, ...
    ['Log-frequency display must not replace the user''s frequency ', ...
     'minimum with the first positive grid ordinate.']);
verifyAlignedLogFrequencyAxes(testCase,linearResult);

delete(linearResult);
logResult = runEvofft(app);
logGrid = evalin('base','x');

verifyEqual(testCase,logGrid,linearGrid,'AbsTol',0, ...
    'Changing only log-frequency display must not change x_grid.');
verifyEqual(testCase,numericEditValue(app.EditFmin),0,'AbsTol',0);
verifyAlignedLogFrequencyAxes(testCase,logResult);
end

function testThreeDimensionalRotationUsesAllTimedFrames(testCase)
pauseDurations = zeros(0,1);
hooks = struct('RotationPauseFcn',@recordPause);
app = createTestApp(testCase,hooks);

selectRadio(app.Radio3D);
verifyTrue(testCase,app.CheckRotation.Value);

result = runEvofft(app);
spectrumAxis = resultAxis(result,'evofft-spectrum');

verifySize(testCase,pauseDurations,[370 1]);
verifyEqual(testCase,pauseDurations,0.05*ones(370,1),'AbsTol',0, ...
    'Every one of the 370 rotation frames must request a 0.05 s pause.');
verifyEqual(testCase,spectrumAxis.View,[370 70],'AbsTol',0);
verifyEqual(testCase,mod(spectrumAxis.View(1),360),10,'AbsTol',0);

    function recordPause(duration)
        pauseDurations(end+1,1) = duration;
    end
end


function testMtmRedGridDoesNotDependOnPlotSeries(testCase)
app = createTestApp(testCase);
app.CheckMTMRed.Value = true;
setCheckboxValue(app.CheckXPadding,true);

app.CheckPlotSeries.Value = true;
withSeries = runEvofft(app);
withSeriesX = topLineXData(withSeries);

app.CheckPlotSeries.Value = false;
withoutSeries = runEvofft(app);
withoutSeriesX = topLineXData(withoutSeries);

verifyEqual(testCase,withoutSeriesX,withSeriesX,'AbsTol',0, ...
    ['Plot series is a layout choice and must not change any MTM-red ', ...
     'line frequency coordinates.']);
end

function testMtmSeriesLayoutRestoresV28LegendAndHiddenTicks(testCase)
app = createTestApp(testCase);
app.CheckMTMRed.Value = true;

result = runEvofft(app);
topAxis = resultAxis(result,'evofft-top');
spectrumAxis = resultAxis(result,'evofft-spectrum');

verifyNumElements(testCase,findall(result,'Type','legend'),1);
verifyEmpty(testCase,topAxis.XTickLabel);
verifyEmpty(testCase,spectrumAxis.YTickLabel);
end

function testAcceptedSamplingJitterUsesMedianLahFrequencyGrid(testCase)
coordinate = (0:63)';
coordinate(2:end) = coordinate(2:end)+2e-6;
spacing = median(diff(coordinate));
signal = sin(2*pi*coordinate/12);
context = struct('current_data',[coordinate,signal], ...
    'data_name','evofft-sampling-jitter.txt','unit','kyr','unit_type',2);
app = evofftGUI(context);
testCase.addTeardown(@()deleteApp(app));
app.UIFigure.Visible = 'off';
setEditValue(app.EditWindow,16);
setEditValue(app.EditStep,4);
setCheckboxValue(app.CheckXPadding,false);

result = runEvofft(app); %#ok<NASGU>
frequency = evalin('base','x');
expectedSpacing = 1/(4*round(16/spacing)*spacing);

verifyEqual(testCase,frequency(2)-frequency(1),expectedSpacing, ...
    'RelTol',1e-12, ...
    ['The LAH spectrum must use the same median sample interval as the ', ...
     'GUI Nyquist and MTM-red frequency grids.']);
end

function testAcceptedSamplingJitterUsesMedianIntervalInAllHelpers(testCase)
uniformCoordinate = (0:63)';
jitteredCoordinate = uniformCoordinate;
jitteredCoordinate(2:end) = jitteredCoordinate(2:end)+2e-6;
signal = sin(2*pi*uniformCoordinate/12)+0.1*cos(2*pi*uniformCoordinate/5);
uniformData = [uniformCoordinate,signal];
jitteredData = [jitteredCoordinate,signal];
verifyFalse(testCase,acycleSamplingIsUneven(jitteredCoordinate));

helpers = {@evofftML,@evoperiodogram,@evoplomb,@evopmtm};
for helperIndex = 1:numel(helpers)
    [uniformPower,uniformFrequency] = helpers{helperIndex}( ...
        uniformData,16,4,0,0.5,0);
    [jitteredPower,jitteredFrequency] = helpers{helperIndex}( ...
        jitteredData,16,4,0,0.5,0);
    verifyEqual(testCase,jitteredFrequency,uniformFrequency, ...
        'AbsTol',1e-12);
    verifyEqual(testCase,jitteredPower,uniformPower, ...
        'RelTol',1e-12,'AbsTol',1e-12, ...
        ['Accepted sampling jitter must not make ', ...
         func2str(helpers{helperIndex}),' use a different window grid.']);
end
end

function testFmaxAboveNyquistRemainsDisplayOnly(testCase)
app = createTestApp(testCase);
app.CheckMTMRed.Value = true;
requestedMaximum = 0.75;
verifyGreaterThan(testCase,requestedMaximum, ...
    str2double(app.LabelNyquist.Text));

setEditValue(app.EditFmax,requestedMaximum);
result = runEvofft(app);

verifyTrue(testCase,isgraphics(result,'figure'));
verifyEqual(testCase,app.GroupFmax.SelectedObject,app.RadioInput);
spectrumAxis = resultAxis(result,'evofft-spectrum');
verifyEqual(testCase,spectrumAxis.XLim,[0 requestedMaximum], ...
    'AbsTol',1e-12, ...
    ['A user fmax above Nyquist must extend the display without changing ', ...
     'or invalidating the Nyquist-limited calculation.']);
calculationGrid = evalin('base','x');
verifyLessThanOrEqual(testCase,max(calculationGrid), ...
    str2double(app.LabelNyquist.Text)+1e-12);
end

function testNumericColormapGridIsApplied(testCase)
app = createTestApp(testCase);
result = runEvofft(app);

app.DropCmap.Value = 'jet';
invokeUiCallback(app.DropCmap,'ValueChangedFcn');
setEditValue(app.EditGrid,7);

verifySize(testCase,colormap(result),[7 3], ...
    'Grid # must produce a colormap with the requested number of colors.');
end

function app = createTestApp(testCase,hooks)
if nargin < 2
    hooks = struct();
end
coordinate = (0:63)';
signal = sin(2*pi*coordinate/12) + 0.25*cos(2*pi*coordinate/5);
context = struct( ...
    'current_data',[coordinate,signal], ...
    'data_name','evofft-display-regression.txt', ...
    'unit','kyr', ...
    'unit_type',2, ...
    'EvofftTestHooks',hooks);

app = evofftGUI(context);
testCase.addTeardown(@()deleteApp(app));
app.UIFigure.Visible = 'off';
setEditValue(app.EditWindow,16);
setEditValue(app.EditStep,4);
setCheckboxValue(app.CheckXPadding,false);
app.CheckSave.Value = false;
drawnow;
end

function result = runEvofft(app)
before = findall(groot,'Type','figure','Tag','evofftResultFigure');
invokeUiCallback(app.ButtonOK,'ButtonPushedFcn');
drawnow;
after = findall(groot,'Type','figure','Tag','evofftResultFigure');
result = setdiff(after,before);
assert(isscalar(result),'Expected exactly one new evofft result figure.');
end

function axisHandle = resultAxis(result,tag)
axisHandle = findall(result,'Type','axes','Tag',tag);
assert(isscalar(axisHandle), ...
    'Expected exactly one result axis tagged "%s".',tag);
end

function xData = topLineXData(result)
topAxis = resultAxis(result,'evofft-top');
lines = findall(topAxis,'Type','line');
assert(numel(lines) == 4,'Expected four MTM-red overlay lines.');
xData = cell(numel(lines),1);
for lineIndex = 1:numel(lines)
    xData{lineIndex} = lines(lineIndex).XData(:);
end
lengths = cellfun(@numel,xData);
assert(all(lengths == lengths(1)), ...
    'Expected all MTM-red overlay lines to share one frequency grid.');
xData = [xData{:}];
end

function verifyAlignedLogFrequencyAxes(testCase,result)
topAxis = resultAxis(result,'evofft-top');
spectrumAxis = resultAxis(result,'evofft-spectrum');
verifyEqual(testCase,string(topAxis.XScale),"log");
verifyEqual(testCase,string(spectrumAxis.XScale),"log");
verifyEqual(testCase,topAxis.XLim,spectrumAxis.XLim,'AbsTol',1e-12, ...
    'The top spectrum and evolutionary-spectrum axes must stay aligned.');
verifyGreaterThan(testCase,topAxis.XLim(1),0);
end

function selectRadio(radio)
group = radio.Parent;
group.SelectedObject = radio;
invokeUiCallback(group,'SelectionChangedFcn');
end

function setCheckboxValue(control,value)
control.Value = logical(value);
invokeUiCallback(control,'ValueChangedFcn');
end

function setEditValue(control,value)
if ischar(value) || (isstring(value) && isscalar(value))
    control.Value = char(value);
else
    control.Value = num2str(value,'%.15g');
end
invokeUiCallback(control,'ValueChangedFcn');
end

function value = numericEditValue(control)
value = str2double(string(control.Value));
end

function invokeUiCallback(control,propertyName)
callback = control.(propertyName);
if isempty(callback)
    return
end
if isa(callback,'function_handle')
    callback(control,[]);
elseif iscell(callback)
    feval(callback{1},control,[],callback{2:end});
else
    eval(callback);
end
end

function deleteApp(app)
try
    if isvalid(app)
        delete(app);
    end
catch
end
end

function state = snapshotBaseVariables(names)
state = struct('Names',{names},'Exists',false(size(names)), ...
    'Values',{cell(size(names))});
for index = 1:numel(names)
    state.Exists(index) = evalin('base', ...
        sprintf('exist(''%s'',''var'') == 1',names{index}));
    if state.Exists(index)
        state.Values{index} = evalin('base',names{index});
    end
end
end

function restoreBaseVariables(state)
for index = 1:numel(state.Names)
    name = state.Names{index};
    if state.Exists(index)
        assignin('base',name,state.Values{index});
    else
        evalin('base',['clear ',name]);
    end
end
end
