function data=findduplicate(data)

% This function aims to creat a new data series
% with no duplicate values
% Updated: data >2 columns allowed.
%
% Mingsong Li
% Peking University
% Oct. 14, 2023
%

x=data(:,1);
b=unique(x);
sizex=length(x);
sizeb=length(b);

    if sizex-sizeb~=0
        y = data(:,2:end);
        %c = histc(x,b);
        
          for i = 1:length(b)
            d(i,:) = mean( y(x==b(i),:) , 1);
          end
          
        %d=d';
        data=[b,d];
        disp('>> Duplicate has been detected')
     end
end