function [data,errorMessage] = bispectralReadDataFile(dataPath)
%BISPECTRALREADDATAFILE Read and validate one bispectral input file.
%   [DATA,ERRORMESSAGE] returns an empty DATA and a user-facing message for
%   invalid paths, unreadable files, or non-real matrices with fewer than two
%   columns. It does not open a dialog.

data = [];
if ~(ischar(dataPath) || (isstring(dataPath) && isscalar(dataPath)))
    errorMessage = 'The selected data path is invalid.';
    return
end
dataPath = char(dataPath);
if exist(dataPath,'file') ~= 2
    errorMessage = {'The selected data file no longer exists.';dataPath};
    return
end

loadedNumeric = false;
loadMessage = '';
try
    candidate = load(dataPath);
    if isnumeric(candidate)
        data = candidate;
        loadedNumeric = true;
    else
        loadMessage = 'load returned nonnumeric content.';
    end
catch exception
    loadMessage = exception.message;
end

if ~loadedNumeric
    try
        data = readmatrix(dataPath);
    catch exception
        errorMessage = { ...
            'Acycle could not read the selected data file.'; ...
            ['load: ',loadMessage]; ...
            ['readmatrix: ',exception.message]};
        data = [];
        return
    end
end

errorMessage = validateData(data);
if ~isempty(errorMessage)
    data = [];
end
end

function errorMessage = validateData(data)
errorMessage = '';
if ~isnumeric(data) || ~isreal(data) || ~ismatrix(data) || ...
        size(data,2) < 2
    errorMessage = { ...
        'Data format invalid.'; ...
        'Input must be a real 2-D numeric matrix with at least two columns.'; ...
        'Column 1 must be coordinate and column 2 must be value.'};
end
end
