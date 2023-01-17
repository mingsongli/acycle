function varargout = LODGUI(varargin)
% LODGUI MATLAB code for LODGUI.fig
%      LODGUI, by itself, creates a new LODGUI or raises the existing
%      singleton*.
%
%      H = LODGUI returns the handle to a new LODGUI or the handle to
%      the existing singleton*.
%
%      LODGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LODGUI.M with the given input arguments.
%
%      LODGUI('Property','Value',...) creates a new LODGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before LODGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to LODGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LODGUI

% Last Modified by GUIDE v2.5 11-Mar-2020 14:07:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LODGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @LODGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before LODGUI is made visible.
function LODGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to LODGUI (see VARARGIN)
handles.MonZoom = varargin{1}.MonZoom;
handles.sortdata = varargin{1}.sortdata;
handles.val1 = varargin{1}.val1;

% language
lang_choice = varargin{1}.lang_choice;
handles.lang_choice = lang_choice;
lang_id = varargin{1}.lang_id;
lang_var = varargin{1}.lang_var;
handles.lang_id = lang_id;
handles.lang_var = lang_var;
handles.main_unit_selection = varargin{1}.main_unit_selection;
if handles.lang_choice == 0
    set(gcf,'Name','Acycle: Milankovitch Calculator')
else
    [~, menu52] = ismember('menu52',lang_id);
    set(gcf,'Name',['Acycle: ',lang_var{menu52}])
end

[~, mical01] = ismember('mical01',lang_id);
[~, mical02] = ismember('mical02',lang_id);
[~, mical03] = ismember('mical03',lang_id);
[~, mical04] = ismember('mical04',lang_id);
[~, mical05] = ismember('mical05',lang_id);
[~, mical06] = ismember('mical06',lang_id);

[~, main00] = ismember('main00',lang_id); % ok
[~, main16] = ismember('main16',lang_id); % from
[~, main17] = ismember('main17',lang_id); % to 
[~, main32] = ismember('main32',lang_id); % step
%[~, mical23] = ismember('mical23',lang_id);
set(handles.uibuttongroup1,'Title',lang_var{mical01})
set(handles.uipanel1,'Title',lang_var{mical03})
set(handles.uipanel2,'Title',lang_var{mical04})
set(handles.uipanel3,'Title',lang_var{mical05})

set(handles.radiobutton1,'String',lang_var{mical02})
set(handles.radiobutton2,'String',lang_var{mical01})
set(handles.pushbutton1,'String',lang_var{main00})
set(handles.text2,'String',lang_var{main16})
set(handles.text3,'String',lang_var{main17})
set(handles.text4,'String',lang_var{main32})

set(gcf,'position',[0.4,0.55,0.313,0.289]* handles.MonZoom) % set position
set(0,'Units','normalized') % set units as normalized
set(gcf,'units','norm') % set location
h=get(gcf,'Children');  % get all content
h1=findobj(h,'FontUnits','norm');  % find all font units as points
set(h1,'FontUnits','points','FontSize',11);  % set as norm
h2=findobj(h,'FontUnits','points');  % find all font units as points
set(h2,'FontUnits','points','FontSize',11);  % set as norm

set(handles.uibuttongroup1, 'Position',[0.05, 0.65, 0.26, 0.3])
set(handles.uipanel1, 'Position',[0.33, 0.65, 0.33, 0.3])
set(handles.uipanel2, 'Position',[0.05, 0.22, 0.9, 0.39])
set(handles.uipanel3, 'Position',[0.05, 0.03, 0.9, 0.19])

set(handles.radiobutton1, 'Position',[0.1, 0.55, 0.9, 0.35])
set(handles.radiobutton1, 'value',0)
set(handles.radiobutton2, 'Position',[0.1, 0.1, 0.9, 0.35])
set(handles.radiobutton2, 'value',1)
set(handles.popupmenu1, 'Position',[0.05, 0.3, 0.9, 0.41])
set(handles.text2, 'Position',[0.01, 0.6, 0.12, 0.2])
set(handles.text3, 'Position',[0.4, 0.6, 0.07, 0.2])
set(handles.text4, 'Position',[0.7, 0.6, 0.13, 0.2])
set(handles.text5, 'Position',[0.3, 0.6, 0.055, 0.2])
set(handles.text6, 'Position',[0.64, 0.6, 0.055, 0.2])
set(handles.text7, 'Position',[0.93, 0.6, 0.055, 0.2])
set(handles.edit1, 'Position',[0.13, 0.56, 0.17, 0.25])
set(handles.edit1, 'String','10')
set(handles.edit2, 'Position',[0.47, 0.56, 0.17, 0.25])
set(handles.edit2, 'String','250')  
set(handles.edit3, 'Position',[0.806, 0.56, 0.11, 0.25])
set(handles.edit3, 'String','10')
set(handles.text8, 'Position',[0.03, 0.2, 0.94, 0.2])
set(handles.text8, 'String',[lang_var{mical06},' 10, ... , 250 Ma'])
set(handles.edit4, 'Position',[0.03, 0.25, 0.94, 0.6])
set(handles.pushbutton1, 'Position',[0.71, 0.7, 0.2, 0.2])

set(handles.text2, 'String','From')
set(handles.edit2, 'Visible','on')
set(handles.edit3, 'Visible','on')
set(handles.text3, 'Visible','on')
set(handles.text4, 'Visible','on')
set(handles.text6, 'Visible','on')
set(handles.text7, 'Visible','on')

handles.listbox_acmain = varargin{1}.listbox_acmain; % save path
handles.edit_acfigmain_dir = varargin{1}.edit_acfigmain_dir;

% Choose default command line output for LODGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LODGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LODGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
single0 = get(handles.radiobutton1,'Value');
single1 = get(handles.radiobutton2,'Value');
model = get(handles.popupmenu1,'Value');
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical08] = ismember('mical08',lang_id);
[~, mical09] = ismember('mical09',lang_id);
[~, mical10] = ismember('mical10',lang_id);
[~, mical11] = ismember('mical11',lang_id);
[~, mical12] = ismember('mical12',lang_id);
[~, mical13] = ismember('mical13',lang_id);
[~, mical14] = ismember('mical14',lang_id);
[~, mical15] = ismember('mical15',lang_id);
[~, mical16] = ismember('mical16',lang_id);
[~, mical17] = ismember('mical17',lang_id);
[~, mical18] = ismember('mical18',lang_id);
[~, mical19] = ismember('mical19',lang_id);
[~, mical21] = ismember('mical21',lang_id);
[~, mical22] = ismember('mical22',lang_id);
[~, MainUnit9] = ismember('MainUnit9',lang_id);
[~, menu52] = ismember('menu52',lang_id);
[~, menu03] = ismember('menu03',lang_id);
[~, main22] = ismember('main22',lang_id); % age

if model == 1
    if single0 == 1
        % single time
        T1 = str2double(get(handles.edit1,'string'));
        if T1 >=4500 || T1<=-4500
            if T1 >=4500
                errordlg(lang_var{mical08})
            else
                errordlg(lang_var{mical09})
            end
        else            
            [daymin, daymax,amin, amax, kmin, kmax, obmin,...
                obmax, o1min, o1max, p1min, p1max, p2min, p2max, ...
                p3min, p3max, p4min, p4max] = MilankovitchCal(T1);
            
            % write out distance range
            distance = 0.5*( amax + amin );
            distsigma = 0.5*( amax - amin);
            %accuracy = decimalPlaces(distsigma);
            %disp(['Earth-Moon Distance : ', num2str(distance), ' +/- ', num2str(distsigma),' km'])

            % write out day-length range
            day = 0.5*( daymax + daymin );
            daysigma = 0.5*( daymax - daymin );
            %accuracy = decimalPlaces(daysigma);
            %disp(['Earth Day : ', num2str(day), ' +/- ', num2str(daysigma),' hours'])

            % write out obliquity range
            obliq = 0.5*( obmax + obmin );
            obsigma = 0.5*( obmax - obmin);
            %accuracy = decimalPlaces(obsigma);
            %disp(['Earth Axis Mean Obliquity : ', num2str(obliq), ' +/- ', num2str(obsigma),' degrees'])

            % write out precession range
            kkymin = 360.0*3.6/kmax;
            kkymax = 360.0*3.6/kmin;
            prec = 0.5*( kkymax + kkymin );
            precsigma = 0.5*( kkymax - kkymin);
            %accuracy = decimalPlaces(precsigma);
            %disp(['Earth Axis Precession Period : ', num2str(prec), ' +/- ', num2str(precsigma),' kyr'])

            % write out obliquity cycle periods
            o1 = 0.5*( o1max + o1min );
            o1sigma = 0.5*( o1max - o1min );
            %accuracy = decimalPlaces(p1sigma);
            %disp('Main Obliquity Period : (kyr)')
            %disp([num2str(o1), ' +/- ', num2str(o1sigma)])

            % write out climatic precession periods
            p1 = 0.5*( p1max + p1min );
            p1sigma = 0.5*( p1max - p1min );
            %accuracy = decimalPlaces(p1sigma);
            %disp('Climatic Precession Periods : (kyr)')
            %disp([num2str(p1), ' +/- ', num2str(p1sigma)])

            p2 = 0.5*( p2max + p2min );
            p2sigma = 0.5*( p2max - p2min );
            %accuracy = decimalPlaces(p2sigma);
            %disp([num2str(p2), ' +/- ', num2str(p2sigma)])

            p3 = 0.5*( p3max + p3min );
            p3sigma = 0.5*( p3max - p3min );
            %accuracy = decimalPlaces(p3sigma);
            %disp([num2str(p3), ' +/- ', num2str(p3sigma)])

            p4 = 0.5*( p4max + p4min );
            p4sigma = 0.5*( p4max - p4min );
            %accuracy = decimalPlaces(p4sigma);
            %disp([num2str(p4), ' +/- ', num2str(p4sigma)])
            
            prompt = {...
                lang_var{mical11}; ...
                lang_var{mical12};...
                lang_var{mical13}; ...
                lang_var{mical14};...
                lang_var{mical15};...
                [lang_var{mical16},' #1 (',lang_var{MainUnit9},')'];...
                [lang_var{mical16},' #2 (',lang_var{MainUnit9},')'];...
                [lang_var{mical16},' #3 (',lang_var{MainUnit9},')'];...
                [lang_var{mical16},' #4 (',lang_var{MainUnit9},')'];...
                [lang_var{mical17},' Waltham, D., 2015. JSR. doi: 10.2110/jsr.2015.66']};
%             prompt = {...
%                 'Earth-Moon Distance (x1000 km)'; ...
%                 'Earth Day (hours)';...
%                 'Earth Axis Mean Obliquity (degrees)'; ...
%                 'Earth Axis Precession Period (kyr)';...
%                 'Main Obliquity Period (kyr)';...
%                 'Climatic Precession Periods #1 (kyr)';...
%                 'Climatic Precession Periods #2 (kyr)';...
%                 'Climatic Precession Periods #3 (kyr)';...
%                 'Climatic Precession Periods #4 (kyr)';...
%                 'Details in: Waltham, D., 2015. JSR. doi: 10.2110/jsr.2015.66'};
            dlg_title = lang_var{menu52};
            num_lines = 1;
            defaultans = {...
                [num2str(distance), ' +/- ', num2str(distsigma)],...
                [num2str(day), ' +/- ', num2str(daysigma)],...
                [num2str(obliq), ' +/- ', num2str(obsigma)],...
                [num2str(prec), ' +/- ', num2str(precsigma)],...
                [num2str(o1), ' +/- ', num2str(o1sigma)],...
                [num2str(p1), ' +/- ', num2str(p1sigma)],...
                [num2str(p2), ' +/- ', num2str(p2sigma)],...
                [num2str(p3), ' +/- ', num2str(p3sigma)],...
                [num2str(p4), ' +/- ', num2str(p4sigma)],...
                'https://davidwaltham.com/wp-content/uploads/2014/01/Milankovitch.html'};
            options.Resize='on';
            answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);
                if ~isempty(answer)
                end
        end
    elseif single1 == 1
        % time series
        age1 = str2double(get(handles.edit1,'string'));
        age2 = str2double(get(handles.edit2,'string'));
        step = str2double(get(handles.edit3,'string'));
        T1 = age1:step:age2;
        T1 = T1';
        T1n = length(T1);
        if isempty(T1) == 0
            for ti = 1:T1n
                age = T1(ti);
                [daymin, daymax,amin, amax, kmin, kmax, obmin,obmax, o1min, o1max, ...
                    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max] = MilankovitchCal(age);
                calmi(ti,:) = [daymin, daymax, amin, amax, kmin, kmax, obmin, obmax, o1min, o1max, ...
                    p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max];
            end
            
            figure;
            set(gcf,'Name',['Acycle: ',lang_var{menu52},' | ',lang_var{menu03}])
            set(gcf,'color','white')
            subplot(3,2,1); hold on;
            plot(T1,calmi(:,3),'k--')
            plot(T1,calmi(:,4),'k--')
            plot(T1,(calmi(:,3) + calmi(:,4))/2,'r-','LineWidth',1)
            ylabel(lang_var{mical11})
            xlim([age1, age2])
            
            subplot(3,2,2); hold on;
            plot(T1,calmi(:,1),'k--')
            plot(T1,calmi(:,2),'k--')
            plot(T1,(calmi(:,1) + calmi(:,2))/2,'r-','LineWidth',1)
            ylabel(lang_var{mical12})
            xlim([age1, age2])
                      
            subplot(3,2,4); hold on;
            plot(T1,360.0*3.6./calmi(:,5),'k--')
            plot(T1,360.0*3.6./calmi(:,6),'k--')
            plot(T1,0.5*( 360.0*3.6./calmi(:,5) + 360.0*3.6./calmi(:,6)),'r-','LineWidth',1)
            ylabel(lang_var{mical14})
            xlim([age1, age2])
            
            subplot(3,2,3); hold on;
            plot(T1,calmi(:,7),'k--')
            plot(T1,calmi(:,8),'k--')
            plot(T1,(calmi(:,7) + calmi(:,8))/2,'r-','LineWidth',1)
            ylabel(lang_var{mical13})
            xlim([age1, age2])
            
            subplot(3,2,5); hold on;
            plot(T1,calmi(:,9),'k--')
            plot(T1,calmi(:,10),'k--')
            plot(T1,(calmi(:,9) + calmi(:,10))/2,'r-','LineWidth',1)
            ylabel(lang_var{mical15})
            xlabel([lang_var{main22}, ' (Ma)'])
            xlim([age1, age2])
            
            subplot(3,2,6); hold on;
            plot(T1,calmi(:,11),'k--')
            plot(T1,calmi(:,12),'k--')
            plot(T1,(calmi(:,11) + calmi(:,12))/2,'k-','LineWidth',1)
            
            plot(T1,calmi(:,13),'g--')
            plot(T1,calmi(:,14),'g--')
            plot(T1,(calmi(:,13) + calmi(:,14))/2,'g-','LineWidth',1)
            
            plot(T1,calmi(:,15),'b--')
            plot(T1,calmi(:,16),'b--')
            plot(T1,(calmi(:,15) + calmi(:,16))/2,'b-','LineWidth',1)
            
            plot(T1,calmi(:,17),'r--')
            plot(T1,calmi(:,18),'r--')
            plot(T1,(calmi(:,17) + calmi(:,18))/2,'r-','LineWidth',1)
            xlabel([lang_var{main22}, ' (Ma)'])
            ylabel([lang_var{mical16},' (kyr)'],'LineWidth',1)
            xlim([age1, age2])
            
            % reorder
            CalMiR = [...
                calmi(:,3),calmi(:,4),calmi(:,1),calmi(:,2),calmi(:,7),calmi(:,8)...
                360.0*3.6./calmi(:,5),360.0*3.6./calmi(:,6),...
                calmi(:,9:end)];
            name1 = ['CalMi_',num2str(age1),'_',num2str(age2),'-Ma-step_',num2str(step),'.txt'];
            CDac_pwd
            disp([lang_var{mical18}, name1])
            disp(['  ',lang_var{mical19},' #1, #2, #3, ... , #19'])
            disp('  age, amin, amax, daymin, daymax, obmin, obmax, kmin, kmax, o1min, o1max, p1min, p1max, p2min, p2max, p3min, p3max, p4min, p4max')
            dlmwrite(name1, [T1,CalMiR], 'delimiter', ' ', 'precision', 9);
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder
        else
            errordlg(lang_var{mical10})
        end
    end
elseif model == 2
    if single0 == 1
        % single time
        T1 = str2double(get(handles.edit1,'string'));
        if T1 >=4500 || T1<=-4500
            if T1 >=4500
                errordlg(lang_var{mical08})
            else
                errordlg(lang_var{mical09})
            end
        else

            [lod, doy] = lodla04(T1/-1000);

            name1 = ['LOD_',num2str(T1),'Ma.txt'];
            name2 = ['LOD_DOY_',num2str(T1),'Ma.txt'];
            CDac_pwd
            dlmwrite(name1, [T1,lod], 'delimiter', ' ', 'precision', 9);
            dlmwrite(name2, [T1,doy], 'delimiter', ' ', 'precision', 9);
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder

            figure;
            set(gcf,'Name',lang_var{mical21})
            set(gcf,'color','w');
            subplot(2,1,1)
            plot(T1,lod,'-ko')
            ylabel(lang_var{mical12})
            subplot(2,1,2)
            plot(T1,doy,'-ko')
            xlabel([lang_var{main22}, ' (Ma)'])
            ylabel(lang_var{mical22})
        end
    elseif single1 == 1
        % time series
        age1 = str2double(get(handles.edit1,'string'));
        age2 = str2double(get(handles.edit2,'string'));
        step = str2double(get(handles.edit3,'string'));
        T1 = age1:step:age2;
        T1 = T1';
        if isempty(T1) == 0
            [lod, doy] = lodla04(T1/-1000);

            name1 = ['LOD-',num2str(age1),'_',num2str(age2),'_Ma-step_',num2str(step),'.txt'];
            CDac_pwd
            dlmwrite(name1, [T1,lod,doy], 'delimiter', ' ', 'precision', 9);
            d = dir; %get files
            set(handles.listbox_acmain,'String',{d.name},'Value',1) %set string
            refreshcolor;
            cd(pre_dirML); % return to matlab view folder

            figure;
            set(gcf,'Name',lang_var{mical21})
            set(gcf,'color','w');
            subplot(2,1,1)
            plot(T1,lod,'-ko')
            ylabel(lang_var{mical12})
            subplot(2,1,2)
            plot(T1,doy,'-ko')
            xlabel([lang_var{main22}, ' (Ma)'])
            ylabel(lang_var{mical22})
        else
            errordlg(lang_var{mical10})
        end
    end
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical07] = ismember('mical07',lang_id);
[~, mical08] = ismember('mical08',lang_id);
[~, mical09] = ismember('mical09',lang_id);
[~, mical10] = ismember('mical10',lang_id);

single0 = get(handles.radiobutton1,'Value');

if single0 == 1
    T = str2double(get(handles.edit1,'string'));
    if T >=4500 || T<=-4500
        if T >=4500
            set(handles.text8, 'String',lang_var{mical08})
        else
            set(handles.text8, 'String',lang_var{mical09})
        end
    else
        string0 = [lang_var{mical07},num2str(T),' Ma'];
        set(handles.text8, 'String',string0)
    end
else
    age1 = str2double(get(handles.edit1,'string'));
    age2 = str2double(get(handles.edit2,'string'));
    step = str2double(get(handles.edit3,'string'));
    T = age1:step:age2;
    if isempty(T) == 0
        if max(T) >=4500 || min(T)<=-4500
            set(handles.text8, 'String',lang_var{mical10})
        end
        if length(T)>3
            string0 = [lang_var{mical07},num2str(T(1)),', ',...
                num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
        else
            string0 = [lang_var{mical07},...
                num2str(T(1)),' - ', num2str(T(end)),' Ma'];
        end
        set(handles.text8, 'String',string0)
    else
        set(handles.text8, 'String',lang_var{mical10})
    end
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical07] = ismember('mical07',lang_id);
[~, mical10] = ismember('mical10',lang_id);

age1 = str2double(get(handles.edit1,'string'));
age2 = str2double(get(handles.edit2,'string'));
step = str2double(get(handles.edit3,'string'));
T = age1:step:age2;
if isempty(T) == 0
    if max(T) >=4500 || min(T)<=-4500
        set(handles.text8, 'String',lang_var{mical10})
    end
    if length(T)>3
        string0 = [lang_var{mical07},num2str(T(1)),', ',...
            num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
    else
        string0 = [lang_var{mical07},...
            num2str(T(1)),' - ', num2str(T(end)),' Ma'];
    end
    set(handles.text8, 'String',string0)
else
    set(handles.text8, 'String',lang_var{mical10})
end


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical07] = ismember('mical07',lang_id);
[~, mical10] = ismember('mical10',lang_id);

age1 = str2double(get(handles.edit1,'string'));
age2 = str2double(get(handles.edit2,'string'));
step = str2double(get(handles.edit3,'string'));
T = age1:step:age2;
if isempty(T) == 0
    if max(T) >=4500 || min(T)<=-4500
        set(handles.text8, 'String',lang_var{mical10})
    end
    if length(T)>3
        string0 = [lang_var{mical07},num2str(T(1)),', ',...
            num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
    else
        string0 = [lang_var{mical07},...
            num2str(T(1)),' - ', num2str(T(end)),' Ma'];
    end
    set(handles.text8, 'String',string0)
else
    set(handles.text8, 'String',lang_var{mical10})
end

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical07] = ismember('mical07',lang_id);
[~, mical10] = ismember('mical10',lang_id);
[~, main16] = ismember('main16',lang_id);
% Hint: get(hObject,'Value') returns toggle state of radiobutton2
if get(hObject,'Value')
    set(handles.text2, 'String',lang_var{main16})
    set(handles.edit2, 'Visible','on')
    set(handles.edit3, 'Visible','on')
    set(handles.text3, 'Visible','on')
    set(handles.text4, 'Visible','on')
    set(handles.text6, 'Visible','on')
    set(handles.text7, 'Visible','on')
    
    age1 = str2double(get(handles.edit1,'string'));
    age2 = str2double(get(handles.edit2,'string'));
    step = str2double(get(handles.edit3,'string'));
    T = age1:step:age2;
    if isempty(T) == 0
        if max(T) >=4500 || min(T)<=-4500
            set(handles.text8, 'String',lang_var{mical10})
        end
        if length(T)>3
            string0 = [lang_var{mical07},num2str(T(1)),', ',...
                num2str(T(2)),', ... , ', num2str(T(end)),' Ma'];
        else
            string0 = [lang_var{mical07},...
                num2str(T(1)),' - ', num2str(T(end)),' Ma'];
        end
        set(handles.text8, 'String',string0)
    else
        set(handles.text8, 'String',lang_var{mical10})
    end
end

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% language
lang_id = handles.lang_id;
lang_var = handles.lang_var;
[~, mical07] = ismember('mical07',lang_id);
[~, mical08] = ismember('mical08',lang_id);
[~, mical09] = ismember('mical09',lang_id);
[~, main22] = ismember('main22',lang_id);
% Hint: get(hObject,'Value') returns toggle state of radiobutton1
single = get(hObject,'Value');
if single == 1
    set(handles.text2, 'String',lang_var{main22})
    set(handles.edit2, 'Visible','off')
    set(handles.edit3, 'Visible','off')
    set(handles.text3, 'Visible','off')
    set(handles.text4, 'Visible','off')
    set(handles.text6, 'Visible','off')
    set(handles.text7, 'Visible','off')
    
    T = str2double(get(handles.edit1,'string'));
    if T >=4500 || T<=-4500
        if T >=4500
            set(handles.text8, 'String',lang_var{mical08})
        else
            set(handles.text8, 'String',lang_var{mical09})
        end
    else
        string0 = [lang_var{mical07},num2str(T),' Ma'];
        set(handles.text8, 'String',string0)
    end

end
