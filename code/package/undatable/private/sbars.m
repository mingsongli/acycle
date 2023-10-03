function h = sbars(x,y,xerr,yerr)
% h = sbars(x,y,xerr,yerr)
%
% Plots simple symmetrical error bars in a fast way.
% For asymmetrical error bars, use the abars() function.
%
% Input
% =====
% x = x coordinate of data point(s)
% y = y coordinate of data point(s)
% xerr = x error(s)
% yerr = y error(s)
%
% x, y, xerr, yerr must all be vectors 
% with the same number of elements.
%
% Output
% ======
% h = handle to the plotted line, for changing colour, etc.
%
% ------------------------
% B.C. Lougheed, July 2020
% Matlab 2020a

if sum([isvector(x),isvector(y),isvector(xerr),isvector(yerr)]) ~= 4
	error('Inputs should be vectors with same number of elements')
end
if ~isequal(numel(x),numel(y),numel(xerr),numel(yerr))
		error('Inputs should be vectors with same number of elements')
end

xmin = x - xerr;
xmax = x + xerr;
ymin = y - yerr;
ymax = y + yerr;

if numel(xmin) == 1
	h = plot([xmin xmax NaN x x],[y y NaN ymin ymax]);
else
	xplots = NaN(numel(xmin)*6,1);
	yplots = NaN(size(xplots));
	z = 1;
	for i = 1:numel(xmin)
		
		xplots(z) = xmin(i);
		xplots(z+1) = xmax(i);
		xplots(z+3:z+4) = x(i);
		
		yplots(z:z+1) = y(i);
		yplots(z+3) = ymin(i);
		yplots(z+4) = ymax(i);
		
		z = z+6;

	end
	
	h = plot(xplots,yplots,'-');
end


end % end function
