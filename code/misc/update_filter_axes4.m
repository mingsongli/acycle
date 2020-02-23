
set(handles.popupmenu4,'value',1)
contents = cellstr(get(handles.popupmenu5,'String'));
filter_s = contents{get(handles.popupmenu5,'Value')};
handles.filter = filter_s;
x_1 = str2double(get(handles.edit10,'string'));
x_2 = str2double(get(handles.edit11,'string'));
y_1 = str2double(get(handles.edit12,'string'));
y_2 = str2double(get(handles.edit13,'string'));

data = handles.current_data;
datax=data(:,2);
time = data(:,1);

L = length(data(:,2));
dt = mean(diff(data(:,1)));
Y = fft(data(:,2),L);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1/dt * (0:(L/2))/L;

nyquist = 1/(2*dt);
rayleigh = 1/(dt*L);

%read pass type
if (get(handles.radiobutton6,'Value'))
    passtype = 'highpassiir';
    f11 = str2double(get(handles.edit16,'string'));
    f1 = f11/nyquist;
end
if (get(handles.radiobutton7,'Value'))
    passtype = 'lowpassiir';
    f11 = str2double(get(handles.edit16,'string'));
    f1 = f11/nyquist;
end
if (get(handles.radiobutton8,'Value'))
    passtype = 'bandstopiir';
    f11 = str2double(get(handles.edit16,'string'));
    f12 = str2double(get(handles.edit17,'string'));
    flow = min(f12,f11)/nyquist; % lowpass
    fhigh = max(f12,f11)/nyquist; % highpass
    passband1 = flow + 2*rayleigh/nyquist;
    passband2 = fhigh - 2*rayleigh/nyquist;
    f1 = [flow fhigh];
end

axes(handles.ft_axes3);
plot(f,P1)
hold on
if (get(handles.radiobutton8,'Value'))
    ff12 = [f11,f12];
    f11 = min(ff12);
    f12 = max(ff12);
    plot([f11,f11],[y_1,y_2],'r-')
    plot([f12,f12],[y_1,y_2],'r-')
    plot([0,f11],[y_2,y_2],'r-')
    plot([f12,max(f)],[y_2,y_2],'r-')
end
if (get(handles.radiobutton7,'Value'))
    plot([f11,f11],[y_1,y_2],'r-')
    plot([0,f11],[y_2,y_2],'r-')
end
if (get(handles.radiobutton6,'Value'))
    plot([f11,f11],[y_1,y_2],'r-')
    plot([f11,max(f)],[y_2,y_2],'r-')
end
xlim([x_1, x_2])
ylim([y_1, y_2])
hold off
axes(handles.ft_axes4);
xlim([x_1, x_2])



handles.filename = handles.dat_name;

tf = strcmp(passtype,{'highpassiir','lowpassiir'});
if any(tf(:))
    if strcmp(filter_s,'Butter')
        d = designfilt(passtype, ...
        'FilterOrder',6, ...
        'HalfPowerFrequency',f1,...
        'DesignMethod','butter');
        add_list = [handles.filename,passtype,'butter-',num2str(f11),'.txt'];

    elseif strcmp(filter_s,'Cheby1')
        d = designfilt(passtype, ...
        'FilterOrder',6, ...
        'PassbandFrequency',f1,...
        'PassbandRipple',1,...
        'DesignMethod','cheby1');
        add_list = [handles.filename,passtype,'cheby1-',num2str(f11),'.txt'];

    elseif strcmp(filter_s,'Ellip')
        d = designfilt(passtype, ...
        'FilterOrder',6, ...
        'PassbandFrequency',f1,...
        'PassbandRipple',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','ellip');
        add_list = [handles.filename,passtype,'ellip-',num2str(f11),'.txt'];
    end
elseif strcmp(passtype,{'bandstopiir'})
    flow = f1(1);
    fhigh = f1(2);
    
    if strcmp(filter_s,'Butter')
        d = designfilt(passtype, ...
        'FilterOrder',6, ...
        'HalfPowerFrequency1',flow,...
        'HalfPowerFrequency2',fhigh,...
        'DesignMethod','butter');
        add_list = [handles.filename,passtype,'butter-',num2str(flow*nyquist),'-',num2str(fhigh*nyquist),'.txt'];
    elseif strcmp(filter_s,'Cheby1')
        d = designfilt(passtype, ...
        'PassbandFrequency1',flow,...
        'StopbandFrequency1',passband1,...
        'StopbandFrequency2',passband2,...
        'PassbandFrequency2',fhigh,...
        'PassbandRipple1',1,...
        'PassbandRipple2',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','cheby1',...
        'MatchExactly','both');
        add_list = [handles.filename,passtype,'cheby1-',num2str(flow*nyquist),'-',num2str(fhigh*nyquist),'.txt'];
    elseif strcmp(filter_s,'Ellip')
        d = designfilt(passtype, ...
        'PassbandFrequency1',flow,...
        'StopbandFrequency1',passband1,...
        'StopbandFrequency2',passband2,...
        'PassbandFrequency2',fhigh,...
        'PassbandRipple1',1,...
        'PassbandRipple2',1,...
        'StopbandAttenuation',20,...
        'DesignMethod','ellip',...
        'MatchExactly','both');
        add_list = [handles.filename,passtype,'ellip-',num2str(flow*nyquist),'-',num2str(fhigh*nyquist),'.txt'];
    else
        add_list = '';
    end

end

yb = filtfilt(d,datax);  % filtfilt is okay. but it may not be included in some version of Matlab
data_filterout = [time,yb];
handles.add_list = add_list;
handles.data_filterout = data_filterout;

disp(' Ready to save')
guidata(hObject, handles);