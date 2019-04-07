% Output even spaced data
%%
function [data_even]=interpolate(data,interpolate_rate)
  
  dataxeven=[];
  datax=data(:,1);
  datay=data(:,2);
  npts=length(datax);      
  diffx=diff(datax);
  diffxmean=mean(diffx);
  diffxmax=max(diffx);
  diffxmin=min(diffx);
    
    dataxeven=(datax(1):interpolate_rate:datax(npts));  
    dataxeven=dataxeven';
 %   datayeven=interp1(datax,datay,dataxeven,'PCHIP');
    datayeven=interp1(datax,datay,dataxeven);
    data_even=[dataxeven,datayeven];
end