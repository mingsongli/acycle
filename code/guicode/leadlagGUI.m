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
        app.val1 = getFieldDefault(ctx,'val1',4);
        app.monzoom = getFieldDefault(ctx,'MonZoom',1);
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});

        app.pathRef = '';
        app.pathTarget = '';

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

        app.LTarget = uilabel(app.PanelFiles,'Text', ...
            langText(app,'leadlag_target','Target'),'BackgroundColor',app.bg);
        app.BOpenTarget = uibutton(app.PanelFiles,'push','Text',openTxt, ...
            'ButtonPushedFcn',@(~,~)pickTarget());
        app.ETarget = uieditfield(app.PanelFiles,'text','Editable','off');

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
            % Empty fields cannot accidentally treat the working directory
            % itself as a data file.
            app.ERef.Value = '';
            app.ETarget.Value = '';
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

            app.LTarget.Position = [round(0.015*pw) round(0.28*ph) round(0.23*pw) round(0.12*ph)];
            app.BOpenTarget.Position = [round(0.015*pw) round(0.03*ph) round(0.10*pw) round(0.20*ph)];
            app.ETarget.Position = [round(0.125*pw) round(0.02*ph) round(0.86*pw) round(0.22*ph)];

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
            [file,path] = uigetfile({'*.*','All Files (*.*)'}, ...
                'Select a Reference Series',getAcPwdFromContext());
            if ~isequal(file,0)
                selectedPath = fullfile(path,file);
                try
                    localLoadStrictSeries(selectedPath,'REFERENCE');
                    app.pathRef = selectedPath;
                    app.ERef.Value = selectedPath;
                catch ME
                    uialert(app.UIFigure,ME.message, ...
                        'Acycle: invalid reference');
                end
            end
        end

        function pickTarget()
            [file,path] = uigetfile({'*.*','All Files (*.*)'}, ...
                'Select a Target Series',getAcPwdFromContext());
            if ~isequal(file,0)
                selectedPath = fullfile(path,file);
                try
                    targetData = localLoadStrictSeries( ...
                        selectedPath,'TARGET');
                    app.pathTarget = selectedPath;
                    app.ETarget.Value = selectedPath;
                    updateDefaultLimitAndStep(targetData);
                catch ME
                    uialert(app.UIFigure,ME.message, ...
                        'Acycle: invalid target');
                end
            end
        end

        function updateDefaultLimitAndStep(targetData)
            coordinateSpan = targetData(end,1)-targetData(1,1);
            st = mean(diff(targetData(:,1)))/2;
            ll = max(coordinateSpan/10,st);
            app.ELimit.Value = num2str(ll,17);
            app.EStep.Value = num2str(st,17);
        end

        function runLeadlag()
            pre = pwd;
            directoryCleanup = onCleanup(@()restoreDirectory(pre));
            createdFigures = gobjects(0,1);
            try
                p1 = strtrim(app.ERef.Value);
                p2 = strtrim(app.ETarget.Value);
                if isempty(p1) || isempty(p2)
                    error('Acycle:LeadLagGUI:EmptyPath', ...
                        'Reference and Target paths are both required.');
                end

                reference = localLoadStrictSeries(p1,'REFERENCE');
                target = localLoadStrictSeries(p2,'TARGET');
                maximumLag = str2double(app.ELimit.Value);
                lagStep = str2double(app.EStep.Value);
                if strcmp(app.DDir.Value,'Small = Young')
                    coordinateDirection = 'small_is_young';
                else
                    coordinateDirection = 'small_is_old';
                end

                [result,meta] = acycleLeadLagRmse( ...
                    reference,target,maximumLag,lagStep, ...
                    coordinateDirection);
                createdFigures = plotLeadLagResult( ...
                    reference,target,result,meta);

                if app.CSave.Value
                    workDir = getAcPwdFromContext();
                    [~,name1,~] = fileparts(p1);
                    [~,name2,~] = fileparts(p2);
                    outName = [name2,'-LeadLagRMSE-',name1,'.txt'];
                    saveLeadLagResult(result,fullfile(workDir,outName));
                    refreshMainListbox(workDir);
                end
            catch ME
                deleteGraphics(createdFigures);
                uialert(app.UIFigure,ME.message,'Acycle: lead/lag');
            end
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

        function refreshMainListbox(workDir)
            if ac_refresh_main_list(app.listbox_acmain,workDir)
                return
            end
            if ~isempty(app.listbox_acmain) && isgraphics(app.listbox_acmain)
                d = dir(workDir);
                d = d(~ismember({d.name},{'.','..'}));
                sortMode = app.val1;
                try
                    mainHandles = guidata(app.listbox_acmain);
                    if isstruct(mainHandles) && isfield(mainHandles,'val1') && ...
                            ~isempty(mainHandles.val1)
                        sortMode = mainHandles.val1;
                    end
                catch
                end
                d = ac_sort_dir_entries(d,sortMode);
                ac_update_listbox_acmain(app.listbox_acmain, ...
                    {d.name},[d.isdir]);
                if ~isempty(app.edit_acfigmain_dir) && ...
                        isgraphics(app.edit_acfigmain_dir)
                    set(app.edit_acfigmain_dir,'String',workDir);
                end
                ac_working_directory('set',workDir);
                drawnow limitrate;
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

function data = localLoadStrictSeries(filename,label)
try
    data = load(filename);
catch loadException
    try
        data = readmatrix(filename);
    catch readException
        error('Acycle:LeadLagGUI:CannotReadFile', ...
            ['Cannot read %s file %s. LOAD reported: %s ', ...
             'READMATRIX reported: %s'], ...
            label,filename,loadException.message,readException.message);
    end
end
if ~((isa(data,'double') || isa(data,'single')) && ...
        ~issparse(data) && isreal(data) && ismatrix(data) && ...
        size(data,2) == 2)
    error('Acycle:LeadLagGUI:InvalidData', ...
        ['%s file must contain exactly two real floating-point columns ', ...
         '[coordinate,value]: %s'],label,filename);
end
if size(data,1) < 3
    error('Acycle:LeadLagGUI:TooFewRows', ...
        '%s file must contain at least three rows: %s',label,filename);
end
if any(~isfinite(data(:)))
    error('Acycle:LeadLagGUI:NonfiniteData', ...
        '%s file contains NaN or Inf; rows are not silently deleted: %s', ...
        label,filename);
end
data = full(double(data));
spacing = diff(data(:,1));
if any(~isfinite(spacing)) || ...
        ~(isfinite(data(end,1)-data(1,1)) && data(end,1) > data(1,1))
    error('Acycle:LeadLagGUI:UnrepresentableCoordinates', ...
        '%s coordinate span or spacing is not finite: %s',label,filename);
end
if any(spacing <= 0)
    error('Acycle:LeadLagGUI:CoordinatesNotStrictlyIncreasing', ...
        ['%s coordinates must already be unique and strictly increasing; ', ...
         'the GUI does not sort or merge rows: %s'],label,filename);
end
standardizeForDisplay(data(:,2),label);
end

function figures = plotLeadLagResult(reference,target,result,meta)
figures = gobjects(0,1);
try
    firstFigure = figure( ...
        'Color','white','Name','Acycle: Lead-lag standardized RMSE', ...
        'NumberTitle','off');
    figures(end+1,1) = firstFigure;
    firstAxes = axes('Parent',firstFigure);
    plot(firstAxes,result(:,1),result(:,2),'k.-');
    hold(firstAxes,'on');
    yLimits = ylim(firstAxes);
    plot(firstAxes,[meta.best_lag meta.best_lag],yLimits,'r-.');
    hold(firstAxes,'off');
    xlabel(firstAxes,'Target coordinate shift (lag)');
    ylabel(firstAxes,'Standardized RMSE');
    title(firstAxes,sprintf( ...
        'Minimum @ %.9g. %s.',meta.best_lag, ...
        relationshipLabel(meta.best_lag_interpretation)));

    secondFigure = figure( ...
        'Color','white','Name','Acycle: Lead-lag alignment', ...
        'NumberTitle','off');
    figures(end+1,1) = secondFigure;
    referenceStandardized = standardizeForDisplay( ...
        reference(:,2),'REFERENCE');
    targetStandardized = standardizeForDisplay(target(:,2),'TARGET');

    referenceAxes = subplot(3,1,1,'Parent',secondFigure);
    plot(referenceAxes,reference(:,1),reference(:,2),'b-');
    title(referenceAxes,'Reference');

    targetAxes = subplot(3,1,2,'Parent',secondFigure);
    plot(targetAxes,target(:,1),target(:,2),'k-');
    hold(targetAxes,'on');
    if meta.best_lag ~= 0
        plot(targetAxes,target(:,1)+meta.best_lag,target(:,2),'r-.');
        legend(targetAxes,{'Raw Target','Adjusted Target'}, ...
            'Location','best');
    end
    hold(targetAxes,'off');
    title(targetAxes,'Target');

    alignmentAxes = subplot(3,1,3,'Parent',secondFigure);
    plot(alignmentAxes,reference(:,1),referenceStandardized,'b-');
    hold(alignmentAxes,'on');
    plot(alignmentAxes,target(:,1),targetStandardized,'k-');
    if meta.best_lag ~= 0
        plot(alignmentAxes,target(:,1)+meta.best_lag, ...
            targetStandardized,'r-.');
        legend(alignmentAxes, ...
            {'Reference','Raw Target','Adjusted Target'}, ...
            'Location','best');
    else
        legend(alignmentAxes,{'Reference','Target'},'Location','best');
    end
    hold(alignmentAxes,'off');
    xlabel(alignmentAxes,'Depth/Time');
    ylabel(alignmentAxes,'Whole-record standardized value');
catch ME
    deleteGraphics(figures);
    rethrow(ME);
end
end

function standardized = standardizeForDisplay(values,label)
valueScale = max(abs(values));
if valueScale == 0
    error('Acycle:LeadLagGUI:ConstantSeries', ...
        '%s value column is constant.',label);
end
scaled = values/valueScale;
centered = scaled-mean(scaled);
sampleStandardDeviation = std(centered,0);
if ~(isfinite(sampleStandardDeviation) && sampleStandardDeviation > 0)
    error('Acycle:LeadLagGUI:ConstantSeries', ...
        '%s value column has no representable nonzero variance.',label);
end
standardized = centered/sampleStandardDeviation;
if any(~isfinite(standardized))
    error('Acycle:LeadLagGUI:NonfiniteStandardization', ...
        '%s standardization produced a nonfinite value.',label);
end
end

function label = relationshipLabel(identifier)
switch identifier
    case 'target_leads_reference'
        label = 'Target leads Reference';
    case 'target_lags_reference'
        label = 'Target lags Reference';
    otherwise
        label = 'Target is in phase with Reference';
end
end

function saveLeadLagResult(result,outputPath)
outputDirectory = fileparts(outputPath);
if exist(outputDirectory,'dir') ~= 7
    error('Acycle:LeadLagGUI:MissingOutputDirectory', ...
        'Output directory does not exist: %s',outputDirectory);
end
temporaryPath = [tempname(outputDirectory),'.txt'];
temporaryCleanup = onCleanup(@()deleteFileIfPresent(temporaryPath));
writematrix(result,temporaryPath,'Delimiter','space');
[moved,message] = movefile(temporaryPath,outputPath,'f');
if ~moved
    error('Acycle:LeadLagGUI:SaveFailed', ...
        'Cannot save Lead-lag result: %s',message);
end
end

function deleteFileIfPresent(filename)
if exist(filename,'file') == 2
    delete(filename);
end
end

function deleteGraphics(handles)
if isempty(handles)
    return
end
handles = handles(isgraphics(handles));
if ~isempty(handles)
    delete(handles);
end
end

function restoreDirectory(originalDirectory)
if strcmp(pwd,originalDirectory)
    return
end
try
    cd(originalDirectory);
catch ME
    warning('Acycle:LeadLagGUI:DirectoryRestoreFailed', ...
        'Cannot restore working directory: %s',ME.message);
end
end
