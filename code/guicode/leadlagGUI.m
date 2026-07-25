function varargout = leadlagGUI(varargin)
% leadlagGUI - single-file App Designer style migration (no GUIDE .fig).

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = buildUI(ctx);
if nargout > 0
    varargout{1} = app.UIFigure;
end

    function app = buildUI(ctx)
        app = struct();
        app.ctx = ctx;
        app.bg = [0.94 0.94 0.94];
        app.blue = [0.08 0.02 0.95];

        app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
        app.edit_acfigmain_dir = getFieldDefault(ctx,'edit_acfigmain_dir',[]);
        app.monzoom = getFieldDefault(ctx,'MonZoom',1);
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});

        app.pathRef = '';
        app.pathSeries = '';

        sc = get(groot,'ScreenSize');
        pos = round([0.38*sc(3), 0.2*sc(4), 0.60*sc(3), 0.25*sc(4)] * app.monzoom);
        pos(3) = max(pos(3),1200);
        pos(4) = max(pos(4),430);

        titleTxt = ['Acycle: ',langText(app,'menu112','leadlagGUI')];
        app.UIFigure = uifigure('Name',titleTxt,'Color',app.bg,'Position',pos,'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)layoutUI();

        app.PanelFiles = uipanel(app.UIFigure,'Title',langText(app,'intser01','Select Reference and Target'),'BackgroundColor',app.bg);
        app.PanelFiles.FontWeight = 'bold';

        openTxt = langText(app,'intser04','Open');
        app.LRef = uilabel(app.PanelFiles,'Text',langText(app,'intser02','Reference'),'BackgroundColor',app.bg);
        app.BOpenRef = uibutton(app.PanelFiles,'push','Text',openTxt,'ButtonPushedFcn',@(~,~)pickRef());
        app.ERef = uieditfield(app.PanelFiles,'text','Editable','off');

        app.LSeries = uilabel(app.PanelFiles,'Text',langText(app,'intser06','Series'),'BackgroundColor',app.bg);
        app.BOpenSeries = uibutton(app.PanelFiles,'push','Text',openTxt,'ButtonPushedFcn',@(~,~)pickSeries());
        app.ETwitter = uieditfield(app.PanelFiles,'text','Editable','off');

        app.LDepthTime = uilabel(app.UIFigure,'Text',langText(app,'leadlag02','Depth/time'),'BackgroundColor',app.bg);
        app.DDir = uidropdown(app.UIFigure,'Items',{'Small = Young','Small = Old'},'Value','Small = Young');
        app.LLimit = uilabel(app.UIFigure,'Text',langText(app,'leadlag01','Test limit'),'BackgroundColor',app.bg);
        app.ELimit = uieditfield(app.UIFigure,'text','Value','0');
        app.LStep = uilabel(app.UIFigure,'Text',langText(app,'main32','Step'),'BackgroundColor',app.bg);
        app.EStep = uieditfield(app.UIFigure,'text','Value','1');

        app.CSave = uicheckbox(app.UIFigure,'Text',langText(app,'main01','Save data'),'Value',false);
        app.BRun = uibutton(app.UIFigure,'push','Text',langText(app,'main00','OK'), ...
            'BackgroundColor',app.blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@(~,~)runLeadlag());

        seedInitialPaths();
        layoutUI();
        setappdata(app.UIFigure,'LEADLAG_APP',app);

        function seedInitialPaths()
            here = getAcPwdFromContext();
            app.ERef.Value = here;
            app.ETwitter.Value = here;
        end

        function layoutUI()
            p = app.UIFigure.Position;
            w = p(3); h = p(4);
            m = round(0.025*w);

            app.PanelFiles.Position = [m round(0.29*h) round(0.95*w) round(0.65*h)];
            pw = app.PanelFiles.Position(3);
            ph = app.PanelFiles.Position(4);

            dTop = round(0.10*ph);
            app.LRef.Position = [round(0.015*pw) round(0.84*ph)-dTop round(0.23*pw) round(0.12*ph)];
            app.BOpenRef.Position = [round(0.015*pw) round(0.54*ph)-dTop round(0.10*pw) round(0.20*ph)];
            app.ERef.Position = [round(0.125*pw) round(0.53*ph)-dTop round(0.86*pw) round(0.22*ph)];

            app.LSeries.Position = [round(0.015*pw) round(0.28*ph) round(0.23*pw) round(0.12*ph)];
            app.BOpenSeries.Position = [round(0.015*pw) round(0.03*ph) round(0.10*pw) round(0.20*ph)];
            app.ETwitter.Position = [round(0.125*pw) round(0.02*ph) round(0.86*pw) round(0.22*ph)];

            yb = round(0.11*h);
            xShift = round(0.05*w);
            app.LDepthTime.Position = [round(0.06*w)-xShift yb round(0.10*w) round(0.10*h)];
            app.DDir.Position = [round(0.16*w)-xShift yb+2 round(0.20*w) round(0.09*h)];
            app.LLimit.Position = [round(0.46*w)-xShift yb round(0.10*w) round(0.10*h)];
            app.ELimit.Position = [round(0.56*w)-xShift yb+2 round(0.10*w) round(0.09*h)];
            app.LStep.Position = [round(0.66*w)-xShift yb round(0.06*w) round(0.10*h)];
            app.EStep.Position = [round(0.75*w)-xShift yb+2 round(0.10*w) round(0.09*h)];

            app.CSave.Position = [round(0.86*w)-xShift yb round(0.10*w) round(0.10*h)];
            app.BRun.Position = [round(0.93*w)-xShift yb-2 round(0.09*w) round(0.17*h)];
        end

        function pickRef()
            pre = pwd;
            moveToAcPwd();
            [file,path] = uigetfile({'*.*','All Files (*.*)'},'Select a Reference Series');
            if ~isequal(file,0)
                app.pathRef = fullfile(path,file);
                app.ERef.Value = app.pathRef;
            end
            safeCd(pre);
        end

        function pickSeries()
            pre = pwd;
            moveToAcPwd();
            [file,path] = uigetfile({'*.*','All Files (*.*)'},'Select a Target Series');
            if ~isequal(file,0)
                app.pathSeries = fullfile(path,file);
                app.ETwitter.Value = app.pathSeries;
                updateDefaultLimitAndStep();
            end
            safeCd(pre);
        end

        function updateDefaultLimitAndStep()
            try
                dat2 = localLoad2Col(app.ETwitter.Value);
                xmax = max(dat2(:,1),[],'omitnan');
                xmin = min(dat2(:,1),[],'omitnan');
                ll = (xmax-xmin)/10;
                st = mean(diff(dat2(:,1)),'omitnan')/2;
                if ~isfinite(ll), ll = 0; end
                if ~isfinite(st) || st<=0, st = 1; end
                app.ELimit.Value = num2str(ll);
                app.EStep.Value = num2str(st);
            catch
            end
        end

        function runLeadlag()
            pre = pwd;
            try
                p1 = strtrim(app.ERef.Value);
                p2 = strtrim(app.ETwitter.Value);
                if isempty(p1) || isempty(p2)
                    error('Reference/Series path is empty.');
                end

                dat1 = localLoad2Col(p1);
                dat2 = localLoad2Col(p2);
                dat1 = sortrows(dat1);
                dat2 = sortrows(dat2);
                if exist('findduplicate','file') == 2
                    dat1 = findduplicate(dat1);
                    dat2 = findduplicate(dat2);
                else
                    [~,ia] = unique(dat1(:,1),'stable'); dat1 = dat1(ia,:);
                    [~,ib] = unique(dat2(:,1),'stable'); dat2 = dat2(ib,:);
                end
                dat1(any(isinf(dat1),2),:) = [];
                dat2(any(isinf(dat2),2),:) = [];

                ll = str2double(app.ELimit.Value);
                st = str2double(app.EStep.Value);
                if ~isfinite(ll) || ll < 0, ll = 0; end
                if ~isfinite(st) || st <= 0, st = 1; end

                timedir = find(strcmp(app.DDir.Items,app.DDir.Value),1,'first');
                if isempty(timedir), timedir = 1; end
                plotn = 1;
                [llgrid,RMSE] = rmse4leadlag(dat1,dat2,ll,st,timedir,plotn);

                if app.CSave.Value
                    moveToAcPwd();
                    [~,name1,~] = fileparts(p1);
                    [~,name2,ext2] = fileparts(p2);
                    if isempty(ext2), ext2 = '.txt'; end
                    outName = [name2,'-LeadLag-',name1,ext2];
                    dlmwrite(outName,[llgrid',RMSE'],'delimiter',' ','precision',9);
                    refreshMainListbox();
                end

                safeCd(pre);
            catch ME
                safeCd(pre);
                uialert(app.UIFigure,ME.message,'Acycle: lead/lag');
            end
        end

        function moveToAcPwd()
            safeCd(getAcPwdFromContext());
        end

        function out = getAcPwdFromContext()
            out = pwd;
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
                            out = v;
                        end
                    end
                end
            catch
            end
        end

        function refreshMainListbox()
            if ac_refresh_main_list(app.listbox_acmain)
                return
            end
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

        function safeCd(target)
            if nargin < 1 || isempty(target), return; end
            try
                cd(target);
            catch
            end
        end
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

function data = localLoad2Col(filename)
try
    data = load(filename);
catch
    fid = fopen(filename,'r');
    if fid < 0
        error('Cannot open file: %s', filename);
    end
    c = onCleanup(@()fclose(fid)); %#ok<NASGU>
    data_ft = textscan(fid,'%f%f','EmptyValue',Inf);
    data = cell2mat(data_ft);
end
if isempty(data)
    error('File is empty or unreadable: %s', filename);
end
if size(data,2) < 2
    error('File needs at least 2 columns: %s', filename);
end
data = data(:,1:2);
end
