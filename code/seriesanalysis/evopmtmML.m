 function [powratio]=evopmtmML(dat,filename,fmin,fmax,window,fterm,nw)
% Mingsong Li, Nov 12, 2014 @ JHU
% dat should be even spaced time series

%%
datasxdif=diff(dat(:,1));
dt=mean(datasxdif);
nyquist=1/(2*dt);                   % nyquist
[nrow ncol]=size(dat);    % size of dat
xdata=dat(:,2);           % value of interpolated series
npts=round(window/dt);              % number of data used for one calculation
m=nrow-npts+1;                      % number of pmtm calculations, n_row of pmtm matrix results
pow=ones(1,m);                      % matrix of sum power from fmin to fmax
powall=ones(1,m);                   % matrix of sum power from 0 to fterm
ratio=zeros(1,m);                   % ratio of selected pow/powall
x=zeros(1,npts);                    % 1*npts matrix for picking data using floating window
[nfpts]=nfft(npts);                 % function nfft is at the end of this function
ss=zeros(m,nfpts);                  % pmtm results of each mtm calculation
%% Calculate evolutionary pmtm results of dat using givin window
%  get a ss[m X nfpts]
for m1=1:m
    m2=npts+m1-1;
    if m2>nrow                      % break in case of reach boundary of moving window
        break
    end
    for mx=m1:m2                    % pick data usging floating npts 
        j=mx-m1+1;                  % j = 1:npts
        x(j)=xdata(mx);             %
    end
    x=detrend(x);
    [p,w]=pmtm(x,nw);
    ss(m1,:)=p;
    m1=m1+dt;
end    

%% Power sum of selected frequency
nfmin=ceil(nfpts*fmin/nyquist);
if nfmin==0
    nfmin=1;
end
nfmax=fix(nfpts*fmax/nyquist);
nfterm=ceil(nfpts*fterm/nyquist);
if nfterm>nfpts
    nfterm=nfpts;
end
powallsum=zeros(1,nfterm);
nfn=nfmax-nfmin+1;
spq=zeros(1,nfn);

% calculate power
for p=1:m
    %  total power of 'total' frequency (from 0 to fterm)
    for ii=1:nfterm
        powallsum(ii)=ss(p,ii);
    end
    powall(p)=sum(powallsum);
    % total power of selected frequency cutoff
    ij=1;
    for q=nfmin:nfmax
        spq(ij)=ss(p,q);
        ij=ij+1;
    end 
    pow(p)=sum(spq);
    %%
    ratio(p)=pow(p)/powall(p);   
end
%% plot
data1=dat(1,1);
data2=dat(nrow,1);
xgrid=linspace(data1+window/2,data2-window/2,m);
%
figure;
subplot(3,1,1);
plot(xgrid,ratio);
title(['pmtm ratio of selected frequency from ',num2str(fmin),' to ',num2str(fmax),char(10),...
       'Window, dt, nw and frequency cutoff are: ',num2str(window),', ' ,num2str(dt),', ',num2str(nw),', ', num2str(fterm)]);
subplot(3,1,2);
plot(xgrid,pow);
title(['Total power of selected frequency from ',num2str(fmin),' to ',num2str(fmax)])
subplot(3,1,3);
plot(xgrid,powall);
title(['Total power of frequency from 0 to ',num2str(fterm)])
set(gcf,'Name',[num2str(filename),': power ratio'])
 
% %% output & save xlsx figure
% 
% powratio=[xgrid;ratio;pow;powall];
% powratio=powratio';
% col1=['depth/time'];
% col2=['power/power_0_',num2str(fterm)];
% col3=['pow_freq_',num2str(fmin),'_',num2str(fmax)];
% col4=['pow_freq_0_',num2str(fterm)];
% title0 = {col1;col2;col3;col4}';
% 
%    cd ..; cd result
%    figurename=[filename,'_freq_Power_ratio_',num2str(fmin),'_',num2str(fmax),'_win_',num2str(window),'.fig'];
%    saveas(gcf,num2str(figurename))
% filename1=[filename '_log.xls'];
% xlswrite(filename1,title0,'pow_ratio_results','A1:D1');
% xlswrite(filename1,powratio,'pow_ratio_results','A2');

 end 

function [nfpts]=nfft(npts)
   x=rand(1,npts);
   xx=pmtm(x);
   [nfpts n]=size(xx);
end
