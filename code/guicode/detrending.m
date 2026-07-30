function varargout = detrending(varargin)
% detrending - App-style detrending tool (replacement for GUIDE prewhiten.fig).
% NOTE: This is the detrending tool (not prewhitenGUI).

ctx = struct();
if nargin > 0 && isstruct(varargin{1})
    ctx = varargin{1};
end

app = struct();
app.ctx = ctx;
app.bg = [0.94 0.94 0.94];
app.blue = [0.08 0.02 0.95];

app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
app.lang_id = getFieldDefault(ctx,'lang_id',{});
app.lang_var = getFieldDefault(ctx,'lang_var',{});
app.main_unit_selection = getFieldDefault(ctx,'main_unit_selection',0);
app.MonZoom = getFieldDefault(ctx,'MonZoom',1);

app.acfigmain = getFieldDefault(ctx,'acfigmain',[]);
app.listbox_acmain = getFieldDefault(ctx,'listbox_acmain',[]);
app.edit_acfigmain_dir = getFieldDefault(ctx,'edit_acfigmain_dir',[]);
app.unit = getFieldDefault(ctx,'unit','unit');
app.unit_type = getFieldDefault(ctx,'unit_type',0);
app.val1 = getFieldDefault(ctx,'val1',1);
app.current_data = getFieldDefault(ctx,'current_data',[]);
app.data_name = getFieldDefault(ctx,'data_name','data.txt');

if isempty(app.current_data) || size(app.current_data,2) < 2
    error('prewhiten: current_data is required and must have 2 columns.');
end

app.xmin = min(app.current_data(:,1));
app.xmax = max(app.current_data(:,1));
app.xrange = app.xmax - app.xmin;
if ~isfinite(app.xrange) || app.xrange <= 0
    app.xrange = 1;
end
app.smooth_win = 0.35;
app.prewhiten_win = app.xrange * app.smooth_win;
app.poly_order = 3;

app.trendFig = [];
app.modelItems = {'Raw'};
app.lastNameOut = '';
app.lastTrendOut = [];

createUI();
updateWindowControls();
updateTrendFigure();

if nargout > 0
    varargout{1} = app.UIFigure;
end

    function createUI()
        sc = get(groot,'ScreenSize');
        pos = round([0.45*sc(3),0.30*sc(4),0.25*sc(3),0.50*sc(4)] * app.MonZoom);
        pos(3) = max(pos(3), 860);
        pos(4) = max(pos(4), 760);

        app.UIFigure = uifigure('Name',windowTitle(),'Color',app.bg,'Position',pos,'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @(~,~)layoutUI();
        try
            app.UIFigure.WindowKeyPressFcn = @(~,evt)onKeyPress(evt);
        catch
            app.UIFigure.KeyPressFcn = @(~,evt)onKeyPress(evt);
        end

        app.PDetrend = uipanel(app.UIFigure,'Title',langText('Fitting01','Detrending'),'BackgroundColor',app.bg,'FontWeight','bold');
        app.LWindow = uilabel(app.PDetrend,'Text',langText('main41','Window'),'BackgroundColor',app.bg);
        app.EWindow = uieditfield(app.PDetrend,'text','BackgroundColor','white','ValueChangedFcn',@(~,~)onWindowChanged());
        app.LOr = uilabel(app.PDetrend,'Text','OR','BackgroundColor',app.bg);
        app.EPercent = uieditfield(app.PDetrend,'text','BackgroundColor','white','ValueChangedFcn',@(~,~)onPercentChanged());
        app.LPercent = uilabel(app.PDetrend,'Text','%','BackgroundColor',app.bg);
        app.BBest = uibutton(app.PDetrend,'push','Text','best','ButtonPushedFcn',@(~,~)onBest());
        app.SSlider = uislider(app.PDetrend,'Limits',[0.01 0.99],'ValueChangedFcn',@(~,~)onSlider());
        app.SSlider.MajorTicks = [];
        app.SSlider.MinorTicks = [];

        app.CLowess = uicheckbox(app.PDetrend,'Text','LOWESS','ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CRlowess = uicheckbox(app.PDetrend,'Text','rLOWESS','ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CLoess = uicheckbox(app.PDetrend,'Text','LOESS','ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CRloess = uicheckbox(app.PDetrend,'Text','rLOESS','ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CEMD = uicheckbox(app.PDetrend,'Text',langText('Fitting24','EEMD residual'),'ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CAll = uicheckbox(app.PDetrend,'Text',langText('Fitting11','Select All'),'ValueChangedFcn',@(~,~)onSelectAll());
        app.BClear = uibutton(app.PDetrend,'push','Text',langText('Fitting12','Clear All'),'ButtonPushedFcn',@(~,~)onClearAll());
        app.BPlot = uibutton(app.PDetrend,'push','Text',langText('menu03','Plot'),...
            'BackgroundColor',app.blue,'FontColor','white','FontWeight','bold','ButtonPushedFcn',@(~,~)onPlot());

        app.PPoly = uipanel(app.PDetrend,'Title',langText('Fitting06','Polynomial fit'),'BackgroundColor',app.bg,'FontWeight','bold');
        app.CMean = uicheckbox(app.PPoly,'Text',langText('Fitting07','Mean'),'ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CLinear = uicheckbox(app.PPoly,'Text',langText('Fitting08','1 order (Linear)'),'ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CPoly2 = uicheckbox(app.PPoly,'Text',langText('Fitting09','2 order'),'ValueChangedFcn',@(~,~)updateTrendFigure());
        app.CPolyN = uicheckbox(app.PPoly,'Text','','ValueChangedFcn',@(~,~)updateTrendFigure());
        app.EPolyN = uieditfield(app.PPoly,'text','Value','3','BackgroundColor','white','ValueChangedFcn',@(~,~)onPolyNChanged());
        app.LPolyOrder = uilabel(app.PPoly,'Text',langText('Fitting10','order'),'BackgroundColor',app.bg);

        app.PSave = uipanel(app.UIFigure,'Title',langText('Fitting13','Select & Save detrending Model'),'BackgroundColor',app.bg,'FontWeight','bold');
        app.DModel = uidropdown(app.PSave,'Items',app.modelItems,'Value',app.modelItems{1},'ValueChangedFcn',@(~,~)onModelSelect());

        layoutUI();
    end

    function t = windowTitle()
        if app.lang_choice == 0
            t = 'Acycle: Curve Fitting | Detrending | Smoothing';
        else
            t = ['Acycle: ', langText('menu100','Curve Fitting | Detrending | Smoothing')];
        end
    end

    function layoutUI()
        w = app.UIFigure.Position(3);
        h = app.UIFigure.Position(4);

        app.PDetrend.Position = [round(0.025*w), round(0.255*h), round(0.95*w), round(0.665*h)];
        pd = app.PDetrend.Position;

        app.LWindow.Position = [round(0.07*pd(3)), round(0.87*pd(4)), round(0.17*pd(3)), 30];
        app.EWindow.Position = [round(0.23*pd(3)), round(0.85*pd(4)), round(0.20*pd(3)), 42];
        app.LOr.Position = [round(0.48*pd(3)), round(0.87*pd(4)), round(0.07*pd(3)), 30];
        app.EPercent.Position = [round(0.57*pd(3)), round(0.85*pd(4)), round(0.15*pd(3)), 42];
        app.LPercent.Position = [round(0.75*pd(3)), round(0.87*pd(4)), round(0.05*pd(3)), 30];
        app.BBest.Position = [round(0.82*pd(3)), round(0.86*pd(4)), round(0.12*pd(3)), 40];
        app.SSlider.Position = [round(0.03*pd(3)), round(0.79*pd(4)), round(0.94*pd(3)), 3];

        app.CLowess.Position = [round(0.05*pd(3)), round(0.63*pd(4)), round(0.22*pd(3)), 30];
        app.CRlowess.Position = [round(0.05*pd(3)), round(0.53*pd(4)), round(0.22*pd(3)), 30];
        app.CLoess.Position = [round(0.05*pd(3)), round(0.43*pd(4)), round(0.22*pd(3)), 30];
        app.CRloess.Position = [round(0.05*pd(3)), round(0.33*pd(4)), round(0.22*pd(3)), 30];
        app.CEMD.Position = [round(0.8*pd(3)), round(0.63*pd(4)), round(0.18*pd(3)), 30];

        app.PPoly.Position = [round(0.25*pd(3)), round(0.25*pd(4)), round(0.45*pd(3)), round(0.45*pd(4))];
        pp = app.PPoly.Position;
        app.CMean.Position = [round(0.07*pp(3)), round(0.74*pp(4)), round(0.35*pp(3)), 30];
        app.CLinear.Position = [round(0.07*pp(3)), round(0.54*pp(4)), round(0.50*pp(3)), 30];
        app.CPoly2.Position = [round(0.07*pp(3)), round(0.34*pp(4)), round(0.30*pp(3)), 30];
        app.CPolyN.Position = [round(0.07*pp(3)), round(0.14*pp(4)), round(0.10*pp(3)), 30];
        app.EPolyN.Position = [round(0.29*pp(3)), round(0.12*pp(4)), round(0.20*pp(3)), 40];
        app.LPolyOrder.Position = [round(0.50*pp(3)), round(0.15*pp(4)), round(0.20*pp(3)), 30];

        app.CAll.Position = [round(0.05*pd(3)), round(0.14*pd(4)), round(0.28*pd(3)), 30];
        app.BClear.Position = [round(0.38*pd(3)), round(0.11*pd(4)), round(0.27*pd(3)), 44];
        app.BPlot.Position = [round(0.67*pd(3)), round(0.10*pd(4)), round(0.24*pd(3)), 56];

        app.PSave.Position = [round(0.025*w), round(0.03*h), round(0.95*w), round(0.21*h)];
        ps = app.PSave.Position;
        app.DModel.Position = [round(0.06*ps(3)), round(0.46*ps(4)), round(0.86*ps(3)), 40];
    end

    function onWindowChanged()
        v = str2double(app.EWindow.Value);
        if ~isfinite(v), return; end
        app.prewhiten_win = v;
        app.smooth_win = max(0.01, min(0.99, v / app.xrange));
        updateWindowControls();
        updateTrendFigure();
    end

    function onPercentChanged()
        v = str2double(app.EPercent.Value);
        if ~isfinite(v), return; end
        app.smooth_win = max(0.01, min(0.99, v/100));
        app.prewhiten_win = app.xrange * app.smooth_win;
        updateWindowControls();
        updateTrendFigure();
    end

    function onSlider()
        app.smooth_win = max(0.01, min(0.99, app.SSlider.Value));
        app.prewhiten_win = app.xrange * app.smooth_win;
        updateWindowControls();
        updateTrendFigure();
    end

    function onBest()
        try
            t = app.current_data(:,1);
            y = app.current_data(:,2);
            [bestSpan,~,~] = smoothbestSpanRand(t,y,'lowess',100,1);
            app.smooth_win = max(0.01,min(0.99,bestSpan));
            app.prewhiten_win = app.xrange * app.smooth_win;
            updateWindowControls();
            updateTrendFigure();
        catch ME
            uialert(app.UIFigure,ME.message,'Acycle: detrending');
        end
    end

    function onPolyNChanged()
        p = str2double(app.EPolyN.Value);
        if ~isfinite(p) || p < 3
            p = 3;
            app.EPolyN.Value = '3';
        end
        app.poly_order = round(p);
        updateTrendFigure();
    end

    function onSelectAll()
        if app.CAll.Value
            app.CLowess.Value = true;
            app.CRlowess.Value = true;
            app.CLoess.Value = true;
            app.CRloess.Value = true;
            app.CEMD.Value = true;
            app.CMean.Value = true;
            app.CLinear.Value = true;
            app.CPoly2.Value = true;
            app.CPolyN.Value = true;
        end
        updateTrendFigure();
    end

    function onClearAll()
        app.CAll.Value = false;
        app.CLowess.Value = false;
        app.CRlowess.Value = false;
        app.CLoess.Value = false;
        app.CRloess.Value = false;
        app.CEMD.Value = false;
        app.CMean.Value = false;
        app.CLinear.Value = false;
        app.CPoly2.Value = false;
        app.CPolyN.Value = false;
        updateTrendFigure();
    end

    function onPlot()
        npts = size(app.current_data,1);
        if npts > 2000
            warndlg('Large dataset, wait ...');
        end
        if isempty(app.trendFig) || ~isgraphics(app.trendFig)
            app.trendFig = figure('Color','white');
        else
            figure(app.trendFig);
        end
        updateTrendFigure();
    end

    function updateWindowControls()
        app.EWindow.Value = num2str(app.prewhiten_win);
        app.EPercent.Value = num2str(app.smooth_win*100);
        app.SSlider.Value = app.smooth_win;
    end

    function onKeyPress(evt)
        key = '';
        mods = {};
        try
            key = evt.Key;
        catch
        end
        try
            mods = evt.Modifier;
        catch
        end
        if isstring(key), key = char(key); end
        if isempty(key) || ~strcmpi(key,'w')
            return
        end
        if any(strcmpi(mods,'control')) || any(strcmpi(mods,'command'))
            if isgraphics(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end

    function updateTrendFigure()
        datax = app.current_data(:,1);
        datay = app.current_data(:,2);
        npts = numel(datax);
        win = app.smooth_win * (max(datax)-min(datax));
        if isempty(app.trendFig) || ~isgraphics(app.trendFig)
            app.trendFig = figure('Color','white');
        else
            figure(app.trendFig);
            clf(app.trendFig);
        end

        plot(datax,datay,'-k'); hold on;
        axis([min(datax),max(datax),min(datay),max(datay)]);

        names = {langText('Fitting14','Raw')};
        detr = struct();

        datamean = zeros(npts,1); datalinear = zeros(npts,1); data2nd = zeros(npts,1);
        datamore = zeros(npts,1); datalowess = zeros(npts,1); datarlowess = zeros(npts,1);
        dataloess = zeros(npts,1); datarloess = zeros(npts,1); dataEMDres = zeros(npts,1);

        if app.CMean.Value
            m = nanmean(datay) * ones(npts,1);
            plot(datax,m,'-k','LineWidth',2.5);
            datamean = m;
            names{end+1} = langText('Fitting15','Mean'); %#ok<AGROW>
            detr.mean = datay - m;
            detr.meanTrend = m;
        end
        if app.CLinear.Value
            p = polyfit(datax,datay,1);
            l = datax*p(1)+p(2);
            plot(datax,l,'-y','LineWidth',2);
            datalinear = l;
            names{end+1} = langText('Fitting16','Linear'); %#ok<AGROW>
            detr.linear = datay - l;
            detr.linearTrend = l;
        end
        if app.CPoly2.Value
            p = polyfit(datax,datay,2);
            l = polyval(p,datax);
            plot(datax,l,':r','LineWidth',2);
            data2nd = l;
            names{end+1} = langText('Fitting17','2nd'); %#ok<AGROW>
            detr.poly2 = datay - l;
            detr.poly2Trend = l;
        end
        if app.CPolyN.Value
            p = polyfit(datax,datay,app.poly_order);
            l = polyval(p,datax);
            plot(datax,l,'b-.','LineWidth',2);
            datamore = l;
            names{end+1} = langText('Fitting18','3+order'); %#ok<AGROW>
            detr.polyN = datay - l;
            detr.polyNTrend = l;
        end
        if app.CLowess.Value
            l = smooth(datax,datay,app.smooth_win,'lowess');
            plot(datax,l,'-g','LineWidth',2);
            datalowess = l;
            names{end+1} = langText('Fitting22','LOWESS'); %#ok<AGROW>
            detr.lowess = datay - l;
            detr.lowessTrend = l;
        end
        if app.CRlowess.Value
            l = smooth(datax,datay,app.smooth_win,'rlowess');
            plot(datax,l,':b','LineWidth',2);
            datarlowess = l;
            names{end+1} = langText('Fitting19','rLOWESS'); %#ok<AGROW>
            detr.rlowess = datay - l;
            detr.rlowessTrend = l;
        end
        if app.CLoess.Value
            l = smooth(datax,datay,app.smooth_win,'loess');
            plot(datax,l,'--r','LineWidth',2);
            dataloess = l;
            names{end+1} = langText('Fitting20','LOESS'); %#ok<AGROW>
            detr.loess = datay - l;
            detr.loessTrend = l;
        end
        if app.CRloess.Value
            l = smooth(datax,datay,app.smooth_win,'rloess');
            plot(datax,l,'--m','LineWidth',2);
            datarloess = l;
            names{end+1} = langText('Fitting21','rLOESS'); %#ok<AGROW>
            detr.rloess = datay - l;
            detr.rloessTrend = l;
        end
        if app.CEMD.Value
            try
                [imfs,~,~] = emd(datay);
                [~, ncol] = size(imfs);
                imfs = eemd(datay',ncol+1,50,0.2);
                imfs = imfs';
                l = imfs(:,end);
                if numel(l) == npts
                    dataEMDres = l;
                    plot(datax,l,'-r','LineWidth',3);
                    names{end+1} = langText('Fitting25','EEMDres'); %#ok<AGROW>
                    detr.eemd = datay - l;
                    detr.eemdTrend = l;
                end
            catch
            end
        end

        if app.lang_choice == 0 || app.main_unit_selection == 0
            if app.unit_type == 0
                xlabel(['Unit (',app.unit,')']);
            elseif app.unit_type == 1
                xlabel(['Depth (',app.unit,')']);
            else
                xlabel(['Time (',app.unit,')']);
            end
            if numel(names) > 1
                title(['Raw data & ',num2str(win),'-',app.unit,' trend']);
            end
        else
            if app.unit_type == 0
                xlabel([langText('main34','Unit'),' (',app.unit,')']);
            elseif app.unit_type == 1
                xlabel([langText('main23','Depth'),' (',app.unit,')']);
            else
                xlabel([langText('main21','Time'),' (',app.unit,')']);
            end
            if numel(names) > 1
                title([langText('Fitting14','Raw'),' & ',num2str(win),'-',app.unit,' ',langText('Fitting23','trend')]);
            end
        end
        legend(names,'Location','best');
        set(gca,'XMinorTick','on','YMinorTick','on');
        hold off;

        app.prewhiten_data1 = [datax,datay,(datay-datalinear),datalinear,(datay-datamean),datamean];
        app.prewhiten_data2 = [(datay-datalowess),datalowess,(datay-datarlowess),datarlowess,...
                               (datay-dataloess),dataloess,(datay-datarloess),datarloess,...
                               (datay-data2nd),data2nd,(datay-datamore),datamore,...
                               (datay-dataEMDres),dataEMDres];
        app.modelItems = names;
        app.DModel.Items = names;
        app.DModel.Value = names{1};
    end

    function onModelSelect()
        str = app.DModel.Items;
        val = find(strcmp(str,app.DModel.Value),1,'first');
        if isempty(val), return; end
        current_data1 = app.prewhiten_data1(:,1);
        trend = zeros(size(current_data1));
        nametype = 0;
        prewhiten_s = '';

        switch str{val}
            case langText('Fitting14','Raw')
                current_data2 = app.prewhiten_data1(:,2);
                trend = zeros(size(current_data1));
                prewhiten_s = 'No_prewhiten';
                nametype = 0;
            case langText('Fitting22','LOWESS')
                current_data2 = app.prewhiten_data2(:,1); trend = app.prewhiten_data2(:,2); prewhiten_s='LOWESS'; nametype=1;
            case langText('Fitting19','rLOWESS')
                current_data2 = app.prewhiten_data2(:,3); trend = app.prewhiten_data2(:,4); prewhiten_s='rLOWESS'; nametype=1;
            case langText('Fitting20','LOESS')
                current_data2 = app.prewhiten_data2(:,5); trend = app.prewhiten_data2(:,6); prewhiten_s='LOESS'; nametype=1;
            case langText('Fitting21','rLOESS')
                current_data2 = app.prewhiten_data2(:,7); trend = app.prewhiten_data2(:,8); prewhiten_s='rLOESS'; nametype=1;
            case langText('Fitting15','Mean')
                current_data2 = app.prewhiten_data1(:,5); trend = app.prewhiten_data1(:,6); prewhiten_s='Mean'; nametype=2;
            case langText('Fitting16','Linear')
                current_data2 = app.prewhiten_data1(:,3); trend = app.prewhiten_data1(:,4); prewhiten_s='Linear'; nametype=3;
            case langText('Fitting17','2nd')
                current_data2 = app.prewhiten_data2(:,9); trend = app.prewhiten_data2(:,10); prewhiten_s='2nd'; nametype=3;
            case langText('Fitting18','3+order')
                current_data2 = app.prewhiten_data2(:,11); trend = app.prewhiten_data2(:,12); prewhiten_s='3+order'; nametype=3;
            case langText('Fitting25','EEMDres')
                current_data2 = app.prewhiten_data2(:,13); trend = app.prewhiten_data2(:,14); prewhiten_s='EEMDres'; nametype=3;
            otherwise
                return;
        end

        new_data = [current_data1,current_data2];
        current_trend = [current_data1,trend];
        [~,dat_name,ext] = fileparts(app.data_name);
        win = app.prewhiten_win;
        if nametype == 1
            name1 = [dat_name,'-',num2str(win),'-',prewhiten_s,ext];
            name2 = [dat_name,'-',num2str(win),'-',prewhiten_s,'trend',ext];
        elseif nametype == 2
            name1 = [dat_name,'-demean',ext];
            name2 = [dat_name,'-mean',ext];
        elseif nametype == 3
            name1 = [dat_name,'-',prewhiten_s,ext];
            name2 = [dat_name,'-',prewhiten_s,'trend',ext];
        else
            return;
        end
        
        saveDir = getAcPwdFromContext();
        pre = pwd;
        c = onCleanup(@()safeCd(pre)); 
        safeCd(saveDir);
        dlmwrite(name1,new_data,'delimiter',' ','precision',9);
        dlmwrite(name2,current_trend,'delimiter',' ','precision',9);
        refreshMainListbox(saveDir);
        disp('>>  AC main window: see trend and detrended data');
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

    function refreshMainListbox(dirpath)
        if isempty(app.listbox_acmain) || ~isgraphics(app.listbox_acmain)
            return
        end
        if nargin < 1 || isempty(dirpath) || exist(dirpath,'dir') ~= 7
            dirpath = pwd;
        end
        try
            d = dir(dirpath);
            if numel(d) >= 2
                d = d(~ismember({d.name},{'.','..'}));
            end
            names = {};
            isDir = false(0,1);
            if ~isempty(d)
                sortMode = getSortMode();
                sd = ac_sort_dir_entries(d,sortMode);
                names = {sd.name};
                isDir = [sd.isdir];
            end
            if ~isempty(app.edit_acfigmain_dir) && isgraphics(app.edit_acfigmain_dir)
                set(app.edit_acfigmain_dir,'String',dirpath);
            end
            syncAcPwd(dirpath);
            if exist('ac_update_listbox_acmain','file') == 2
                ac_update_listbox_acmain(app.listbox_acmain,names,isDir);
            elseif isempty(names)
                set(app.listbox_acmain,'String',{},'Value',[]);
            else
                set(app.listbox_acmain,'String',names,'Value',1);
            end
            drawnow limitrate;
        catch
        end
    end

    function val1 = getSortMode()
        val1 = app.val1;
        try
            mainFig = ancestor(app.listbox_acmain,'figure');
            mainHandles = guidata(mainFig);
            if isstruct(mainHandles) && isfield(mainHandles,'val1') && ~isempty(mainHandles.val1)
                val1 = mainHandles.val1;
            end
        catch
        end
    end

    function syncAcPwd(dirpath)
        try
            acPwdFile = which('ac_pwd.txt');
            if isempty(acPwdFile)
                return
            end
            fid = fopen(acPwdFile,'w');
            if fid == -1
                return
            end
            fprintf(fid,'%s',dirpath);
            fclose(fid);
        catch
        end
    end

    function t = langText(key,fallback)
        t = fallback;
        if app.lang_choice == 0 || isempty(app.lang_id) || isempty(app.lang_var)
            return;
        end
        [tf,idx] = ismember(key,app.lang_id);
        if tf && idx > 0 && idx <= numel(app.lang_var)
            v = app.lang_var{idx};
            if ischar(v) || isstring(v)
                t = char(v);
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

function v = getFieldDefault(s,name,default)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
end
end
