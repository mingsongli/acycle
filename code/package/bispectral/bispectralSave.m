function files = bispectralSave(result,fig,outputDirectory,baseName)
%BISPECTRALSAVE Save reproducible bispectral results without overwriting.
%   Creates one uniquely named result folder per call. The folder contains
%   a strictly vector PDF, editable MATLAB FIG, complete MAT result,
%   preprocessed-series CSV, and JSON configuration. Every filename carries
%   the unique result-folder stem, and the complete folder is committed
%   atomically.

if nargin < 3 || isempty(outputDirectory)
    outputDirectory = pwd;
end
if ~isfolder(outputDirectory)
    [ok,message] = mkdir(outputDirectory);
    if ~ok
        error('Acycle:Bispectral:CreateOutputDirectory','%s',message);
    end
end
if nargin < 4 || isempty(baseName)
    baseName = result.InputName;
end
rawBaseName = char(baseName);
[~,namePart,extensionPart] = fileparts(rawBaseName);
knownDataExtensions = {'.txt','.csv','.dat','.out','.res','.tab','.mat','.xlsx','.xls'};
if any(strcmpi(extensionPart,knownDataExtensions))
    baseName = namePart;
else
    baseName = [namePart,extensionPart];
end
baseName = regexprep(baseName,'[^A-Za-z0-9._-]+','-');
baseName = regexprep(baseName,'^-+|-+$','');
if isempty(baseName)
    baseName = 'data';
end
if numel(baseName) > 100
    baseName = baseName(1:100);
end

resultDirectory = uniqueResultDirectory(outputDirectory,baseName);
[~,resultStem] = fileparts(resultDirectory);

files = struct( ...
    'Directory',resultDirectory, ...
    'PDF',fullfile(resultDirectory,[resultStem,'.pdf']), ...
    'FIG',fullfile(resultDirectory,[resultStem,'.fig']), ...
    'MAT',fullfile(resultDirectory,[resultStem,'.mat']), ...
    'ProcessedCSV',fullfile(resultDirectory, ...
        [resultStem,'-preprocessed.csv']), ...
    'ConfigJSON',fullfile(resultDirectory,[resultStem,'-config.json']));

if isempty(fig) || ~isgraphics(fig,'figure')
    error('Acycle:Bispectral:InvalidFigure','A valid figure is required for saving.');
end
renderSettings = getappdata(fig,'BispectralRenderSettings');
if ~isstruct(renderSettings) || ~isscalar(renderSettings) || isempty(fieldnames(renderSettings))
    error('Acycle:Bispectral:MissingRenderSettings', ...
        ['The figure does not contain BispectralRenderSettings. Create it ', ...
        'with bispectralPlot before saving so the archive describes the ', ...
        'actual rendered figure.']);
end
result.RenderSettings = renderSettings;

% Build the complete five-file group in a private directory on the same
% filesystem. Only after every writer succeeds is the directory renamed to
% its final unique name. A failed writer therefore leaves no result folder.
temporaryDirectory = tempname(outputDirectory);
[ok,message] = mkdir(temporaryDirectory);
if ~ok
    error('Acycle:Bispectral:CreateTemporaryDirectory','%s',message);
end
temporaryCleanup = onCleanup(@()removeTemporaryDirectory(temporaryDirectory));
temporaryFiles = struct( ...
    'PDF',fullfile(temporaryDirectory,[resultStem,'.pdf']), ...
    'FIG',fullfile(temporaryDirectory,[resultStem,'.fig']), ...
    'MAT',fullfile(temporaryDirectory,[resultStem,'.mat']), ...
    'ProcessedCSV',fullfile(temporaryDirectory, ...
        [resultStem,'-preprocessed.csv']), ...
    'ConfigJSON',fullfile(temporaryDirectory,[resultStem,'-config.json']));

bispectralExportVectorPDF(fig,temporaryFiles.PDF);
savefig(fig,temporaryFiles.FIG);
save(temporaryFiles.MAT,'result','-v7.3');
writematrix(result.ProcessedData,temporaryFiles.ProcessedCSV);

preprocessing = result.Preprocessing;
if isfield(preprocessing,'Trend')
    preprocessing = rmfield(preprocessing,'Trend');
end
significance = struct( ...
    'Method',result.Significance.Method, ...
    'ConfidenceLevel',result.Significance.ConfidenceLevel, ...
    'Threshold',result.Significance.Threshold, ...
    'SurrogateType',result.Significance.SurrogateType, ...
    'NumSurrogates',result.Significance.NumSurrogates, ...
    'RandomSeed',result.Significance.RandomSeed, ...
    'Interpretation',result.Significance.Interpretation);
method = lower(strtrim(char(result.Significance.Method)));
if any(strcmp(method,{'surrogate-global','global-surrogate','max-surrogate'}))
    significance.MultipleComparisonControl = ...
        'maximum-statistic family-wise error rate (FWER)';
    if isfield(result.Significance,'InferenceFamilyDefinition')
        significance.InferenceFamily = ...
            result.Significance.InferenceFamilyDefinition;
    else
        significance.InferenceFamily = ...
            'Fixed finite observed b^2 triads in the computed principal domain';
    end
    significance.FrequencyViewLimitsAffectInferenceFamily = false;
elseif any(strcmp(method,{'none','off',''}))
    significance.MultipleComparisonControl = 'none';
    significance.InferenceFamily = 'none';
    significance.FrequencyViewLimitsAffectInferenceFamily = false;
else
    significance.MultipleComparisonControl = ...
        'pointwise compatibility mode; no map-wide FWER control';
    if isfield(result.Significance,'InferenceFamilyDefinition')
        significance.InferenceFamily = ...
            result.Significance.InferenceFamilyDefinition;
    else
        significance.InferenceFamily = 'individual computed triads';
    end
    significance.FrequencyViewLimitsAffectInferenceFamily = false;
end
qualityFields = { ...
    'ThresholdComparison', ...
    'SurrogateAttemptCount','RejectedSurrogateCount', ...
    'RejectedIAAFTQualityCount','RejectedNonfiniteEstimateCount', ...
    'IAAFTSpectralTolerance','MaxSurrogateAttempts', ...
    'SurrogateSpectralErrorDomain','InferenceFamilyTriadCount', ...
    'InferenceFamilyDefinition'};
for fieldIndex = 1:numel(qualityFields)
    fieldName = qualityFields{fieldIndex};
    if isfield(result.Significance,fieldName)
        significance.(fieldName) = result.Significance.(fieldName);
    end
end
if isfield(result.Significance,'SurrogateSpectralErrors')
    finiteErrors = result.Significance.SurrogateSpectralErrors;
    finiteErrors = finiteErrors(isfinite(finiteErrors));
    if isempty(finiteErrors)
        significance.MaximumAcceptedSurrogateSpectralError = NaN;
        significance.MedianAcceptedSurrogateSpectralError = NaN;
    else
        significance.MaximumAcceptedSurrogateSpectralError = max(finiteErrors);
        significance.MedianAcceptedSurrogateSpectralError = median(finiteErrors);
    end
end
configuration = struct( ...
    'Version',result.Version, ...
    'Created',result.Created, ...
    'InputName',result.InputName, ...
    'CoordinateUnit',result.CoordinateUnit, ...
    'Options',result.Options, ...
    'RenderSettings',renderSettings, ...
    'Preprocessing',preprocessing, ...
    'EstimatorMetadata',result.Meta, ...
    'Significance',significance, ...
    'Interpretation',result.Interpretation);
if isfield(result,'ExternalPreprocessing')
    configuration.ExternalPreprocessing = result.ExternalPreprocessing;
end
if isfield(result,'GUIParameterCorrections')
    configuration.GUIParameterCorrections = result.GUIParameterCorrections;
end
json = jsonencode(configuration,'PrettyPrint',true);
fileId = fopen(temporaryFiles.ConfigJSON,'w');
if fileId < 0
    error('Acycle:Bispectral:WriteConfiguration', ...
        'Could not open configuration file for writing: %s',temporaryFiles.ConfigJSON);
end
fileCleanup = onCleanup(@()fclose(fileId));
fprintf(fileId,'%s\n',json);
clear fileCleanup

temporaryPaths = struct2cell(temporaryFiles);
if ~all(cellfun(@isNonemptyFile,temporaryPaths))
    error('Acycle:Bispectral:IncompleteSave', ...
        'One or more temporary result files are missing or empty.');
end

if isfile(resultDirectory) || isfolder(resultDirectory)
    error('Acycle:Bispectral:ResultFolderCollision', ...
        'The selected result folder now exists; run Save again: %s',resultDirectory);
end
[moved,moveMessage] = movefile(temporaryDirectory,resultDirectory);
if ~moved
    error('Acycle:Bispectral:CommitSave', ...
        'Could not finalize result folder %s: %s',resultDirectory,moveMessage);
end
clear temporaryCleanup
end

function directory = uniqueResultDirectory(outputDirectory,baseName)
for index = 1:9999
    directory = fullfile(outputDirectory, ...
        sprintf('%s-bispectral-%d',baseName,index));
    if ~isfile(directory) && ~isfolder(directory)
        return
    end
end
timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmssSSS'));
directory = fullfile(outputDirectory, ...
    sprintf('%s-bispectral-%s',baseName,timestamp));
if isfile(directory) || isfolder(directory)
    error('Acycle:Bispectral:ResultFolderCollision', ...
        'Could not choose a unique result folder in %s.',outputDirectory);
end
end

function tf = isNonemptyFile(path)
info = dir(path);
tf = isfile(path) && ~isempty(info) && info(1).bytes > 0;
end

function removeTemporaryDirectory(path)
if isfolder(path)
    try
        rmdir(path,'s');
    catch
    end
end
end
