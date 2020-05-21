set(handles.popupmenu5,'value',1)
% read filter method
filter = handles.filter;
data = handles.current_data;
datax=data(:,2);
time = data(:,1);
npts = length(time);
dt=mean(diff(time));
nyquist = 1/(2*dt);
rayleigh = 1/(dt*npts);

fm = str2double(get(handles.edit1,'string')); % mean freq.
fb = str2double(get(handles.edit2,'string')); %bandwidth

if fb<=0
    % in case fmin >= fmid
    warndlg('Minimum bandwidth must be >= 0. Set it to 0.2 * freq')
    fb = 0.2 * fm;
    f1 = fm - fb;
    f2 = fm;
    f3 = fm + fb;
    
    flch = [f1 f2 f3];
    flch = sort(flch);
    ftext3 = [num2str(flch(1)),' ~ ',num2str(flch(3))];
    set(handles.edit2,'string',num2str(fb))
    set(handles.text3,'string',ftext3)
else
    f1 = fm - fb;
    f2 = fm;
    f3 = fm + fb;
    flch = [f1 f2 f3];
    flch = sort(flch);
    ftext3 = [num2str(flch(1)),' ~ ',num2str(flch(3))];
    set(handles.text3,'string',ftext3)
end

handles.flch = flch;
handles.ftmin = flch(1);
handles.ftmid = flch(2);
handles.ftmax = flch(3);

flow = flch(1)/nyquist; % lowpass
fcenter = flch(2)/nyquist;
fhigh = flch(3)/nyquist; % highpass

taner_c = 10^str2double(get(handles.edit18,'string'));

x_1 = str2double(get(handles.edit10,'string'));
x_2 = str2double(get(handles.edit11,'string'));
y_1 = str2double(get(handles.edit12,'string'));
y_2 = str2double(get(handles.edit13,'string'));

L = length(data(:,2));
dt = mean(diff(data(:,1)));
Y = fft(data(:,2),L);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1/dt * (0:(L/2))/L;

if strcmp(filter,'Gaussian')
    set(handles.edit18,'enable','off')
    fwidth = abs(f2 - f1);
    gauss_mf = max(P1)*gaussmf(f,[fwidth fm]);
    % plot
    axes(handles.ft_axes3);
    plot(f,P1)
    hold on
    plot(f,gauss_mf,'r-')
    xlim([x_1, x_2])
    ylim([y_1, y_2])
    hold off
    axes(handles.ft_axes4);
    xlim([x_1, x_2])
    % update data and names
    [gaussbandx,filter,f]=gaussfilter(datax,dt,flch(2),flch(1),flch(3));
    data_filterout = [time,gaussbandx];
    add_list = [handles.dat_name,'-Gau-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'.txt'];
    
elseif strcmp(filter,'Taner-Hilbert')
    set(handles.edit18,'enable','on')
    % update data and names
    [tanhilb,handles.ifaze,handles.ifreq] = ...
    tanerhilbertML(data,flch(2),flch(1),flch(3),taner_c);

    tanerfilterenv = evalin('base','tanerfilterenv');
    tf = tanerfilterenv(1:floor(L/2)+1) ./ max(tanerfilterenv(1:floor(L/2)+1)) .* max(P1);
    % plot
    axes(handles.ft_axes3);
    plot(f,P1)
    hold on
    plot(f,tf,'r-')
    xlim([x_1, x_2])
    ylim([y_1, y_2])
    hold off
    axes(handles.ft_axes4);
    xlim([x_1, x_2])
    
    handles.filterdd = tanhilb;
    add_list = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'.txt'];
    add_list_am = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'-AM.txt'];
    add_list_ufaze = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'-ufaze.txt'];
    add_list_ufazedet = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'-ufazedet.txt'];
    add_list_ifaze = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'-ifaze.txt'];
    add_list_ifreq = [handles.dat_name,'-Tan-',num2str(flch(2)),char(177),num2str(abs(flch(2)-flch(3))),'-e',num2str(log10(taner_c)),'-ifreq.txt'];
    data_filterout = tanhilb;
    handles.add_list_am = add_list_am;
    handles.add_list_ufaze = add_list_ufaze;
    handles.add_list_ufazedet = add_list_ufazedet;
    handles.add_list_ifaze = add_list_ifaze;
    handles.add_list_ifreq = add_list_ifreq;
    
elseif strcmp(filter,'Cheby1')
    set(handles.edit18,'enable','off')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'PassbandFrequency1',flow,...
    'PassbandFrequency2',fhigh,...
    'PassbandRipple',1,...
    'DesignMethod','cheby1');
    yb = filtfilt(d,datax);
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-Cheby1-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];
    
elseif strcmp(filter,'Ellip')
    set(handles.edit18,'enable','off')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'PassbandFrequency1',flow,...
    'PassbandFrequency2',fhigh,...
    'StopbandAttenuation1',20,...
    'PassbandRipple',1,...
    'StopbandAttenuation2',20,...
    'DesignMethod','ellip');
    yb = filtfilt(d,datax);
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-Ellip-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];

elseif strcmp(filter,'Butter')
    set(handles.edit18,'enable','off')
    d = designfilt('bandpassiir', ...
        'FilterOrder',6, ...
    'HalfPowerFrequency1',flow,...
    'HalfPowerFrequency2',fhigh,...
    'DesignMethod','butter');
    yb = filtfilt(d,datax);  % filtfilt is okay. but it may not be included in some version of Matlab
    data_filterout = [time,yb];
    add_list = [handles.dat_name,'-Butter-',num2str(flch(1)),'-',num2str(flch(3)),'.txt'];
    
else
    set(handles.edit18,'enable','on')
    add_list = '';
    data_filterout = '';
    axes(handles.ft_axes3);
    plot(f,P1)
    xlim([x_1, x_2])
    ylim([y_1, y_2])
    hold off
    axes(handles.ft_axes4);
    xlim([x_1, x_2])
end

handles.add_list = add_list;
handles.data_filterout = data_filterout;
guidata(hObject, handles);