function [datapks,m] = getpks(data)


datax=data(:,1);
datay=data(:,2);

n=size(datax);
m=1;


for i=2:n-1
    if datay(i)>= datay(i-1)
      if  datay(i)>= datay(i+1)
          datapksx(m)=datax(i);
          datapksy(m)=datay(i);
          m=m+1;
      end
    end
end

datapksx=datapksx';
datapksy=datapksy';

datapks=[datapksx,datapksy];
end