function [dataMatrix,axisValues,seriesNames,baseName,errorMessage] = ...
        multivariateLoadSelection(context,selectedNames)
%MULTIVARIATELOADSELECTION Load and stack Acycle main-list series.
%   [DATAMATRIX,AXIS,NAMES,BASENAME,ERRORMESSAGE] = ...
%       MULTIVARIATELOADSELECTION(CONTEXT,SELECTEDNAMES) resolves each
%   cleaned file name against Acycle's working directory, reads it as a
%   two-column series (numeric load first, tolerant textscan fallback),
%   and stacks the second columns into an n-by-p matrix.
%
%   Rows are stratigraphic horizons: every series must therefore have the
%   same number of rows, the same requirement as Acycle's Principal
%   Component analysis. The first column of the first series provides the
%   common depth/time axis.
%
%   CONTEXT is the main-window handles struct (only ac_pwd resolution via
%   GETac_pwd is used). SELECTEDNAMES is a cellstr of file names with any
%   list markup already removed. On success ERRORMESSAGE is empty; on
%   failure all outputs except ERRORMESSAGE are empty.

dataMatrix = [];
axisValues = [];
seriesNames = {};
baseName = '';
errorMessage = '';

if nargin < 1 || ~isstruct(context)
    context = struct();
end
if isempty(selectedNames) || ~iscellstr(selectedNames)
    errorMessage = 'No data files were selected.';
    return
end

GETac_pwd;   % sets ac_pwd to Acycle's working directory

columnCount = 0;
rowCount = [];
axisValues = [];
dataMatrix = [];
seriesNames = cell(1,numel(selectedNames));

for k = 1:seriesCount
    filePath = fullfile(ac_pwd,selectedNames{k});
    if isfolder(filePath)
        errorMessage = sprintf('"%s" is a folder, not a data file.',selectedNames{k});
        dataMatrix = [];
        axisValues = [];
        return
    end
    series = readTwoColumnSeries(filePath);
    if isempty(series)
        errorMessage = sprintf( ...
            'Could not read "%s" as a two-column numeric series.',selectedNames{k});
        dataMatrix = [];
        axisValues = [];
        return
    end
    series = series(~any(isnan(series),2),:);   % remove empty rows
    if size(series,1) < 3
        errorMessage = sprintf( ...
            '"%s" has fewer than 3 complete rows after removing empty lines.', ...
            selectedNames{k});
        dataMatrix = [];
        axisValues = [];
        return
    end

    if k == 1
        rowCount = size(series,1);
        axisValues = series(:,1);
    elseif size(series,1) ~= rowCount
        errorMessage = sprintf( ...
            ['The number of rows of the selected series must be the same ', ...
             '(series "%s" has %d rows, the first series has %d). ', ...
             'Interpolate the series to a common grid first ', ...
             '(Math > Interpolation).'], ...
            selectedNames{k},size(series,1),rowCount);
        dataMatrix = [];
        axisValues = [];
        return
    end

    columnCount = columnCount + 1;
    dataMatrix(:,columnCount) = series(:,2);
    [~,seriesBase] = fileparts(selectedNames{k});
    seriesNames{columnCount} = seriesBase;
    if k == 1
        baseName = seriesBase;
    end
end
end


function data = readTwoColumnSeries(filePath)
% Read a two-column numeric series with the same fallback chain the
% Principal Component callback uses: numeric load, then a tolerant
% textscan pass over common delimiters.
data = [];
try
    loaded = load(filePath);
catch
    loaded = [];
end
if ~isempty(loaded)
    if ismatrix(loaded) && isnumeric(loaded) && size(loaded,2) >= 2
        data = loaded(:,1:2);
        return
    end
    if isstruct(loaded)
        fields = fieldnames(loaded);
        for k = 1:numel(fields)
            candidate = loaded.(fields{k});
            if isnumeric(candidate) && ismatrix(candidate) && size(candidate,2) >= 2 ...
                    && size(candidate,1) >= 1
                data = candidate(:,1:2);
                return
            end
        end
    end
end

try
    fid = fopen(filePath,'r');
    if fid == -1
        return
    end
    cleanup = onCleanup(@() fclose(fid));
    scanned = textscan(fid,'%f%f','Delimiter',{';','*',',','\t','\b',' '}, ...
        'EmptyValue',Inf);
    if iscell(scanned) && numel(scanned) == 2
        column1 = scanned{1};
        column2 = scanned{2};
        data = [column1(:),column2(:)];
    end
catch
    data = [];
end
end
