function ac

% The start-up script for acycle
% in MatLab command window, type
%   ac
% press "Enter" to run the acycle
%
% By (c) Mingsong Li, Penn State, 2017-2018
%
%

ac_dir_str = which('ac.m');
[path_root,~,~] = fileparts(ac_dir_str);
addpath(genpath(path_root));

%
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