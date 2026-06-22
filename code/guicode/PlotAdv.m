function varargout = PlotAdv(varargin)
% App Designer-style migration of PlotAdv (single-file).

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

        app.plot_s = getFieldDefault(ctx,'plot_s',{});
        app.nplot = getFieldDefault(ctx,'nplot',numel(app.plot_s));
        app.unit = getFieldDefault(ctx,'unit','unit');
        app.lang_choice = getFieldDefault(ctx,'lang_choice',0);
        app.lang_id = getFieldDefault(ctx,'lang_id',{});
        app.lang_var = getFieldDefault(ctx,'lang_var',{});

        if isempty(app.plot_s)
            app.plot_s = {'data.txt'};
            app.nplot = 1;
        end

        titleTxt = ['Acycle: ',langText(app,'menu03','Plot'),' ',langText(app,'pltadv1','Advance')];
        app.UIFigure = uifigure('Name',titleTxt,'Color',app.bg, ...
            'Position',[120 80 716 404],'AutoResizeChildren','off');
        app.UIFigure.SizeChangedFcn = @layoutUI;
        app.UIFigure.WindowKeyPressFcn = @onFigureKeyPress;
        app.UIFigure.WindowKeyReleaseFcn = @onFigureKeyPress;

        % data
        app.LData = uilabel(app.UIFigure,'Text',langText(app,'main02','Data'),'BackgroundColor',app.bg);
        app.DropData = uidropdown(app.UIFigure,'Items',{},'ValueChangedFcn',@onDataChanged);

        % plot type
        app.LType = uilabel(app.UIFigure,'Text',langText(app,'pltadv2','Plot Type'),'BackgroundColor',app.bg);
        app.DropType = uidropdown(app.UIFigure,'Items',{'Line','Stairs','Bar','Stem','Area'}, ...
            'Value','Line','ValueChangedFcn',@onTypeChanged);
        app.CkBase = uicheckbox(app.UIFigure,'Text',langText(app,'pltadv16','Base value'), ...
            'Value',false,'ValueChangedFcn',@onBaseCheckChanged);
        app.EBase = uieditfield(app.UIFigure,'text','Value','0.5','ValueChangedFcn',@onBaseEditChanged);

        % line row
        app.LLine = uilabel(app.UIFigure,'Text',langText(app,'pltadv3','Line'),'BackgroundColor',app.bg);
        app.DropLineStyle = uidropdown(app.UIFigure,'Items',{'-','--',':','-.','none'},'Value','-', ...
            'ValueChangedFcn',@onStyleChanged);
        app.DropLineSize = uidropdown(app.UIFigure,'Items',compose('%.1f',1:0.5:10), ...
            'Value','1.0','ValueChangedFcn',@onStyleChanged);
        app.LColor = uilabel(app.UIFigure,'Text',langText(app,'pltadv4','Color'),'BackgroundColor',app.bg);
        app.BLineColor = uibutton(app.UIFigure,'push','Text','','BackgroundColor',[0 0 0],'ButtonPushedFcn',@onLineColor);
        app.CkLegend = uicheckbox(app.UIFigure,'Text','Show legend','Value',true, ...
            'ValueChangedFcn',@onLegendToggle);

        % marker/bar row
        app.LMarker = uilabel(app.UIFigure,'Text',langText(app,'pltadv5','Marker'),'BackgroundColor',app.bg);
        app.DropMarkerStyle = uidropdown(app.UIFigure,'Items',{'none','+','o','*','.','x','s','d','^','v','>','<','p','h'}, ...
            'Value','none','ValueChangedFcn',@onStyleChanged);
        app.DropMarkerSize = uidropdown(app.UIFigure,'Items',compose('%.1f',1:0.5:10), ...
            'Value','6.0','ValueChangedFcn',@onStyleChanged);

        app.BFace = uibutton(app.UIFigure,'push','Text',langText(app,'pltadv6','Face'), ...
            'BackgroundColor',app.blue,'FontColor','white','ButtonPushedFcn',@onFaceToggle);
        app.BMarkerFaceColor = uibutton(app.UIFigure,'push','Text','','BackgroundColor',[0 0 0],'ButtonPushedFcn',@onFaceColor);
        app.BEdge = uibutton(app.UIFigure,'push','Text',langText(app,'pltadv8','None'), ...
            'BackgroundColor',app.blue,'FontColor','white','ButtonPushedFcn',@onEdgeToggle);
        app.BMarkerEdgeColor = uibutton(app.UIFigure,'push','Text','','BackgroundColor',[0 0 0],'ButtonPushedFcn',@onEdgeColor);

        % axis row
        app.LAxis = uilabel(app.UIFigure,'Text',langText(app,'pltadv9','Axis'),'BackgroundColor',app.bg);
        app.BAxis = uibutton(app.UIFigure,'push','Text','X','BackgroundColor',app.blue,'FontColor','white','FontWeight','bold', ...
            'ButtonPushedFcn',@onAxisToggle);
        app.EAxisStart = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@onAxisEdit);
        app.EAxisEnd = uieditfield(app.UIFigure,'text','Value','0','ValueChangedFcn',@onAxisEdit);
        app.BAxisScale = uibutton(app.UIFigure,'push','Text',langText(app,'pltadv10','Linear'),'BackgroundColor',app.blue,'FontColor','white', ...
            'ButtonPushedFcn',@onAxisScaleToggle);
        app.BAxisFlip = uibutton(app.UIFigure,'push','Text',langText(app,'pltadv12','Normal'),'BackgroundColor',app.blue,'FontColor','white', ...
            'ButtonPushedFcn',@onAxisFlipToggle);
        app.BSwap = uibutton(app.UIFigure,'push','Text','--','BackgroundColor',app.blue,'FontColor','white', ...
            'ButtonPushedFcn',@onSwapToggle);

        % labels row
        app.LXLabel = uilabel(app.UIFigure,'Text',['X ',langText(app,'plt18','label')],'BackgroundColor',app.bg);
        app.LYLabel = uilabel(app.UIFigure,'Text',['Y ',langText(app,'plt18','label')],'BackgroundColor',app.bg);
        app.LTitle = uilabel(app.UIFigure,'Text',langText(app,'plt07','Title'),'BackgroundColor',app.bg);
        app.EXLabel = uieditfield(app.UIFigure,'text','Value',app.unit,'ValueChangedFcn',@onTextChanged);
        app.EYLabel = uieditfield(app.UIFigure,'text','Value','value','ValueChangedFcn',@onTextChanged);
        app.ETwitter = uieditfield(app.UIFigure,'text','Value','','ValueChangedFcn',@onTextChanged);

        app.BPlot = uibutton(app.UIFigure,'push','Text',langText(app,'menu03','Plot'),'BackgroundColor',app.blue, ...
            'FontColor','white','FontWeight','bold','ButtonPushedFcn',@onPlot);

        % model/state
        [app.dataList, app.dataNames, app.seriesTitles, app.axisInit] = loadAllSeries(app.plot_s);
        app.styles = repmat(defaultStyle(), app.nplot, 1);
        colorSeq = [1 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 1; 1 1 0];
        for i = 1:app.nplot
            if i == 1
                c = [0 0 0];
            elseif i-1 <= size(colorSeq,1)
                c = colorSeq(i-1,:);
            else
                c = rand(1,3);
            end
            app.styles(i).lineColor = c;
            app.styles(i).markerFaceColor = c;
            app.styles(i).markerEdgeColor = c;
        end
        app.axisState = struct('xStart',app.axisInit(1),'xEnd',app.axisInit(2),'xLinear',true, ...
            'yStart',app.axisInit(3),'yEnd',app.axisInit(4),'yLinear',true,'selectX',true, ...
            'flipX',false,'flipY',false,'swap',false);
        app.basevalue_check = false;
        app.basevalue = app.axisState.yStart;
        app.current = 1;
        app.previewFig = [];

        if isempty(app.dataNames)
            app.dataNames = {'data.txt'};
            app.seriesTitles = {'data'};
            app.ETwitter.Value = 'data';
        else
            app.ETwitter.Value = app.seriesTitles{1};
        end
        app.DropData.Items = app.dataNames;
        app.DropData.Value = app.dataNames{1};

        syncStyleToUI();
        layoutUI();
        updateTypeUI();
        syncAxisUI();

        function layoutUI(~,~)
            w = app.UIFigure.Position(3); h = app.UIFigure.Position(4);
            place(app.LData,[0.031,0.88,0.16,0.08],w,h);
            place(app.DropData,[0.179,0.88,0.8,0.08],w,h);

            place(app.LType,[0.031,0.737,0.16,0.08],w,h);
            place(app.DropType,[0.179,0.737,0.312,0.08],w,h);
            place(app.CkBase,[0.522,0.737,0.188,0.08],w,h);
            place(app.EBase,[0.717,0.737,0.155,0.08],w,h);

            place(app.LLine,[0.031,0.59,0.16,0.08],w,h);
            place(app.DropLineStyle,[0.179,0.59,0.312,0.08],w,h);
            place(app.DropLineSize,[0.493,0.59,0.186,0.08],w,h);
            place(app.LColor,[0.681,0.59,0.08,0.08],w,h);
            place(app.BLineColor,[0.772,0.59,0.055,0.08],w,h);
            place(app.CkLegend,[0.84,0.59,0.15,0.08],w,h);

            place(app.LMarker,[0.031,0.42,0.16,0.08],w,h);
            place(app.DropMarkerStyle,[0.179,0.42,0.312,0.08],w,h);
            place(app.DropMarkerSize,[0.493,0.42,0.186,0.08],w,h);
            place(app.BFace,[0.681,0.42,0.084,0.08],w,h);
            place(app.BMarkerFaceColor,[0.772,0.42,0.055,0.08],w,h);
            place(app.BEdge,[0.841,0.42,0.084,0.08],w,h);
            place(app.BMarkerEdgeColor,[0.929,0.42,0.055,0.08],w,h);

            place(app.LAxis,[0.031,0.271,0.16,0.088],w,h);
            place(app.BAxis,[0.195,0.271,0.095,0.088],w,h);
            place(app.EAxisStart,[0.319,0.271,0.155,0.088],w,h);
            place(app.EAxisEnd,[0.496,0.271,0.155,0.088],w,h);
            place(app.BAxisScale,[0.677,0.271,0.095,0.088],w,h);
            place(app.BAxisFlip,[0.779,0.271,0.122,0.088],w,h);
            place(app.BSwap,[0.907,0.271,0.084,0.088],w,h);

            place(app.LXLabel,[0.03,0.14,0.15,0.088],w,h);
            place(app.EXLabel,[0.03,0.05,0.15,0.088],w,h);
            place(app.LYLabel,[0.19,0.14,0.15,0.088],w,h);
            place(app.EYLabel,[0.19,0.05,0.15,0.088],w,h);
            place(app.LTitle,[0.35,0.14,0.45,0.088],w,h);
            place(app.ETwitter,[0.35,0.05,0.45,0.088],w,h);
            place(app.BPlot,[0.82,0.056,0.15,0.143],w,h);
        end

        function onDataChanged(~,~)
            saveUIToStyle(app.current);
            idx = find(strcmp(app.DropData.Value,app.dataNames),1,'first');
            if isempty(idx), idx = 1; end
            app.current = idx;
            syncStyleToUI();
            updateTypeUI();
            refreshPreview();
        end

        function onTypeChanged(~,~)
            saveUIToStyle(app.current);
            updateTypeUI();
            refreshPreview();
        end

        function onStyleChanged(~,~)
            saveUIToStyle(app.current);
            refreshPreview();
        end

        function onLegendToggle(~,~)
            refreshPreview();
        end

        function onLineColor(~,~)
            c = uisetcolor(app.BLineColor.BackgroundColor,langText(app,'pltadv28','Choose color'));
            if isnumeric(c) && numel(c)==3
                app.BLineColor.BackgroundColor = c;
                saveUIToStyle(app.current);
                refreshPreview();
            end
        end

        function onFaceColor(~,~)
            c = uisetcolor(app.BMarkerFaceColor.BackgroundColor,langText(app,'pltadv28','Choose color'));
            if isnumeric(c) && numel(c)==3
                app.BMarkerFaceColor.BackgroundColor = c;
                saveUIToStyle(app.current);
                refreshPreview();
            end
        end

        function onEdgeColor(~,~)
            c = uisetcolor(app.BMarkerEdgeColor.BackgroundColor,langText(app,'pltadv28','Choose color'));
            if isnumeric(c) && numel(c)==3
                app.BMarkerEdgeColor.BackgroundColor = c;
                saveUIToStyle(app.current);
                refreshPreview();
            end
        end

        function onFaceToggle(~,~)
            st = app.styles(app.current);
            st.showFace = ~st.showFace;
            app.styles(app.current) = st;
            syncStyleToUI();
            updateTypeUI();
            refreshPreview();
        end

        function onEdgeToggle(~,~)
            st = app.styles(app.current);
            st.showEdge = ~st.showEdge;
            app.styles(app.current) = st;
            syncStyleToUI();
            updateTypeUI();
            refreshPreview();
        end

        function onAxisToggle(~,~)
            app.axisState.selectX = ~app.axisState.selectX;
            syncAxisUI();
            refreshPreview();
        end

        function onAxisEdit(~,~)
            v1 = str2double(app.EAxisStart.Value);
            v2 = str2double(app.EAxisEnd.Value);
            if ~isfinite(v1) || ~isfinite(v2)
                return
            end
            if app.axisState.selectX
                app.axisState.xStart = v1; app.axisState.xEnd = v2;
            else
                app.axisState.yStart = v1; app.axisState.yEnd = v2;
            end
            refreshPreview();
        end

        function onAxisScaleToggle(~,~)
            if app.axisState.selectX
                app.axisState.xLinear = ~app.axisState.xLinear;
            else
                app.axisState.yLinear = ~app.axisState.yLinear;
            end
            syncAxisUI();
            refreshPreview();
        end

        function onAxisFlipToggle(~,~)
            if app.axisState.selectX
                app.axisState.flipX = ~app.axisState.flipX;
            else
                app.axisState.flipY = ~app.axisState.flipY;
            end
            syncAxisUI();
            refreshPreview();
        end

        function onSwapToggle(~,~)
            app.axisState.swap = ~app.axisState.swap;
            if app.axisState.swap
                app.BSwap.Text = langText(app,'pltadv14','Swap');
            else
                app.BSwap.Text = '--';
            end
            refreshPreview();
        end

        function onBaseCheckChanged(~,~)
            app.basevalue_check = app.CkBase.Value;
            refreshPreview();
        end

        function onBaseEditChanged(~,~)
            v = str2double(app.EBase.Value);
            if isfinite(v)
                app.basevalue = v;
            end
            refreshPreview();
        end

        function onTextChanged(~,~)
            refreshPreview();
        end

        function syncAxisUI()
            if app.axisState.selectX
                app.BAxis.Text = 'X';
                app.EAxisStart.Value = num2str(app.axisState.xStart,'%.10g');
                app.EAxisEnd.Value = num2str(app.axisState.xEnd,'%.10g');
                app.BAxisScale.Text = iff(app.axisState.xLinear,langText(app,'pltadv10','Linear'),langText(app,'pltadv11','Log'));
                app.BAxisFlip.Text = iff(~app.axisState.flipX,langText(app,'pltadv12','Normal'),langText(app,'pltadv13','Reverse'));
            else
                app.BAxis.Text = 'Y';
                app.EAxisStart.Value = num2str(app.axisState.yStart,'%.10g');
                app.EAxisEnd.Value = num2str(app.axisState.yEnd,'%.10g');
                app.BAxisScale.Text = iff(app.axisState.yLinear,langText(app,'pltadv10','Linear'),langText(app,'pltadv11','Log'));
                app.BAxisFlip.Text = iff(~app.axisState.flipY,langText(app,'pltadv12','Normal'),langText(app,'pltadv13','Reverse'));
            end
        end

        function syncStyleToUI()
            st = app.styles(app.current);
            app.DropType.Value = typeName(st.typeIdx);
            app.DropLineStyle.Value = st.lineStyle;
            app.DropLineSize.Value = sprintf('%.1f',st.lineWidth);
            app.BLineColor.BackgroundColor = st.lineColor;
            app.DropMarkerStyle.Value = st.markerStyle;
            app.DropMarkerSize.Value = sprintf('%.1f',st.markerSize);
            app.BMarkerFaceColor.BackgroundColor = st.markerFaceColor;
            app.BMarkerEdgeColor.BackgroundColor = st.markerEdgeColor;
            app.BFace.Text = iff(st.showFace,langText(app,'pltadv6','Face'),langText(app,'pltadv8','None'));
            app.BEdge.Text = iff(st.showEdge,langText(app,'pltadv7','Edge'),langText(app,'pltadv8','None'));
        end

        function saveUIToStyle(i)
            st = app.styles(i);
            st.typeIdx = typeIdx(app.DropType.Value);
            st.lineStyle = app.DropLineStyle.Value;
            st.lineWidth = str2double(app.DropLineSize.Value);
            st.lineColor = app.BLineColor.BackgroundColor;
            st.markerStyle = app.DropMarkerStyle.Value;
            st.markerSize = str2double(app.DropMarkerSize.Value);
            st.markerFaceColor = app.BMarkerFaceColor.BackgroundColor;
            st.markerEdgeColor = app.BMarkerEdgeColor.BackgroundColor;
            st.showFace = strcmp(app.BFace.Text,langText(app,'pltadv6','Face'));
            st.showEdge = strcmp(app.BEdge.Text,langText(app,'pltadv7','Edge'));
            app.styles(i) = st;
        end

        function updateTypeUI()
            st = app.styles(app.current);
            t = st.typeIdx;

            if t == 3 % Bar
                app.LMarker.Text = 'Bar';
                app.DropMarkerStyle.Visible = 'off';
                app.DropMarkerSize.Visible = 'off';
                app.BLineColor.Visible = 'off';
                app.CkBase.Text = langText(app,'pltadv15','Width');
                if ~app.basevalue_check
                    app.EBase.Value = '0.5';
                end
            else
                app.LMarker.Text = langText(app,'pltadv5','Marker');
                app.DropMarkerStyle.Visible = 'on';
                app.DropMarkerSize.Visible = 'on';
                app.BLineColor.Visible = 'on';
                app.CkBase.Text = langText(app,'pltadv16','Base value');
            end

            if t == 5 % Area
                app.EBase.Value = num2str(app.axisState.yStart,'%.10g');
                app.DropLineSize.Enable = 'off';
                app.DropMarkerStyle.Enable = 'off';
                app.DropMarkerSize.Enable = 'off';
                app.BFace.Enable = 'off';
                app.BMarkerFaceColor.Enable = 'off';
                app.BEdge.Enable = 'off';
                app.BMarkerEdgeColor.Enable = 'off';
            else
                app.DropLineSize.Enable = 'on';
                app.DropMarkerStyle.Enable = 'on';
                app.DropMarkerSize.Enable = 'on';
                app.BFace.Enable = 'on';
                app.BMarkerFaceColor.Enable = 'on';
                app.BEdge.Enable = 'on';
                app.BMarkerEdgeColor.Enable = 'on';
            end

            if any(t == [3 5])
                app.CkBase.Visible = 'on';
                app.EBase.Visible = 'on';
            else
                app.CkBase.Visible = 'off';
                app.EBase.Visible = 'off';
            end

            app.basevalue = str2double(app.EBase.Value);
            if ~isfinite(app.basevalue)
                app.basevalue = 0;
            end
        end

        function onPlot(~,~)
            saveUIToStyle(app.current);
            ensurePreviewFigure();
            figure(app.previewFig);
            clf(app.previewFig);
            fig = app.previewFig;
            fig.Color = 'w';
            fig.Name = 'Acycle: Plot Advance';
            drawPlotOnCurrentFigure();
        end

        function refreshPreview()
            ensurePreviewFigure();
            saveUIToStyle(app.current);
            figure(app.previewFig);
            clf(app.previewFig);
            drawPlotOnCurrentFigure();
        end

        function ensurePreviewFigure()
            if isempty(app.previewFig) || ~isgraphics(app.previewFig)
                app.previewFig = figure('Color','w','Name','Acycle: Plot Advance');
            end
        end

        function drawPlotOnCurrentFigure()
            hold on
            for i = 1:app.nplot
                dat = app.dataList{i};
                if isempty(dat), continue; end
                st = app.styles(i);
                lt = st.lineStyle;
                if strcmp(lt,'none'), lt = 'none'; end

                if st.typeIdx == 2
                    pp = stairs(dat(:,1),dat(:,2));
                elseif st.typeIdx == 1
                    pp = plot(dat(:,1),dat(:,2));
                elseif st.typeIdx == 4
                    pp = stem(dat(:,1),dat(:,2));
                elseif st.typeIdx == 3
                    if app.basevalue_check
                        pp = bar(dat(:,1),dat(:,2),app.basevalue);
                    else
                        pp = bar(dat(:,1),dat(:,2));
                    end
                    pp.LineStyle = lt;
                    pp.LineWidth = st.lineWidth;
                    if st.showFace
                        pp.FaceColor = st.markerFaceColor;
                    else
                        pp.FaceColor = 'none';
                    end
                    if st.showEdge
                        pp.EdgeColor = st.markerEdgeColor;
                    else
                        pp.EdgeColor = 'none';
                    end
                    continue
                else
                    if app.basevalue_check
                        pp = area(dat(:,1),dat(:,2),app.basevalue);
                    else
                        pp = area(dat(:,1),dat(:,2));
                    end
                    pp.FaceColor = st.lineColor;
                    pp.LineStyle = lt;
                    continue
                end

                pp.LineStyle = lt;
                pp.LineWidth = st.lineWidth;
                pp.Color = st.lineColor;
                pp.Marker = st.markerStyle;
                pp.MarkerSize = st.markerSize;
                if st.showFace
                    pp.MarkerFaceColor = st.markerFaceColor;
                else
                    pp.MarkerFaceColor = 'none';
                end
                if st.showEdge
                    pp.MarkerEdgeColor = st.markerEdgeColor;
                else
                    pp.MarkerEdgeColor = 'none';
                end
            end

            if app.axisState.xStart < app.axisState.xEnd
                xlim([app.axisState.xStart app.axisState.xEnd]);
            end
            if app.axisState.yStart < app.axisState.yEnd
                ylim([app.axisState.yStart app.axisState.yEnd]);
            end
            xlabel(app.EXLabel.Value); ylabel(app.EYLabel.Value); title(app.ETwitter.Value);
            set(gca,'XMinorTick','on','YMinorTick','on');
            set(gca,'XScale',iff(app.axisState.xLinear,'linear','log'));
            set(gca,'YScale',iff(app.axisState.yLinear,'linear','log'));
            set(gca,'XDir',iff(app.axisState.flipX,'reverse','normal'));
            set(gca,'YDir',iff(app.axisState.flipY,'reverse','normal'));
            if app.axisState.swap
                view([90 -90]);
            else
                view([0 90]);
            end
            set(groot,'DefaultLegendInterpreter','none');
            if app.CkLegend.Value
                legend(app.seriesTitles,'Location','best');
            else
                legend('off');
            end
            hold off
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
end

function [dataList, dataNames, seriesTitles, axisInit] = loadAllSeries(plot_s)
if isempty(plot_s)
    dataList = {[]};
    dataNames = {'data.txt'};
    seriesTitles = {'data'};
    axisInit = [0 1 0 1];
    return
end
n = numel(plot_s);
dataList = cell(n,1);
dataNames = cell(n,1);
seriesTitles = cell(n,1);
x1 = inf; x2 = -inf; y1 = inf; y2 = -inf;
for i = 1:n
    p = stripHtmlPath(plot_s{i});
    [~,nm,ext] = fileparts(p);
    dataNames{i} = [nm,ext];
    seriesTitles{i} = nm;
    dat = loadTwoCols(p);
    dataList{i} = dat;
    if ~isempty(dat)
        x1 = min(x1,min(dat(:,1))); x2 = max(x2,max(dat(:,1)));
        y1 = min(y1,min(dat(:,2))); y2 = max(y2,max(dat(:,2)));
    end
end
if ~isfinite(x1), x1 = 0; x2 = 1; y1 = 0; y2 = 1; end
axisInit = [x1 x2 y1 y2];
end

function s = defaultStyle()
s = struct('typeIdx',1,'lineStyle','-','lineWidth',1.0,'lineColor',[0 0 0], ...
    'markerStyle','none','markerSize',6.0,'markerFaceColor',[0 0 0], ...
    'showFace',true,'markerEdgeColor',[0 0 0],'showEdge',false);
end

function t = typeName(idx)
items = {'Line','Stairs','Bar','Stem','Area'};
idx = max(1,min(numel(items),idx));
t = items{idx};
end

function idx = typeIdx(name)
items = {'Line','Stairs','Bar','Stem','Area'};
idx = find(strcmpi(name,items),1,'first');
if isempty(idx), idx = 1; end
end

function dat = loadTwoCols(p)
dat = [];
if isempty(p)
    return
end
try
    dat = load(p);
catch
    try
        T = readtable(p,'VariableNamingRule','preserve');
        dat = table2array(T);
    catch
        try
            fid = fopen(p,'r');
            if fid >= 0
                c = onCleanup(@()fclose(fid)); %#ok<NASGU>
                tmp = textscan(fid,'%f%f','EmptyValue',Inf);
                dat = cell2mat(tmp);
            end
        catch
        end
    end
end
if isempty(dat)
    dat = [];
    return
end
if size(dat,2) >= 2
    dat = dat(:,1:2);
else
    dat = [(1:size(dat,1))', dat(:,1)];
end
dat = dat(~any(isnan(dat),2),:);
end

function p = stripHtmlPath(p)
if isstring(p), p = char(p); end
if ~ischar(p), p = ''; end
p = strrep(p,'<HTML><FONT color="blue">','');
p = strrep(p,'</FONT></HTML>','');
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
    v = app.lang_var{idx};
    if ischar(v) || isstring(v)
        txt = char(v);
    end
end
end

function out = iff(cond,a,b)
if cond
    out = a;
else
    out = b;
end
end

function v = getFieldDefault(s,name,default)
if isstruct(s) && isfield(s,name) && ~isempty(s.(name))
    v = s.(name);
else
    v = default;
end
end

function place(h,r,w,hgt)
if isempty(h) || ~isvalid(h), return; end
h.Position = [round(r(1)*w) round(r(2)*hgt) round(r(3)*w) round(r(4)*hgt)];
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
