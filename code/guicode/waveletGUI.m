function varargout = waveletGUI(varargin)
% WAVELETGUI Acycle wavelet GUI (code-only, GUIDE-free)

if nargin < 1 || ~isstruct(varargin{1})
    error('waveletGUI requires the AC handles/context struct as input.');
end
ctx = varargin{1};

handles = buildUI(ctx);
handles = initState(handles, ctx);
guidata(handles.waveletGUIfig, handles);

if nargout > 0
    varargout{1} = handles.waveletGUIfig;
end

if handles.lengthdata == 1
    wave_readGUI;
    wave_update_plots;
else
    wavecoh_readGUI;
    wavecoh_update_plots;
end
% The scripts above add the computed wavelet cache and result-figure handle
% to this local structure.  Reading GUIDATA here would restore the older
% pre-computation copy and make the first Save lose handles.figwave.
guidata(handles.waveletGUIfig, handles);

end

function handles = buildUI(ctx)
bg = get(0, 'DefaultUicontrolBackgroundColor');
handles.waveletGUIfig = figure('Name','Acycle: Wavelet', ...
    'Color', bg, ...
    'MenuBar','none', ...
    'Toolbar','none', ...
    'NumberTitle','off', ...
    'Units','normalized', ...
    'Position',[0.25,0.2,0.5,0.35] * ctx.MonZoom, ...
    'Tag','waveletGUIfig');
handles.waveletGUIfig.KeyPressFcn = @onKeyPressClose;
try
    handles.waveletGUIfig.WindowKeyPressFcn = @onKeyPressClose;
catch
end

% top
handles.text2 = uicontrol(handles.waveletGUIfig,'Style','text','Units','normalized','HorizontalAlignment','left','String','Series 1','Position',[0.02,0.85,0.1,0.06]);
handles.edit1 = uicontrol(handles.waveletGUIfig,'Style','edit','Units','normalized','HorizontalAlignment','left','BackgroundColor','w','Position',[0.13,0.85,0.65,0.06]);
handles.text3 = uicontrol(handles.waveletGUIfig,'Style','text','Units','normalized','HorizontalAlignment','left','String','Series 2','Position',[0.02,0.77,0.1,0.06]);
handles.edit2 = uicontrol(handles.waveletGUIfig,'Style','edit','Units','normalized','HorizontalAlignment','left','BackgroundColor','w','Position',[0.13,0.77,0.65,0.06]);
handles.pushbutton1 = uicontrol(handles.waveletGUIfig,'Style','pushbutton','Units','normalized','String','switch','Position',[0.79,0.77,0.2,0.06], ...
    'Callback',@pushbutton1_Callback);
handles.checkbox11 = uicontrol(handles.waveletGUIfig,'Style','checkbox','Units','normalized','String','standardize','Position',[0.79,0.86,0.12,0.06], ...
    'Callback',@(h,~)updateCommon(h,1));

% set period group
handles.uibuttongroup1 = uibuttongroup(handles.waveletGUIfig,'Units','normalized','Title','Set Period','Position',[0.02,0.4,0.46,0.35]);
handles.text4 = uicontrol(handles.uibuttongroup1,'Style','text','Units','normalized','String','Period Min','HorizontalAlignment','left','Position',[0.04,0.8,0.2,0.15]);
handles.edit3 = uicontrol(handles.uibuttongroup1,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.3,0.75,0.3,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.text5 = uicontrol(handles.uibuttongroup1,'Style','text','Units','normalized','String','Period Max','HorizontalAlignment','left','Position',[0.04,0.5,0.2,0.15]);
handles.edit4 = uicontrol(handles.uibuttongroup1,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.3,0.45,0.3,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.text6 = uicontrol(handles.uibuttongroup1,'Style','text','Units','normalized','String','Discrete scale spacing','HorizontalAlignment','left','Position',[0.04,0.15,0.4,0.15]);
handles.edit5 = uicontrol(handles.uibuttongroup1,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.45,0.1,0.15,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.radiobutton1 = uicontrol(handles.uibuttongroup1,'Style','radiobutton','Units','normalized','String','linear','Position',[0.7,0.75,0.25,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.radiobutton2 = uicontrol(handles.uibuttongroup1,'Style','radiobutton','Units','normalized','String','log2','Position',[0.7,0.45,0.25,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox1 = uicontrol(handles.uibuttongroup1,'Style','checkbox','Units','normalized','String','padding','Position',[0.7,0.15,0.25,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));

% method group
handles.uipanel1 = uipanel(handles.waveletGUIfig,'Units','normalized','Title','Method','Position',[0.5,0.4,0.46,0.35]);
handles.text7 = uicontrol(handles.uipanel1,'Style','text','Units','normalized','HorizontalAlignment','left','String','Method','Position',[0.06,0.75,0.2,0.15]);
handles.popupmenu1 = uicontrol(handles.uipanel1,'Style','popupmenu','Units','normalized','BackgroundColor','w','Position',[0.28,0.65,0.68,0.2], ...
    'String',{'Wavelet';'Continous Wavelet Transform';'Wavelet (Torrence & Compo, 1998)'}, ...
    'Callback',@popupmenu1_Callback);
handles.text8 = uicontrol(handles.uipanel1,'Style','text','Units','normalized','HorizontalAlignment','left','String','Mother','Position',[0.06,0.45,0.2,0.15]);
handles.popupmenu2 = uicontrol(handles.uipanel1,'Style','popupmenu','Units','normalized','BackgroundColor','w','Position',[0.28,0.35,0.68,0.2], ...
    'String',{'MORLET';'PAUL';'DOG'}, ...
    'Callback',@popupmenu2_Callback);
handles.text11 = uicontrol(handles.uipanel1,'Style','text','Units','normalized','HorizontalAlignment','left','String','Parameter','Position',[0.06,0.12,0.2,0.15]);
handles.edit7 = uicontrol(handles.uipanel1,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.28,0.1,0.1,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.text13 = uicontrol(handles.uipanel1,'Style','text','Units','normalized','HorizontalAlignment','left','String','Monte Carlo','Position',[0.4,0.12,0.2,0.15]);
handles.edit11 = uicontrol(handles.uipanel1,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.6,0.1,0.1,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));

% plot group
handles.uipanel2 = uipanel(handles.waveletGUIfig,'Units','normalized','Title','Plot','Position',[0.02,0.02,0.78,0.36]);
handles.checkbox2 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','plot series','Position',[0.02,0.75,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox3 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','plot spectrum','Position',[0.02,0.5,0.2,0.2], ...
    'Callback',@checkbox3_Callback);
handles.edit10 = uicontrol(handles.uipanel2,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.22,0.5,0.05,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.checkbox8 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','cone of influence','Position',[0.02,0.25,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox10 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','power log2','Position',[0.02,0.02,0.12,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.edit9 = uicontrol(handles.uipanel2,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.125,0.02,0.04,0.2], ...
    'Callback',@edit9_Callback);
handles.checkbox12 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','Z level','Position',[0.17,0.02,0.08,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));

handles.checkbox4 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','flip depth/time','Position',[0.3,0.75,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox5 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','flip period','Position',[0.3,0.5,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox6 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','swap x-y','Position',[0.3,0.25,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.checkbox9 = uicontrol(handles.uipanel2,'Style','checkbox','Units','normalized','String','p=0.05 sig.lev.','Position',[0.3,0.05,0.2,0.2], ...
    'Callback',@(h,~)updateCommon(h,0));

handles.text9 = uicontrol(handles.uipanel2,'Style','text','Units','normalized','HorizontalAlignment','left','String','colormap','Position',[0.5,0.75,0.1,0.15]);
handles.popupmenu3 = uicontrol(handles.uipanel2,'Style','popupmenu','Units','normalized','BackgroundColor','w','Position',[0.62,0.72,0.2,0.2], ...
    'String',{'default';'jet';'parula';'hot';'cool';'gray';'turbo';'hsv'}, ...
    'Callback',@(h,~)updateCommon(h,0));
handles.text10 = uicontrol(handles.uipanel2,'Style','text','Units','normalized','HorizontalAlignment','left','String','grid #','Position',[0.5,0.55,0.1,0.15]);
handles.edit6 = uicontrol(handles.uipanel2,'Style','edit','Units','normalized','BackgroundColor','w','Position',[0.62,0.55,0.07,0.15], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.text12 = uicontrol(handles.uipanel2,'Style','text','Units','normalized','HorizontalAlignment','left','String','tick label','Position',[0.5,0.35,0.1,0.15]);
handles.edit8 = uicontrol(handles.uipanel2,'Style','edit','Units','normalized','BackgroundColor','w','HorizontalAlignment','left','Position',[0.62,0.35,0.32,0.15], ...
    'Callback',@(h,~)updateCommon(h,0));
handles.pushbutton3 = uicontrol(handles.uipanel2,'Style','pushbutton','Units','normalized','String','?','Position',[0.955,0.35,0.035,0.15], ...
    'Callback',@pushbutton3_Callback);
handles.radiobutton3 = uicontrol(handles.uipanel2,'Style','radiobutton','Units','normalized','String','2D','Position',[0.65,0.1,0.1,0.2], ...
    'Callback',@radiobutton3_Callback);
handles.radiobutton4 = uicontrol(handles.uipanel2,'Style','radiobutton','Units','normalized','String','3D','Position',[0.75,0.1,0.1,0.2], ...
    'Callback',@radiobutton4_Callback);

% save panel
handles.uipanel3 = uipanel(handles.waveletGUIfig,'Units','normalized','Title','Save','Position',[0.82,0.02,0.14,0.36]);
handles.checkbox7 = uicontrol(handles.uipanel3,'Style','checkbox','Units','normalized','String','save result','Position',[0.03,0.6,0.95,0.2], ...
    'Callback',@(h,~)updateCommon(h,1));
handles.pushbutton2 = uicontrol(handles.uipanel3,'Style','pushbutton','Units','normalized','String','OK','Position',[0.2,0.1,0.6,0.4], ...
    'ForegroundColor','w','FontWeight','bold','BackgroundColor',[0.1 0.2 0.95], ...
    'Callback',@pushbutton2_Callback);

end

function handles = initState(handles, ctx)
handles.val1 = ctx.val1;
handles.MonZoom = ctx.MonZoom;
handles.sortdata = ctx.sortdata;
handles.unit = ctx.unit;
handles.unit_type = ctx.unit_type;
handles.data_name = ctx.data_name;
handles.path_temp = ctx.path_temp;
handles.listbox_acmain = ctx.listbox_acmain;
handles.edit_acfigmain_dir = ctx.edit_acfigmain_dir;
handles.lang_choice = ctx.lang_choice;
handles.lang_id = ctx.lang_id;
handles.lang_var = ctx.lang_var;
handles.main_unit_selection = ctx.main_unit_selection;
handles.wavehastorerun = 1;
handles.switchdata = 0;

[handles.lengthdata,~] = size(handles.data_name);
set(handles.edit9,'String','2');

if handles.lengthdata == 1
    if handles.lang_choice == 0
        set(handles.waveletGUIfig,'Name','Acycle: Wavelet');
    else
        [~, menu109] = ismember('menu109',handles.lang_id);
        set(handles.waveletGUIfig,'Name',['Acycle: ',handles.lang_var{menu109}]);
    end
    data = ctx.current_data;
    handles.current_data = data;
    [~,handles.filename1,exten] = fileparts(strtrim(handles.data_name(1,:)));

    set(handles.text3,'Enable','off');
    set(handles.edit2,'Enable','off');
    set(handles.pushbutton1,'Visible','off');
    set(handles.edit1,'String',[handles.filename1,exten]);
    set(handles.edit5,'String','0.1');
    set(handles.popupmenu2,'Enable','on');
    set(handles.edit7,'Enable','on');
    set(handles.edit10,'Visible','off');
    set(handles.checkbox1,'Value',1,'Enable','on');
    set(handles.checkbox3,'Value',0,'Enable','on','String','plot spectrum');
    set(handles.checkbox9,'Value',1,'Enable','on');
    set(handles.checkbox10,'Value',1,'Enable','on');
    set(handles.popupmenu1,'Value',2,'Enable','on', ...
        'String',{'Wavelet';'Continous Wavelet Transform';'Wavelet (Torrence & Compo, 1998)'});
    set(handles.text13,'Visible','off');
    set(handles.edit11,'Visible','off');
else
    if handles.lang_choice == 0
        set(handles.waveletGUIfig,'Name','Acycle: Wavelet coherence and cross-spectrum');
    else
        [~, wave15] = ismember('wave15',handles.lang_id);
        set(handles.waveletGUIfig,'Name',['Acycle: ',handles.lang_var{wave15}]);
    end
    [~,handles.filename1,handles.exten] = fileparts(strtrim(handles.data_name(1,:)));
    [~,handles.filename2,handles.exten] = fileparts(strtrim(handles.data_name(2,:)));

    set(handles.text3,'Enable','on');
    set(handles.edit2,'Enable','on');
    set(handles.pushbutton1,'Visible','on');
    set(handles.edit1,'String',[handles.filename1,handles.exten]);
    set(handles.edit2,'String',[handles.filename2,handles.exten]);
    set(handles.popupmenu1,'Value',2,'String',{'Wavelet coherence (MatLab)';'Wavelet Coherence (Grinsted2014)'});
    set(handles.popupmenu2,'Enable','off');
    set(handles.edit7,'Enable','on');
    set(handles.edit5,'String','0.1');
    set(handles.edit10,'Visible','on');
    set(handles.checkbox1,'Value',1,'Enable','on');
    set(handles.checkbox3,'Value',1,'Enable','on','String','phase, wtc threshold');
    set(handles.checkbox9,'Value',1,'Enable','on');
    set(handles.checkbox10,'Value',0,'Enable','off');
    set(handles.checkbox12,'Value',0,'Enable','off');
    set(handles.edit9,'Enable','off');
    set(handles.text13,'Visible','on');
    set(handles.edit11,'Visible','on');
    set(handles.radiobutton1,'Enable','off','Value',0);
    set(handles.radiobutton2,'Enable','off','Value',1);
    set(handles.checkbox8,'Enable','on','Value',1);
    set(handles.edit5,'Enable','on');
end

if handles.lang_choice > 0
    lv = handles.lang_var;
    li = handles.lang_id;
    [~, main12] = ismember('main12',li); set(handles.text2,'String',[lv{main12},'1']);
    [~, main12] = ismember('main12',li); set(handles.text3,'String',[lv{main12},'2']);
    [~, wave01] = ismember('wave01',li); set(handles.pushbutton1,'String',lv{wave01});
    [~, menu81] = ismember('menu81',li); set(handles.checkbox11,'String',lv{menu81});
end

if handles.lengthdata == 1
    data = handles.current_data;
    time = data(:,1);
    timelen = time(end)-time(1);
    Dti = diff(time);
    dt = mean(Dti);
    if acycleSamplingIsUneven(time)
        warndlg('Interpolation needed. Mean sampling rate was used.','Warning');
        data = interpolate(data,dt);
        handles.current_data = data;
    end
else
    s1 = strtrim(handles.data_name(1,:));
    s2 = strtrim(handles.data_name(2,:));
    dat1 = sortrows(load(s1));
    dat2 = sortrows(load(s2));
    xmin = max(min(dat1(:,1), min(dat2(:,1))));
    xmax = min(max(dat1(:,1), max(dat2(:,1))));
    dat1 = select_interval(dat1,xmin,xmax);
    Dti1 = diff(dat1(:,1));
    dt = mean(Dti1);
    if acycleSamplingIsUneven(dat1(:,1))
        warndlg('Series 1: Interpolation needed! Done!','Warning');
        dat1 = interpolate(dat1,dt);
    end
    if ~isequal(dat1(:,1),dat2(:,1))
        warndlg('Time ranges are not equal. Inerpolation series applied.','Warning');
        dat2int2 = interp1(dat2(:,1),dat2(:,2),dat1(:,1));
        dat2 = [dat1(:,1),dat2int2];
    end
    data = dat1;
    time = data(:,1);
    timelen = time(end)-time(1);
end

dt = mean(diff(data(:,1)));
Yticks_default = 2.^(fix(log2(2*dt)):fix(log2(timelen)));
Yticks = mat2str(Yticks_default);
Yticks(1)=[]; Yticks(end)=[];

s0 = 2*dt;
pt2 = 2^fix(log2(timelen));
dss = 0.1;
j1 = round(log2(pt2))/dss;
pad = 1; mother = 'MORLET'; param = 6;
[~,period,~,coi] = wavelet(data(:,2),dt,pad,dss,s0,j1,mother,param);

set(handles.edit3,'String',num2str(min(period)));
set(handles.edit4,'String',num2str(max(coi)));
set(handles.popupmenu2,'Value',1);
set(handles.checkbox2,'Value',1);
set(handles.checkbox8,'Value',1);
set(handles.checkbox4,'Value',0);
set(handles.checkbox5,'Value',0);
set(handles.checkbox6,'Value',0);
set(handles.checkbox7,'Value',0);
set(handles.edit8,'String',Yticks);
set(handles.radiobutton1,'Value',0);
set(handles.radiobutton2,'Value',1);
set(handles.radiobutton3,'Value',1);
set(handles.radiobutton4,'Value',0);
set(handles.edit6,'String','');
set(handles.edit7,'String','6');
set(handles.popupmenu3,'Value',1);
set(handles.checkbox11,'Value',0);

if handles.lengthdata > 1
    set(handles.edit10,'String','0.5');
    set(handles.edit11,'String','300');
end

end

function pushbutton1_Callback(hObject,~)
handles = guidata(hObject);
handles.wavehastorerun = 1;
data_name = handles.data_name;
handles.data_name = [data_name(2,:); data_name(1,:)];
[~,f1,e1] = fileparts(strtrim(handles.data_name(1,:)));
[~,f2,e2] = fileparts(strtrim(handles.data_name(2,:)));
set(handles.edit1,'String',[f1,e1]);
set(handles.edit2,'String',[f2,e2]);
handles.switchdata = 1 - handles.switchdata;
wavecoh_readGUI;
wavecoh_update_plots;
guidata(handles.waveletGUIfig, handles);
end

function pushbutton2_Callback(hObject,~)
handles = guidata(hObject);
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    wave_readGUI;
    wave_update_plots;
else
    wavecoh_readGUI;
    wavecoh_update_plots;
end
handles.wavehastorerun = 0;
guidata(handles.waveletGUIfig, handles);
end

function checkbox3_Callback(hObject,~)
handles = guidata(hObject);
if handles.lengthdata == 1
    updateCommon(hObject,0);
else
    handles.wavehastorerun = 0;
    if get(hObject,'Value')
        set(handles.radiobutton1,'Enable','off','Value',0);
        set(handles.radiobutton2,'Enable','off','Value',1);
        set(handles.checkbox8,'Enable','on','Value',1);
        set(handles.edit5,'Enable','on');
    else
        set(handles.radiobutton1,'Enable','on','Value',0);
        set(handles.radiobutton2,'Enable','on','Value',1);
        set(handles.checkbox8,'Enable','on');
        set(handles.edit5,'Enable','on');
        try
            figure(handles.figwave); clf;
        catch
        end
    end
    if ~hasWavecohCache(handles)
        handles.wavehastorerun = 1;
    end
    wavecoh_readGUI;
    wavecoh_update_plots;
    guidata(handles.waveletGUIfig, handles);
end
end

function popupmenu1_Callback(hObject,~)
handles = guidata(hObject);
handles.wavehastorerun = 1;
if handles.lengthdata == 1
    if get(hObject,'Value') == 2
        set(handles.edit5,'String',num2str(1/12));
    else
        set(handles.edit5,'String','0.1');
    end
    wave_readGUI;
    wave_update_plots;
else
    if get(hObject,'Value') == 2
        set(handles.edit5,'String',num2str(1/12));
        set(handles.checkbox9,'Value',1,'Enable','on');
        set(handles.text13,'Visible','on');
        set(handles.edit11,'Visible','on');
        set(handles.waveletGUIfig,'Name','Acycle: Wavelet coherence and cross-spectrum');
    else
        set(handles.edit5,'String','0.1');
        set(handles.checkbox9,'Value',0,'Enable','off');
        set(handles.text13,'Visible','off');
        set(handles.edit11,'Visible','off');
        set(handles.waveletGUIfig,'Name','Acycle: Wavelet coherence');
    end
    wavecoh_readGUI;
    wavecoh_update_plots;
end
guidata(handles.waveletGUIfig, handles);
end

function popupmenu2_Callback(hObject,~)
handles = guidata(hObject);
items = get(hObject,'String');
mother = items{get(hObject,'Value')};
if strcmp(mother,'MORLET')
    set(handles.edit7,'String','6');
elseif strcmp(mother,'PAUL')
    set(handles.edit7,'String','4');
elseif strcmp(mother,'DOG')
    set(handles.edit7,'String','2');
end
updateCommon(hObject,1);
end

function radiobutton3_Callback(hObject,~)
handles = guidata(hObject);
if get(hObject,'Value')
    set(handles.radiobutton4,'Value',0);
else
    set(handles.radiobutton4,'Value',1);
end
updateCommon(hObject,0);
end

function radiobutton4_Callback(hObject,~)
handles = guidata(hObject);
if get(hObject,'Value')
    set(handles.radiobutton3,'Value',0);
else
    set(handles.radiobutton3,'Value',1);
end
updateCommon(hObject,0);
end

function edit9_Callback(hObject,~)
if str2double(get(hObject,'String')) <= 1
    set(hObject,'String','2');
end
updateCommon(hObject,0);
end

function pushbutton3_Callback(hObject,~)
handles = guidata(hObject);
lang_var = handles.lang_var;
[~, wave19] = ismember('wave19',handles.lang_id);
[~, wave26] = ismember('wave26',handles.lang_id);
[~, wave21] = ismember('wave21',handles.lang_id);
msgbox({lang_var{wave19};lang_var{wave26}},lang_var{wave21});
end

function updateCommon(hObject, rerunFlag)
handles = guidata(hObject);
handles.wavehastorerun = rerunFlag;
if handles.lengthdata == 1
    if handles.wavehastorerun == 0 && ~hasWaveCache(handles)
        handles.wavehastorerun = 1;
    end
    wave_readGUI;
    wave_update_plots;
else
    if handles.wavehastorerun == 0 && ~hasWavecohCache(handles)
        handles.wavehastorerun = 1;
    end
    wavecoh_readGUI;
    wavecoh_update_plots;
end
guidata(handles.waveletGUIfig, handles);
end

function onKeyPressClose(src, evt)
try
    key = lower(string(evt.Key));
    mods = lower(string(evt.Modifier));
    isCtrlW = key == "w" && any(mods == "control");
    isCmdW = key == "w" && any(mods == "command");
    if isCtrlW || isCmdW
        delete(src);
    end
catch
end
end

function tf = hasWaveCache(handles)
req = {'datax','datay','dt','period','power','sig95','coi','global_ws','global_signif'};
tf = all(isfield(handles, req));
end

function tf = hasWavecohCache(handles)
if isfield(handles,'wcoh') && isfield(handles,'wcs') && isfield(handles,'period') && isfield(handles,'coi')
    tf = true;
    return;
end
if isfield(handles,'Rsq') && isfield(handles,'Wxy') && isfield(handles,'period') && isfield(handles,'coi')
    tf = true;
    return;
end
tf = false;
end
