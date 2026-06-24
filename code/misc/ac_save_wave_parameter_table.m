function ac_save_wave_parameter_table(handles, baseName, inputNames)
% Save wavelet GUI parameters using the Acycle parameter table layout.

paramFile = ac_wave_next_file([baseName,'-wavelet-parameters'],'.xls');
params = repmat({''},22,6);
params(1,2) = {'Detailed Parameters Used in Data Processing by Acycle'};
params(2,2:6) = {'Version','Designed by','Institute','E-mail','Date'};
params(3,2:6) = {'v1.1','Mingsong Li','Peking University','msli@pku.edu.cn',datestr(now,'yyyy-mm-dd HH:MM:SS')};
params(5,2:5) = {'Tools','Items','Parameters','Explanations'};

methodList = get(handles.popupmenu1,'String');
method = methodList{get(handles.popupmenu1,'Value')};
mother = 'NA';
try
    motherList = get(handles.popupmenu2,'String');
    mother = motherList{get(handles.popupmenu2,'Value')};
catch
end
powerScale = 'linear';
if get(handles.checkbox10,'Value')
    powerScale = ['log',get(handles.edit9,'String')];
end
periodScale = 'linear';
if get(handles.radiobutton2,'Value')
    periodScale = 'log2';
end

params(7,:) = {'','Wavelet','Input file name',strjoin(cellstr(inputNames),', '),'',''};
params(8,:) = {'','','Method',method,'',''};
params(9,:) = {'','','Mother',mother,'',''};
params(10,:) = {'','','Parameter',get(handles.edit7,'String'),'',''};
params(11,:) = {'','','Period minimum',get(handles.edit3,'String'),'',''};
params(12,:) = {'','','Period maximum',get(handles.edit4,'String'),'',''};
params(13,:) = {'','','Discrete scale spacing',get(handles.edit5,'String'),'',''};
params(14,:) = {'','','Period scale',periodScale,'Select linear/log2',''};
params(15,:) = {'','','Padding',ac_wave_yesno(get(handles.checkbox1,'Value')),'Select Yes or No',''};
params(16,:) = {'','','Standardize',ac_wave_yesno(get(handles.checkbox11,'Value')),'Select Yes or No',''};
params(17,:) = {'','','Cone of influence',ac_wave_yesno(get(handles.checkbox8,'Value')),'Select Yes or No',''};
params(18,:) = {'','','Significance level',ac_wave_significance_level(get(handles.checkbox9,'Value')),'',''};
params(19,:) = {'','','Power scale',powerScale,'',''};
params(20,:) = {'','','Z level',ac_wave_yesno(get(handles.checkbox12,'Value')),'Select Yes or No',''};
params(21,:) = {'','','Colormap',ac_wave_selected_string(handles.popupmenu3),'',''};
params(22,:) = {'','','Grid number',ac_wave_or_na(get(handles.edit6,'String')),'',''};

writecell(params,paramFile,'Sheet','COCO');
end

function s = ac_wave_yesno(tf)
if tf
    s = 'Yes';
else
    s = 'No';
end
end

function s = ac_wave_or_na(v)
s = strtrim(char(v));
if isempty(s)
    s = 'NA';
end
end

function s = ac_wave_significance_level(tf)
if tf
    s = 'p = 0.05';
else
    s = 'NA';
end
end

function s = ac_wave_selected_string(h)
items = get(h,'String');
s = items{get(h,'Value')};
end

function filename = ac_wave_next_file(baseName,ext)
for ii = 1:9999
    filename = sprintf('%s-%d%s',baseName,ii,ext);
    if ~exist(filename,'file')
        return
    end
end
filename = sprintf('%s-%s%s',baseName,datestr(now,'yyyymmddTHHMMSS'),ext);
end
