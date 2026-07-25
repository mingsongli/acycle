function [datapks,m] = getpks(data)


datax=data(:,1);
datay=data(:,2);

n=numel(datax);
m=1;
datapks = zeros(max(n-2,0),2);

for i=2:n-1
    if datay(i)>= datay(i-1)
      if  datay(i)>= datay(i+1)
          datapks(m,1)=datax(i);
          datapks(m,2)=datay(i);
          m=m+1;
      end
    end
end
datapks = datapks(1:m-1,:);
end
