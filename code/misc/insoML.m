function [I, T, xorb, yorb, veq, Insol_a_m, Ix,II]=insoML(t,day,lat,qinso,author,res, L)
%[I, T]= inso(ky,day,lat,qinso,author,res);

% INPUT
%  I      = inoslation in Watts/m^2 at top of the atmosphere.
%  T      = time vector
%  xorb   = elliptical orbit location x with eccentricity = e, perihelion = perh (ML)
%  yorb   = elliptical orbit location y with eccentricity = e, perihelion = perh (ML)
%  veq    = the number of days between perihelion and vernal equinox (ML)
%  L      = solar constant default is 1365
%  
% OUTPUT
%  t      = kilo-years before present; format as oldest to youngest.
%  day    = day of year from Jan 1st, this fraction of a KY is added to t. 
%           negative values or day gives output for equinoxes.
%  lat    = lattitude in degrees (-90:90).  Would like to add lon. 
%  qinso  = -2 is mean daily insolation, -1 is max daily insolation.
%
%              else hours above input threshold. 
%  author = 6 gives  Berger and Loutre (1992) solution.
%           1 gives  Laskar et al. (2004) solution,
%           2 gives  Laskar et al. (2011) solution la10a,
%           3 gives  Laskar et al. (2011) solution la10b,
%           4 gives  Laskar et al. (2011) solution la10c,
%           5 gives  Laskar et al. (2011) solution la10d,
%           
%  res    = by default 365 points are calculated per year, if different
%           than one, this multiplies the resolution.
%
%
%  Example: I=inso([20 19.999],[1:365],65,-2,1);
%    Gives mean daily insolation for a 2 year period from 20 to 19.999 KY BP
%    at 65 degrees N using the solution of Berger and Loutre (1991). 
%
%Refs:
%
%Berger, A. and Loutre, M. F., "Astronomical solutions for paleoclimate
%studies over the last 3 million years", Earth Planet. Sci. Lett., v111,
%p369-382, 1992.
%
%Quinn, T.R. et al. "A Three Million Year Integration of the Earth's
%Orbit"  The Astronomical Journal v101, p2287-2305, 1991.
%
%Jonathan Levine (2001), UC Berkeley, wrote the original version of this code
%Peter Huybers (Harvard) made some modifications.

% Edited by Mingsong Li (Penn State) 2018 for the Acycle software

%if min(t)<0, display('time must be in KY BP'); return; end;
if nargin<7, L = 1365; end;
if nargin<6, res=1;    end;
if nargin<5, author=2; end;
if nargin<4, qinso=-2; end;
if nargin<3, lat=65;   end;
day=day*res;

if author == 6
  load BergerLoutre1991.mat;
  %   Time    ECC      OMEGA   OBL       PREC   65NJul  65SJan  15NJul  15SJan
  %      0  0.017236  101.37  23.446   0.01690  426.76  455.58  440.60  470.35
  %fprintf('\n Using orbital solution of Berger and Loutre, 1991 \n'); 
  time = -1 * Orbit(:,1);
  ecc  = Orbit(:,2);
  oblE = Orbit(:,4) * pi / 180;
  Prec = -Orbit(:,5);
  clear Orbit
  w = unwrap(angle(hilbert(Prec./ecc)))*180/pi+270;    %There is 270 degree phase discrepancy here.
elseif  author == 1
  %fprintf('\n Using orbital solution of Laskar et al. (2004) \n');
  load La04.mat;		%contains time, ecc, obl, prec
elseif author == 2
  %fprintf('\n Using orbital solution la10a of Laskar et al. (2011) \n');
  load La10a.mat;		%contains time, ecc, obl, prec
elseif author == 3
  %fprintf('\n Using orbital solution la10a of Laskar et al. (2011) \n');
  load La10b.mat;		%contains time, ecc, obl, prec
elseif author == 4
  %fprintf('\n Using orbital solution la10a of Laskar et al. (2011) \n');
  load La10c.mat;		%contains time, ecc, obl, prec
elseif author == 5
  %fprintf('\n Using orbital solution la10a of Laskar et al. (2011) \n');
  load La10d.mat;		%contains time, ecc, obl, prec
else
    errordlg('No astronomical solution available')
end

if ismember(author, [1,2,3,4,5])
  time = data(:,1);
  ecc = data(:,2);
  oblE = data(:,3);
  Prec = -1* data(:,4);
  w = unwrap(angle(hilbert(Prec./ecc)))*180/pi+270;    %There is 270 degree phase discrepancy here.
  clear data;
end

%eccentricity(time), obliquity(time), and the precession parameter.  
I=[];
T=[];
Insol_a_m = zeros(1,length(t)); % Insolation annual mean
Ix = zeros(1,length(t));
%II = [];
II = zeros(length(lat),length(day),length(t));
%L = 1365;	    %the solar constant, in W/m2 at 1 AU
% [xorb,yorb] = ellipse_s(0.0167,365*res);
%dist02 = (xorb.^2 + yorb.^2);
% dist0m = mean(sqrt(dist02));
%interpolate to times t
et = spline(time,ecc,t);		%eccentricity(t)
ot = spline(time,oblE,t);		%obliquity(t)
wt = spline(time,w,t);			%longitude of perihelion

for tnx = 1:length(t)			%loop over times in history
    tt  = t(tnx);			    %time for this iteration
	etx = et(tnx);			    %eccentricity at tt
	otx = ot(tnx);			    %obliquity at tt
	wtx = wt(tnx)*pi/180;	 	%argument of precession at tt 
	%etx = .4;
    %wtx = pi/2; 
	%if rem(tnx,100)==0, disp(tt); end;
	disp(['time: ',num2str(tt),' kyr']);
    
	%model of the orbit is an ellipse with 365 points, one for
	%each day of a non-leap year.  The eccentricity, obliquity, and
    %precessional parameter are all
	%taken from data of Quinn, Tremaine, and Duncan (1991) or Berger
    %and Loutre (1991).  The x,y,z
	%coordinate system is: x points to perihelion, and z is normal to
    %the modern ecliptic	
	%Note using four times the spatial resolution.

	[xorb,yorb] = ellipse(etx,365*res); 		
    %[xorb,yorb] = ellipse(a,etx,wtx,365*res); 
	zorb = zeros(size(xorb));
	dist = sqrt(xorb.^2 + yorb.^2 + zorb.^2);
    Insol_a_m(tnx) = mean(1/(dist.*dist));
    
	unit = [xorb./dist, yorb./dist, zorb./dist];
	%from perihelion, rotate counterclockwise by w degrees
	vtry = [cos(wtx)*unit(1,1)-sin(wtx)*unit(1,2), cos(wtx)*unit(1,2)+sin(wtx)*unit(1,1),unit(1,3)];
	%closest match is the vernal equinox day
	dif = (unit-repmat(vtry,length(unit),1)).^2;	%difference between the unit vector to each day and the vernal equinox
	[~,veq] = min(sum(dif')');	
	%now veq holds the number of days between perihelion and vernal equinox
	
	vernal = 80*res; %vernal equinox, March 20, is 80th day of year (if not a leap year)`	
	%the following lines create variables with the index corresponding to day of the year,
	%not days since perihelion, as ellipse function generates
    if veq>vernal;  pl=([veq-vernal+1:length(xorb) 1:veq-vernal]); end;
	if veq<vernal;  pl=[length(xorb)+veq-vernal+1:length(xorb) 1:length(xorb)+veq-vernal]; end;
	if veq==vernal; pl=1:length(xorb); end;
	xorb=xorb(pl);
  	yorb=yorb(pl);
  	zorb=zorb(pl);
  	dist=dist(pl);

	%Calculate the day of spring equinox
	if day<0 | exist('seq'),
	  unit = [xorb./dist, yorb./dist, zorb./dist];
	  vtry = [cos(pi)*unit(vernal,1)-sin(pi)*unit(vernal,2), cos(pi)*unit(vernal,2)+sin(pi)*unit(vernal,1),unit(vernal,3)];
	  dif = (unit-repmat(vtry,length(unit),1)).^2;	%difference between the unit vector to each day and the spring equinox
	  [~,seq] = min(sum(dif')');	
	  day=[vernal seq];
	%day2(tnx)=day(2)/res;
	%figure(1); clf; hold on;
	%plot(xorb,yorb);
	%plot([0 xorb(day(1))],[0 yorb(day(1))],'b');
	%plot([0 xorb(day(2))],[0 yorb(day(2))],'r');
	%[dummy pl]=min(dist);
	%plot(xorb(pl),yorb(pl),'b*');
	%plot([0 xorb(40)],[0 yorb(40)],'g:');	
	%plot([0 xorb(80)],[0 yorb(80)],'m:');	
	%plot([0 xorb(1)],[0 yorb(1)],'k:');
	%title(num2str([veq seq]/res));
        %r=round(wtx/(2*pi)); wtx=wtx-r*2*pi; 
	%xlabel(num2str(wtx*180/pi));
	%drawnow;
	end;
	
	%get the direction of the north pole from the vernal equinox and the obliquity
	%the vector north3 is perpendicular to the vector to the Sun on March 20
	%and makes an angle of oblE with the normal to the orbit.  Further, it gives
	%the correct sense of summer (ie north3 points to Sun on June 20).
	firstpt = [-xorb(vernal),-yorb(vernal),-zorb(vernal)];	%from Earth to Sun on vernal equinox
	firstpt = firstpt/norm(firstpt);			%normalized
	%another vector in the orbit plane
	vec2 = [xorb(vernal)-xorb(vernal+90*res), yorb(vernal)-yorb(vernal+90*res), zorb(vernal)-zorb(vernal+90*res)];
	vec2 = vec2/norm(vec2);						%normalized
	%normal to plane is given by cross(firstpt,vec2)
	angmom = cross(firstpt,vec2);
	angmom = angmom/norm(angmom);				%normalized
	%need the vector cross(angmom,firstpt)
	vec3 = cross(angmom,firstpt);				%already normalized
	north3 = cos(otx)*angmom + sin(otx)*vec3;
	northproj = atan2(north3(2),north3(1));

%lattitudinal loop	
for lnx=1:length(lat);
latitude=lat(lnx);   

longit = [0:1/res:360-1/res];		%longitude 
%latitiude ring with 360 degreees longitude
xring = cos(latitude*pi/180)*cos(longit*pi/180);
yring = cos(latitude*pi/180)*sin(longit*pi/180);
zring = sin(latitude*pi/180)*ones(size(longit));

%compute orientation of ring for date with respect to the ecliptic
%coordinate system.  Measures the elevation of the Sun in the sky
%at all longitudes on that ring.
[xorient,yorient,zorient] = rot(xring,yring,zring,acos(north3(3)),pi/2+northproj);
up = [xorient',yorient',zorient'];

%day loop
for dnx = 1:length(day);
  doy = day(dnx);
  if doy>365*res | doy<1, fac=floor(doy/(365*res)); t=t+fac/1000; doy=doy-fac*365*res; end

  if rem(doy,1)==0,
    txorb=xorb(doy); 
    tyorb=yorb(doy); 
    tzorb=zorb(doy); 
    tdist=dist(doy);
  else
    txorb=spline(1:365*res,xorb,doy); 
    tyorb=spline(1:365*res,yorb,doy); 
    tzorb=spline(1:365*res,zorb,doy); 
    tdist=spline(1:365*res,dist,doy); 
  end

  sundirect = [-txorb,-tyorb,-tzorb];
  solarelevation = 90 - acos(up*sundirect'/tdist)*(180/pi);
  sunlight = (solarelevation + abs(solarelevation))/2;
  %each time point represents 2 minutes.  Find the daily radiation
  %radky(tnx).d(dnx).ml(:,lnx) = (L/(tdist.^2))*(sin(sunlight*pi/180));
  if qinso==-2, sun(lnx,dnx)=mean((L/(tdist.^2))*(sin(sunlight*pi/180))); end;
  if qinso==-1, sun(lnx,dnx)=max((L/(tdist.^2))*(sin(sunlight*pi/180))); end;
  if qinso>0, 
    pl=find((L/(tdist.^2))*(sin(sunlight*pi/180))>qinso);
    sun(lnx,dnx)=length(pl)/(res*30);  %hours above threshold. 
  end;   
end;
end;

if min(size(sun)==1),
  I(end+1:end+length(sun))=sun;
else
  I=sun;
end
T(end+1:end+length(sun(1,:)))=t(tnx)-day/(res*365*1000);
Ix(tnx) = mean(sun(:));
if length(lat) == 1
    II(:,:,tnx) = I(end);
else %length(I) > 1
    II(:,:,tnx) = I;
end
%figure(2); hold on;
%plot(t(1:length(I)/length(day)),I(1:2:end),'r');
%plot(t(1:length(I)/length(day)),I(2:2:end),'b');
%drawnow;
 end;
% 
% 
function [x,y] = ellipse(e,npts);
% [x,y] = ellipse(e,npts)
% generates an elliptical orbit with eccentricity = e
% npts points equally spaced in time
% and rotated such the perihelion is the first point
%
% uses iteration, and formula from Landau & Lifshitz Mechanics pg 38
% r = a(1-e*cos(xi));	
% t = sqrt(a^3/GM)*(xi - e*sin(xi));
% x = a*(cos(xi)-e);
% y = a*sqrt(1-e^2)*sin(xi);

npts=npts+1;
t = linspace(0,1,npts)';
% solve for xi
fac = sqrt(1/(4*pi^2));
xi = linspace(0,2*pi,npts)';	% starting value
for k = 1:20;	%number of iterations.  Most results not very sensitive.
  xi = e*sin(xi) + t/fac;		
end
x1 = cos(xi)-e;
y1 = sqrt(1-e^2)*sin(xi);

%rotate to perihelion, modified not to require periE input.
[dummy peri]=min(x1.^2+y1.^2);
if peri>1, 
  pl=[peri:length(x1)-1 1:peri-1]; 	 
else,
  pl=1:length(x1)-1;
end;
x=x1(pl);
y=y1(pl); 
	 	 
	 
function [xp,yp,zp] = rot(x,y,z,inc,omega);
% [xp,yp,zp] = rot(x,y,z,inc,omega);
% takes vectors x,y,z and transforms them
% rotates through angle of nodes omega
% tilts through inclination inc
% evaluate trig functions once:
	cosomega = cos(omega);
	sinomega = sin(omega);
	cosinc = cos(inc);
	sininc = sin(inc);
% transform:
% tilt by inclination angle around x axis
% since perihelion is defined in generating ellipse
% with ellip.m, node is on x-axis.
% recall that argument of perihelion is defined from node
	xt = x;
	yt = y*cosinc - z*sininc;
	zt = z*cosinc + y*sininc;
% these are NOT new axes, but the vectors themselves are 
% rotated in ecliptic coordinates.  Thus, the next 
% transformation is truly about the z-axis, as it should
% be.  It is NOT about a rotated z-axis.  Think of 
% transforming components, not basis vectors.

% rotate around z axis by omega 
	xp = xt*cosomega - yt*sinomega;
	yp = yt*cosomega + xt*sinomega;
	zp = zt;
% 	