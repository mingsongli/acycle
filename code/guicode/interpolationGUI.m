function varargout = interpolationGUI(varargin)
% App Designer-style migration of interpolationGUI (single-file).

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = buildUI(ctx);
if nargout > 0
    varargout{1} = app.UIFigure;
end

    function app = buildUI(ctx)
        bg = [0.94 0.94 0.94];
        blue = [0 0 1];

        app = struct();
        app.ctx = ctx;
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});
        app.MonZoom = getFieldDefault(ctx,'MonZoom',1); %#ok<NASGU>
        app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
        app.edit_acfigmain_dir = getFieldDefault(ctx,'edit_acfigmain_dir',[]);
        app.val1 = getFieldDefault(ctx,'val1',1);

        app.data = getCurrentData(ctx);
        app.data = sortrows(app.data,1);
        app.dat_name = getFieldDefault(ctx,'dat_name','data');
        app.ext = getFieldDefault(ctx,'ext','.txt');
        app.data_name = getFieldDefault(ctx,'data_name','');

        app.methods = {'linear','nearest','next','previous','pchip','cubic','v5cubic','makima','spline'};
        app.methodLabels = getMethodLabels(app);

        titleText = 'Acycle: Interpolation Pro';
        if app.lang_choice > 0
            titleText = ['Acycle: ', langText(app,'menu93',titleText)];
        end

        figPos = [500 170 1125 653];

        app.UIFigure = uifigure('Name',titleText,'Color',bg,'Position',figPos,'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();
        app.UIFigure.WindowKeyPressFcn = @onFigureKeyPress;
        app.UIFigure.WindowKeyReleaseFcn = @onFigureKeyPress;

        panelTitle = 'Interpolation';
        if app.lang_choice > 0
            panelTitle = langText(app,'menu71',panelTitle);
        end
        app.PanelTop = uipanel(app.UIFigure,'Title',panelTitle,'BackgroundColor',bg);

        app.LDataName = uilabel(app.PanelTop,'Text',[app.dat_name,app.ext],'BackgroundColor',bg);
        app.LDataName.FontSize = 18;

        srateText = 'Sampling rate';
        methodText = 'Method';
        saveText = 'Save';
        gapText = 'Set gap (';
        tailText = 'x median sampling rate ) = 0';
        if app.lang_choice > 0
            srateText = langText(app,'menu46',srateText);
            methodText = langText(app,'c37',methodText);
            saveText = langText(app,'main52',saveText);
            gapText = [langText(app,'interpGUI02','Set gap'),'('];
            tailText = [' x ',langText(app,'interpGUI03','median sampling rate'),') = 0'];
        end

        app.LDt = uilabel(app.PanelTop,'Text',srateText,'BackgroundColor',bg,'FontColor',blue);
        app.EDt = uieditfield(app.PanelTop,'text','Value','','FontColor',blue, ...
            'ValueChangedFcn',@updatePlot);

        app.LMethod = uilabel(app.PanelTop,'Text',methodText,'BackgroundColor',bg,'FontColor',blue);
        app.DropMethod = uidropdown(app.PanelTop,'Items',app.methodLabels,'Value',app.methodLabels{1}, ...
            'ValueChangedFcn',@updatePlot);

        app.LX1 = uilabel(app.PanelTop,'Text','X1','BackgroundColor',bg);
        app.EX1 = uieditfield(app.PanelTop,'text','Value','','ValueChangedFcn',@updatePlot);
        app.LX2 = uilabel(app.PanelTop,'Text','X2','BackgroundColor',bg);
        app.EX2 = uieditfield(app.PanelTop,'text','Value','','ValueChangedFcn',@updatePlot);

        app.LY1 = uilabel(app.PanelTop,'Text','Y1','BackgroundColor',bg);
        app.EY1 = uieditfield(app.PanelTop,'text','Value','','ValueChangedFcn',@updatePlot);
        app.LY2 = uilabel(app.PanelTop,'Text','Y2','BackgroundColor',bg);
        app.EY2 = uieditfield(app.PanelTop,'text','Value','','ValueChangedFcn',@updatePlot);

        app.BtnSave = uibutton(app.PanelTop,'push','Text',saveText, ...
            'FontColor',blue,'FontWeight','bold','ButtonPushedFcn',@saveInterpolation);

        app.UIAxes = uiaxes(app.UIFigure,'BackgroundColor','white');

        app.CkGap = uicheckbox(app.UIFigure,'Text',gapText,'Value',false, ...
            'ValueChangedFcn',@updatePlot);
        app.EGap = uieditfield(app.UIFigure,'text','Value','10','ValueChangedFcn',@updatePlot);
        app.LTail = uilabel(app.UIFigure,'Text',tailText,'BackgroundColor',bg);

        initDefaults();
        doLayout();
        updatePlot();

        function initDefaults()
            dt = median(diff(app.data(:,1)),'omitnan');
            if ~isfinite(dt) || dt <= 0
                dt = 1;
            end
            app.EDt.Value = num2str(dt,'%.10g');
            app.EX1.Value = num2str(min(app.data(:,1)),'%.10g');
            app.EX2.Value = num2str(max(app.data(:,1)),'%.10g');
            app.EY1.Value = num2str(min(app.data(:,2)),'%.10g');
            app.EY2.Value = num2str(max(app.data(:,2)),'%.10g');
        end

        function doLayout()
            p = app.UIFigure.Position;
            w = p(3);
            h = p(4);

            app.PanelTop.Position = [round(0.05*w) round(0.69*h) round(0.90*w) round(0.24*h)];
            app.UIAxes.Position = [round(0.05*w) round(0.12*h) round(0.90*w) round(0.53*h)];

            pw = app.PanelTop.Position(3);
            ph = app.PanelTop.Position(4);

            app.LDataName.Position = [round(0.01*pw) round(0.60*ph) round(0.50*pw) round(0.24*ph)];

            app.LDt.Position = [round(0.01*pw) round(0.16*ph) round(0.15*pw) round(0.26*ph)];
            app.EDt.Position = [round(0.16*pw) round(0.09*ph) round(0.08*pw) round(0.30*ph)];
            app.LMethod.Position = [round(0.25*pw) round(0.16*ph) round(0.08*pw) round(0.26*ph)];
            app.DropMethod.Position = [round(0.32*pw) round(0.09*ph) round(0.15*pw) round(0.30*ph)];

            app.LX1.Position = [round(0.52*pw) round(0.60*ph) round(0.04*pw) round(0.22*ph)];
            app.EX1.Position = [round(0.56*pw) round(0.56*ph) round(0.11*pw) round(0.23*ph)];
            app.LX2.Position = [round(0.52*pw) round(0.18*ph) round(0.04*pw) round(0.22*ph)];
            app.EX2.Position = [round(0.56*pw) round(0.14*ph) round(0.11*pw) round(0.23*ph)];

            app.LY1.Position = [round(0.72*pw) round(0.60*ph) round(0.04*pw) round(0.22*ph)];
            app.EY1.Position = [round(0.76*pw) round(0.56*ph) round(0.11*pw) round(0.23*ph)];
            app.LY2.Position = [round(0.72*pw) round(0.18*ph) round(0.04*pw) round(0.22*ph)];
            app.EY2.Position = [round(0.76*pw) round(0.14*ph) round(0.11*pw) round(0.23*ph)];

            app.BtnSave.Position = [round(0.90*pw) round(0.39*ph) round(0.075*pw) round(0.25*ph)];

            rowX = 0.54 * w; % shift the whole bottom row to the right
            rowY = 0.05 * h;
            app.CkGap.Position = [round(rowX) round(rowY) round(0.13*w) round(0.05*h)];
            app.EGap.Position = [round(rowX + 0.075*w) round(rowY) round(0.07*w) round(0.045*h)];
            app.LTail.Position = [round(rowX + 0.16*w) round(rowY) round(0.28*w) round(0.05*h)];
        end

        function updatePlot(~,~)
            try
                data = app.data;

                dt = parsePositive(app.EDt.Value, median(diff(data(:,1)),'omitnan'));
                x1 = parseNumber(app.EX1.Value, min(data(:,1)));
                x2 = parseNumber(app.EX2.Value, max(data(:,1)));
                y1 = parseNumber(app.EY1.Value, min(data(:,2)));
                y2 = parseNumber(app.EY2.Value, max(data(:,2)));
                gapdt = parsePositive(app.EGap.Value, 10);

                if x1 == x2
                    x2 = x1 + eps;
                end
                if y1 == y2
                    y2 = y1 + eps;
                end

                methodIdx = find(strcmp(app.DropMethod.Value,app.methodLabels),1,'first');
                if isempty(methodIdx)
                    methodIdx = 1;
                end
                method = app.methods{methodIdx};

                xq = data(1,1):dt:data(end,1);
                if numel(xq) < 2
                    xq = linspace(data(1,1),data(end,1),2);
                end
                vq = interp1(data(:,1),data(:,2),xq,method);

                gappair = [];
                if app.CkGap.Value
                    dfdt = diff(data(:,1));
                    gapi = 0;
                    for i = 1:numel(dfdt)
                        if dfdt(i) > dt * gapdt
                            gapi = gapi + 1;
                            gappair(gapi,1) = data(i,1); %#ok<AGROW>
                            gappair(gapi,2) = data(i+1,1); %#ok<AGROW>
                            vq(xq > gappair(gapi,1) & xq < gappair(gapi,2)) = 0;
                        end
                    end
                    if ~isempty(gappair)
                        if app.lang_choice > 0
                            disp(langText(app,'interpGUI15','start and end of gaps'))
                        else
                            disp('start and end of gaps')
                        end
                        disp(gappair)
                    end
                end

                cla(app.UIAxes);
                hold(app.UIAxes,'on');
                plot(app.UIAxes,data(:,1),data(:,2),'o','Color',[0 0.447 0.741]);
                plot(app.UIAxes,xq,vq,':.','Color',[0.85 0.325 0.098]);

                title(app.UIAxes,getPlotTitle(app,methodIdx));
                legend(app.UIAxes,getLegendRaw(app),method,'Location','northeast');
                xlim(app.UIAxes,[x1 x2]);
                ylim(app.UIAxes,[y1 y2]);
                hold(app.UIAxes,'off');

                app.result.xq = xq;
                app.result.vq = vq;
                app.result.dt = dt;
                app.result.method = method;
            catch ME
                uialert(app.UIFigure,ME.message,'Interpolation Error');
            end
        end

        function saveInterpolation(~,~)
            if ~isfield(app,'result') || ~isfield(app.result,'xq')
                updatePlot();
            end

            dt = app.result.dt;
            method = app.result.method;
            xq = app.result.xq;
            vq = app.result.vq;
            outName = [app.dat_name,'-rsp',num2str(dt,'%.10g'),'-',method,'.txt'];

            oldDir = pwd;
            try
                saveDir = getAcPwdPath(oldDir);
                if ~isempty(saveDir)
                    cd(saveDir);
                end
                dlmwrite(outName, [xq(:),vq(:)], 'delimiter', ' ', 'precision', 9);
                refreshMainListbox();
                disp('Interpolated data:');
                disp(outName);
            catch ME
                try
                    cd(oldDir);
                catch
                end
                uialert(app.UIFigure,ME.message,'Save Error');
                return
            end

            try
                cd(oldDir);
            catch
            end
        end

        function refreshMainListbox()
            if ac_refresh_main_list(app.listbox_acmain)
                return
            end
            if isempty(app.listbox_acmain) || ~ishandle(app.listbox_acmain)
                return
            end

            d = dir;
            d = d(~ismember({d.name},{'.','..'}));

            % Keep original sort behavior tied to main window popup choice.
            val1 = app.val1;
            if ~isscalar(val1) || ~isfinite(val1)
                val1 = 1;
            end
            sortMode = round(val1);
            switch sortMode
                case {1,2,3,4,5,6}
                otherwise
                    sortMode = 1;
            end
            d = ac_sort_dir_entries(d,sortMode);

            pre = '<HTML><FONT color="blue">';
            post = '</FONT></HTML>';
            listboxStr = cell(numel(d),1);
            for i = 1:numel(d)
                if d(i).isdir
                    listboxStr{i} = [pre,d(i).name,post];
                else
                    listboxStr{i} = d(i).name;
                end
            end

            try
                set(app.listbox_acmain,'String',listboxStr,'Value',[]);
            catch
            end
            try
                if ~isempty(app.edit_acfigmain_dir) && ishandle(app.edit_acfigmain_dir)
                    set(app.edit_acfigmain_dir,'String',pwd);
                end
            catch
            end
            updateAcPwdTextFile(pwd);
        end

        function onFigureKeyPress(~,event)
            keyIsW = isfield(event,'Key') && strcmpi(event.Key,'w');
            chIsCtrlW = isfield(event,'Character') && isequal(event.Character,char(23));
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
end

function data = getCurrentData(ctx)
if isfield(ctx,'current_data') && ~isempty(ctx.current_data)
    data = ctx.current_data;
else
    x = linspace(0,100,300)';
    y = sin(x/10) + 0.2*randn(size(x));
    data = [x y];
end
if size(data,2) < 2
    data = [data(:), zeros(numel(data),1)];
end
end

function v = getFieldDefault(s,name,default)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
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

function labels = getMethodLabels(app)
defaultLabels = {'linear','nearest','next','previous','pchip','cubic','v5cubic','makima','spline'};
labels = defaultLabels;
if app.lang_choice == 0
    return
end
keys = {'interpGUI05','interpGUI07','interpGUI08','interpGUI09','interpGUI10','interpGUI11','interpGUI12','interpGUI13','interpGUI14'};
for i = 1:numel(keys)
    labels{i} = langText(app,keys{i},defaultLabels{i});
end
end

function t = getPlotTitle(app,methodIdx)
defaultTitles = {
    '(Default) Linear Interpolation', ...
    'Nearest Neighbor Interpolation', ...
    'Next Neighbor Interpolation', ...
    'Previous Neighbor Interpolation', ...
    'Shape-preserving Piecewise Cubic Interpolation', ...
    'Cubic Interpolation', ...
    'V5cubic Interpolation', ...
    'Modified Akima Cubic Hermite Interpolation', ...
    'Spline Interpolation'};

t = defaultTitles{methodIdx};
if app.lang_choice > 0
    a = langText(app,'interpGUI04','Default');
    b = langText(app,'interpGUI06','Interpolation');
    c = getMethodLabels(app);
    if methodIdx == 1
        t = ['(',a,') ',c{methodIdx},' ',b];
    else
        t = [c{methodIdx},' ',b];
    end
end
end

function s = getLegendRaw(app)
s = 'raw';
if app.lang_choice > 0
    s = langText(app,'a281',s);
end
end

function x = parsePositive(val,default)
x = str2double(string(val));
if ~isfinite(x) || x <= 0
    x = default;
end
end

function x = parseNumber(val,default)
x = str2double(string(val));
if ~isfinite(x)
    x = default;
end
end

function outDir = getAcPwdPath(fallbackDir)
outDir = fallbackDir;
try
    if exist('ac_pwd.txt','file') == 2
        p = strtrim(fileread('ac_pwd.txt'));
        if ~isempty(p) && isfolder(p)
            outDir = p;
        end
    end
catch
end
end

function updateAcPwdTextFile(address)
try
    ac_pwd_str = which('ac_pwd.txt');
    if isempty(ac_pwd_str)
        return
    end
    [ac_pwd_dir,~,~] = fileparts(ac_pwd_str);
    fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
    if fileID < 0
        return
    end
    c = onCleanup(@()fclose(fileID));
    fprintf(fileID,'%s',address);
catch
end
end

function mods = normalizeModifiers(event)
mods = strings(0,1);
if ~isfield(event,'Modifier') || isempty(event.Modifier)
    return
end
raw = event.Modifier;
if isstring(raw)
    mods = lower(raw(:));
elseif ischar(raw)
    mods = string(lower(raw));
elseif iscell(raw)
    mods = lower(string(raw(:)));
end
end
