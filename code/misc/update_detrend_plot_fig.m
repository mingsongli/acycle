% update_detrend_plot_fig
% for the detrending tool

% read data
prewhiten_win_edit1 = str2double(get(handles.edit10,'String'));
handles.prewhiten_win = prewhiten_win_edit1;
% smooth win 
handles.smooth_win = prewhiten_win_edit1/handles.xrange;  % windows for smooth 

% lang
lang_id = handles.lang_id;
lang_var = handles.lang_var;

[~, Fitting07] = ismember('Fitting07',lang_id);
[~, Fitting08] = ismember('Fitting08',lang_id);
[~, Fitting09] = ismember('Fitting09',lang_id);

[~, Fitting14] = ismember('Fitting14',lang_id);
[~, Fitting15] = ismember('Fitting15',lang_id);
[~, Fitting16] = ismember('Fitting16',lang_id);
[~, Fitting17] = ismember('Fitting17',lang_id);
[~, Fitting18] = ismember('Fitting18',lang_id);
[~, Fitting19] = ismember('Fitting19',lang_id);
[~, Fitting20] = ismember('Fitting20',lang_id);
[~, Fitting21] = ismember('Fitting21',lang_id);
[~, Fitting22] = ismember('Fitting22',lang_id);
% mean
if get(handles.prewhiten_mean_checkbox, 'Value') == 1
    handles.prewhiten_mean = get(handles.prewhiten_mean_checkbox, 'String');
else
    handles.prewhiten_mean = '';
end
% linear
if get(handles.prewhiten_linear_checkbox, 'Value') == 1
    handles.prewhiten_linear = get(handles.prewhiten_linear_checkbox, 'String');
else
    handles.prewhiten_linear = '';
end
% 2nd
if get(handles.checkbox11, 'Value') == 1
    handles.prewhiten_polynomial2 = get(handles.checkbox11, 'String');
else
    handles.prewhiten_polynomial2 = '';
end
polynomialmore = get(handles.checkbox13,'Value');
% LOWESS
if get(handles.prewhiten_lowess_checkbox, 'Value') == 1
    handles.prewhiten_lowess = get(handles.prewhiten_lowess_checkbox, 'String');
else
    handles.prewhiten_lowess = '';
end
% rLOWESS
if get(handles.prewhiten_rlowess_checkbox, 'Value') == 1
    handles.prewhiten_rlowess = get(handles.prewhiten_rlowess_checkbox, 'String');
else
    handles.prewhiten_rlowess = '';
end
% LOESS
if get(handles.prewhiten_loess_checkbox, 'Value') == 1
    handles.prewhiten_loess = get(handles.prewhiten_loess_checkbox, 'String');
else
    handles.prewhiten_loess = '';
end
% rLOESS
if get(handles.prewhiten_rloess_checkbox, 'Value') == 1
    handles.prewhiten_rloess = get(handles.prewhiten_rloess_checkbox, 'String');
else
    handles.prewhiten_rloess = '';
end
% Savitzky-Golay
if get(handles.checkbox34, 'Value') == 1
    handles.prewhiten_sgolay = get(handles.checkbox34, 'String');
else
    handles.prewhiten_sgolay = '';
end

try figure(handles.detrendfig)
    
catch
    handles.detrendfig = figure;
end

set(gcf,'Color', 'white')
current_data = handles.current_data;
smooth_win = handles.smooth_win;
unit = handles.unit;
datax=current_data(:,1);
datay=current_data(:,2);
dataymean = nanmean(datay);
npts=length(datax);
win = smooth_win * (max(datax)-min(datax));

plot(datax,datay,'-k');
axis([min(datax) max(datax) min(datay) max(datay)])

 

fig = gcf;

hold on;
prewhiten_list = 1;
prewhiten = {};
title_trend = 0;
%prewhiten(prewhiten_list,1)={'No_prewhiten (black)'};
prewhiten(prewhiten_list,1)={lang_var{Fitting14}};

if strcmp(handles.prewhiten_mean,lang_var{Fitting07})
    datamean = dataymean * ones(npts,1);
    hlin = line([min(datax),max(datax)],[dataymean,dataymean]);
    set(hlin,'Linewidth',2.5,'Color','k')
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting15}};
end

if strcmp(handles.prewhiten_linear,lang_var{Fitting08})
    sdat=polyfit(datax,datay,1);
    datalinear=datax*sdat(1)+sdat(2);
    plot(datax,datalinear,'-y','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting16}};
end

if strcmp(handles.prewhiten_polynomial2,lang_var{Fitting09})
    sdat=polyfit(datax,datay,2);
    data2nd=polyval(sdat,datax);
    plot(datax,data2nd,':r','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting17}};
end

if polynomialmore == 1
    polynomial_value = str2double(get(handles.edit23,'String'));
    sdat=polyfit(datax,datay,polynomial_value);
    datamore=polyval(sdat,datax);
    plot(datax,datamore,'b-.','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting18}};
end

if strcmp(handles.prewhiten_lowess,'LOWESS')
    datalowess=smooth(datax,datay, smooth_win,'lowess');
    plot(datax,datalowess,'-g','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting22}};
    title_trend = 1;
end

if strcmp(handles.prewhiten_rlowess,'rLOWESS')
    datarlowess=smooth(datax,datay, smooth_win,'rlowess');
    plot(datax,datarlowess,':b','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting19}};
    title_trend = 1;
end

if strcmp(handles.prewhiten_loess,'LOESS')
    dataloess=smooth(datax,datay, smooth_win,'loess');
    plot(datax,dataloess,'--r','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting20}};
    title_trend = 1;
end

if strcmp(handles.prewhiten_rloess,'rLOESS')
    datarloess=smooth(datax,datay, smooth_win,'rloess');
    plot(datax,datarloess,'--m','Linewidth',2)
    prewhiten_list = prewhiten_list + 1;
    prewhiten(prewhiten_list,1) = {lang_var{Fitting21}};
    title_trend = 1;
end



if or(handles.lang_choice == 0, handles.main_unit_selection == 0)
    if handles.unit_type == 0
        xlabel(['Unit (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel(['Depth (',handles.unit,')'])
    else
        xlabel(['Time (',handles.unit,')'])
    end
    
    if title_trend == 1
        title(['Raw data & ',num2str(win),'-',unit,' trend'])
    end

else
    [~, main34] = ismember('main34',handles.lang_id); % unit
    [~, main23] = ismember('main23',handles.lang_id);
    [~, main21] = ismember('main21',handles.lang_id);
    [~, Fitting14] = ismember('Fitting14',handles.lang_id);
    [~, Fitting23] = ismember('Fitting23',handles.lang_id);

    if handles.unit_type == 0
        xlabel([lang_var{main34},' (',handles.unit,')'])
    elseif handles.unit_type == 1
        xlabel([lang_var{main23},' (',handles.unit,')'])
    else
        xlabel([lang_var{main21},' (',handles.unit,')'])
    end
    if title_trend == 1
        title([lang_var{Fitting14},' & ',num2str(win),'-',unit,' ',lang_var{Fitting23}])
    end
end

hold off

legendlist = [];
for j = 1: prewhiten_list
    legendlist = [legendlist, prewhiten(j,1)];
end
legend(legendlist)
set(handles.prewhiten_select_popupmenu,'String',prewhiten,'Value',1);
set(gca,'XMinorTick','on','YMinorTick','on')


% prepare data for export
if exist('datamean')
else
    datamean = zeros(npts,1);
end
if exist('datalinear')
else
    datalinear = zeros(npts,1);
end
if exist('data2nd')
else
    data2nd = zeros(npts,1);
end
if exist('datamore')
else
    datamore = zeros(npts,1);
end
if exist('datalowess')
else
    datalowess = (zeros(npts,1));
end
if exist('datarlowess')
else
    datarlowess = (zeros(npts,1));
end
if exist('dataloess')
else
    dataloess = (zeros(npts,1));
end
if exist('datarloess')
else
    datarloess = (zeros(npts,1));
end
if exist('datasgolay')
else
    datasgolay = (zeros(npts,1));
end

handles.prewhiten_data1 = [datax,datay,(datay-datalinear),datalinear,(datay-datamean),datamean];
handles.prewhiten_data2 = [(datay-datalowess),datalowess,(datay-datarlowess),datarlowess,...
    (datay-dataloess),dataloess,(datay-datarloess),datarloess,...
    (datay-data2nd),data2nd,(datay-datamore),datamore];