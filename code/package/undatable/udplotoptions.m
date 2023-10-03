%% settings for the age-depth plot
% set plot size here
plotwidth  = 18    ; % centimetres
plotheight = 18    ; % centimetres
% set font size here
textsize   = 8     ; % font size
% set axis labels here (e.g. change to metres or Ma if you wish)
depthlabel = 'Depth (cm)';
agelabel =  'Age (ka)';

%% settings for the SAR plot
if exist('plotsar','var') == 1
	if plotsar == 1
		plotheight = plotheight * 1.5;	% The total height of both plots relative to plotheight to also accomodate SAR plot
	end
end
sarlabel = 'SAR (cm kyr^{-1})';
