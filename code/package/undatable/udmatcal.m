function  [p95_4, p68_2, calprob, medage] = matcal(labdet, laberr, calcurve, yeartype, varargin)
% [p95_4, p68_2, calprob, medage] = matcal(labdet, laberr, calcurve, yeartype)
%
% Function for 14C age calibration using Bayesian higher posterior
% density analysis of a probability density function of calibrated age.
%
% Please see manuscript for more detailed information:
% Lougheed, B.C. & Obrochta, S.P. (2016). MatCal: Open Source Bayesian
% 14C Age Calibration in Matlab. Journal of Open Research Software. 4(1),
% p.e42. DOI: http://doi.org/10.5334/jors.130
%
% Required input parameters
% =================================
%
% labdet:    Lab 14C determination (default unit is 14C yr BP).
%
% laberr:    Lab 14C determination uncertainty (1 sigma).
%
% calcurve:  String specifying calibration curve to use, select from
%            the following (not case sensitive):
%            'IntCal20', 'Marine20', 'SHCal20', 'IntCal13', 'Marine13',
%			 'SHCal13, 'IntCal09', 'Marine09', 'IntCal04', 'Marine04',
%			 'SHCal04, 'IntCal98', 'Marine98'
%
% yeartype:  String specifying how to report calibrated age.
%            Choices are 'CalBP' or 'BCE/CE'. (Not case sensitive)
%
% Optional input parameters
% =================================
%
% resage:    Optional (parameter name and value). Specify reservoir
%            age in 14C yr. Reservoir age is R(t) in the case of an 
%			 atmospheric calibration curve, and DeltaR in the case of
%			 a marine curve. (default = 0)
%            e.g. 'resage',320 for a reservoir age of 320
%
% reserr:    Optional (parameter name and value). Specify a 1 sigma
%            uncertainty for your chosen resage (default = 0)
%            e.g. 'reserr',50 for an uncertainty of 50
%
% dettype:   Optional (parameter name and value). Choose to handle
%            lab determination and plot as F14C or 14C years (default).
%            Options are '14cyr' (default) or 'f14c'. Not case sensitive.
%            e.g. 'dettype','f14c' to activate F14C mode.
%            If F14C is chosen then lab determination (labdet, laberr)
%            must be inputted as F14C, with resage (and reserr)
%            inputted as the F14C depletion ratio relative to the chosen
%            calibration curve, in per mil notation. This notation has been
%            referred to as d14R by Soulet et al (2016), doi: 10.1017/RDC.2015.22.            
%
% plot:      Optional (parameter name and value). Return a calibration
%            plot to Figure 14. The plot displays the 1 and 2
%            sigma ranges of the calibration curve. The calibraiton
%            curve raw data is also shown if IntCal13 is selected.
%            Specify 1 to plot and 0 not to plot. (default = 1 for Matlab
%            users; default = 0 for Octave users)
%            e.g. 'plot',0 not to plot
%
% saveplot:  Optional (parameter name and value). Save an Adobe PDF of
%            the calibration plot to your working directory. Specify 1
%            to save and 0 not to save. (default = 0) Will be ignored
%            if plotting has been disabled.
%            e.g. 'saveplot',1 to save to your working directory.
%
% plotsize:  Optional (parameter name and value). Set the width and height
%            of the printed figure in cm. (default = 16).
%            e.g. 'plotsize',10 for 10 cm.
%
% fontsize:  Optional (parameter name and value). Set the value of the font
%            size in the output plot. (default = 8)
%            e.g. 'fontsize',12 for a font size of 12.
%
% revxdir:   Optional (parameter name and value). Reverse the plot x-axis.
%            Specify 1 to reverse and 0 not to reverse. (default = 0)
%            e.g. 'revxdir',1 to reverse the x-axis.
%
% Output data
% =================================
%
% p95_4:     n by 3 matrix containing 95.45% calibrated age probability
%            range interval(s) calculated using highest posterior density.
%            Each row contains a probability range in Cols 1 and 2, and
%            the associated probability for that range in Col 3.
%            Probabilities are normalised to between zero and one.
%
% p68_2:     Same as p95_4, but for the 68.27% calibrated range.
%
% calprob:   n by 2 matrix containing an annualised calibrated age
%            probability density function for implementation in, e.g.,
%            age modelling. n is the annualised length of the chosen
%            calibration curve. Col 1 is a series of annual cal ages,
%            Col 2 contains their associated probability. All probabilities
%            are normalised such that they sum to 1.
%
% medage:    Median age calculated from calprob.
%
% Functional examples
% =================================
%
% [p95_4, p68_2, prob, medage] = matcal(1175, 30, 'IntCal20', 'BCE/CE');
% Calibrate a 14C age of 1175±30 14C yr BP using IntCal20 with output in BCE/CE.
%
% [p95_4, p68_2, prob, medage] = matcal(23175, 60, 'Marine20', 'CalBP',...
% 'resage', -50, 'reserr', 100, 'saveplot', 1);
% Calibrate a 14C age of 23175±60 14C yr BP using Marine20, with output in
% Cal BP, with delta-R of -50±100 14C yr and save a copy of the plot to
% your working directory as an Adobe PDF.
%
% [p95_4, p68_2, prob, medage] = matcal(1175, 30, 'IntCal20', 'CalBP', 'plot', 0);
% Calibrate a 14C age of 1175±50 14C yr BP using IntCal20, with output in
% Cal BP and disable the plot window.
%
% ------------
%
% MatCal 3.0 (2020-08-13)
% Originally written using MatLab 2012a, tested compatible with 2019a.
% No toolboxes required.
% Please see manuscript for more information:
% http://doi.org/10.5334/jors.130
matcalvers = 'MatCal (Lougheed and Obrochta, 2016), ver 3.0';

if nargin < 4
	error('Not enough input parameters (see help for instructions)')
end

% Optional parameters input parser (parse varargin)
p = inputParser;
p.KeepUnmatched = true;
p.CaseSensitive = false;
p.FunctionName='matcal';
defaultresage = NaN;
defaultreserr = NaN;
defaultplotme = 1;
defaultprintme = 0;
defaultplotsize = 16;
defaultfontsize = 8;
defaultrevxdir = 0;
defaultdettype = '14cyr';
if exist('OCTAVE_VERSION', 'builtin') ~= 0
	addParamValue(p,'resage',defaultresage,@isnumeric); %#ok<*NVREPL>
	addParamValue(p,'reserr',defaultreserr,@isnumeric);
	addParamValue(p,'plot',defaultplotme,@isnumeric); 
	addParamValue(p,'saveplot',defaultprintme,@isnumeric);
	addParamValue(p,'plotsize',defaultplotsize,@isnumeric);
	addParamValue(p,'fontsize',defaultfontsize,@isnumeric);
	addParamValue(p,'revxdir',defaultrevxdir,@isnumeric);
	addParamValue(p,'dettype',defaultdettype);
else
	if datenum(version('-date'))>datenum('May 19, 2013')
		addParameter(p,'resage',defaultresage,@isnumeric);
		addParameter(p,'reserr',defaultreserr,@isnumeric);
		addParameter(p,'plot',defaultplotme,@isnumeric);
		addParameter(p,'saveplot',defaultprintme,@isnumeric);
		addParameter(p,'plotsize',defaultplotsize,@isnumeric);
		addParameter(p,'fontsize',defaultfontsize,@isnumeric);
		addParameter(p,'revxdir',defaultrevxdir,@isnumeric);
		addParameter(p,'dettype',defaultdettype);
	else
		addParamValue(p,'resage',defaultresage,@isnumeric);
		addParamValue(p,'reserr',defaultreserr,@isnumeric);
		addParamValue(p,'plot',defaultplotme,@isnumeric);
		addParamValue(p,'saveplot',defaultprintme,@isnumeric);
		addParamValue(p,'plotsize',defaultplotsize,@isnumeric);
		addParamValue(p,'fontsize',defaultfontsize,@isnumeric);
		addParamValue(p,'revxdir',defaultrevxdir,@isnumeric);
		addParamValue(p,'dettype',defaultdettype);
	end
end
parse(p,varargin{:});
resage = p.Results.resage;
reserr = p.Results.reserr;
plotme = p.Results.plot;
printme = p.Results.saveplot;
plotsize = p.Results.plotsize;
fontsize = p.Results.fontsize;
revxdir = p.Results.revxdir;
dettype = p.Results.dettype;

% Cal curve case and symbols
headerlines = 11;
if strcmpi(calcurve, 'IntCal20') == 1
	calcurve = 'IntCal20';
	cite = '(Reimer et al., 2020)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'Marine20') == 1
	calcurve = 'Marine20';
	cite = '(Heaton et al., 2020)';
	curvetype = 'mar';
elseif strcmpi(calcurve, 'SHCal20') == 1
	calcurve = 'SHCal20';
	cite = '(Hogg et al., 2020)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'IntCal13') == 1
	calcurve = 'IntCal13';
	cite = '(Reimer et al., 2013)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'Marine13') == 1
	calcurve = 'Marine13';
	cite = '(Reimer et al., 2013)';
	curvetype = 'mar';
elseif strcmpi(calcurve, 'SHCal13') == 1
	calcurve = 'SHCal13';
	cite = '(Hogg et al., 2013)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'IntCal09') == 1
	calcurve = 'IntCal09';
	cite = '(Reimer et al., 2009)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'Marine09') == 1
	calcurve = 'Marine09';
	cite = '(Reimer et al., 2009)';
	curvetype = 'mar';
elseif strcmpi(calcurve, 'IntCal04') == 1
	calcurve = 'IntCal04';
	cite = '(Reimer et al., 2004)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'Marine04') == 1
	calcurve = 'Marine04';
	cite = '(Hughen et al., 2004)';
	curvetype = 'mar';
elseif strcmpi(calcurve, 'SHCal04') == 1
	calcurve = 'SHCal04';
	cite = '(McCormac et al., 2004)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'IntCal98') == 1
	headerlines = 18;
	calcurve = 'IntCal98';
	cite = '(Stuiver et al., 1998)';
	curvetype = 'atm';
elseif strcmpi(calcurve, 'Marine98') == 1
	headerlines = 18;
	calcurve = 'Marine98';
	cite = '(Stuiver et al., 1998)';
	curvetype = 'mar';
else
	error(['Calibration curve "',calcurve,'" unknown. Please specify a valid calibration curve (see help for options)'])
end

if strcmpi(yeartype, 'Cal BP') == 1 || strcmpi(yeartype, 'CalBP') == 1
	yearlabel = 'cal yr BP';
elseif strcmpi(yeartype, 'BCE/CE') == 1
	yearlabel = 'cal yr BCE/CE';
else
	error('Please specify a valid year type (see help for options)')
end

% set plot settings for later depending on if there is a reservoir correction or not
if strcmp(curvetype, 'atm') == 1
	if isnan(resage) == 0 || isnan(reserr) == 0
		extralabel = 1; % extra line of text detailing reservoir correction info
		plot14Cextra = 1; % plot both original 14 determination & reservoir corrected one
		if strcmpi(dettype,'14cyr') == 1
			reslabel = 'R(t)';
		elseif strcmpi(dettype,'f14c') == 1
			reslabel = '\delta^1^4R';
		end
	else
		extralabel = 0;
		plot14Cextra = 0;
	end
elseif strcmp(curvetype, 'mar') == 1
	extralabel = 1;
	plot14Cextra = 1;
	if strcmpi(dettype,'14cyr') == 1
		reslabel = '\DeltaR';
	elseif strcmpi(dettype,'f14c') == 1
		reslabel = '\delta^1^4R';
	end
end

% store original 14C ages in memory and process reservoir age
if isnan(resage) == 1
	resage = 0;
end
if isnan(reserr) == 1 
	reserr = 0;
end
if strcmpi(dettype,'14cyr') == 1
	labdetorig = labdet;
	laberrorig = laberr;
	labdet = labdet - resage;
	laberr = sqrt(laberr^2 + reserr^2);
	f14cdet = exp(labdet/-8033);
	f14cerr = f14cdet*laberr/8033;
elseif strcmpi(dettype,'f14c') == 1
	labdetorig = labdet;
	laberrorig = laberr;
	labdet = labdet / (resage/1000+1); % d14R to F14R
	laberr = sqrt(laberr^2 + (reserr/1000)^2); % d14R to F14R
	f14cdet = labdet;
	f14cerr = laberr;
end

% open cal curve data
File = fopen([calcurve,'.14c']);
Contents = textscan(File,'%f %f %f %f %f','headerlines',headerlines,'delimiter',',');
fclose(File);
curvecal = flipud(Contents{1});
curve14c = flipud(Contents{2});
curve14cerr = flipud(Contents{3});
curvef14 = exp(curve14c/-8033); % and also convert to F14 space
curvef14err = curvef14.*curve14cerr/8033; % and also convert to F14 space

% interpolate F14C cal curve to annual resolution
interpres = 1;
calprob(:,1) = curvecal(1):interpres:curvecal(end);
hicurvef14 = interp1(curvecal, curvef14, calprob(:,1));
hicurvef14err = interp1(curvecal, curvef14err, calprob(:,1));
% Calculate probability for every cal year in F14C space
% equation from e.g. p.261 in Bronk Ramsey, 2008. doi:10.1111/j.1475-4754.2008.00394.x
calprob(:,2) = exp(-((f14cdet - hicurvef14).^2)./(2 .* (f14cerr^2 + hicurvef14err.^2))) ./ ((f14cerr^2 + hicurvef14err.^2).^0.5) ;
calprob(:,2) = calprob(:,2) / sum(calprob(:,2)); % normalise to 1

warn = 0;
if strcmpi(dettype,'14cyr') == 1;
	% throw warning if 4sigma of 14C age exceeds 14C age limits in cal curve
	if (labdet + 4*laberr) > max(curve14c) || (labdet - 4*laberr) < min(curve14c)
		warn = 1;
		warning(['4sigma range of 14C age ',num2str(labdetorig),char(177),num2str(laberrorig),' may exceed limits of calibration curve'])
	end
	% also throw warning if cal age PDF does not tail to zero at ends of cal curve (exceeds cal curve)
	if calprob(1,2) > 0.000001 || calprob(end,2) > 0.000001
		warn = 1;
		warning(['Calibrated age PDF for 14C age ',num2str(labdetorig),char(177),num2str(laberrorig),' may exceed limits of calibration curve'])
	end
elseif strcmpi(dettype,'f14c') == 1;
	% throw warning if 4sigma of 14C age exceeds 14C age limits in cal curve
	if (labdet + 4*laberr) > max(hicurvef14) || (labdet - 4*laberr) < min(hicurvef14)
		warn = 1;
		warning(['4sigma range of F14C activity ',num2str(labdetorig),char(177),num2str(laberrorig),' may exceed limits of calibration curve'])
	end
	% also throw warning if cal age PDF does not tail to zero at ends of cal curve (exceeds cal curve)
	if calprob(1,2) > 0.000001 || calprob(end,2) > 0.000001
		warn = 1;
		warning(['Calibrated age PDF for F14C activity ',num2str(labdetorig),char(177),num2str(laberrorig),' may exceed limits of calibration curve'])
	end
end

% find 68.2% and 95.4% intervals using Bayesian highest posterior density (HPD)
hpd = calprob(:,1:2);
hpd = sortrows(hpd, 2);
hpd(:,3) = cumsum(hpd(:,2));
% 68.2%
hpd68_2 = hpd(hpd(:,3) >= 1-erf(1/sqrt(2)), :);
hpd68_2 = sortrows(hpd68_2,1);
ind1 = find(diff(hpd68_2(:,1)) > 1);
if isempty(ind1) == 1
	p68_2(1,1) = hpd68_2(end,1);
	p68_2(1,2) = hpd68_2(1,1);
	p68_2(1,3) = sum(hpd68_2(1:end,2));
else
	indy1 = NaN(length(ind1)*2,1);
	for i = 1:length(ind1)
		indy1(i*2-1,1) = ind1(i);
		indy1(i*2,1) = ind1(i)+1;
	end
	indy1 = [ 1 ; indy1; length(hpd68_2(:,1)) ];
	p68_2 = NaN(length(2:2:length(indy1)),3);
	for i = 2:2:length(indy1)
		p68_2(i/2,1) = hpd68_2(indy1(i),1);
		p68_2(i/2,2) = hpd68_2(indy1(i-1),1);
		p68_2(i/2,3) = sum(hpd68_2(indy1(i-1):indy1(i),2));
	end
	p68_2 = flipud(p68_2);
end
% 95.4%
hpd95_4 = hpd(hpd(:,3) >= 1-erf(2/sqrt(2)), :);
hpd95_4 = sortrows(hpd95_4,1);
ind2 = find(diff(hpd95_4(:,1)) > 1);
if isempty(ind2) == 1
	p95_4(1,1) = hpd95_4(end,1);
	p95_4(1,2) = hpd95_4(1,1);
	p95_4(1,3) = sum(hpd95_4(1:end,2));
else
	indy2 = NaN(length(ind2)*2,1);
	for i = 1:length(ind2)
		indy2(i*2-1,1) = ind2(i);
		indy2(i*2,1) = ind2(i)+1;
	end
	indy2 = [ 1 ; indy2; length(hpd95_4(:,1)) ];
	p95_4 = NaN(length(2:2:length(indy2)),3);
	for i = 2:2:length(indy2)
		p95_4(i/2,1) = hpd95_4(indy2(i),1);
		p95_4(i/2,2) = hpd95_4(indy2(i-1),1);
		p95_4(i/2,3) = sum(hpd95_4(indy2(i-1):indy2(i),2));
	end
	p95_4 = flipud(p95_4);
end

% calculate median (can't use interp1 because of potential repeat values)
[~, median_ind] = min(abs(cumsum(calprob(:,2))-0.5));
medage = round(mean(calprob(median_ind,1)));

% Convert output to BCE/CE if necessary
if strcmpi(yeartype,'BCE/CE') == 1
	medage = (medage-1950) * -1;
	calprob(:,1) = (calprob(:,1)-1950) * -1;
	p95_4(:,1:2) = (p95_4(:,1:2)-1950) * -1;
	p68_2(:,1:2) = (p68_2(:,1:2)-1950) * -1;
end

%%%%% ----- Start of plotting module ----- %%%%%

if plotme == 1
	
	% prep age range for plot window
	calprob2 = calprob(cumsum(calprob(:,2)) > 0.001 & cumsum(calprob(:,2)) < 0.999);
	if strcmpi(yeartype,'BCE/CE') == 1
		calprob2 = flipud(calprob2);
		curvecal = (curvecal-1950) * -1;
	end
	yrrng = (calprob2(end,1) - calprob2(1,1))/2;
	syr = (10^2) * round((calprob2(1,1)-yrrng) / (10^2)); % round to nearest hundred for nice plot limits
	eyr = (10^2) * round((calprob2(end,1)+yrrng) / (10^2));
	ind = find(curvecal >= syr & curvecal <= eyr);
	curvecal = curvecal(ind);
	curve14c = curve14c(ind);
	curve14cerr = curve14cerr(ind);
	
	if exist('OCTAVE_VERSION', 'builtin') ~= 0 % very simple output plot for octave users
		
		figure(14)
		clf
		plot(calprob(:,1),calprob(:,2),'b-')
		xlim([syr eyr])
		xlabel(['Age (',yearlabel,')'])
		ylabel('Calbriated age probability')
		title('Simplified output plot for OCTAVE')
		
	else % otherwise continue with more fancy plot for matlab users
			
		figure(14)
		clf
		
		%----- Plot ProbDistFunc
		axpdf = axes;
		axes(axpdf)
		area(calprob(:,1),calprob(:,2),'edgecolor','none')
		axpdfylims = ylim;
		% axpdfxlims = xlim; % not used
		area(calprob(:,1),calprob(:,2)*0.2,'edgecolor',[0 0 0],'facecolor',[0.9 0.9 0.9])
		hold on
		for i = 1:size(p95_4,1)
			if strcmpi(yeartype,'Cal BP') == 1 || strcmpi(yeartype,'CalBP') == 1
				area( calprob(calprob(:,1) <= p95_4(i,1) & calprob(:,1) >= p95_4(i,2),1)  , calprob(calprob(:,1) <= p95_4(i,1) & calprob(:,1) >= p95_4(i,2),2)*0.2,'edgecolor','none','facecolor',[0.56 0.56 0.66])
			elseif strcmpi(yeartype,'BCE/CE') == 1
				area( calprob(calprob(:,1) >= p95_4(i,1) & calprob(:,1) <= p95_4(i,2),1)  , calprob(calprob(:,1) >= p95_4(i,1) & calprob(:,1) <= p95_4(i,2),2)*0.2,'edgecolor','none','facecolor',[0.56 0.56 0.66])
			end
		end
		for i = 1:size(p68_2,1)
			if strcmpi(yeartype,'Cal BP') == 1 || strcmpi(yeartype,'CalBP') == 1
				area( calprob(calprob(:,1) <= p68_2(i,1) & calprob(:,1) >= p68_2(i,2),1)  , calprob(calprob(:,1) <= p68_2(i,1) & calprob(:,1) >= p68_2(i,2),2)*0.2,'edgecolor','none','facecolor',[0.5 0.5 0.6])
			elseif strcmpi(yeartype,'BCE/CE') == 1
				area( calprob(calprob(:,1) >= p68_2(i,1) & calprob(:,1) <= p68_2(i,2),1)  , calprob(calprob(:,1) >= p68_2(i,1) & calprob(:,1) <= p68_2(i,2),2)*0.2,'edgecolor','none','facecolor',[0.5 0.5 0.6])
			end
		end
		
		%----- Plot cal curve
		axcurve = axes;
		axes(axcurve)
		xdata = curvecal;
		ydata = curve14c;
		onesig = curve14cerr;
		if strcmpi(dettype,'f14c') == 1
			ydata = exp(ydata/-8033);
			onesig = ydata.*onesig/8033;
		end
		fill([xdata' fliplr(xdata')],[ydata'+2*onesig' fliplr(ydata'-2*onesig')],[0.8 0.8 0.8],'edgecolor','none');
		hold on
		fill([xdata' fliplr(xdata')],[ydata'+onesig' fliplr(ydata'-onesig')],[0.6 0.6 0.6],'edgecolor','none');
		axcurveylims = ylim;
		axcurvexlims = [min(curvecal) max(curvecal)];
		
		
		%----- Plot raw data if intcal13 or intcal20 is selected
		if strcmpi('intcal13',calcurve) == 1 || strcmpi('intcal20',calcurve) == 1
			
			axraw = axes;
			axes(axraw)
			
			if strcmpi('intcal13',calcurve) == 1
				
				rd = load('IntCal13 raw data.txt');
				% now trim out the bits that weren't actually used in IntCal13
				rd_trees = rd(rd(:,1) >= 1 & rd(:,1) <= 8, :);
				rd_other = rd(rd(:,1) >= 9, :);
				rd_trees = rd_trees(rd_trees(:,3) <= 13900, :);
				rd_other = rd_other(rd_other(:,3) >= 13900, :);
				rd = [rd_trees; rd_other];
				if strcmpi(yeartype,'BCE/CE') == 1
					rd(:,3) = (rd(:,3)-1950) * -1;
					ind = find(rd(:,3) <= curvecal(1) & rd(:,3) >= curvecal(end));
				else
					ind = find(rd(:,3) >= curvecal(1) & rd(:,3) <= curvecal(end));
				end
				
				raw_cal = rd(ind,3);
				raw_calsigma = rd(ind,5);
				raw_14c = rd(ind,6);
				raw_14csigma = rd(ind,7);
				if strcmpi(dettype,'f14c') == 1
					raw_14c = exp(raw_14c/-8033);
					raw_14csigma = raw_14c.*raw_14csigma/8033;
				end
				
			elseif strcmpi('intcal20',calcurve) == 1
				
				rd = load('IntCal20 raw data.txt');
				if strcmpi(yeartype,'BCE/CE') == 1
					rd(:,3) = (rd(:,3)-1950) * -1;
					ind = find(rd(:,3) <= curvecal(1) & rd(:,3) >= curvecal(end));
				else
					ind = find(rd(:,3) >= curvecal(1) & rd(:,3) <= curvecal(end));
				end
				
				raw_cal = rd(ind,3);
				raw_calsigma = rd(ind,4);
				raw_14c = rd(ind,5);
				raw_14csigma = rd(ind,6);
				if strcmpi(dettype,'f14c') == 1
					raw_14c = exp(raw_14c/-8033);
					raw_14csigma = raw_14c.*raw_14csigma/8033;
				end
				
			end
			
			hbars = sbars(raw_cal, raw_14c, raw_calsigma, raw_14csigma);
			set(hbars,'color',[132 193 150]/256);
			
			axrawylims = [min(raw_14c-raw_14csigma) max(raw_14c+raw_14csigma)];
			% axrawxlims = xlim;  % not used
			
		end
		
		%----- Plot 14C age normal distribution(s)
		axgauss = axes;
		axes(axgauss);
		
		if strcmpi(dettype,'14cyr') == 1
			gaussrange = (labdet-4*laberr:labdet+4*laberr);
			if plot14Cextra == 1
				gaussrangeorig = (labdetorig-4*laberrorig:labdetorig+4*laberrorig);
			end
		elseif strcmpi(dettype,'f14c') == 1
			gaussrange = (labdet-4*laberr:0.00001:labdet+4*laberr);
			if plot14Cextra == 1
				gaussrangeorig = (labdetorig-4*laberrorig:0.00001:labdetorig+4*laberrorig);
			end
		end
		gauss = normpdf(gaussrange,labdet,laberr);
				
		patch(gauss, gaussrange, 'blue');
		% axgaussylims = ylim; % not used
		axgaussxlims = xlim;
		axgaussxlims(2) = axgaussxlims(2)*5;
		if plot14Cextra == 1
			gaussorig = normpdf(gaussrangeorig, labdetorig, laberrorig);
			a = patch(gaussorig, gaussrangeorig, 'blue');
			set(a,'edgecolor','none','facecolor',[0.8 0.5 0.5]);
			hold on
		end
		a = patch(gauss, gaussrange, 'blue');
		set(a,'edgecolor',[0 0 0],'facecolor',[0.7 0.4 0.4]);
		
		
		%----- set plot settings by axis, starting from back layer to front layer
		
		axes(axcurve)
		xlim(axcurvexlims)
		if revxdir == 1
			set(gca, 'XDir', 'reverse')
		end
		set(gca,'color','none')
		if strcmpi(dettype,'14cyr') == 1
			lab1 = ylabel('Conventional ^1^4C age (^1^4C yr BP)');
		elseif strcmpi(dettype,'f14c') == 1
			lab1 = ylabel('^1^4C activity (F^1^4C)');
		end
		lab2 = xlabel(['Calibrated age (',yearlabel,')']);
		set( gca, 'TickDir', 'out' );
		if strcmpi('intcal13',calcurve) == 1 || strcmpi('intcal20',calcurve) == 1
			ylim(axrawylims)
		else
			ylim(axcurveylims)
		end
		yt=get(gca,'ytick');
		if strcmpi(dettype,'14cyr') == 1
			ytl=textscan(sprintf('%1.0f \n',yt),'%s','delimiter','');
			set(gca,'yticklabel',ytl{1})
		end
		xt=get(gca,'xtick');
		xtl=textscan(sprintf('%1.0f \n',xt),'%s','delimiter','');
		set(gca,'xticklabel',xtl{1})
		
		axes(axpdf)
		set(gca,'color','none')
		xlim(axcurvexlims)
		ylim(axpdfylims)
		set(gca,'xticklabel',[]);
		set(gca,'xtick',[]);
		set(gca,'yticklabel',[]);
		if revxdir == 1
			set(gca, 'XDir', 'reverse')
		end
		set(gca,'ytick',[]);
		
		axes(axgauss)
		set(gca,'color','none')
		xlim(axgaussxlims)
		set(gca,'xticklabel',[]);
		set(gca,'xtick',[]);
		set(gca,'yticklabel',[]);
		set(gca,'ytick',[]);
		if strcmpi('intcal13',calcurve) == 1 || strcmpi('intcal20',calcurve) == 1
			ylim(axrawylims)
		else
			ylim(axcurveylims)
		end
		
		axes(axcurve) % bring curve forward
		
		if strcmpi('intcal13',calcurve) == 1 || strcmpi('intcal20',calcurve) == 1
			axes(axraw)
			hold on
			set(gca,'color','none')
			xlim(axcurvexlims)
			ylim(axrawylims)
			set(gca,'xticklabel',[]);
			set(gca,'xtick',[]);
			set(gca,'yticklabel',[]);
			set(gca,'ytick',[]);
			if revxdir == 1
				set(gca, 'XDir', 'reverse')
			end
		else
			axes(axpdf)
		end
		
		
		
		%----- Plot some text on the final axis
		
		% Top left text box: MatCal version and cal curve used
		verboxstr = [matcalvers,newline,calcurve, ' ', cite];
		vbh = annotation('textbox',get(gca,'position'),'String',verboxstr);
		set(vbh, 'linestyle','none')
		set(vbh, 'horizontalalignment','left')
		set(vbh, 'verticalalignment','top')
		
		% Top right text box: Raw and calibrated age info
		if strcmpi(dettype,'14cyr') == 1
			ageboxstr = ['^1^4C det.: ',num2str(labdetorig),' \pm ',num2str(laberrorig),' ^1^4C yr BP'];
		elseif strcmpi(dettype,'f14c') == 1
			ageboxstr = ['^1^4C det.: ',num2str(labdetorig,'%.5f'),' \pm ',num2str(laberrorig,'%.5f'),' F^1^4C'];
		end
		
		if extralabel == 1
			if strcmpi(dettype,'14cyr') == 1
				ageboxstr = [ageboxstr,newline,reslabel,': ',num2str(resage),' \pm ',num2str(reserr), ' ^1^4C yr'];
			elseif strcmpi(dettype,'f14c') == 1
				ageboxstr = [ageboxstr,newline,reslabel,': ',num2str(resage),' \pm ',num2str(reserr)];
			end
		end
		
		ageboxstr = [ageboxstr,newline];
		
		if size(p95_4,1) == 1
			ageboxstr = [ageboxstr,newline,'Cal age 95.45% HPD interval:'];
		else
			ageboxstr = [ageboxstr,newline,'Cal age 95.45% HPD intervals:'];
		end
		for i = 1:size(p95_4,1)
			ageboxstr = [ageboxstr,newline,num2str(floor(p95_4(i,3)*1000)/10),'%: ',num2str(p95_4(i,1)),' to ',num2str(p95_4(i,2)),' ',yearlabel];
		end
		
		abh = annotation('textbox',get(gca,'position'),'String',ageboxstr);
		set(abh, 'linestyle','none')
		set(abh, 'horizontalalignment','right')
		set(abh, 'verticalalignment','top')
		
		
		%----- Warning if tail of 14C date or cal age is near limit of cal curve
		if warn == 1
			title('Warning! Age calibration may exceed limits of calibration curve.')
		end
		
		%----- Uniform fonts and appearance
		
		set(findall(gcf,'-property','FontSize'),'FontSize',fontsize)
		set(lab1,'FontWeight','bold')
		set(lab2,'FontWeight','bold')
		set(gcf,'color',[1 1 1]);
		
	end
	
	%----- Prep plot for export
	if printme == 1
		
		% set figure size (cm)
		xSize = plotsize;
		ySize = plotsize;
		
		% set paper size (cm)f
		set(gcf,'PaperUnits','centimeters')
		Y = plotsize+2;
		X = plotsize+2;
		set(gcf, 'PaperSize',[X Y])
		
		% put figure in centre of paper
		xLeft = (X-xSize)/2;
		yBottom = (Y-ySize)/2;
		set(gcf,'PaperPosition',[xLeft yBottom xSize ySize])
		% make background white
		set(gcf,'InvertHardcopy','on');
		set(gcf,'color',[1 1 1]);
		
		print(figure(14), '-dpdf', '-painters', ['MatCal ',num2str(labdetorig),char(177),num2str(laberrorig),'.pdf']);
	end
	
end

%%%%% ----- End of plotting module ----- %%%%%


end % end function
