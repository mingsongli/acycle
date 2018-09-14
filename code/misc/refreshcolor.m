% refresh add color in the list box
pre  = '<HTML><FONT color="blue">';
post = '</FONT></HTML>';
d = dir; %get files
address = pwd;
set(handles.edit1,'String',address);
listboxStr = cell(numel(d),1);
% Save pwd into a text file
ac_pwd_str = which('ac_pwd.txt');
[ac_pwd_dir,ac_pwd_name,ext] = fileparts(ac_pwd_str);
fileID = fopen(fullfile(ac_pwd_dir,'ac_pwd.txt'),'w');
fprintf(fileID,'%s',address);
fclose(fileID);
%
for i = 1:numel( d )
    if isdir(d(i).name)
        str = [pre d(i).name post];
        listboxStr{i} = str;
    else
        listboxStr{i} = d(i).name;
    end
end
set(handles.listbox1,'String',listboxStr,'Value',1) %set string