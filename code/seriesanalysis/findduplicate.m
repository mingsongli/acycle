function data=findduplicate(data)

% This function aims to creat a new data series
% with no repetitions

x=data(:,1);
b=unique(x);
sizex=length(x);
sizeb=length(b);
    if sizex-sizeb~=0
        y=data(:,2);
        c=histc(x,b);
          for i=1:length(b)
            d(i)=sum(y(x==b(i)))/c(i);
          end
          d=d';
        data=[b,d];
        disp('>> Duplicate has been detected')
     end
end