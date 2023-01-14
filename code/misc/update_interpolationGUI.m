% code for interpolation GUI
% designed for Acycle v2.4.1
lang_var = handles.lang_var;
data = handles.data;

dt = str2double(get(handles.edit1,'string'));
method = get(handles.popupmenu1,'value');
x1 = str2double(get(handles.edit2,'string'));
x2 = str2double(get(handles.edit3,'string'));
y1 = str2double(get(handles.edit4,'string'));
y2 = str2double(get(handles.edit5,'string'));

gap2zero = get(handles.checkbox3,'value');
gapdt = str2double(get(handles.edit6,'string'));

xq = data(1,1):dt:data(end,1);

% language
if handles.lang_choice > 0
    [~, interpGUI04] = ismember('interpGUI04',handles.lang_id); % default
    [~, interpGUI05] = ismember('interpGUI05',handles.lang_id); % linear
    [~, interpGUI06] = ismember('interpGUI06',handles.lang_id); % interpolation
    
    [~, interpGUI07] = ismember('interpGUI07',handles.lang_id);
    [~, interpGUI08] = ismember('interpGUI08',handles.lang_id);
    [~, interpGUI09] = ismember('interpGUI09',handles.lang_id);
    [~, interpGUI10] = ismember('interpGUI10',handles.lang_id);
    [~, interpGUI11] = ismember('interpGUI11',handles.lang_id);
    [~, interpGUI12] = ismember('interpGUI12',handles.lang_id);
    [~, interpGUI13] = ismember('interpGUI13',handles.lang_id);
    [~, interpGUI14] = ismember('interpGUI14',handles.lang_id);
    
    % 1 = linear; 2 = nearest; 3 = next; 4 = previous
    % 5 = pchip; 6 = cubic; 7 = v5cubic; 8 = makima
    % 9 = spline;10= FFT
    if method == 1    
        vq = interp1(data(:,1),data(:,2),xq);
        title(['(',lang_var{interpGUI04},') ',lang_var{interpGUI05},lang_var{interpGUI06}]);
        legendi = 'linear';
    elseif method == 2
        vq = interp1(data(:,1),data(:,2),xq, 'nearest');
        titlei = lang_var{interpGUI07};
        legendi = 'nearest';
    elseif method == 3
        vq = interp1(data(:,1),data(:,2),xq, 'next');
        titlei = lang_var{interpGUI08};
        legendi = 'next';
    elseif method == 4
        vq = interp1(data(:,1),data(:,2),xq, 'previous');
        titlei = lang_var{interpGUI09};
        legendi = 'previous';
    elseif method == 5
        vq = interp1(data(:,1),data(:,2),xq, 'pchip');
        titlei = lang_var{interpGUI10};
        legendi = 'pchip';
    elseif method == 6
        vq = interp1(data(:,1),data(:,2),xq, 'cubic');
        titlei = lang_var{interpGUI11};
        legendi = 'cubic';
    elseif method == 7
        vq = interp1(data(:,1),data(:,2),xq, 'v5cubic');
        titlei = lang_var{interpGUI12};
        legendi = 'v5cubic';
    elseif method == 8
        vq = interp1(data(:,1),data(:,2),xq, 'makima');
        titlei = lang_var{interpGUI13};
        legendi = 'makima';
    elseif method == 9
        vq = interp1(data(:,1),data(:,2),xq,'spline');
        titlei = lang_var{interpGUI14};
        legendi = 'spline';
    end
else
    % 1 = linear; 2 = nearest; 3 = next; 4 = previous
    % 5 = pchip; 6 = cubic; 7 = v5cubic; 8 = makima
    % 9 = spline;10= FFT
    if method == 1    
        vq = interp1(data(:,1),data(:,2),xq);
        titlei = '(Default) Linear Interpolation';
        legendi = 'linear';
    elseif method == 2
        vq = interp1(data(:,1),data(:,2),xq, 'nearest');
        titlei = 'Nearest Neighbor Interpolation';
        legendi = 'nearest';
    elseif method == 3
        vq = interp1(data(:,1),data(:,2),xq, 'next');
        titlei = 'Next Neighbor Interpolation';
        legendi = 'next';
    elseif method == 4
        vq = interp1(data(:,1),data(:,2),xq, 'previous');
        titlei = 'Previous Neighbor Interpolation';
        legendi = 'previous';
    elseif method == 5
        vq = interp1(data(:,1),data(:,2),xq, 'pchip');
        titlei = 'Shape-preserving Piecewise Cubic Interpolation';
        legendi = 'pchip';
    elseif method == 6
        vq = interp1(data(:,1),data(:,2),xq, 'cubic');
        titlei = 'Cubic Interpolation';
        legendi = 'cubic';
    elseif method == 7
        vq = interp1(data(:,1),data(:,2),xq, 'v5cubic');
        titlei = 'V5cubic Interpolation';
        legendi = 'v5cubic';
    elseif method == 8
        vq = interp1(data(:,1),data(:,2),xq, 'makima');
        titlei = 'Modified Akima Cubic Hermite Interpolation';
        legendi = 'makima';
    elseif method == 9
        vq = interp1(data(:,1),data(:,2),xq,'spline');
        titlei = 'Spline Interpolation';
        legendi = 'spline';
    end
end
% force value=0 for gaps
if gap2zero == 1
    dfdt = diff(data(:,1));
    gapi = 0;
    gappair = [];
    for dti = 1 : length(dfdt)
        if dfdt(dti) > dt * gapdt
            gapi = gapi + 1;
            gappair(gapi,1) = data(dti,1);
            gappair(gapi,2) = data(dti+1,1);
            vq(and(xq> gappair(gapi,1), xq < gappair(gapi,2))) = 0;
        end
    end
end
if gap2zero == 1
    % language
    if handles.lang_choice > 0
        [~, interpGUI15] = ismember('interpGUI15',handles.lang_id);
        disp(lang_var{interpGUI15})
    else
        disp('start and end of gaps')
    end
    disp(gappair)
end

plot(handles.axes1,data(:,1),data(:,2),'o')
hold on
plot(handles.axes1,xq,vq,':.')

title(titlei);
legend('raw',legendi)
xlim([x1, x2])
ylim([y1, y2])
hold off