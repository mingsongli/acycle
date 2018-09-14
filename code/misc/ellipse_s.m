function [x,y] = ellipse_s(e,npts)
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