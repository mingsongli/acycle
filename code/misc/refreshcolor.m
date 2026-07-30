% refresh add color in the list box
%
d = dir; %get files
if numel(d) >= 2
    d(1:2) = [];
else
    d = [];
end
address = pwd;
set(handles.edit_acfigmain_dir,'String',address);
% Save pwd outside the packaged CTF cache.
ac_working_directory('set',address);

if isempty(d)
    ac_update_listbox_acmain(handles.listbox_acmain,{},false(0,1));
    return
end

sd = ac_sort_dir_entries(d,handles.val1);
names = {sd.name};
isDir = [sd.isdir];
ac_update_listbox_acmain(handles.listbox_acmain,names,isDir);
