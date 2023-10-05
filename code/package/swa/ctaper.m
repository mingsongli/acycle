%%
% Cosine tapering first and last 5% of time_ml series based
% on TAPER of Bloomfield (1976).
% Designed for fixed spacing or irregularly spaced data.
function [x,time_ml,ndata,tdif]=ctaper(x,time_ml,ndata,tdif,varargin)
persistent andata bit_ml i weight xpi xprop ; 

 if isempty(i), i=0; end 
 if isempty(andata), andata=0; end 
 if isempty(xprop), xprop=0; end 
 if isempty(bit_ml), bit_ml=0; end 
 if isempty(xpi), xpi=0; end 
 if isempty(weight), weight=0; end 
xpi=3.1415926535897932d0;
andata=ndata;
bit_ml=tdif./(10.0.*andata);
xprop=0.0;
if(time_ml(ndata)-time_ml(1) > 0.0d0);
for  i=1:ndata;
xprop=(time_ml(ndata)-time_ml(i)+bit_ml)./tdif;
if(xprop < 0.05||xprop > 0.95);
weight=0.5 - 0.5.*cos(xpi.*(xprop./0.05));
x(i)=x(i).*weight;
end 
     end   
     i=fix(ndata+1);
else;
for  i=1:ndata;
xprop=(time_ml(i)-time_ml(ndata)+bit_ml)./tdif;
if(xprop < 0.05||xprop > 0.95);
weight=0.5 - 0.5.*cos(xpi.*(xprop./0.05));
x(i)=x(i).*weight;
end 
     end   
     i=fix(ndata+1);
end 
return;
end