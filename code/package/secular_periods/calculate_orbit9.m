function orbit9 = calculate_orbit9(ageMa)
% CALCULATE_ORBIT9 Calculate nine principal astronomical frequencies
% and their corresponding periods at a specified geological age.
%
% INPUT
%   ageMa  - Geological age in Ma. The input age is rounded to the
%            nearest integer Ma before calculation.
%
% DATA FILES
%   AstroGeo22.txt
%       Column 1  : time in Ga
%       Column 11 : precession constant k, in arcsec/yr
%
%   La04gisi.csv
%       One row with 18 columns:
%       g1, g2, ..., g9, s1, s2, ..., s9
%       All frequencies are assumed to be in arcsec/yr.
%
% OUTPUT
%   orbit9 - A 9-by-2 matrix:
%            Column 1: astronomical frequency, in arcsec/yr
%            Column 2: astronomical period, in years
%
%   The nine frequencies are arranged as:
%       1. g2 - g5
%       2. g3 - g2
%       3. g4 - g2
%       4. g3 - g5
%       5. g4 - g5
%       6. k  + s3
%       7. k  + g5
%       8. k  + g2
%       9. k  + g4

    %% Check the input
    if nargin < 1
        error('An input age in Ma is required.');
    end

    if ~isnumeric(ageMa) || ~isscalar(ageMa) || ~isfinite(ageMa)
        error('ageMa must be a finite numeric scalar.');
    end

    %% Round the age to the nearest integer Ma and convert Ma to Ga
    ageMa = round(ageMa);
    ageGa = ageMa / 1000;

    %% Read bundled secular-frequency resources relative to this function.
    % GUI and publication batch runs commonly change the current folder;
    % bare filenames would then fail even though the resources are installed.
    resourceDirectory = fileparts(mfilename('fullpath'));
    astroPath = fullfile(resourceDirectory,'AstroGeo22.txt');
    gisiPath = fullfile(resourceDirectory,'La04gisi.csv');
    if exist(astroPath,'file') ~= 2 || exist(gisiPath,'file') ~= 2
        error('calculate_orbit9:MissingResource', ...
            ['Cannot locate the bundled AstroGeo22.txt and La04gisi.csv ', ...
             'resources beside calculate_orbit9.m.']);
    end
    astroData = readmatrix(astroPath);

    if size(astroData, 2) < 11
        error('AstroGeo22.txt must contain at least 11 columns.');
    end

    timeGa = astroData(:, 1);

    % Find the row whose time is closest to the requested age.
    % The tolerance accounts for floating-point precision.
    [timeDifference, rowIndex] = min(abs(timeGa - ageGa));

    toleranceGa = 1e-8;

    if timeDifference > toleranceGa
        error(['No corresponding time row was found in AstroGeo22.txt ', ...
               'for age %d Ma (%.6f Ga).'], ageMa, ageGa);
    end

    % Precession constant k at the specified age
    k = astroData(rowIndex, 11);

    %% Read the g and s frequencies
    gisiData = readmatrix(gisiPath);

    % Remove rows or columns that are entirely NaN, which may be produced
    % by headers or empty cells in the CSV file.
    gisiData = gisiData(~all(isnan(gisiData), 2), :);
    gisiData = gisiData(:, ~all(isnan(gisiData), 1));

    if isempty(gisiData) || size(gisiData, 2) < 18
        error('La04gisi.csv must contain at least one row and 18 columns.');
    end

    % Use the first valid row.
    % Columns 1-9 are g1-g9; columns 10-18 are s1-s9.
    g = gisiData(1, 1:9);
    s = gisiData(1, 10:18);

    %% Calculate the nine principal astronomical frequencies
    freq9 = [ ...
        g(2) - g(5);   % g2 - g5
        g(3) - g(2);   % g3 - g2
        g(4) - g(2);   % g4 - g2
        g(3) - g(5);   % g3 - g5
        g(4) - g(5);   % g4 - g5
        k    + s(3);   % k + s3
        k    + g(5);   % k + g5
        k    + g(2);   % k + g2
        k    + g(4)];  % k + g4

    %% Convert frequencies to periods
    % There are 360 degrees in a cycle and 3600 arcseconds per degree.
    % abs() ensures that the calculated periods are positive.
    period9 = 360 * 3600 ./ abs(freq9);

    %% Combine frequencies and periods
    % Column 1: frequency in arcsec/yr
    % Column 2: period in years
    orbit9 = [freq9, period9];

end
