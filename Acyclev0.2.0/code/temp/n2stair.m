% Series to stair using given step.
function [dat]=n2stair(data,dt)
datax=data(:,1);
datay=data(:,2);
npts_data=length(datax);
nn = round((datax(npts_data)-datax(1))/dt);
datx = linspace(datax(1),datax(npts_data),nn);
datx = datx';
daty = zeros(length(datx),1);

npts_dat=length(datx);

for i=1:npts_dat
  for j=2:npts_data
    if datx(i)>=datax(j-1) && datx(i)<=datax(j)
        daty(i)=datay(j-1);
    end
  end
end

dat=[datx,daty];

%figure;plot(datx,daty)