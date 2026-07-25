function varargout = InterplationSeries(varargin)
% App Designer-style migration of InterplationSeries (single-file).

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

        app = struct();
        app.ctx = ctx;
        app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
        app.unit = getFieldDefault(ctx,'unit','');
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});

        figName = 'Acycle: Interpolation Series';
        if app.lang_choice > 0
            figName = ['Acycle: ',langText(app,'menu72','Interpolation Series')];
        end

        app.UIFigure = uifigure('Name',figName,'Color',bg, ...
            'Position',[120 90 2048 740],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)doLayout();

        panelTitle = langText(app,'intser01','Select Reference and Target');
        app.PanelMain = uipanel(app.UIFigure,'Title',panelTitle,'BackgroundColor',bg);
        app.PanelMain.FontWeight = 'bold';

        app.LRef = uilabel(app.PanelMain,'Text',langText(app,'intser02','Reference'),'BackgroundColor',bg);
        app.LSeries = uilabel(app.PanelMain,'Text',langText(app,'intser03','Series'),'BackgroundColor',bg);

        openText = langText(app,'intser04','Open');
        app.BtnOpenRef = uibutton(app.PanelMain,'push','Text',openText, ...
            'ButtonPushedFcn',@(~,~)pickReference());
        app.BtnOpenSeries = uibutton(app.PanelMain,'push','Text',openText, ...
            'ButtonPushedFcn',@(~,~)pickSeries());

        app.ERef = uieditfield(app.PanelMain,'text','Value','','Editable','off');
        app.ETwitter = uieditfield(app.PanelMain,'text','Value','','Editable','off');

        app.BtnInterp = uibutton(app.UIFigure,'push', ...
            'Text',langText(app,'intser05','Interpolation'), ...
            'ButtonPushedFcn',@(~,~)runInterpolation());

        seedInitialPath();
        doLayout();

        function seedInitialPath()
            here = pwd;
            try
                if exist('GETac_pwd','file') == 2
                    GETac_pwd;
                    if exist('ac_pwd','var')
                        here = ac_pwd;
                    end
                end
            catch
            end
            app.ERef.Value = here;
            app.ETwitter.Value = here;
        end

        function doLayout()
            p = app.UIFigure.Position;
            w = p(3);
            h = p(4);

            app.PanelMain.Position = [round(0.025*w) round(0.27*h) round(0.95*w) round(0.60*h)];

            pw = app.PanelMain.Position(3);
            ph = app.PanelMain.Position(4);

            app.LRef.Position = [round(0.015*pw) round(0.82*ph) round(0.20*pw) round(0.10*ph)];
            app.BtnOpenRef.Position = [round(0.015*pw) round(0.52*ph) round(0.10*pw) round(0.18*ph)];
            app.ERef.Position = [round(0.125*pw) round(0.51*ph) round(0.855*pw) round(0.19*ph)];

            app.LSeries.Position = [round(0.015*pw) round(0.33*ph) round(0.20*pw) round(0.10*ph)];
            app.BtnOpenSeries.Position = [round(0.015*pw) round(0.04*ph) round(0.10*pw) round(0.18*ph)];
            app.ETwitter.Position = [round(0.125*pw) round(0.03*ph) round(0.855*pw) round(0.19*ph)];

            app.BtnInterp.Position = [round(0.50*w) round(0.10*h) round(0.25*w) round(0.12*h)];
        end

        function pickReference()
            pre_dirML = pwd;
            moveToAcPwd();

            filterTxt = langText(app,'intser08','All Files');
            dlgTitle = langText(app,'intser09','Select Reference');
            [file,path] = uigetfile({'*.*',filterTxt},dlgTitle);
            if isequal(file,0)
                disp(langText(app,'intser11','User canceled file selection.'));
            else
                app.ERef.Value = fullfile(path,file);
            end

            safeCd(pre_dirML);
        end

        function pickSeries()
            pre_dirML = pwd;
            moveToAcPwd();

            filterTxt = langText(app,'intser08','All Files');
            dlgTitle = langText(app,'intser10','Select Series');
            [file,path] = uigetfile({'*.*',filterTxt},dlgTitle);
            if isequal(file,0)
                disp(langText(app,'intser11','User canceled file selection.'));
            else
                app.ETwitter.Value = fullfile(path,file);
            end

            safeCd(pre_dirML);
        end

        function runInterpolation()
            pre_dirML = pwd;
            try
                refFile = strtrim(app.ERef.Value);
                tgtFile = strtrim(app.ETwitter.Value);
                if isempty(refFile) || isempty(tgtFile)
                    error('Reference/Series path is empty.');
                end

                dat1 = localLoad2Col(refFile); % reference
                dat2 = localLoad2Col(tgtFile); % target

                if size(dat1,2) < 2 || size(dat2,2) < 2
                    error('Input files must have at least 2 columns.');
                end

                dat1 = sortrows(dat1,1);
                dat2 = sortrows(dat2,1);

                xmin = min([dat1(:,1); dat2(:,1)]);
                xmax = max([dat1(:,1); dat2(:,1)]);

                dat2int2 = interp1(dat2(:,1),dat2(:,2),dat1(:,1),'linear');
                dat2int = [dat1(:,1),dat2int2];

                plotInterpolation(dat1,dat2,dat2int,xmin,xmax);
                outName = saveInterpolation(refFile,tgtFile,dat2int);
                refreshMainListbox();

                safeCd(pre_dirML);
                disp('Interpolated data:');
                disp(outName);
            catch ME
                safeCd(pre_dirML);
                uialert(app.UIFigure,ME.message,'Interpolation Error');
            end
        end

        function plotInterpolation(dat1,dat2,dat2int,xmin,xmax)
            figName = [langText(app,'menu72','Interpolation Series'),' ',langText(app,'menu40','Result')];
            fig = figure('Color','white','Name',['Acycle: ',figName]);

            subplot(3,1,1,'Parent',fig);
            plot(dat1(:,1),dat1(:,2),'b--o');
            xlim([xmin,xmax]);
            title(langText(app,'intser02','Reference'));

            subplot(3,1,2,'Parent',fig);
            plot(dat2(:,1),dat2(:,2),'r-s');
            xlim([xmin,xmax]);
            title(langText(app,'intser06','Series'));

            subplot(3,1,3,'Parent',fig);
            plot(dat2int(:,1),dat2int(:,2),'r-o');
            xlim([xmin,xmax]);
            if ~isempty(app.unit)
                xlabel(app.unit);
            end
            title([langText(app,'intser06','Series'),' ',langText(app,'intser07','Interpolated')]);
        end

        function outName = saveInterpolation(refFile,tgtFile,dat2int)
            moveToAcPwd();
            [~,name1,~] = fileparts(refFile);
            [~,name2,ext2] = fileparts(tgtFile);
            outName = [name2,'-IntP-',name1,ext2];
            dlmwrite(outName, dat2int, 'delimiter', ' ', 'precision', 9);
        end

        function refreshMainListbox()
            if ac_refresh_main_list(app.listbox_acmain)
                return
            end
            if isempty(app.listbox_acmain) || ~ishandle(app.listbox_acmain)
                return
            end
            d = dir;
            try
                set(app.listbox_acmain,'String',{d.name},'Value',1);
            catch
            end
            if exist('refreshcolor','file') == 2
                refreshcolor;
            end
        end

        function moveToAcPwd()
            if exist('CDac_pwd','file') == 2
                CDac_pwd;
            end
        end

        function safeCd(target)
            if nargin < 1 || isempty(target)
                return
            end
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
    c = onCleanup(@()fclose(fid));
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
