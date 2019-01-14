function ac

%% ACYCLE v0.3 
%%- a time-series analysis software for paleoclimate projects and education
%%
% This is a start-up script for the Acycle software (MatLab version)
%
% Option 1: Right-click ac.m , then select "Run". All set.
%
% Option 2: In MatLab Command Window, type:
%           ac
%           then press the "Enter" key. All set.
%%
%**************************************************************************
% Please acknowledge the program author on any publication of scientific 
% results based in part on use of the program and cite the following
% article in which the program was described:
%
%           Mingsong Li, Linda Hinnov, Lee Kump. Acycle: a time-series  
%           analysis software for paleoclimate projects and education,
%           Computers and Geosciences, in press
%
% If you publish results using techniques such as correlation coefficient,
% sedimentary noise model, power decomposition analysis, evolutionary fast
% Fourier transform, wavelet transform, Bayesian changepoint, gaussian
% processes toolbox, or other approaches, please also cite original
% publications, as detailed in "AC_Users_Guide.pdf" file at
%
% https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
%
% Program Author:
%           Mingsong Li
%           Department of Geosciences
%           Pennsylvania State University
%           410 Deike Bldg, 
%           University Park, PA 16801, USA
%
% Email:    mul450@psu.edu; limingsonglms@gmail.com
% Website:  https://github.com/mingsongli/acycle
%           http://mingsongli.com
%
% Copyright (C) 2017-2019
%
% This program is a free software; you can redistribute it and/or modify it
% under the terms of the GNU GENERAL PUBLIC LICENSE as published by the 
% Free Software Foundation.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
% or FITNESS FOR A PARTICULAR PURPOSE.
%
% You should have received a copy of the GNU General Public License. If
% not, see < https://www.gnu.org/licenses/ >
%
%**************************************************************************
%%
%restoredefaultpath;
%
ac_dir_str = which('ac.m');
[path_root,~,~] = fileparts(ac_dir_str);
% Test valid directory
pwd_init = pwd;
try 
    eval(['cd ',path_root])
    cd(pwd_init)
catch
    errordlg('Directory may NOT contain SPACE, non-English or non-numeric characters',...
        'Path Error')
end
% add path
addpath(genpath(path_root));
% start up
AC
end