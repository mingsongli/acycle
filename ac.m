function ac

%% ACYCLE
%% time-series analysis software for paleoclimate research and education
%%
% This is a start-up script for the Acycle software (MatLab version)
%
% Option 1: Right click ac.m , then select "Run". All set.
%
% Option 2: In MatLab Command Window, type:
%           ac
%           then press the "Enter" key. All set.
%
%%
%**************************************************************************
% Please acknowledge the program author on any publication of scientific 
% results based in part on use of the program and cite the following
% article in which the program was described:
%
%           Mingsong Li, Linda Hinnov, Lee Kump. 2019. Acycle: Time-series  
%           analysis software for paleoclimate projects and education,
%           Computers & Geosciences, https://doi.org/10.1016/j.cageo.2019.02.011
%
% If you publish results using techniques such as correlation coefficient,
% sedimentary noise model, power decomposition analysis, evolutionary fast
% Fourier transform, wavelet transform, Bayesian changepoint, (e)TimeOpt,
% or other approaches, please also cite original publications,
% as detailed in Acycle Wiki and the "AC_Users_Guide.pdf" file at
%
% https://github.com/mingsongli/acycle/wiki
% https://github.com/mingsongli/acycle/blob/master/doc/AC_Users_Guide.pdf
%
% Program Author:
%
%   Mingsong Li, PhD
%   3417 Yifu No. 2 Bldg, 
%   School of Earth and Space Sciences, Peking University
%   No. 5 Yiheyuan Road, Haidian, Beijing 100871, China
%   Contact:  msli@pku.edu.edu; limingsonglms@gmail.com
%   Website:  http://acycle.org
%             https://github.com/mingsongli/acycle
%             
% 
%   Linda A. Hinnov
%   Department of Atmospheric, Oceanic and Earth Sciences
%   George Mason University
%   3454 Exploratory Hall
%   Fairfax, Virginia 22030, USA
%   Email: lhinnov@gmu.edu
%   Website: http://mason.gmu.edu/~lhinnov/
%
% Copyright (C) 2017-2023
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
%help ac
ac_dir_str = which('ac.m');
[path_root,~,~] = fileparts(ac_dir_str);
% Test valid directory
pwd_init = pwd;



if ~isdeployed
    
    % MatLab version
    
    % add path for MatLab version
    addpath(genpath(path_root));
    % Please don't remove the following "Acknowledgment"
    help ac_acknowledgment
    try
        eval(['cd ',path_root])
        cd(pwd_init)
    catch
        errordlg('Directory may NOT contain non-English or non-numeric characters',...
            'Path Error')
    end
    try
        % splash screen
        s = SplashScreen( 'Splashscreen', 'acycle_logo.jpg', ...
                        'ProgressBar', 'on', ...
                        'ProgressPosition', 1, ...
                        'ProgressRatio', 0.05 );
        s.addText( 160, 460, 'Loading ...', 'FontSize', 50, 'Color', 'white' )
        % logo
        pause(0.25)
    catch
        
    end
else
    try
        % standalone version
        % splash screen
        s = SplashScreen( 'Splashscreen', 'acycle_logo.jpg', ...
                        'ProgressBar', 'on', ...
                        'ProgressPosition', 1, ...
                        'ProgressRatio', 0.05 );
        s.addText( 160, 460, 'Loading ...', 'FontSize', 50, 'Color', 'white' )
        s.addText( 140, 488, 'may take 10-60 seconds', 'FontSize', 20, 'Color', 'white' )
        pause(1)
        set(s,'ProgressRatio', 0.3)
        pause(1)
        set(s,'ProgressRatio', 0.5)
        pause(1)
    catch
    end
end


% start up Acycle GUI
AC

% delete splash screen
delete( s )
end
