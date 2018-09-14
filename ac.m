function ac

% Start-up script for the acycle software
%
% In MatLab command window, type:

%   ac

% then, press "Enter" to run the acycle
%
% Directory of the Acycle folder should NOT contain SPACE, non-English
%  or non-numeric characters
%
% By Mingsong Li, Penn State, 2017-2018 (c)
%
%
restoredefaultpath;
ac_dir_str = which('ac.m');
[path_root,~,~] = fileparts(ac_dir_str);

pwd_init = pwd;
try 
    eval(['cd ',path_root])
    cd(pwd_init)
catch
    errordlg('Directory of the Acycle folder should NOT contain SPACE, non-English or non-numeric characters','Path Error')
end

addpath(genpath(path_root));

if ismac
    GuiFolder = fullfile(path_root,['/','code','/','guiwin']);
elseif ispc
    GuiFolder = fullfile(path_root,['\','code','\','gui']);
end

try
    rmpath(GuiFolder);
catch
    errordlg('Acycle works with Mac and Windows only!')
end
%
AC
clear ac_dir_str path_root;
end