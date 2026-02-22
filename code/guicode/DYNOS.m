function varargout = DYNOS(varargin)
% DYNOS App Designer-style single-file GUI (no GUIDE .fig dependency)

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

S = initState(ctx);
S = createUI(S);
S = loadDataReady(S, true);
setappdata(S.UIFigure,'DYNOS_STATE',S);

if nargout > 0
    varargout{1} = S.UIFigure;
end

end

function S = initState(ctx)
S = struct();
S.ctx = ctx;
S.bg = [0.94 0.94 0.94];
S.blue = [0.08 0.02 0.95];
S.monzoom = getfielddef(ctx,'MonZoom',1);
S.val1 = getfielddef(ctx,'val1',1);
S.unit = char(getfielddef(ctx,'unit','ka'));
S.data = [];
S.dat_name = char(getfielddef(ctx,'dat_name','data'));
S.data_name = char(getfielddef(ctx,'data_name','data'));
S.listbox_acmain = getfielddef(ctx,'listbox_acmain',[]);
S.edit_acfigmain_dir = getfielddef(ctx,'edit_acfigmain_dir',[]);

S.use_middle_age = true;
S.age = 0;
S.cycles = [405 125 95 40.9 23.6 22.3 19.1];
S.f = 1./S.cycles;

S.window1 = 300;
S.window2 = 500;
S.nw1 = 2;
S.nw2 = 2;
S.pad = 1000;
S.step = 5;
S.nout = 1000;
S.shiftwin = 1;
S.padwin = 1;
S.fza = 0.9;
S.fzb = 1.2;
S.ftmin = 0.001;
S.ftmax = 1;
S.nmc = 1000;
S.numcore = feature('numCores');
S.itinerary = 50;

S.percent_on = [true true true true true true];
S.cut1 = NaN;
S.cut2 = NaN;
S.sampa = NaN;
S.sampb = NaN;
S.parmhat = [1 1];

S.run = struct('y_grid',[],'powyad_p_nan',[],'npercent',0,'npercent2',0,'colorcode',[],'powyadjust',[],'f3m',[],'nwz',[],'windowz',[],'samplez',[]);
end

function S = createUI(S)
sc = get(groot,'ScreenSize');
pos = [round(0.02*sc(3)) round(0.03*sc(4)) round(0.96*sc(3)) round(0.92*sc(4))];

S.UIFigure = uifigure('Name','Acycle: Sedimentary Noise Model - DYNOT', ...
    'Color',S.bg,'Position',pos,'AutoResizeChildren','off');
S.UIFigure.SizeChangedFcn = @(~,~)onResize(S.UIFigure);

% restore quick toolbar actions: save + print/export
tb = uitoolbar(S.UIFigure);
iconSave = fullfile(matlabroot,'toolbox','matlab','icons','file_save.png');
iconPrint = fullfile(matlabroot,'toolbox','matlab','icons','tool_print.png');
if ~isfile(iconPrint)
    iconPrint = iconSave;
end
uipushtool(tb,'Icon',iconSave,'Tooltip','Save DYNOT figure/data', ...
    'ClickedCallback',@(src,evt)onSaveFigure(src));
uipushtool(tb,'Icon',iconPrint,'Tooltip','Print/Export DYNOT figure', ...
    'ClickedCallback',@(src,evt)onPrintFigure(src));

% top labels
S.LTitle = uilabel(S.UIFigure,'Text','DYnamic Noise after Orbital Tuning (DYNOT) sea-level model v2.0', ...
    'FontSize',28/2,'FontWeight','bold','HorizontalAlignment','center','BackgroundColor',S.bg);
S.LRef = uieditfield(S.UIFigure,'text','Editable','off', ...
    'Value','(Li et al., 2018 Nature Communications, 9: doi: 10.1038/s41467-018-03454-y)');

% left column panels
S.PDataB = uipanel(S.UIFigure,'Title','','BackgroundColor',S.bg);
S.BRun = uibutton(S.PDataB,'push','Text','Let''s go','BackgroundColor',S.blue,'FontColor','white','FontWeight','bold', ...
    'ButtonPushedFcn',@(src,evt)onRun(src));

S.PInterp = uipanel(S.UIFigure,'Title','Interpolation','BackgroundColor',S.bg);
S.TCut = uilabel(S.PInterp,'Text','Cut data','BackgroundColor',S.bg);
S.ECut1 = uieditfield(S.PInterp,'text','Value','7000');
S.TTo1 = uilabel(S.PInterp,'Text','to','BackgroundColor',S.bg);
S.ECut2 = uieditfield(S.PInterp,'text','Value','8000');
S.BCut = uibutton(S.PInterp,'push','Text','Cut','ButtonPushedFcn',@(src,evt)onCut(src));
S.TSamp = uilabel(S.PInterp,'Text','Sample rate','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.ESampA = uieditfield(S.PInterp,'text','Value','1');
S.TTo2 = uilabel(S.PInterp,'Text','to','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.ESampB = uieditfield(S.PInterp,'text','Value','1');
S.TKa1 = uilabel(S.PInterp,'Text','ka','FontColor',[0.8 0 0],'BackgroundColor',S.bg);

S.PMC = uipanel(S.UIFigure,'Title','Monte Carlo Simulation Settings','BackgroundColor',S.bg);
S.TWinFrom = uilabel(S.PMC,'Text','Windows from','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.EWin1 = uieditfield(S.PMC,'text','Value',num2str(S.window1));
S.TTo3 = uilabel(S.PMC,'Text','to','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.EWin2 = uieditfield(S.PMC,'text','Value',num2str(S.window2));
S.TKa2 = uilabel(S.PMC,'Text','ka','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.TNW = uilabel(S.PMC,'Text','Time-halfbandwidth product:','BackgroundColor',S.bg);
S.ENW1 = uieditfield(S.PMC,'text','Value',num2str(S.nw1));
S.TTo4 = uilabel(S.PMC,'Text','to','BackgroundColor',S.bg);
S.ENW2 = uieditfield(S.PMC,'text','Value',num2str(S.nw2));
S.TPad = uilabel(S.PMC,'Text','Zero-padding','BackgroundColor',S.bg);
S.EPad = uieditfield(S.PMC,'text','Value',num2str(S.pad));
S.TStep = uilabel(S.PMC,'Text','Step','BackgroundColor',S.bg);
S.EStep = uieditfield(S.PMC,'text','Value',num2str(S.step));
S.TKa3 = uilabel(S.PMC,'Text','ka','BackgroundColor',S.bg);
S.TNMC = uilabel(S.PMC,'Text','Number of Monte Carlo Simulations','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.ENMC = uieditfield(S.PMC,'text','Value',num2str(S.nmc));

S.PFreq = uipanel(S.UIFigure,'Title','Frequency','BackgroundColor',S.bg);
S.BGFreq = uibuttongroup(S.PFreq,'BorderType','none','BackgroundColor',S.bg, ...
    'SelectionChangedFcn',@(bg,evt)onFreqMode(bg));
S.RMiddle = uiradiobutton(S.BGFreq,'Text','Middle age of data','Value',true,'FontWeight','bold','FontColor',[0.8 0 0]);
S.EAge = uieditfield(S.BGFreq,'text','Value',num2str(S.age),'FontColor',[0.8 0 0]);
S.TMa = uilabel(S.BGFreq,'Text','Ma','FontColor',[0.8 0 0],'BackgroundColor',S.bg);
S.RCycles = uiradiobutton(S.BGFreq,'Text','Type target orbital cycles (space delimited, ka)','Value',false);
S.ECycles = uieditfield(S.BGFreq,'text','Value',num2str(S.cycles,'%1.1f '),'Enable','off');
S.TRange = uilabel(S.BGFreq,'Text','Frequency ranges: +/-','BackgroundColor',S.bg);
S.EFza = uieditfield(S.BGFreq,'text','Value',num2str(S.fza));
S.TTo5 = uilabel(S.BGFreq,'Text','to','BackgroundColor',S.bg);
S.EFzb = uieditfield(S.BGFreq,'text','Value',num2str(S.fzb));
S.TXBW = uilabel(S.BGFreq,'Text','x bandwidth','BackgroundColor',S.bg);
S.TCutoff = uilabel(S.BGFreq,'Text','Cutoff frequencies:','BackgroundColor',S.bg);
S.EFtmin = uieditfield(S.BGFreq,'text','Value',num2str(S.ftmin));
S.TTo6 = uilabel(S.BGFreq,'Text','to','BackgroundColor',S.bg);
S.EFtmax = uieditfield(S.BGFreq,'text','Value',num2str(S.ftmax));
S.TUnitF = uilabel(S.BGFreq,'Text','cycles/kyr','BackgroundColor',S.bg);

S.PPlot = uipanel(S.UIFigure,'Title','Plot','BackgroundColor',S.bg);
S.TCI = uilabel(S.PPlot,'Text','Confidence Intervals','BackgroundColor',S.bg);
S.CMedian = uicheckbox(S.PPlot,'Text','Median','Value',true);
S.C50 = uicheckbox(S.PPlot,'Text','50%','Value',true);
S.C68 = uicheckbox(S.PPlot,'Text','68%','Value',true);
S.C80 = uicheckbox(S.PPlot,'Text','80%','Value',true);
S.C90 = uicheckbox(S.PPlot,'Text','90%','Value',true);
S.C95 = uicheckbox(S.PPlot,'Text','95%','Value',true);
S.TNout = uilabel(S.PPlot,'Text','Interpolation number','BackgroundColor',S.bg);
S.ENout = uieditfield(S.PPlot,'text','Value',num2str(S.nout));
S.TPadWin = uilabel(S.PPlot,'Text','Half-window padding','BackgroundColor',S.bg);
S.EPadWin = uieditfield(S.PPlot,'text','Value',num2str(S.padwin));

S.PProc = uipanel(S.UIFigure,'Title','Process','BackgroundColor',S.bg);
S.TCore = uilabel(S.PProc,'Text','Numer of physical core will be used','BackgroundColor',S.bg);
S.ECore = uieditfield(S.PProc,'text','Value',num2str(S.numcore));
S.TIt = uilabel(S.PProc,'Text','The first','BackgroundColor',S.bg);
S.EIt = uieditfield(S.PProc,'text','Value',num2str(S.itinerary));
S.TIt2 = uilabel(S.PProc,'Text','iterations to estimate process time','BackgroundColor',S.bg);
S.TTips = uitextarea(S.PProc,'Editable','off','BackgroundColor',S.bg,'FontSize',11, ...
    'Value',{'Press "CTRL" + "X" to cease the process;', ...
             'May type the following script to quit the parallel computing:', ...
             'delete(gcp(''nocreate''))'});

% right plot panels
S.PDataPlot = uipanel(S.UIFigure,'Title','Data','BackgroundColor',S.bg);
S.AxData = uiaxes(S.PDataPlot);
S.PDynot = uipanel(S.UIFigure,'Title','DYNOT','BackgroundColor',S.bg);
S.AxDynot = uiaxes(S.PDynot);

setappdata(S.UIFigure,'DYNOS_STATE',S);
onResize(S.UIFigure);
end

function onResize(fig)
S = getappdata(fig,'DYNOS_STATE');
if isempty(S), return; end
w = max(1200, fig.Position(3));
h = max(760, fig.Position(4));
if fig.Position(3) < w || fig.Position(4) < h
    fig.Position(3:4) = [w h];
end

leftW = max(540, round(0.355*w));
rightX = leftW + round(0.01*w);
rightW = max(500, w - rightX - round(0.01*w));

topX = round(0.01*w);
topY = round(0.90*h);
topH = max(48,round(0.06*h));
topW2 = max(220, round(0.42*leftW));
S.PDataB.Position = [topX topY topW2 topH];
S.BRun.Position = [10 8 max(20,S.PDataB.Position(3)-20) max(20,S.PDataB.Position(4)-16)];

S.PInterp.Position = [round(0.01*w) round(0.775*h) leftW max(96,round(0.12*h))];
S.PMC.Position = [round(0.01*w) round(0.595*h) leftW max(126,round(0.175*h))];
S.PFreq.Position = [round(0.01*w) round(0.365*h) leftW max(150,round(0.22*h))];
S.PPlot.Position = [round(0.01*w) round(0.205*h) leftW max(128,round(0.16*h))];
S.PProc.Position = [round(0.01*w) round(0.01*h) leftW max(178,round(0.21*h))];

S.LTitle.Position = [rightX round(0.93*h) rightW 30];
S.LRef.Position = [rightX+round(0.03*rightW) round(0.895*h) round(0.90*rightW) 24];
S.PDataPlot.Position = [rightX round(0.48*h) rightW max(290,round(0.41*h))];
S.PDynot.Position = [rightX round(0.01*h) rightW max(280,round(0.40*h))];
S.AxData.Position = [30 40 max(120,S.PDataPlot.Position(3)-40) max(120,S.PDataPlot.Position(4)-60)];
S.AxDynot.Position = [30 40 max(120,S.PDynot.Position(3)-40) max(120,S.PDynot.Position(4)-60)];

layoutInterp(S); layoutMC(S); layoutFreq(S); layoutPlot(S); layoutProc(S);
setappdata(fig,'DYNOS_STATE',S);
end

function layoutInterp(S)
pw = S.PInterp.Position(3); ph = S.PInterp.Position(4);
S.TCut.Position = [12 round(0.66*ph) 100 24];
S.ECut1.Position = [130 round(0.62*ph) 100 28];
S.TTo1.Position = [238 round(0.66*ph) 24 24];
S.ECut2.Position = [270 round(0.62*ph) 100 28];
S.BCut.Position = [380 round(0.62*ph) 90 28];
S.TSamp.Position = [12 round(0.27*ph) 100 24];
S.ESampA.Position = [130 round(0.23*ph) 100 28];
S.TTo2.Position = [238 round(0.27*ph) 24 24];
S.ESampB.Position = [270 round(0.23*ph) 100 28];
S.TKa1.Position = [380 round(0.27*ph) 30 24];
end

function layoutMC(S)
pw = S.PMC.Position(3); ph = S.PMC.Position(4);
S.TWinFrom.Position = [12 round(0.72*ph) 110 22];
S.EWin1.Position = [135 round(0.70*ph) 70 26];
S.TTo3.Position = [210 round(0.72*ph) 24 22];
S.EWin2.Position = [235 round(0.70*ph) 70 26];
S.TKa2.Position = [310 round(0.72*ph) 24 22];
S.TNW.Position = [12 round(0.52*ph) 160 22];
S.ENW1.Position = [205 round(0.50*ph) 50 26];
S.TTo4.Position = [260 round(0.52*ph) 24 22];
S.ENW2.Position = [280 round(0.50*ph) 50 26];
S.TPad.Position = [12 round(0.32*ph) 80 22];
S.EPad.Position = [120 round(0.30*ph) 60 26];
S.TStep.Position = [225 round(0.32*ph) 35 22];
S.EStep.Position = [260 round(0.30*ph) 50 26];
S.TKa3.Position = [315 round(0.32*ph) 24 22];
S.TNMC.Position = [12 round(0.08*ph) 180 22];
S.ENMC.Position = [205 round(0.06*ph) 90 26];
end

function layoutFreq(S)
pw = S.PFreq.Position(3); ph = S.PFreq.Position(4);
S.BGFreq.Position = [2 2 pw-4 ph-4];
S.RMiddle.Position = [12 round(0.78*ph) 140 22];
S.EAge.Position = [160 round(0.75*ph) 70 26];
S.TMa.Position = [238 round(0.78*ph) 30 22];
S.RCycles.Position = [12 round(0.58*ph) 280 22];
S.ECycles.Position = [12 round(0.41*ph) pw-24 26];
S.TRange.Position = [12 round(0.22*ph) 120 22];
S.EFza.Position = [145 round(0.20*ph) 55 26];
S.TTo5.Position = [207 round(0.22*ph) 24 22];
S.EFzb.Position = [232 round(0.20*ph) 55 26];
S.TXBW.Position = [294 round(0.22*ph) 75 22];
S.TCutoff.Position = [12 round(0.05*ph) 120 22];
S.EFtmin.Position = [145 round(0.03*ph) 55 26];
S.TTo6.Position = [207 round(0.05*ph) 24 22];
S.EFtmax.Position = [232 round(0.03*ph) 55 26];
S.TUnitF.Position = [294 round(0.05*ph) 80 22];
end

function layoutPlot(S)
pw = S.PPlot.Position(3); ph = S.PPlot.Position(4);
S.TCI.Position = [12 round(0.64*ph) 150 22];
S.CMedian.Position = [250 round(0.62*ph) 90 22];
S.C50.Position = [360 round(0.62*ph) 80 22];
S.C68.Position = [52 round(0.40*ph) 70 22];
S.C80.Position = [158 round(0.40*ph) 70 22];
S.C90.Position = [264 round(0.40*ph) 70 22];
S.C95.Position = [370 round(0.40*ph) 70 22];
S.TNout.Position = [12 round(0.12*ph) 160 22];
S.ENout.Position = [190 round(0.10*ph) 84 26];
S.TPadWin.Position = [286 round(0.12*ph) 130 22];
S.EPadWin.Position = [425 round(0.10*ph) 62 26];
end

function layoutProc(S)
pw = S.PProc.Position(3); ph = S.PProc.Position(4);
S.TCore.Position = [12 round(0.80*ph) 250 22];
S.ECore.Position = [280 round(0.78*ph) 95 28];
S.TIt.Position = [12 round(0.57*ph) 70 22];
S.EIt.Position = [95 round(0.55*ph) 70 28];
S.TIt2.Position = [175 round(0.57*ph) 250 22];
S.TTips.Position = [12 10 pw-22 round(0.36*ph)];
end

function onDataReady(src)
S = getState(src);
S = loadDataReady(S, false);
setState(src,S);
end

function S = loadDataReady(S, initCall)
try
    data = getfielddef(S.ctx,'current_data',[]);
    if isempty(data)
        if ~initCall
            data_type;
        end
        return
    end
    data = sanitizeData(data);
    if size(data,1) < 10
        return
    end
    S.data = data;
    assignin('base','data',data);

    if data(2,1) <= data(1,1)
        data = flipud(data);
    end
    samplerate = diff(data(:,1));
    S.parmhat = wblfit(samplerate);
    samplerange = prctile(samplerate,[5 95]);

    S.sampa = samplerange(1);
    S.sampb = samplerange(2);
    S.cut1 = data(1,1);
    S.cut2 = data(end,1);

    S.ECut1.Value = num2str(S.cut1);
    S.ECut2.Value = num2str(S.cut2);
    S.ESampA.Value = num2str(S.sampa);
    S.ESampB.Value = num2str(S.sampb);
    S.EPad.Value = num2str(S.pad);
    S.EWin1.Value = num2str(S.window1);
    S.EWin2.Value = num2str(S.window2);
    S.ENW1.Value = num2str(S.nw1);
    S.ENW2.Value = num2str(S.nw2);
    S.EStep.Value = num2str(S.step);
    S.ENMC.Value = num2str(S.nmc);
    S.ECore.Value = num2str(S.numcore);
    S.EIt.Value = num2str(S.itinerary);
    S.ECycles.Value = num2str(S.cycles,'%1.1f ');

    cla(S.AxData);
    plot(S.AxData,data(:,1),data(:,2),'Color',[0.2 0.6 1]);
    xlim(S.AxData,[data(1,1) data(end,1)]);
    set(S.AxData,'XMinorTick','on','YMinorTick','on');

    cla(S.AxDynot);
    histogram(S.AxDynot,samplerate,40,'FaceColor',[0 0.4470 0.7410],'EdgeColor','none');
    title(S.AxDynot,'Sample rates');
    set(S.AxDynot,'XMinorTick','on','YMinorTick','on');
catch ME
    uialert(S.UIFigure,ME.message,'DYNOS');
end
end

function onCut(src)
S = getState(src);
if isempty(S.data), return; end
cut1 = str2double(S.ECut1.Value);
cut2 = str2double(S.ECut2.Value);
if ~isfinite(cut1) || ~isfinite(cut2), return; end
if cut1 > cut2
    t = cut1; cut1 = cut2; cut2 = t;
end
idx = S.data(:,1)>=cut1 & S.data(:,1)<=cut2;
if nnz(idx) < 10, return; end
S.data = S.data(idx,1:2);

samplerate = diff(S.data(:,1));
S.parmhat = wblfit(samplerate);
sr = prctile(samplerate,[5 95]);
S.sampa = sr(1); S.sampb = sr(2);
S.ESampA.Value = num2str(S.sampa);
S.ESampB.Value = num2str(S.sampb);

cla(S.AxData);
plot(S.AxData,S.data(:,1),S.data(:,2),'Color',[0.2 0.6 1]);
set(S.AxData,'XMinorTick','on','YMinorTick','on');
cla(S.AxDynot);
histogram(S.AxDynot,samplerate,40,'FaceColor',[0 0.4470 0.7410],'EdgeColor','none');
title(S.AxDynot,'Sample rates');
set(S.AxDynot,'XMinorTick','on','YMinorTick','on');

setState(src,S);
end

function onFreqMode(bg)
S = getState(bg);
S.use_middle_age = (bg.SelectedObject == S.RMiddle);
if S.use_middle_age
    S.EAge.Enable = 'on';
    S.ECycles.Enable = 'off';
else
    S.EAge.Enable = 'off';
    S.ECycles.Enable = 'on';
end
setState(bg,S);
end

function onRun(src)
S = getState(src);
if isempty(S.data)
    S = loadDataReady(S,false);
    if isempty(S.data)
        uialert(S.UIFigure,'Data not ready.','DYNOT');
        setState(src,S);
        return;
    end
end

try
    S = readInputs(S);
    setState(src,S);
    S = runDynot(S);
    setState(src,S);
catch ME
    uialert(S.UIFigure,ME.message,'DYNOT Error');
end
end

function S = readInputs(S)
S.window1 = str2double(S.EWin1.Value);
S.window2 = str2double(S.EWin2.Value);
S.nw1 = str2double(S.ENW1.Value);
S.nw2 = str2double(S.ENW2.Value);
S.pad = str2double(S.EPad.Value);
S.step = str2double(S.EStep.Value);
S.nmc = max(10,round(str2double(S.ENMC.Value)));
S.nout = max(100,round(str2double(S.ENout.Value)));
S.padwin = max(0,round(str2double(S.EPadWin.Value)));
S.fza = str2double(S.EFza.Value);
S.fzb = str2double(S.EFzb.Value);
S.ftmin = str2double(S.EFtmin.Value);
S.ftmax = str2double(S.EFtmax.Value);
S.sampa = str2double(S.ESampA.Value);
S.sampb = str2double(S.ESampB.Value);
S.numcore = max(1,round(str2double(S.ECore.Value)));
S.itinerary = max(1,round(str2double(S.EIt.Value)));

S.percent_on = [S.CMedian.Value S.C50.Value S.C68.Value S.C80.Value S.C90.Value S.C95.Value];
if ~any(S.percent_on), S.percent_on(1) = true; end

if S.use_middle_age
    S.age = str2double(S.EAge.Value);
    age_obl = 41 - 0.0332*S.age;
    age_p1 = 22.43 - 0.0108*S.age;
    age_p2 = 23.75 - 0.0121*S.age;
    age_p3 = 19.18 - 0.0079*S.age;
    c = [405 125 95 age_obl age_p2 age_p1 age_p3];
    S.cycles = c;
    S.ECycles.Value = num2str(c,'%1.1f ');
else
    c = str2num(S.ECycles.Value); %#ok<ST2NM>
    if isempty(c), c = [405 125 95 40.9 23.6 22.3 19.1]; end
    S.cycles = c(:)';
end
S.f = 1./S.cycles;

if S.sampa <= 0 || S.sampb <= 0 || S.sampb < S.sampa
    error('Sample rate range is invalid.');
end
end

function S = runDynot(S)
data = S.data;
nmc = S.nmc;
nout = S.nout;

if S.nw2 == S.nw1
    randnw = zeros(nmc,1);
else
    randnw = randi(2*(S.nw2-S.nw1),[nmc 1]);
end
samplez = wblrnd(S.parmhat(1),S.parmhat(2),[nmc 1]);
samplez(samplez<S.sampa) = S.sampa + (S.sampb-S.sampa).*rand(sum(samplez<S.sampa),1);
samplez(samplez>S.sampb) = S.sampa + (S.sampb-S.sampa).*rand(sum(samplez>S.sampb),1);
windowz = S.window1 + (S.window2-S.window1).*rand(nmc,1);
nwz = S.nw1 + randnw/2;
bw = nwz./windowz;

f3m = zeros(nmc,2*numel(S.f));
for i = 1:numel(S.f)
    fz = S.fza + (S.fzb-S.fza).*rand(nmc,1);
    f3m(:,2*i-1) = S.f(i) - fz.*bw;
    fz = S.fza + (S.fzb-S.fza).*rand(nmc,1);
    f3m(:,2*i) = S.f(i) + fz.*bw;
end
f3m(f3m<S.ftmin)=S.ftmin; f3m(f3m>S.ftmax)=S.ftmax;

y_grid = linspace(data(1,1),data(end,1),nout)';
powy = nan(nout,nmc);
powmean = nan(1,nmc);

hwb = waitbar(0,'Running DYNOT ...','WindowStyle','modal');
cleanupWb = onCleanup(@()safeClose(hwb));
for i = 1:nmc
    dat = [];
    dat(:,1) = data(1,1):samplez(i):data(end,1);
    dat(:,2) = interp1(data(:,1),data(:,2),dat(:,1),'pchip');
    p = polyfit(dat(:,1),dat(:,2),1);
    dat(:,2) = dat(:,2) - polyval(p,dat(:,1));
    if S.padwin > 0
        dat = zeropad2(dat,windowz(i),S.padwin);
    end
    nw = nwz(i);
    power = pdan(dat,f3m(i,:),windowz(i),nw,S.ftmin,S.ftmax,S.step,S.pad);
    powy(:,i) = interp1(power(:,1),power(:,2),y_grid);
    p2 = power(:,2);
    powmean(i) = mean(p2(~isnan(p2)));

    if rem(i,max(1,round(nmc/100))) == 0 || i==nmc
        waitbar(i/nmc,hwb,sprintf('Progress %.1f%%',100*i/nmc));
    end
end
clear cleanupWb;

pm = mean(powmean,'omitnan');
adj = pm./powmean;
powyadjust = repmat(adj,nout,1).*powy;
maxp = max(powyadjust,[],'all','omitnan');
if isfinite(maxp) && maxp > 1
    powyadjust = powyadjust/maxp;
end

percentBank = {50,[25 75],[15.865 84.135],[10 90],[5 95],[2.5 97.5]};
pp = [];
for k=1:numel(percentBank)
    if S.percent_on(k)
        pp = [pp percentBank{k}]; %#ok<AGROW>
    end
end
pp = sort(unique(pp));
if isempty(pp), pp = 50; end
powyadjustp = prctile(powyadjust,pp,2);
mask = ~isnan(powyadjustp(:,1));
y_grid_nan = y_grid(mask);
powyad_p_nan = 1 - powyadjustp(mask,:);

colorcode = [221 234 224;201 227 209;176 219 188;126 201 146;67 180 100]/255;
cla(S.AxDynot); hold(S.AxDynot,'on');
npercent = numel(pp);
npercent2 = floor((npercent-1)/2);
for i = 1:min(npercent2,size(colorcode,1))
    x = [y_grid_nan; flipud(y_grid_nan)];
    y = [powyad_p_nan(:,npercent+1-i); flipud(powyad_p_nan(:,i))];
    fill(S.AxDynot,x,y,colorcode(i,:),'LineStyle','none');
end
mid = npercent2+1;
if mid>=1 && mid<=size(powyad_p_nan,2)
    plot(S.AxDynot,y_grid_nan,powyad_p_nan(:,mid),'Color',[0 120/255 0],'LineWidth',1.5,'LineStyle','--');
end
axis(S.AxDynot,[data(1,1) data(end,1) min(powyad_p_nan,[],'all') max(powyad_p_nan,[],'all')]);
set(S.AxDynot,'YDir','reverse');
set(S.AxDynot,'XMinorTick','on','YMinorTick','on');
hold(S.AxDynot,'off');

assignin('base','freqz',f3m);
assignin('base','nwz',nwz);
assignin('base','windowz',windowz);
assignin('base','samplez',samplez);
assignin('base','powy_grid',y_grid);
assignin('base','powy',1-powyadjust);
assignin('base','powyp',1-powyadjustp);

S.run.y_grid = y_grid;
S.run.powyadjust = 1-powyadjust;
S.run.y_grid_nan = y_grid_nan;
S.run.powyad_p_nan = powyad_p_nan;
S.run.npercent = npercent;
S.run.npercent2 = npercent2;
S.run.colorcode = colorcode;
S.run.f3m = f3m;
S.run.nwz = nwz;
S.run.windowz = windowz;
S.run.samplez = samplez;

saveDynotFiles(S, y_grid_nan, powyad_p_nan, npercent2);
end

function saveDynotFiles(S, y_grid_nan, powyad_p_nan, npercent2)
pre_dir = pwd;
try
    CDac_pwd;
catch
end

name1 = [S.dat_name,'-DYNOT-median.txt'];
name2 = [S.dat_name,'-DYNOT-prctile.txt'];
if exist(name1,'file') || exist(name2,'file')
    for i = 1:200
        n1 = [S.dat_name,'-DYNOT-median-',num2str(i),'.txt'];
        n2 = [S.dat_name,'-DYNOT-prctile-',num2str(i),'.txt'];
        if ~exist(n1,'file') && ~exist(n2,'file')
            name1 = n1; name2 = n2; break
        end
    end
end

mid = max(1,min(size(powyad_p_nan,2),npercent2+1));
dlmwrite(name1,[y_grid_nan,powyad_p_nan(:,mid)],'delimiter',' ','precision',9);
dlmwrite(name2,[y_grid_nan,powyad_p_nan],'delimiter',' ','precision',9);

refreshMainListbox(S);
cd(pre_dir);
end

function refreshMainListbox(S)
if isempty(S.listbox_acmain) || ~isgraphics(S.listbox_acmain)
    return
end
pre  = '<HTML><FONT color="blue">';
post = '</FONT></HTML>';
d = dir;
if numel(d)>=2, d(1:2)=[]; end
address = pwd;
if ~isempty(S.edit_acfigmain_dir) && isgraphics(S.edit_acfigmain_dir)
    set(S.edit_acfigmain_dir,'String',address);
end
ac_pwd_str = which('ac_pwd.txt');
if ~isempty(ac_pwd_str)
    [ac_pwd_dir,~,~] = fileparts(ac_pwd_str);
    fid = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    if fid~=-1
        fprintf(fid,'%s',address);
        fclose(fid);
    end
end
if isempty(d)
    set(S.listbox_acmain,'String',{},'Value',[]);
    return
end
T = struct2table(d);
switch S.val1
    case 1, sortedT = sortrows(T,'name','ascend');
    case 2, sortedT = sortrows(T,'name','descend');
    case 3, sortedT = sortrows(T,'date','ascend');
    case 4, sortedT = sortrows(T,'date','descend');
    case 5, sortedT = sortrows(T,'bytes','ascend');
    case 6, sortedT = sortrows(T,'bytes','descend');
    otherwise, sortedT = sortrows(T,'name','ascend');
end
sd = table2struct(sortedT);
out = cell(numel(sd),1);
for i=1:numel(sd)
    if isdir(sd(i).name)
        out{i} = [pre sd(i).name post];
    else
        out{i} = sd(i).name;
    end
end
set(S.listbox_acmain,'String',out,'Value',[]);
end

function onSaveFigure(src)
S = getState(src);
try
    fig = buildDynotFigure(S,'DYNOT');
    out = nextOutputFile('plots_','.fig');
    savefig(fig,out);
    close(fig);
    uialert(S.UIFigure,['Saved: ',out],'Save');
catch ME
    uialert(S.UIFigure,ME.message,'Save Figure Error');
end
end

function onPrintFigure(src)
S = getState(src);
try
    fig = buildDynotFigure(S,'DYNOT print');
    out = nextOutputFile('plots_','.pdf');
    exportgraphics(fig,out,'ContentType','vector');
    close(fig);
    uialert(S.UIFigure,['Printed: ',out],'Print');
catch ME
    uialert(S.UIFigure,ME.message,'Print Error');
end
end

function fig = buildDynotFigure(S, figName)
fig = figure('Color','white','Name',figName);
if isempty(S.data)
    ax = axes(fig);
    text(ax,0.5,0.5,'No data','HorizontalAlignment','center');
    axis(ax,'off');
    return
end

if isempty(S.run.y_grid_nan)
    ax = axes(fig);
    plot(ax,S.data(:,1),S.data(:,2),'Color',[0.2 0.6 1]);
    title(ax,'Data');
    grid(ax,'on');
    set(ax,'XMinorTick','on','YMinorTick','on');
    return
end

tiledlayout(fig,2,1,'Padding','compact','TileSpacing','compact');
nexttile;
plot(S.data(:,1),S.data(:,2),'Color',[0.2 0.6 1]);
title('Data');
grid on;
set(gca,'XMinorTick','on','YMinorTick','on');

nexttile;
ax = gca;
hold(ax,'on');
npercent = S.run.npercent;
npercent2 = S.run.npercent2;
y_grid_nan = S.run.y_grid_nan;
powyad_p_nan = S.run.powyad_p_nan;
colorcode = S.run.colorcode;
for i = 1:min(npercent2,size(colorcode,1))
    x = [y_grid_nan; flipud(y_grid_nan)];
    y = [powyad_p_nan(:,npercent+1-i); flipud(powyad_p_nan(:,i))];
    fill(ax,x,y,colorcode(i,:),'LineStyle','none');
end
mid = npercent2 + 1;
plot(ax,y_grid_nan,powyad_p_nan(:,mid),'Color',[0 120/255 0],'LineWidth',1.5,'LineStyle','--');
set(ax,'YDir','reverse');
title(ax,'DYNOT');
grid(ax,'on');
set(ax,'XMinorTick','on','YMinorTick','on');
hold(ax,'off');
end

function out = nextOutputFile(stem, ext)
if nargin < 2 || isempty(ext)
    ext = '.fig';
end
if ~startsWith(ext,'.')
    ext = ['.', ext];
end
out = [stem, ext];
if exist(out,'file')
    for i = 1:999
        outi = sprintf('%s%d%s',stem,i,ext);
        if ~exist(outi,'file')
            out = outi;
            break
        end
    end
end
end

function data = sanitizeData(data)
if size(data,2) > 2
    data = data(:,1:2);
end
data = sortrows(data,1);
if exist('findduplicate','file') == 2
    data = findduplicate(data);
else
    [~,ia] = unique(data(:,1),'stable');
    data = data(ia,:);
end
data(any(~isfinite(data),2),:) = [];
end

function safeClose(h)
if ~isempty(h) && isgraphics(h)
    close(h);
end
end

function setState(h,S)
fig = ancestor(h,'figure');
setappdata(fig,'DYNOS_STATE',S);
end

function S = getState(h)
fig = ancestor(h,'figure');
S = getappdata(fig,'DYNOS_STATE');
end

function v = getfielddef(s, name, def)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = def;
end
end
