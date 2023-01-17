%% Wavelet coherence
%
% USAGE: [Rsq,period,scale,coi,sig95]=wtc(x,y,[,settings])
%
%
% Settings: pad: pad the time series with zeros?
% .         dss: Octaves per scale (default: '1/12')
% .         S0: Minimum scale
% .         J1: Total number of scales
% .         mother: Mother wavelet (default 'morlet')
% .         MaxScale: An easier way of specifying J1
% .         MakeFigure: Make a figure or simply return the output.
% .         BlackandWhite: Create black and white figures
% .         AR1: the ar1 coefficients of the series
% .              (default='auto' using a naive ar1 estimator. See ar1nv.m)
% .         MonteCarloCount: Number of surrogate data sets in the significance calculation. (default=300)
% .         ArrowDensity (default: [30 30])
% .         ArrowSize (default: 1)
% .         ArrowHeadSize (default: 1)
%
% Settings can also be specified using abbreviations. e.g. ms=MaxScale.
% For detailed help on some parameters type help wavelet.
%
% Example:
%    t=1:200;
%    wtc(sin(t),sin(t.*cos(t*.01)),'ms',16)
%
% Phase arrows indicate the relative phase relationship between the series
% (pointing right: in-phase; left: anti-phase; down: series1 leading
% series2 by 90�)
%
% Please acknowledge the use of this software in any publications:
%   "Crosswavelet and wavelet coherence software were provided by
%   A. Grinsted."
%
% (C) Aslak Grinsted 2002-2014
%
% http://www.glaciology.net/wavelet-coherence


% -------------------------------------------------------------------------
%The MIT License (MIT)
%
%Copyright (c) 2014 Aslak Grinsted
%
%Permission is hereby granted, free of charge, to any person obtaining a copy
%of this software and associated documentation files (the "Software"), to deal
%in the Software without restriction, including without limitation the rights
%to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%copies of the Software, and to permit persons to whom the Software is
%furnished to do so, subject to the following conditions:
%
%The above copyright notice and this permission notice shall be included in
%all copies or substantial portions of the Software.
%
%THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%THE SOFTWARE.
%---------------------------------------------------------------------------

% Revised by Mingsong Li for Acycle v2.4.1

% ------validate and reformat timeseries.
[x,dt]=formatts(dat1);
[y,dty]=formatts(dat2);
if dt~=dty
    error('timestep must be equal between time series')
end
t=(max(x(1,1),y(1,1)):dt:min(x(end,1),y(end,1)))'; %common time period
if length(t)<4
    error('The two time series must overlap.')
end

n=length(t);

S0 = 2*dt;
MaxScale=(n*.17)*2*dt; %auto maxscale
J1=round(log2(MaxScale/S0)/dss);
mother = 'Morlet';
%MonteCarloCount = 300;
AR1=[ar1nv(x(:,2)) ar1nv(y(:,2))];
if any(isnan(AR1))
    disp('Automatic AR1 estimation failed. Specify it manually (use arcov or arburg).')
    AR1=[rhoAR1ML(x(:,2)) rhoAR1ML(y(:,2))];
end
ArrowDensity = [30 30];
ArrowSize = 1;
ArrowHeadSize= 1;

ad=mean(ArrowDensity);
ArrowSize=ArrowSize*30*.03/ad;
ArrowHeadSize=ArrowHeadSize*120/ad;

nx=size(x,1);

ny=size(y,1);

%-----------:::::::::::::--------- ANALYZE ----------::::::::::::------------

[X,period,scale,coix] = wavelet(x(:,2),dt,pad,dss,S0,J1,mother,param);%#ok
[Y,period,scale,coiy] = wavelet(y(:,2),dt,pad,dss,S0,J1,mother,param);

%Smooth X and Y before truncating!  (minimize coi)
sinv=1./(scale');

sX=smoothwavelet(sinv(:,ones(1,nx)).*(abs(X).^2),dt,period,dss,scale);
sY=smoothwavelet(sinv(:,ones(1,ny)).*(abs(Y).^2),dt,period,dss,scale);


% truncate X,Y to common time interval (this is first done here so that the coi is minimized)
dte=dt*.01; %to cricumvent round off errors with fractional timesteps
idx=find((x(:,1)>=(t(1)-dte))&(x(:,1)<=(t(end)+dte)));
X=X(:,idx);
sX=sX(:,idx);
coix=coix(idx);

idx=find((y(:,1)>=(t(1))-dte)&(y(:,1)<=(t(end)+dte)));
Y=Y(:,idx);
sY=sY(:,idx);
coiy=coiy(idx);

coi=min(coix,coiy);

% -------- Cross wavelet -------
Wxy=X.*conj(Y);
%
Pkx=ar1spectrum(AR1(1),period./dt);
Pky=ar1spectrum(AR1(2),period./dt);

sigmax=std(x(:,2));

sigmay=std(y(:,2));

V=2;
Zv=3.9999;
signif=sigmax*sigmay*sqrt(Pkx.*Pky)*Zv/V;
sig95 = (signif')*(ones(1,n));  % expand signif --> (J+1)x(N) array
sig95 = abs(Wxy) ./ sig95;
% ----------------------- Wavelet coherence ---------------------------------
sWxy=smoothwavelet(sinv(:,ones(1,n)).*Wxy,dt,period,dss,scale);
Rsq=abs(sWxy).^2./(sX.*sY);


wtcsig=wtcsignif(MonteCarloCount,AR1,dt,length(t)*2,pad,dss,S0,J1,mother,.6);
wtcsig=(wtcsig(:,2))*(ones(1,n));
wtcsig=Rsq./wtcsig;
