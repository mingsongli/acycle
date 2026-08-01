function varargout = Insolation(varargin)
% Insolation - single-file App Designer style GUI (no GUIDE .fig dependency)
ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = initApp(ctx);
createUI();
setappdata(app.UIFigure,'INSOLATION_APP',app);
applyLayout();
updateUIStates();

if nargout > 0
    varargout{1} = app.UIFigure;
end

    function app = initApp(ctx)
        app = struct();
        app.ctx = ctx;
        app.bg = [0.94 0.94 0.94];
        app.blue = [0.08 0.02 0.95];

        app.type = 0; % 0 daily, 1 mean
        app.author = 1; % 1 La04; 2-5 La10a-d; 6 BergerLoutre91
        app.t1 = 1;
        app.t2 = 1000;
        app.dt = 1;
        app.unit_t = 1; % 1 kyr,2 myr,3 yr

        app.solarconstant = 1365;
        app.qinso = -2; % -2 mean daily; -1 max daily
        app.month1 = 3; app.day1 = 21;
        app.month2 = 9; app.day2 = 23;
        app.dayi1 = 80;
        app.dayi2 = 266;

        app.latrange = 0; % 0 single latitude; 1 latitude range
        app.lat1 = 65;
        app.lat2 = 80;
        app.dlat = 1;

        app.res = 1;
        app.main_unit_selection = getfielddef(ctx,'main_unit_selection',0);
        app.acfigmain = getfielddef(ctx,'acfigmain',[]);
        app.listbox_acmain = getfielddef(ctx,'listbox_acmain',[]);
        app.edit_acfigmain_dir = getfielddef(ctx,'edit_acfigmain_dir',[]);
        app.monzoom = getfielddef(ctx,'MonZoom',1);

        sc = get(groot,'ScreenSize');
        pos = round([0.30*sc(3) 0.08*sc(4) 0.42*sc(3) 0.80*sc(4)] * app.monzoom);
        pos(3) = max(pos(3),900);
        pos(4) = max(pos(4),980);
        app.UIFigure = uifigure('Name','Acycle: Insolation','Color',app.bg, ...
            'Position',pos,'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)onResize();
        app.UIFigure.KeyPressFcn = @(src,evt)onKeyPress(src,evt);
    end

    function createUI()
        app.PType = uipanel(app.UIFigure,'Title','Insolation Type','BackgroundColor',app.bg);
        app.BGType = uibuttongroup(app.PType,'BorderType','none','BackgroundColor',app.bg, ...
            'SelectionChangedFcn',@(s,e)onTypeChanged());
        app.RDaily = uiradiobutton(app.BGType,'Text','Daily','Value',true);
        app.RMean = uiradiobutton(app.BGType,'Text','Mean');

        app.PSolution = uipanel(app.UIFigure,'Title','Astronomical Solution','BackgroundColor',app.bg);
        app.DSolution = uidropdown(app.PSolution,'Items',{'Laskar et al. 2004','Laskar et al. 2010a','Laskar et al. 2010b','Laskar et al. 2010c','Laskar et al. 2010d','Berger and Loutre 1991'}, ...
            'ValueChangedFcn',@(s,e)onSolutionChanged());

        app.PTime = uipanel(app.UIFigure,'Title','Time Scale','BackgroundColor',app.bg);
        app.LChoose = uilabel(app.PTime,'Text','Choose the starting and final time:','BackgroundColor',app.bg,'FontWeight','bold');
        app.LFrom = uilabel(app.PTime,'Text','from','BackgroundColor',app.bg);
        app.EFrom = uieditfield(app.PTime,'text','Value',num2str(app.t1),'ValueChangedFcn',@(s,e)onTimeChanged());
        app.LTo = uilabel(app.PTime,'Text','to','BackgroundColor',app.bg);
        app.ETo = uieditfield(app.PTime,'text','Value',num2str(app.t2),'ValueChangedFcn',@(s,e)onTimeChanged());
        app.LStep = uilabel(app.PTime,'Text','step','BackgroundColor',app.bg);
        app.EStep = uieditfield(app.PTime,'text','Value',num2str(app.dt),'ValueChangedFcn',@(s,e)onTimeChanged());
        app.LTimeUnit = uilabel(app.PTime,'Text','time unit','BackgroundColor',app.bg);
        app.DTimeUnit = uidropdown(app.PTime,'Items',{'kyr','myr','yr'},'Value','kyr','ValueChangedFcn',@(s,e)onTimeUnitChanged());
        app.LPointsA = uilabel(app.PTime,'Text','The series will have','BackgroundColor',app.bg);
        app.LPointsN = uilabel(app.PTime,'Text','999','BackgroundColor',app.bg,'FontWeight','bold');
        app.LPointsB = uilabel(app.PTime,'Text','points','BackgroundColor',app.bg);

        app.PParam = uipanel(app.UIFigure,'Title','Insolation parameters','BackgroundColor',app.bg);
        app.LSolar = uilabel(app.PParam,'Text','Solar constant','BackgroundColor',app.bg);
        app.ESolar = uieditfield(app.PParam,'text','Value',num2str(app.solarconstant),'ValueChangedFcn',@(s,e)onParamChanged());
        app.LWm2 = uilabel(app.PParam,'Text','W/m^2','BackgroundColor',app.bg);
        app.BGInso = uibuttongroup(app.PParam,'BorderType','none','BackgroundColor',app.bg, ...
            'SelectionChangedFcn',@(s,e)onInsoTypeChanged());
        app.RMeanDaily = uiradiobutton(app.BGInso,'Text','Mean daily','Value',true);
        app.RMaxDaily = uiradiobutton(app.BGInso,'Text','Max daily');

        app.LDay1 = uilabel(app.PParam,'Text','Starting day','BackgroundColor',app.bg);
        app.EDay1 = uieditfield(app.PParam,'text','Value',num2str(app.dayi1),'ValueChangedFcn',@(s,e)onParamChanged());
        app.LOr1 = uilabel(app.PParam,'Text','or date','BackgroundColor',app.bg);
        mlist = monthNames();
        app.DMonth1 = uidropdown(app.PParam,'Items',mlist,'Value',mlist{app.month1},'ValueChangedFcn',@(s,e)onMonthDayChanged(1));
        app.DDay1 = uidropdown(app.PParam,'Items',dayItems(31),'Value','21','ValueChangedFcn',@(s,e)onMonthDayChanged(1));

        app.LDay2 = uilabel(app.PParam,'Text','Ending day','BackgroundColor',app.bg);
        app.EDay2 = uieditfield(app.PParam,'text','Value',num2str(app.dayi2),'ValueChangedFcn',@(s,e)onParamChanged());
        app.LOr2 = uilabel(app.PParam,'Text','or date','BackgroundColor',app.bg);
        app.DMonth2 = uidropdown(app.PParam,'Items',mlist,'Value',mlist{app.month2},'ValueChangedFcn',@(s,e)onMonthDayChanged(2));
        app.DDay2 = uidropdown(app.PParam,'Items',dayItems(30),'Value','23','ValueChangedFcn',@(s,e)onMonthDayChanged(2));

        app.PLat = uipanel(app.UIFigure,'Title','Latitude','BackgroundColor',app.bg);
        app.BGLat = uibuttongroup(app.PLat,'BorderType','none','BackgroundColor',app.bg, ...
            'SelectionChangedFcn',@(s,e)onLatModeChanged());
        app.RSingle = uiradiobutton(app.BGLat,'Text','Single latitude','Value',true);
        app.LFromLat = uilabel(app.BGLat,'Text','from','BackgroundColor',app.bg);
        app.ELat1 = uieditfield(app.BGLat,'text','Value',num2str(app.lat1),'ValueChangedFcn',@(s,e)onParamChanged());
        app.LDegree = uilabel(app.BGLat,'Text','degree (N>0, S<0)','BackgroundColor',app.bg);

        app.RRange = uiradiobutton(app.BGLat,'Text','Latitude range');
        app.LToLat = uilabel(app.BGLat,'Text','to','BackgroundColor',app.bg);
        app.ELat2 = uieditfield(app.BGLat,'text','Value',num2str(app.lat2),'Enable','off','ValueChangedFcn',@(s,e)onParamChanged());
        app.LStepLat = uilabel(app.BGLat,'Text','step','BackgroundColor',app.bg);
        app.EDLat = uieditfield(app.BGLat,'text','Value',num2str(app.dlat),'Enable','off','ValueChangedFcn',@(s,e)onParamChanged());

        app.BOK = uibutton(app.UIFigure,'push','Text','OK','BackgroundColor',app.blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@(s,e)onRun());
    end

    function applyLayout()
        onResize();
    end

    function onResize()
        app = getappdata(app.UIFigure,'INSOLATION_APP');
        if isempty(app), return; end
        w = app.UIFigure.Position(3); h = app.UIFigure.Position(4);
        minW = 900; minH = 980;
        if w < minW || h < minH
            app.UIFigure.Position(3:4) = [max(w,minW), max(h,minH)];
            w = app.UIFigure.Position(3); h = app.UIFigure.Position(4);
        end
        m = 24; gap = 14;
        colGap = 18;
        y = h - m - 132;

        pw = floor((w - 2*m - colGap) * 0.43);
        app.PType.Position = [m y pw 122];
        app.BGType.Position = [8 8 pw-16 90];
        app.RDaily.Position = [34 34 120 30];
        app.RMean.Position = [200 34 120 30];

        app.PSolution.Position = [m+pw+colGap y w - (m+pw+colGap) - m 122];
        app.DSolution.Position = [48 48 app.PSolution.Position(3)-76 38];

        y = y - (220 + gap);
        app.PTime.Position = [m y w-2*m 220];
        app.LChoose.Position = [120 164 360 30];
        app.LFrom.Position = [34 114 90 30];
        app.EFrom.Position = [140 114 150 36];
        app.LTo.Position = [34 56 90 30];
        app.ETo.Position = [140 56 150 36];
        app.LStep.Position = [480 114 80 30];
        app.EStep.Position = [560 114 150 36];
        app.LTimeUnit.Position = [440 56 120 30];
        app.DTimeUnit.Position = [560 58 190 32];
        app.LPointsA.Position = [86 10 220 28];
        app.LPointsN.Position = [330 10 90 28];
        app.LPointsB.Position = [430 10 90 28];

        y = y - (300 + gap);
        app.PParam.Position = [m y w-2*m 300];
        app.LSolar.Position = [34 214 160 30];
        app.ESolar.Position = [220 212 120 34];
        app.LWm2.Position = [374 214 120 30];
        app.BGInso.Position = [480 192 360 66];
        app.RMeanDaily.Position = [10 16 160 30];
        app.RMaxDaily.Position = [180 16 160 30];

        app.LDay1.Position = [34 130 160 30];
        app.EDay1.Position = [220 128 120 34];
        app.LOr1.Position = [356 130 90 30];
        app.DMonth1.Position = [480 130 200 32];
        app.DDay1.Position = [710 130 110 32];

        app.LDay2.Position = [34 44 160 30];
        app.EDay2.Position = [220 42 120 34];
        app.LOr2.Position = [356 44 90 30];
        app.DMonth2.Position = [480 44 200 32];
        app.DDay2.Position = [710 44 110 32];

        y = y - (170 + gap);
        app.PLat.Position = [m y w-2*m 170];
        app.BGLat.Position = [8 4 app.PLat.Position(3)-16 app.PLat.Position(4)-26];
        app.RSingle.Position = [34 78 180 30];
        app.LFromLat.Position = [360 80 60 28];
        app.ELat1.Position = [420 76 110 34];
        app.LDegree.Position = [560 80 220 28];

        app.RRange.Position = [34 16 180 30];
        app.LToLat.Position = [360 18 60 28];
        app.ELat2.Position = [420 14 110 34];
        app.LStepLat.Position = [560 18 60 28];
        app.EDLat.Position = [640 14 110 34];

        app.BOK.Position = [w-m-170 max(16,y-86) 170 72];
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function updateUIStates()
        onTypeChanged();
        onLatModeChanged();
        onMonthDayChanged(1);
        onMonthDayChanged(2);
        updatePoints();
    end

    function onTypeChanged()
        app.type = double(app.RMean.Value); % daily=0, mean=1
        if app.type == 1
            app.EDay2.Enable = 'on';
            app.DMonth2.Enable = 'on';
            app.DDay2.Enable = 'on';
        else
            app.EDay2.Enable = 'off';
            app.DMonth2.Enable = 'off';
            app.DDay2.Enable = 'off';
        end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onSolutionChanged()
        app.author = find(strcmp(app.DSolution.Items, app.DSolution.Value),1,'first');
        if isempty(app.author), app.author = 1; end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onTimeChanged()
        app.t1 = str2double(app.EFrom.Value); if ~isfinite(app.t1), app.t1 = 1; end
        app.t2 = str2double(app.ETo.Value); if ~isfinite(app.t2), app.t2 = 1000; end
        app.dt = abs(str2double(app.EStep.Value)); if ~isfinite(app.dt) || app.dt<=0, app.dt = 1; end
        app.EFrom.Value = num2str(app.t1);
        app.ETo.Value = num2str(app.t2);
        app.EStep.Value = num2str(app.dt);
        updatePoints();
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onTimeUnitChanged()
        app.unit_t = find(strcmp({'kyr','myr','yr'},app.DTimeUnit.Value),1,'first');
        if isempty(app.unit_t), app.unit_t = 1; end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onInsoTypeChanged()
        if app.RMeanDaily.Value
            app.qinso = -2;
        else
            app.qinso = -1;
        end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onMonthDayChanged(whichOne)
        if whichOne == 1
            m1 = find(strcmp(monthNames(), app.DMonth1.Value),1,'first');
            if isempty(m1), m1 = 3; end
            app.month1 = m1;
            nday = monthDays(m1);
            app.DDay1.Items = dayItems(nday);
            d = min(str2double(app.DDay1.Value),nday);
            if ~isfinite(d) || d < 1, d = 1; end
            app.DDay1.Value = num2str(d);
            app.day1 = d;
            app.dayi1 = sum(monthDays(1:m1-1)) + d;
            app.EDay1.Value = num2str(app.dayi1);
        else
            m2 = find(strcmp(monthNames(), app.DMonth2.Value),1,'first');
            if isempty(m2), m2 = 9; end
            app.month2 = m2;
            nday = monthDays(m2);
            app.DDay2.Items = dayItems(nday);
            d = min(str2double(app.DDay2.Value),nday);
            if ~isfinite(d) || d < 1, d = 1; end
            app.DDay2.Value = num2str(d);
            app.day2 = d;
            app.dayi2 = sum(monthDays(1:m2-1)) + d;
            app.EDay2.Value = num2str(app.dayi2);
        end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onLatModeChanged()
        app.latrange = double(app.RRange.Value);
        if app.latrange == 1
            app.ELat2.Enable = 'on';
            app.EDLat.Enable = 'on';
        else
            app.ELat2.Enable = 'off';
            app.EDLat.Enable = 'off';
        end
        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function onParamChanged()
        app.solarconstant = str2double(app.ESolar.Value);
        if ~isfinite(app.solarconstant), app.solarconstant = 1365; end
        app.ESolar.Value = num2str(app.solarconstant);

        app.dayi1 = str2double(app.EDay1.Value); if ~isfinite(app.dayi1), app.dayi1 = 80; end
        app.dayi2 = str2double(app.EDay2.Value); if ~isfinite(app.dayi2), app.dayi2 = 266; end
        app.EDay1.Value = num2str(app.dayi1);
        app.EDay2.Value = num2str(app.dayi2);

        app.lat1 = str2double(app.ELat1.Value); if ~isfinite(app.lat1), app.lat1 = 65; end
        app.lat2 = str2double(app.ELat2.Value); if ~isfinite(app.lat2), app.lat2 = 80; end
        app.dlat = abs(str2double(app.EDLat.Value)); if ~isfinite(app.dlat) || app.dlat <= 0, app.dlat = 1; end
        app.ELat1.Value = num2str(app.lat1);
        app.ELat2.Value = num2str(app.lat2);
        app.EDLat.Value = num2str(app.dlat);

        setappdata(app.UIFigure,'INSOLATION_APP',app);
    end

    function updatePoints()
        n = abs((app.t2 - app.t1) / max(app.dt,eps));
        app.LPointsN.Text = num2str(fix(n));
    end

    function onRun()
        onTimeChanged();
        onParamChanged();

        t1 = app.t1; t2 = app.t2; dt = app.dt;
        dayi1 = app.dayi1; dayi2 = app.dayi2;
        lat1 = app.lat1; lat2 = app.lat2; dlat = app.dlat;
        type = app.type; author = app.author; res = app.res; L = app.solarconstant;
        unit_t = app.unit_t;

        if t1 < 0
            uialert(app.UIFigure,'time scale must be no less than 0','Insolation');
            return
        end
        if ismember(author,[1 2 3 4 5])
            bad = (unit_t==1 && t2>249000) || (unit_t==2 && t2>249) || (unit_t==3 && t2>249000000);
            if bad
                uialert(app.UIFigure,'time scale must be no larger than 249000 ka','Insolation');
                return
            end
        end

        t0 = max(t1,t2):-abs(dt):min(t1,t2);
        t = t0;
        unit_t_r = 'ka';
        if unit_t == 2
            t = t0*1000; unit_t_r = 'Ma';
        elseif unit_t == 3
            t = t0/1000; unit_t_r = 'yr';
        end

        if type == 1
            if dayi1 < dayi2
                day = dayi1:dayi2;
            else
                day = dayi1:(dayi2+365);
            end
        else
            day = dayi1;
        end

        if app.latrange == 1
            lat = min(lat1,lat2):abs(dlat):max(lat1,lat2);
        else
            lat = lat1;
        end

        d = uiprogressdlg(app.UIFigure,'Title','Insolation','Message','Please wait...','Indeterminate','on');
        try
            [I, ~, xorb, yorb, veq, Insol_a_m, Ix, II] = insoML(t,day,lat,app.qinso,author,res,L);
        catch ME
            closeSafe(d);
            uialert(app.UIFigure,['Run failed: ',ME.message],'Insolation');
            return
        end
        closeSafe(d);

        assignin('base','insol_t',t0);
        assignin('base','insol_I',I);
        assignin('base','insol_xorb',xorb);
        assignin('base','insol_yorb',yorb);
        assignin('base','insol_veq',veq);
        assignin('base','insol_a_m',Insol_a_m);
        assignin('base','insol_Ix',Ix);
        assignin('base','insol_II',II);

        name_insold = ['Insol-t-',num2str(t1),'-',num2str(t2),unit_t_r,'-day-',num2str(dayi1),'-'];
        if type == 1
            name_insold = [name_insold,num2str(dayi2),'-'];
        end
        name_insol = [name_insold,'lat-(',num2str(lat1),')-'];
        if app.latrange == 1
            name_insol = [name_insol,'(',num2str(lat2),')-'];
        end
        if app.qinso == -1
            name_insol = [name_insol,'maxdaily-'];
        else
            name_insol = [name_insol,'meandaily-'];
        end
        auth_list = {'La04','La10a','La10b','La10c','La10d','BL91'};
        name_insol = [name_insol,auth_list{min(max(author,1),numel(auth_list))}];
        name_insol_all = [name_insol,'.txt'];
        saveDir = resolveSaveDir(app.ctx);
        outTxt = fullfile(saveDir,name_insol_all);
        dlmwrite(outTxt,[t0',Ix'],'delimiter',' ','precision',9);

        figdata = figure('Name','Insolation','Color','w');
        plot(t0',Ix');
        xlim([min(t0),max(t0)]);
        xlabel(['Time (',unit_t_r,')']);
        ylabel('Insolation (W/m^2)');
        title(name_insol,'Interpreter','none');

        if type == 1 && app.latrange == 1
            gifPath = fullfile(saveDir,[name_insol,'.gif']);
            gifDlg = uiprogressdlg(app.UIFigure, ...
                'Title','Insolation', ...
                'Message','Please wait, saving GIF (slow progress)...', ...
                'Indeterminate','on', ...
                'Cancelable','off');
            try
                createInsolGif(II,t0,lat,day,unit_t_r,gifPath);
                closeSafe(gifDlg);
            catch ME
                closeSafe(gifDlg);
                uialert(app.UIFigure,['GIF save failed: ',ME.message],'Insolation');
            end
        end

        try
            refreshMainListbox(app.ctx,saveDir);
        catch
            % Saving already succeeded; leave the output intact if the
            % main window is closing and can no longer be refreshed.
        end

        try
            if ~isempty(app.acfigmain) && isgraphics(app.acfigmain)
                figure(app.acfigmain);
            end
        catch
        end
        try figure(figdata); catch, end
    end

    function onKeyPress(src,evt)
        try
            key = lower(evt.Key);
            mods = lower(string(evt.Modifier));
            isMacClose = strcmp(key,'w') && any(mods == "command");
            isOtherClose = strcmp(key,'w') && any(mods == "control");
            if isMacClose || isOtherClose
                delete(src);
            end
        catch
        end
    end
end

function names = monthNames()
names = {'January','February','March','April','May','June','July','August','September','October','November','December'};
end

function items = dayItems(n)
items = arrayfun(@num2str,1:n,'UniformOutput',false);
end

function d = monthDays(m)
days = [31 28 31 30 31 30 31 31 30 31 30 31];
if nargin == 0
    d = days;
else
    d = days(m);
end
end

function closeSafe(h)
if ~isempty(h) && isvalid(h)
    close(h);
end
end

function refreshMainListbox(ctx,dirpath)
listbox = getfielddef(ctx,'listbox_acmain',[]);
editdir = getfielddef(ctx,'edit_acfigmain_dir',[]);
if ac_refresh_main_list(listbox,dirpath)
    return
end
if isempty(listbox) || ~isgraphics(listbox)
    return
end
if nargin < 2 || isempty(dirpath) || ~isfolder(dirpath)
    dirpath = pwd;
end
try
    d = dir(dirpath);
    if numel(d) >= 2
        d = d(~ismember({d.name},{'.','..'}));
    end
    sortMode = getfielddef(ctx,'val1',4);
    try
        mainHandles = guidata(listbox);
        if isstruct(mainHandles) && isfield(mainHandles,'val1') && ...
                ~isempty(mainHandles.val1)
            sortMode = mainHandles.val1;
        end
    catch
    end
    d = ac_sort_dir_entries(d,sortMode);
    ac_update_listbox_acmain(listbox,{d.name},[d.isdir]);
    if ~isempty(editdir) && isgraphics(editdir)
        set(editdir,'String',dirpath);
    end
    ac_working_directory('set',dirpath);
    drawnow limitrate;
catch
end
end

function saveDir = resolveSaveDir(ctx)
saveDir = pwd;
editdir = getfielddef(ctx,'edit_acfigmain_dir',[]);
if isempty(editdir) || ~isgraphics(editdir)
    return
end
try
    p = get(editdir,'String');
    if iscell(p), p = p{1}; end
    if isstring(p), p = char(p); end
    if ischar(p) && ~isempty(p) && isfolder(p)
        saveDir = p;
    end
catch
end
end

function v = getfielddef(s,name,def)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = def;
end
end

function createInsolGif(II,t,lat,day,unit_t_r,gifPath)
II = real(II);
[LAT,DAY] = meshgrid(lat,day);
LAT = LAT';
DAY = DAY';

fig = figure('Visible','off','Color','w');
ax = axes(fig);
Z = II(:,:,1);
pcolor(ax,DAY,LAT,Z);
colorbar(ax);
axis(ax,'tight');
ax.NextPlot = 'replaceChildren';
caxis(ax,[0 625]);
colormap(ax,jet);
shading(ax,'interp');
title(ax,['Age (',unit_t_r,') = ',num2str(t(1))]);
ylabel(ax,'Latitude');
xlabel(ax,'Day');

F = getframe(fig);
[im,map] = rgb2ind(F.cdata,256,'nodither');
[~,~,loops] = size(II);
im(1,1,1,loops) = 0;
for j = 1:loops
    X = II(:,:,j);
    pcolor(ax,DAY,LAT,X);
    shading(ax,'interp');
    colorbar(ax);
    title(ax,['Age (',unit_t_r,') = ',num2str(t(j))]);
    drawnow;
    F = getframe(fig);
    im(:,:,1,j) = rgb2ind(F.cdata,map,'nodither');
end
imwrite(im,map,gifPath,'DelayTime',0.0,'LoopCount',inf);
close(fig);
end
