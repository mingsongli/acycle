function varargout = LODGUI(varargin)
% LODGUI - App-style single-file Milankovitch calculator (no GUIDE .fig).

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = struct();
app.ctx = ctx;
app.bg = [0.94 0.94 0.94];
app.blue = [0.08 0.02 0.95];
app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
app.edit_acfigmain_dir = getFieldDefault(ctx,'edit_acfigmain_dir',[]);
app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
app.lang_id = getFieldDefault(ctx,'lang_id',{});
app.lang_var = getFieldDefault(ctx,'lang_var',{});

monzoom = getFieldDefault(ctx,'MonZoom',1);
sc = get(groot,'ScreenSize');
pos = round([0.40*sc(3), 0.55*sc(4), 0.313*sc(3), 0.289*sc(4)] * monzoom);
pos(3) = max(pos(3), 1080);
pos(4) = max(pos(4), 660);

titleTxt = ['Acycle: ',langText(app,'menu52','Milankovitch Calculator')];
app.UIFigure = uifigure('Name',titleTxt,'Color',app.bg,'Position',pos,'AutoResizeChildren','off');
app.UIFigure.SizeChangedFcn = @(~,~)layoutUI();
app.UIFigure.WindowKeyPressFcn = @onFigureKeyPress;
app.UIFigure.WindowKeyReleaseFcn = @onFigureKeyPress;

app.PSeries = uipanel(app.UIFigure,'Title',langText(app,'mical01','Time Series'),'BackgroundColor',app.bg,'FontWeight','bold');
app.BGSeries = uibuttongroup(app.PSeries,'BackgroundColor',app.bg,'SelectionChangedFcn',@(~,~)onSeriesModeChanged());
app.RSingle = uiradiobutton(app.BGSeries,'Text',langText(app,'mical02','Single Time'));
app.RSeries = uiradiobutton(app.BGSeries,'Text',langText(app,'mical01','Time Series'));

app.PModel = uipanel(app.UIFigure,'Title',langText(app,'mical03','Model'),'BackgroundColor',app.bg,'FontWeight','bold');
app.DModel = uidropdown(app.PModel,'Items',{'Waltham2015','Laskar et al. 2004'},'Value','Waltham2015');

app.BOK = uibutton(app.UIFigure,'push','Text',langText(app,'main00','OK'), ...
    'BackgroundColor',app.blue,'FontColor','white','FontWeight','bold','ButtonPushedFcn',@(~,~)onRun());

app.PSet = uipanel(app.UIFigure,'Title',langText(app,'mical04','Set time'),'BackgroundColor',app.bg,'FontWeight','bold');
app.LFrom = uilabel(app.PSet,'Text',langText(app,'main16','From'),'BackgroundColor',app.bg);
app.EFrom = uieditfield(app.PSet,'text','Value','10','BackgroundColor','white','ValueChangedFcn',@(~,~)updateHint());
app.LTo = uilabel(app.PSet,'Text',langText(app,'main17','To'),'BackgroundColor',app.bg);
app.ETo = uieditfield(app.PSet,'text','Value','250','BackgroundColor','white','ValueChangedFcn',@(~,~)updateHint());
app.LStep = uilabel(app.PSet,'Text',langText(app,'main32','Step'),'BackgroundColor',app.bg);
app.EStep = uieditfield(app.PSet,'text','Value','10','BackgroundColor','white','ValueChangedFcn',@(~,~)updateHint());
app.LU1 = uilabel(app.PSet,'Text','Ma','BackgroundColor',app.bg);
app.LU2 = uilabel(app.PSet,'Text','Ma','BackgroundColor',app.bg);
app.LU3 = uilabel(app.PSet,'Text','Ma','BackgroundColor',app.bg);
app.LHint = uilabel(app.PSet,'Text','','BackgroundColor',app.bg,'FontColor',app.blue);

app.PRef = uipanel(app.UIFigure,'Title',langText(app,'mical05','Reference'),'BackgroundColor',app.bg,'FontWeight','bold');
app.TRef = uitextarea(app.PRef,'Editable','off','BackgroundColor','white');

app.BGSeries.SelectedObject = app.RSeries;
updateReferenceText();
layoutUI();
onSeriesModeChanged();
updateHint();

if nargout > 0
    varargout{1} = app.UIFigure;
end

    function layoutUI()
        w = app.UIFigure.Position(3);
        h = app.UIFigure.Position(4);
        m = round(0.05*w);

        app.PSeries.Position = [m round(0.66*h) round(0.27*w) round(0.27*h)];
        app.BGSeries.Position = [6 6 app.PSeries.Position(3)-12 app.PSeries.Position(4)-30];
        app.RSingle.Position = [24 round(0.58*app.BGSeries.Position(4)) 200 30];
        app.RSeries.Position = [24 round(0.18*app.BGSeries.Position(4)) 200 30];

        app.PModel.Position = [round(0.33*w) round(0.66*h) round(0.33*w) round(0.27*h)];
        app.DModel.Position = [round(0.09*app.PModel.Position(3)) round(0.53*app.PModel.Position(4)) round(0.80*app.PModel.Position(3)) 40];

        app.BOK.Position = [round(0.71*w) round(0.71*h) round(0.22*w) round(0.19*h)];

        app.PSet.Position = [m round(0.28*h) round(0.88*w) round(0.34*h)];
        pw = app.PSet.Position(3);
        ph = app.PSet.Position(4);
        app.LFrom.Position = [round(0.045*pw) round(0.63*ph) round(0.08*pw) 30];
        app.EFrom.Position = [round(0.13*pw) round(0.60*ph) round(0.17*pw) 42];
        app.LU1.Position = [round(0.31*pw) round(0.63*ph) round(0.05*pw) 30];
        app.LTo.Position = [round(0.42*pw) round(0.63*ph) round(0.06*pw) 30];
        app.ETo.Position = [round(0.47*pw) round(0.60*ph) round(0.17*pw) 42];
        app.LU2.Position = [round(0.65*pw) round(0.63*ph) round(0.05*pw) 30];
        app.LStep.Position = [round(0.74*pw) round(0.63*ph) round(0.06*pw) 30];
        app.EStep.Position = [round(0.81*pw) round(0.60*ph) round(0.11*pw) 42];
        app.LU3.Position = [round(0.93*pw) round(0.63*ph) round(0.05*pw) 30];
        app.LHint.Position = [round(0.03*pw) round(0.18*ph) round(0.94*pw) 36];

        app.PRef.Position = [m round(0.05*h) round(0.88*w) round(0.18*h)];
        app.TRef.Position = [round(0.035*app.PRef.Position(3)) round(0.22*app.PRef.Position(4)) ...
            round(0.93*app.PRef.Position(3)) round(0.52*app.PRef.Position(4))];
    end

    function onSeriesModeChanged()
        isSingle = app.BGSeries.SelectedObject == app.RSingle;
        if isSingle
            app.LFrom.Text = langText(app,'main22','Age');
            app.ETo.Visible = 'off';
            app.EStep.Visible = 'off';
            app.LTo.Visible = 'off';
            app.LStep.Visible = 'off';
            app.LU2.Visible = 'off';
            app.LU3.Visible = 'off';
        else
            app.LFrom.Text = langText(app,'main16','From');
            app.ETo.Visible = 'on';
            app.EStep.Visible = 'on';
            app.LTo.Visible = 'on';
            app.LStep.Visible = 'on';
            app.LU2.Visible = 'on';
            app.LU3.Visible = 'on';
        end
        updateHint();
    end

    function updateHint()
        msgDefault = langText(app,'mical10','Please provide valid age range.');
        msg = msgDefault;
        isSingle = app.BGSeries.SelectedObject == app.RSingle;

        if isSingle
            t = str2double(app.EFrom.Value);
            if isfinite(t)
                if t >= 4500
                    msg = langText(app,'mical08','Age must be < 4500 Ma.');
                elseif t <= -4500
                    msg = langText(app,'mical09','Age must be > -4500 Ma.');
                else
                    msg = [langText(app,'mical07','will calculate length of day and days in a year: '),num2str(t),' Ma'];
                end
            end
        else
            a1 = str2double(app.EFrom.Value);
            a2 = str2double(app.ETo.Value);
            st = str2double(app.EStep.Value);
            if isfinite(a1) && isfinite(a2) && isfinite(st) && st > 0
                T = a1:st:a2;
                if ~isempty(T)
                    if max(T) >= 4500 || min(T) <= -4500
                        msg = msgDefault;
                    elseif numel(T) > 3
                        msg = [langText(app,'mical07','will calculate length of day and days in a year: '), ...
                            num2str(T(1)),', ',num2str(T(2)),', ... , ',num2str(T(end)),' Ma'];
                    else
                        msg = [langText(app,'mical07','will calculate length of day and days in a year: '), ...
                            num2str(T(1)),' - ',num2str(T(end)),' Ma'];
                    end
                end
            end
        end
        app.LHint.Text = msg;
    end

    function updateReferenceText()
        txt = 'Waltham, D., 2015. JSR. doi: 10.2110/jsr.2015.66; Laskar, J., et al., 2004, Astronomy & Astrophysics 428, 261-285.';
        if app.lang_choice ~= 0
            txt = langText(app,'mical17',txt);
        end
        app.TRef.Value = txt;
    end

    function onRun()
        isSingle = app.BGSeries.SelectedObject == app.RSingle;
        modelIdx = find(strcmp(app.DModel.Items,app.DModel.Value),1,'first');
        if isempty(modelIdx), modelIdx = 1; end

        if modelIdx == 1
            runWaltham(isSingle);
        else
            runLaskar(isSingle);
        end
    end

    function runWaltham(isSingle)
        if isSingle
            T1 = str2double(app.EFrom.Value);
            if ~isfinite(T1) || T1 >= 4500 || T1 <= -4500
                uialert(app.UIFigure,langText(app,'mical10','Invalid age.'),'Acycle: Milankovitch');
                return
            end
            [daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max, ...
                p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = MilankovitchCal(T1);

            distance = 0.5*(amax + amin); distsigma = 0.5*(amax - amin);
            day = 0.5*(daymax + daymin);   daysigma = 0.5*(daymax - daymin);
            obliq = 0.5*(obmax + obmin);   obsigma = 0.5*(obmax - obmin);
            kkymin = 360.0*3.6/kmax;       kkymax = 360.0*3.6/kmin;
            prec = 0.5*(kkymax + kkymin);  precsigma = 0.5*(kkymax - kkymin);
            o1 = 0.5*(o1max + o1min);      o1sigma = 0.5*(o1max - o1min);
            p1 = 0.5*(p1max + p1min);      p1sigma = 0.5*(p1max - p1min);
            p2 = 0.5*(p2max + p2min);      p2sigma = 0.5*(p2max - p2min);
            p3 = 0.5*(p3max + p3min);      p3sigma = 0.5*(p3max - p3min);
            p4 = 0.5*(p4max + p4min);      p4sigma = 0.5*(p4max - p4min);

            prompt = {...
                langText(app,'mical11','Earth-Moon Distance (x1000 km)'); ...
                langText(app,'mical12','Earth Day (hours)'); ...
                langText(app,'mical13','Earth Axis Mean Obliquity (degrees)'); ...
                langText(app,'mical14','Earth Axis Precession Period (kyr)'); ...
                langText(app,'mical15','Main Obliquity Period (kyr)'); ...
                [langText(app,'mical16','Climatic Precession Periods'),' #1 (kyr)']; ...
                [langText(app,'mical16','Climatic Precession Periods'),' #2 (kyr)']; ...
                [langText(app,'mical16','Climatic Precession Periods'),' #3 (kyr)']; ...
                [langText(app,'mical16','Climatic Precession Periods'),' #4 (kyr)']; ...
                [langText(app,'mical17','Reference: '),' Waltham, D., 2015. JSR. doi: 10.2110/jsr.2015.66']};
            defaults = {...
                [num2str(distance),' +/- ',num2str(distsigma)],...
                [num2str(day),' +/- ',num2str(daysigma)],...
                [num2str(obliq),' +/- ',num2str(obsigma)],...
                [num2str(prec),' +/- ',num2str(precsigma)],...
                [num2str(o1),' +/- ',num2str(o1sigma)],...
                [num2str(p1),' +/- ',num2str(p1sigma)],...
                [num2str(p2),' +/- ',num2str(p2sigma)],...
                [num2str(p3),' +/- ',num2str(p3sigma)],...
                [num2str(p4),' +/- ',num2str(p4sigma)],...
                'https://davidwaltham.com/wp-content/uploads/2014/01/Milankovitch.html'};
            inputdlg(prompt,langText(app,'menu52','Milankovitch Calculator'),1,defaults,struct('Resize','on')); %#ok<INPDLG>
            return
        end

        age1 = str2double(app.EFrom.Value);
        age2 = str2double(app.ETo.Value);
        step = str2double(app.EStep.Value);
        if ~isfinite(age1) || ~isfinite(age2) || ~isfinite(step) || step <= 0
            uialert(app.UIFigure,langText(app,'mical10','Invalid age range.'),'Acycle: Milankovitch');
            return
        end
        T1 = (age1:step:age2)';
        if isempty(T1)
            uialert(app.UIFigure,langText(app,'mical10','Invalid age range.'),'Acycle: Milankovitch');
            return
        end

        calmi = nan(numel(T1),18);
        for ti = 1:numel(T1)
            age = T1(ti);
            [daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max, ...
                p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = MilankovitchCal(age);
            calmi(ti,:) = [daymin, daymax, amin, amax, kmin, kmax, obmin, obmax, o1min, o1max, ...
                p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max];
        end

        figure('Color','w','Name',['Acycle: ',langText(app,'menu52','Milankovitch Calculator'),' | ',langText(app,'menu03','Plot')]);
        subplot(3,2,1); hold on; plot(T1,calmi(:,3),'k--'); plot(T1,calmi(:,4),'k--'); plot(T1,mean(calmi(:,3:4),2),'r-','LineWidth',1); ylabel(langText(app,'mical11','Distance')); xlim([age1 age2]);
        subplot(3,2,2); hold on; plot(T1,calmi(:,1),'k--'); plot(T1,calmi(:,2),'k--'); plot(T1,mean(calmi(:,1:2),2),'r-','LineWidth',1); ylabel(langText(app,'mical12','Earth Day')); xlim([age1 age2]);
        subplot(3,2,3); hold on; plot(T1,calmi(:,7),'k--'); plot(T1,calmi(:,8),'k--'); plot(T1,mean(calmi(:,7:8),2),'r-','LineWidth',1); ylabel(langText(app,'mical13','Obliquity')); xlim([age1 age2]);
        subplot(3,2,4); hold on; plot(T1,360.0*3.6./calmi(:,5),'k--'); plot(T1,360.0*3.6./calmi(:,6),'k--'); plot(T1,0.5*(360.0*3.6./calmi(:,5)+360.0*3.6./calmi(:,6)),'r-','LineWidth',1); ylabel(langText(app,'mical14','Precession')); xlim([age1 age2]);
        subplot(3,2,5); hold on; plot(T1,calmi(:,9),'k--'); plot(T1,calmi(:,10),'k--'); plot(T1,mean(calmi(:,9:10),2),'r-','LineWidth',1); ylabel(langText(app,'mical15','Main Obliquity')); xlabel([langText(app,'main22','Age'),' (Ma)']); xlim([age1 age2]);
        subplot(3,2,6); hold on;
        plot(T1,calmi(:,11),'k--'); plot(T1,calmi(:,12),'k--'); plot(T1,mean(calmi(:,11:12),2),'k-','LineWidth',1);
        plot(T1,calmi(:,13),'g--'); plot(T1,calmi(:,14),'g--'); plot(T1,mean(calmi(:,13:14),2),'g-','LineWidth',1);
        plot(T1,calmi(:,15),'b--'); plot(T1,calmi(:,16),'b--'); plot(T1,mean(calmi(:,15:16),2),'b-','LineWidth',1);
        plot(T1,calmi(:,17),'r--'); plot(T1,calmi(:,18),'r--'); plot(T1,mean(calmi(:,17:18),2),'r-','LineWidth',1);
        xlabel([langText(app,'main22','Age'),' (Ma)']); ylabel([langText(app,'mical16','Precession'),' (kyr)']); xlim([age1 age2]);

        CalMiR = [calmi(:,3),calmi(:,4),calmi(:,1),calmi(:,2),calmi(:,7),calmi(:,8), ...
            360.0*3.6./calmi(:,5),360.0*3.6./calmi(:,6),calmi(:,9:end)];
        fname = ['CalMi_',num2str(age1),'_',num2str(age2),'-Ma-step_',num2str(step),'.txt'];
        saveInAcPwd(fname,[T1,CalMiR]);
    end

    function runLaskar(isSingle)
        if isSingle
            T1 = str2double(app.EFrom.Value);
            if ~isfinite(T1) || T1 >= 4500 || T1 <= -4500
                uialert(app.UIFigure,langText(app,'mical10','Invalid age.'),'Acycle: LOD');
                return
            end
            [lod,doy] = lodla04(T1/-1000);
            saveInAcPwd(['LOD_',num2str(T1),'Ma.txt'],[T1,lod]);
            saveInAcPwd(['LOD_DOY_',num2str(T1),'Ma.txt'],[T1,doy]);
            figure('Color','w','Name',langText(app,'mical21','Length of Day'));
            subplot(2,1,1); plot(T1,lod,'-ko'); ylabel(langText(app,'mical12','Earth Day'));
            subplot(2,1,2); plot(T1,doy,'-ko'); xlabel([langText(app,'main22','Age'),' (Ma)']); ylabel(langText(app,'mical22','Days in a Year'));
            return
        end

        age1 = str2double(app.EFrom.Value);
        age2 = str2double(app.ETo.Value);
        step = str2double(app.EStep.Value);
        if ~isfinite(age1) || ~isfinite(age2) || ~isfinite(step) || step <= 0
            uialert(app.UIFigure,langText(app,'mical10','Invalid age range.'),'Acycle: LOD');
            return
        end
        T1 = (age1:step:age2)';
        if isempty(T1)
            uialert(app.UIFigure,langText(app,'mical10','Invalid age range.'),'Acycle: LOD');
            return
        end
        [lod,doy] = lodla04(T1/-1000);
        saveInAcPwd(['LOD-',num2str(age1),'_',num2str(age2),'_Ma-step_',num2str(step),'.txt'],[T1,lod,doy]);
        figure('Color','w','Name',langText(app,'mical21','Length of Day'));
        subplot(2,1,1); plot(T1,lod,'-ko'); ylabel(langText(app,'mical12','Earth Day'));
        subplot(2,1,2); plot(T1,doy,'-ko'); xlabel([langText(app,'main22','Age'),' (Ma)']); ylabel(langText(app,'mical22','Days in a Year'));
    end

    function saveInAcPwd(fname, data)
        pre = pwd;
        c = onCleanup(@()safeCd(pre)); %#ok<NASGU>
        safeCd(getAcPwdFromContext());
        dlmwrite(fname,data,'delimiter',' ','precision',9);
        refreshMainListbox();
    end

    function p0 = getAcPwdFromContext()
        p0 = pwd;
        try
            h = app.edit_acfigmain_dir;
            if ~isempty(h) && isgraphics(h)
                try
                    v = get(h,'String');
                catch
                    v = get(h,'Value');
                end
                if iscell(v), v = v{1}; end
                if isstring(v), v = char(v); end
                if ischar(v)
                    v = strtrim(v);
                    if ~isempty(v) && exist(v,'dir') == 7
                        p0 = v;
                    end
                end
            end
        catch
        end
    end

    function refreshMainListbox()
        if ~isempty(app.listbox_acmain) && isgraphics(app.listbox_acmain)
            d = dir;
            names = {d.name};
            keep = ~strcmp(names,'.') & ~strcmp(names,'..');
            names = names(keep);
            try
                if isempty(names)
                    set(app.listbox_acmain,'String',{},'Value',[]);
                else
                    set(app.listbox_acmain,'String',names,'Value',1);
                end
            catch
            end
        end
    end

    function onFigureKeyPress(~,event)
        keyVal = getEventProp(event,'Key','');
        charVal = getEventProp(event,'Character','');
        keyIsW = strcmpi(string(keyVal),'w');
        chIsCtrlW = isequal(char(charVal),char(23));
        if ~(keyIsW || chIsCtrlW)
            return
        end

        mods = normalizeModifiers(event);
        hasCloseMod = any(mods == "control") || any(mods == "command") || any(mods == "meta");
        if hasCloseMod || chIsCtrlW
            try
                if isvalid(app.UIFigure)
                    close(app.UIFigure);
                end
            catch
            end
        end
    end
end

function safeCd(target)
if nargin < 1 || isempty(target), return; end
try
    cd(target);
catch
end
end

function txt = langText(app,key,fallback)
txt = fallback;
if ~isstruct(app) || ~isfield(app,'lang_choice') || app.lang_choice == 0
    return
end
if ~isfield(app,'lang_id') || ~isfield(app,'lang_var')
    return
end
if isempty(app.lang_id) || isempty(app.lang_var)
    return
end
[tf,idx] = ismember(key, app.lang_id);
if tf && idx > 0 && idx <= numel(app.lang_var)
    val = app.lang_var{idx};
    if ischar(val) || isstring(val)
        txt = char(val);
    end
end
end

function v = getFieldDefault(s,name,default)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
end
end

function mods = normalizeModifiers(event)
mods = strings(0,1);
raw = getEventProp(event,'Modifier',[]);
if isempty(raw)
    return
end
if isstring(raw)
    mods = lower(raw(:));
elseif ischar(raw)
    mods = string(lower(raw));
elseif iscell(raw)
    mods = lower(string(raw(:)));
end
end

function v = getEventProp(event,name,default)
v = default;
try
    if isstruct(event)
        if isfield(event,name)
            v = event.(name);
        end
    else
        if isprop(event,name)
            v = event.(name);
        end
    end
catch
end
end
