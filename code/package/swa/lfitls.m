%%
% Line fitting using least squares. Based on FIT
% from Press et al (1992). Used to linearly detrend time_ml series
% with or without missing and/or irregularly spaced data.
function [time_ml,x,ndata,xinterc,slope]=lfitls(time_ml,x,ndata,xinterc,slope,varargin);
persistent aa an bb i st2 sx sxoss sy tt ; 

 if isempty(i), i=0; end 
 if isempty(sx), sx=0; end 
 if isempty(sy), sy=0; end 
 if isempty(st2), st2=0; end 
 if isempty(bb), bb=0; end 
 if isempty(aa), aa=0; end 
 if isempty(an), an=0; end 
 if isempty(tt), tt=0; end 
 if isempty(sxoss), sxoss=0; end 
sx=0.0;
sy=0.0;
st2=0.0;
bb=0.0;
aa=0.0;
xinterc=0.0;
slope=0.0;
an=ndata;
for  i=1:ndata;
sx=sx+time_ml(i);
sy=sy+x(i);
  end   
  i=fix(ndata+1);
sxoss=sx./an;
for  i=1:ndata;
tt=time_ml(i)-sxoss;
st2=st2+(tt.*tt);
bb=bb+tt.*x(i);
  end   
  i=fix(ndata+1);
bb=bb./st2;
aa=(sy-(sx.*bb))./an;
xinterc=aa;
slope=bb;
return;
end