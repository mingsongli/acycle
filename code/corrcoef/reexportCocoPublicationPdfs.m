function audit = reexportCocoPublicationPdfs(outputRoot)
%REEXPORTCOCOPUBLICATIONPDFS Rebuild vector PDFs at their declared FIG size.
%
% This export-only repair loads each saved editable FIG, preserves its
% 180-mm width and recorded height, and uses PRINT so the PDF MediaBox has
% the same physical dimensions. Numerical results are not read or changed.

validateattributes(outputRoot,{'char','string'}, ...
    {'scalartext','nonempty'},mfilename,'outputRoot',1);
outputRoot = char(string(outputRoot));
manifest = jsondecode(fileread(fullfile(outputRoot,'manifest.json')));
nExported = 0;
for caseIndex = 1:numel(manifest.cases)
    figures = manifest.cases(caseIndex).figures;
    for figureIndex = 1:numel(figures)
        figPath = fullfile(outputRoot,figures(figureIndex).fig_path);
        pdfPath = fullfile(outputRoot,figures(figureIndex).pdf_path);
        if ~isfile(figPath)
            error('reexportCocoPublicationPdfs:MissingFigure', ...
                'Missing editable figure: %s',figPath);
        end
        fig = openfig(figPath,'invisible');
        cleanup = onCleanup(@()closeIfValid(fig));
        set(fig,'Units','centimeters');
        position = get(fig,'Position');
        heightCm = position(4);
        if ~isfinite(heightCm) || heightCm <= 0
            error('reexportCocoPublicationPdfs:InvalidHeight', ...
                'Invalid saved physical figure height: %s',figPath);
        end
        widthCm = figures(figureIndex).width_mm/10;
        if ~isfinite(widthCm) || widthCm <= 0 || widthCm > 18
            error('reexportCocoPublicationPdfs:InvalidWidth', ...
                'Invalid declared physical figure width: %s',figPath);
        end
        pdfWidthCm = min(widthCm,17.95);
        pdfHeightCm = heightCm*pdfWidthCm/widthCm;
        set(fig,'Position',[1,1,widthCm,heightCm], ...
            'PaperUnits','centimeters', ...
            'PaperPosition',[0,0,pdfWidthCm,pdfHeightCm], ...
            'PaperSize',[pdfWidthCm,pdfHeightCm], ...
            'InvertHardcopy','off','Color','w');
        print(fig,pdfPath,'-dpdf','-vector','-r600');
        nExported = nExported+1;
        clear cleanup
        closeIfValid(fig);
    end
end
audit = struct('status','PASS','pdfCount',nExported, ...
    'widthLimitMm',180,'completedAt',char(datetime('now', ...
    'TimeZone','local','Format','yyyy-MM-dd''T''HH:mm:ssXXX')));
fprintf('PDF_REEXPORT_PASS files=%d width_limit_mm=%g\n', ...
    audit.pdfCount,audit.widthLimitMm);
end

function closeIfValid(fig)
if isgraphics(fig,'figure')
    close(fig);
end
end
