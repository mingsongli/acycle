% code for interpolation GUI
% designed for Acycle v2.4.1

data = handles.data;

dt = str2double(get(handles.edit1,'string'));
method = get(handles.popupmenu1,'value');
x1 = str2double(get(handles.edit2,'string'));
x2 = str2double(get(handles.edit3,'string'));
y1 = str2double(get(handles.edit4,'string'));
y2 = str2double(get(handles.edit5,'string'));

xq = data(1,1):dt:data(end,1);
% 1 = linear; 2 = nearest; 3 = next; 4 = previous
% 5 = pchip; 6 = cubic; 7 = v5cubic; 8 = makima
% 9 = spline
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

plot(handles.axes1,data(:,1),data(:,2),'o')
hold on
plot(handles.axes1,xq,vq,':.')

title(titlei);
legend('raw',legendi)
xlim([x1, x2])
ylim([y1, y2])
hold off