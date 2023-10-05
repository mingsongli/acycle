%%
% Lomb-Scargle transform based on PERIOD of Press et al. (1992).
% Periodogram normalised power calculated following Press et al. (1992).
% Current frequency (FREQ) set via PNOW.
%function [x,time_ml,ndata,avex,nout,xfint,pow]=period(x,time_ml,ndata,avex)%,nout,xfint,pow(varargin),;
function [x,time_ml,ndata,avex,nout,xfint,pow,freq]=period(x,time_ml,ndata,avex,nout,xfint,varx)%,pow(varargin),;
    
%       [x1,time_ml,ndata,avex,nout,xfint,pow,freq,varx1] 

%persistent ac freq i j nmax nmaxb twopid ; 

persistent ac i j nmax nmaxb twopid; 

%+                   freq,varx);
 if isempty(i), i=0; end 
 if isempty(j), j=0; end 
 if isempty(nmax), nmax=300001; end 
 if isempty(nmaxb), nmaxb=fix(nmax./2) ; end 
% if isempty(freq), freq=zeros(1,nmaxb); end 
 if isempty(ac), ac=zeros(1,nmaxb); end 
% doubleprecision ::;
%+      bc(nmaxb),pow(nmaxb),xfint,wpr(nmax),wpi(nmax),wr(nmax),;
%+      dumma,dummb,wi(nmax),twopid,arg,timeave,sums,pnow,sumsh,;
%+      sumc,cos,ssin,wtau,swtau,cwtau,sumsy,sumcy,ss,cc,yy,;
%+      wtemp,avex,tave,varx;
if isempty(twopid), twopid=6.2831853071795865d0 ; end 

tave=0.5d0.*(time_ml(1)+time_ml(ndata));
% Calculations start at XFINT
pnow=xfint;
% Nb Detrended (zero power at Freq=0.0)
dumma=-2.0d0;
dummb=0.5d0;

for  j=1:ndata;
    arg=twopid.*((time_ml(j)-tave).*pnow);
    wpr(j)=dumma.*sin(dummb.*arg).^2;
    wpi(j)=sin(arg);
    wr(j)=cos(arg);
    wi(j)=wpi(j);
end   
j=fix(ndata+1);
% Start Freq positions from XFINT1
pnow=xfint;
for  i=1:nout;
    freq(i)=pnow;
    sumsh=0.0d0;
    sumc=0.0d0;
    for  j=1:ndata;
        cos1=wr(j);
        ssin=wi(j);
        sumsh=sumsh+ssin.*cos1;
        sumc=sumc+(cos1-ssin).*(cos1+ssin);
    end   
    j=fix(ndata+1);
    wtau=0.5d0.*atan2(2.0d0.*sumsh,sumc);
    swtau=sin(wtau);
    cwtau=cos(wtau);
    sums=0.0d0;
    sumc=0.0d0;
    sumsy=0.0d0;
    sumcy=0.0d0;
    for  j=1:ndata;
        ssin=wi(j);
        cos1=wr(j);
        ss=ssin.*cwtau-cos1.*swtau;
        cc=cos1.*cwtau+ssin.*swtau;
        sums=sums+ss.^2;
        sumc=sumc+cc.^2;
        yy=x(j)-avex;
        sumsy=sumsy+yy.*ss;
        sumcy=sumcy+yy.*cc;
        wtemp=wr(j);
        wr(j)=(wr(j).*wpr(j)-wi(j).*wpi(j))+wr(j);
        wi(j)=(wi(j).*wpr(j)+wtemp.*wpi(j))+wi(j);
    end 
    j=fix(ndata+1);
    % Normalised power
    pow(i)=0.5d0.*(sumcy.^2./sumc+sumsy.^2./sums)./varx;
    pnow=pnow+xfint;
end   
  i=fix(nout+1);
return;
end
