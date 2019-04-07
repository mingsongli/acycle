% interpolate data using cubic model
% Output even spaced data
%%
function [data_even]=interpolate_rand(data,interpolate_rate)
  

  datax=data(:,1);
  datay=data(:,2);
  npts=length(datax);     
  rand_v = interpolate_rate*rand();
    dataxeven=(datax(1):interpolate_rate:datax(npts))+rand_v;  
    dataxeven=dataxeven';
 %   datayeven=interp1(datax,datay,dataxeven,'PCHIP');
    datayeven=interp1(datax,datay,dataxeven);
    data_even=[dataxeven,datayeven];
end