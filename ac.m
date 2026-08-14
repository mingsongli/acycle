function ac

%% ACYCLE
%% Software for Time-Series Analysis in Paleoclimate Research and Education
%%
% Startup Instructions for Acycle Software (MATLAB Version)
%
% Option 1: Right-click on the file 'ac.m' and choose "Run". That's it!
%
% Option 2: Open the MATLAB Command Window, type 'ac', and hit "Enter". You're good to go!
%
%%
%**************************************************************************
% Acknowledgment and Citation Instructions for the Acycle Program:
% 
% If you use Acycle in your scientific work that leads to publication, 
% please acknowledge the program's author. Also, reference the following
% publication, which describes Acycle:
%
%   Mingsong Li, Linda Hinnov, Lee Kump. 2019. "Acycle: Time-Series 
%   Analysis Software for Paleoclimate Projects and Education," 
%   Computers & Geosciences. Available at: https://doi.org/10.1016/j.cageo.2019.02.011
%
% * Mingsong Li, 2026. "Acycle: Enhanced time-series analysis software for 
%   geoscience research and education,"  Science China Earth Sciences. 
%   https://doi.org/10.1007/s11430-025-1848-7
%
% * This paper presents standardized recommendations for reporting data and parameters; 
%   following these recommendations will improve the reproducibility and reliability of 
%   research results. The supplementary materials include a demonstration case study and
%   an Excel file for parameter documentation.
%
% Additionally, if your work involves specific techniques like correlation 
% coefficient, sedimentary noise model, power decomposition analysis, 
% evolutionary fast Fourier transform, wavelet transform, Bayesian changepoint,
% (e)TimeOpt, or other methods, please also cite the respective original 
% publications. Details on these references can be found in the 
% "Acycle_Users_Guide.pdf" document.
%
%**************************************************************************
%
%
% https://github.com/mingsongli/acycleDoc/blob/main/Acycle_Users_Guide.pdf
%
% Author Information for the Acycle Program:
%
%   Dr. Mingsong Li
%   Address: 3417 Yifu No. 2 Building, 
%            School of Earth and Space Sciences, 
%            Peking University, 
%            No. 5 Yiheyuan Road, Haidian District, 
%            Beijing 100871, China
%   Email: msli@pku.edu.edu; limingsonglms@gmail.com
%   Websites: http://acycle.org
%             https://github.com/mingsongli/acycle
%
% Copyright (C) 2017-2026 by Mingsong Li
%
% License Information:
%
% This software is freely available and can be redistributed and/or modified
% under the terms of the GNU General Public License as published by 
% the Free Software Foundation.
%
% This software is provided "as is" with no warranty of any kind, including
% the warranty of design, merchantability, and fitness for a particular purpose.
%
% The GNU General Public License can be accessed at <https://www.gnu.org/licenses/>.

%
%**************************************************************************
%%
% Determine the directory of 'ac.m'
ac_dir_str = which('ac.m');
[path_root, ~, ~] = fileparts(ac_dir_str);
% Store the initial working directory
pwd_init = pwd;

if ~isdeployed
    % If running in MATLAB (not compiled)

    % Add Acycle's runtime directories to MATLAB's search path. Development
    % tests are kept locally under code/test and must not shadow production
    % functions with the same name.
    addpath(genpath(path_root));
    acycle_test_root = fullfile(path_root,'code','test');
    if isfolder(acycle_test_root)
        acycle_test_paths = genpath(acycle_test_root);
        if ~isempty(acycle_test_paths)
            rmpath(acycle_test_paths);
        end
    end
    % Display an acknowledgment message (do not remove this line)
    %#exclude help
    help ac_acknowledgment

    % Change to Acycle's root directory and then revert to initial directory
    % This is necessary for Acycle's proper functioning
    try
        eval(['cd ', path_root])
        cd(pwd_init)
    catch
        % Error message if the directory path contains non-standard characters
        errordlg('Directory may NOT contain non-English or non-numeric characters',...
                 'Path Error');
    end

    % Display a splash screen with progress bar (if available)
    try
        s = SplashScreen('Splashscreen', 'acycle_logo.jpg', ...
                         'ProgressBar', 'on', ...
                         'ProgressPosition', 1, ...
                         'ProgressRatio', 0.05);
        splashCleanup = onCleanup(@()deleteSplashSafely(s));
        s.addText(160, 460, 'Loading ...', 'FontSize', 50, 'Color', 'white');
        pause(0.25);  % Short pause to display the splash screen
    catch
        % If splash screen fails to load, continue without it
    end
else
    % If running a compiled standalone version

    % Similar splash screen setup for the standalone version
    try
        s = SplashScreen('Splashscreen', 'acycle_logo.jpg', ...
                         'ProgressBar', 'on', ...
                         'ProgressPosition', 1, ...
                         'ProgressRatio', 0.05);
        splashCleanup = onCleanup(@()deleteSplashSafely(s));
        s.addText(160, 460, 'Loading ...', 'FontSize', 50, 'Color', 'white');
        s.addText(140, 488, 'may take 10-60 seconds', 'FontSize', 20, 'Color', 'white');
        pause(1);
        set(s,'ProgressRatio', 0.3);
        pause(1);
        set(s,'ProgressRatio', 0.5);
        pause(1);  % Pauses to simulate loading progress
    catch
        % If splash screen fails to load, continue without it
    end
end

% Launch the Acycle GUI
AC;

% Close the splash screen now on success. If AC errors, onCleanup closes it
% during stack unwinding while preserving the original exception.
if exist('splashCleanup','var')
    clear splashCleanup
end


function deleteSplashSafely(splash)
try
    if ~isempty(splash)
        delete(splash);
    end
catch
    % Splash cleanup must not replace the original startup error.
end
