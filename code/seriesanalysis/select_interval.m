function [select_inter] = select_interval(data,t1,t2)
% INPUT
%   data: n column dataset including depth/time as the first column, n > 2
%   t1: start time of the selected interval
%   t2: end time of the selected interval
%   
% By Mingsong Li of Penn State, 2017

datax=data(:,1);
datay=data(:,2:end);
[~, yn] = size(datay);
dataxlength=length(datax);
p=1;
q=dataxlength;
m=1;
%%
while datax(p) < t1
    p=p+1;
end
while datax(q) > t2
    q=q-1;
end
%%
data_select_length = q-p+1;
select_intervalx = zeros(data_select_length,1);
select_intervaly = zeros(data_select_length,yn);
%%
for n=p:q
        select_intervalx(m)=datax(n);
        select_intervaly(m,:)=datay(n,:);
        n=n+1;
        m=m+1;
end
%%
select_inter=[select_intervalx,select_intervaly];