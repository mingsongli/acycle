
% This script translated from radfor.F of the GENIE climate model


% c radfor.F fortran routine to calculate radiative forcing for c-goldstein
% c started 30/5/3 Neil R. Edwards
% c loosely based on Peter Cox's SUNNY.f or see Peixoto and Oort 1992 p.99
% c
% c nyear = number dt per year
% c osct  = angular time of year (0,..,2pi)
% c oscsind = sine of declination (not an input)

% c oscsob = sine of obliquity (input)
% c osce = eccentricity (input)
% c oscgam = ?? [radians!!]

% c oscday = 0.5 * sunlit (angular) fraction of day, ie 1/2 length of day
% c solfor = solar forcing = scaling factor * integral of cosine of solar 
% c          elevation during daylight
% c
% c gn_daysperyear = ?? (input?) Mingsong Li
% c osctau0 = initialise osctau0 for angular time of year
% c          value of osctau0=-0.5 (=> osctau1=0.0) reproduces old orbital calculation

osce=0.0167;  % eccentricity
oscsob=0.397789; % sine of obliquity (input)
oscgam=1.352631;  % longitude of perihelion? [radians!!]
osctau0 = -0.5;
gn_daysperyear = 365; 
nyear = 98;
jmax = 36;
% solconst = 1367;  % present-day
solconst = 1361.7;  % solar constant for the end-Paleocene
%
solavg = zeros(jmax,1);
rpi = 1.0/pi;
% all tv, osce1, osce2, osce3, and osce4 are based on eccentricity.
tv = osce*osce;
osce1 = osce * (2.0 - 0.25*tv);
osce2 = 1.25 * tv ;
osce3 = osce*tv * 13./12.;
osce4 = ((1.0 + 0.5*tv)/(1.0 - tv))^2;

% angular [radians] of each time step (dt).
%oscryr = 2.0*pi/float(nyear);
oscryr = 2.0*pi/double(nyear);

% if osctau0 = -0.5, then osctau1 = 0.0
      osctau1 = osctau0 + 0.5;

% now do each dt calculation
for istep=1:nyear

%pbh Dan's offset for angular time of year
%         osct = float(mod(istep-1,nyear)+1)*oscryr
    osct = (double(mod(istep-1,nyear)+1)-(nyear*osctau1/gn_daysperyear))*oscryr;

%    do from one pole to another pole
     for j=1:jmax
         % v = lambda - varpi;
        oscv = osct + osce1*sin(osct) + osce2*sin(2.0*osct) + osce3*sin(3.0*osct);
        oscsolf = osce4*(1.0 + osce*cos(oscv))^2;
        oscsind = oscsob*sin(oscv-oscgam);  % sin(delta) = sin(obliquity)*sin(lambda)

        oscss = oscsind * s(j); % ??? What is this?
        osccc = sqrt(1.0 - oscsind^2) * c(j); % ? What is this?
        osctt = min(1.0,max(-1.0,oscss/osccc));

        oscday = acos(- osctt);

        solfor(j,istep) = solconst*oscsolf*rpi*(oscss*oscday + osccc*sin(oscday));
% SG > ENTS albedo scheme mod
%         if (flag_ents)
%            call ocean_alb(oscss,osccc,oscday,j,istep)
%         end
% SG <
%           write(1,'(e15.5)')solfor(j,istep)
     end
end


if (dosc) 
else
% replace variable forcing by its average
%
      for j = 1:jmax
% ML <   solavg(j) = 0.;
         for istep=1:nyear
            solavg(j) = solavg(j) + solfor(j,istep);
% SG > ENTS albedo scheme mod
             if (flag_ents)
                alboavg(j) = alboavg(j) + albo(j,istep);
             end
% SG <
         end
      end
      
      for j=1:jmax
         for istep=1:nyear
            solfor(j,istep) = solavg(j)/nyear;
% SG > ENTS albedo scheme mod
         if (flag_ents)
            albo(j,istep) = alboavg(j)/nyear;
         end
% SG <
         end
      end
end
      
      
      