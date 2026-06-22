% refresh add color in the list box
%
d = dir; %get files
d(1)=[];d(1)=[];
address = pwd;
set(handles.edit_acfigmain_dir,'String',address);
% Save pwd into a text file
ac_pwd_str = which('ac_pwd.txt');
[ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
fprintf(fileID,'%s',address);
fclose(fileID);

T = struct2table(d); % convert the struct array to a table

switch handles.val1
    case 1 % User selects unit.
        sortedT = sortrows(T, 'name', 'ascend'); % sort the table by 'date'
    case 2 % User selects unit.
        sortedT = sortrows(T, 'name', 'descend'); % sort the table by 'date'
    case 3 % User selects unit.
        sortedT = sortrows(T, 'date', 'ascend'); % sort the table by 'date'
    case 4 % User selects unit.
        sortedT = sortrows(T, 'date', 'descend'); % sort the table by 'date'
    case 5 % User selects unit.
        sortedT = sortrows(T, 'bytes', 'ascend'); % sort the table by 'date'
    case 6 % User selects unit.
        sortedT = sortrows(T, 'bytes', 'descend'); % sort the table by 'date'
end

sd = table2struct(sortedT); % change it back to struct array
names = {sd.name};
isDir = [sd.isdir];
ac_update_listbox_acmain(handles.listbox_acmain,names,isDir);
