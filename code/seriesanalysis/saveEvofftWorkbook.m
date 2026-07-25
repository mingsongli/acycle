function saveEvofftWorkbook(outputFile,parameters,power,frequency,time,varargin)
%SAVEEVOFFTWORKBOOK Save one self-contained evolutionary-spectrum workbook.
%
% The first sheet records parameters. Remaining sheets preserve the three
% numerical outputs formerly written as separate text files. An optional
% sixth input adds the MTM red-noise diagnostic calculated for the plot.

validateattributes(outputFile,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'outputFile',1);
validateattributes(parameters,{'cell'},{'2d'},mfilename,'parameters',2);
validateattributes(power,{'numeric'},{'2d'},mfilename,'power',3);
validateattributes(frequency,{'numeric'},{'vector'},mfilename,'frequency',4);
validateattributes(time,{'numeric'},{'vector'},mfilename,'time',5);
redNoise = [];
if ~isempty(varargin)
    if numel(varargin) > 1
        error('saveEvofftWorkbook:TooManyInputs', ...
            'At most one optional MTM red-noise result may be supplied.');
    end
    redNoise = varargin{1};
    validateattributes(redNoise,{'numeric'},{'2d'}, ...
        mfilename,'redNoise',6);
end
if size(power,2) ~= numel(frequency) || size(power,1) ~= numel(time)
    error('saveEvofftWorkbook:InconsistentDimensions', ...
        ['POWER must have one row per TIME coordinate and one column ', ...
         'per FREQUENCY coordinate.']);
end
excelMaximumRows = 1048576;
excelMaximumColumns = 16384;
if size(power,1) > excelMaximumRows || ...
        size(power,2) > excelMaximumColumns
    error('saveEvofftWorkbook:ExcelSizeLimit', ...
        ['The power matrix is %d-by-%d; an .xlsx sheet supports at most ', ...
         '%d rows and %d columns.'],size(power,1),size(power,2), ...
        excelMaximumRows,excelMaximumColumns);
end

outputFile = char(string(outputFile));
[folder,~,extension] = fileparts(outputFile);
if isempty(folder)
    folder = pwd;
    outputFile = fullfile(folder,outputFile);
end
if ~strcmpi(extension,'.xlsx')
    error('saveEvofftWorkbook:InvalidExtension', ...
        'The consolidated evolutionary-spectrum output must be an .xlsx file.');
end
temporaryFile = [tempname(folder),'.xlsx'];
cleanup = onCleanup(@()deleteIfPresent(temporaryFile));

writecell(parameters,temporaryFile,'Sheet','Parameters','Range','A1');
writematrix(power,temporaryFile,'Sheet','Power','Range','A1');
writematrix(frequency(:),temporaryFile, ...
    'Sheet','Frequency','Range','A1');
writematrix(time(:),temporaryFile,'Sheet','Time','Range','A1');
if ~isempty(redNoise)
    if size(redNoise,2) == 7
        writecell({'Frequency','Power','Robust_AR1_median', ...
            'Robust_AR1_90pct','Robust_AR1_95pct', ...
            'Robust_AR1_99pct','Robust_AR1_99_9pct'}, ...
            temporaryFile,'Sheet','MTM_Red_Noise','Range','A1');
        redNoiseRange = 'A2';
    else
        redNoiseRange = 'A1';
    end
    writematrix(redNoise,temporaryFile, ...
        'Sheet','MTM_Red_Noise','Range',redNoiseRange);
end

[ok,message] = movefile(temporaryFile,outputFile,'f');
if ~ok
    error('saveEvofftWorkbook:AtomicSaveFailed', ...
        'Could not finalize the evolutionary-spectrum workbook: %s',message);
end
clear cleanup
end

function deleteIfPresent(path)
if isfile(path)
    delete(path);
end
end
