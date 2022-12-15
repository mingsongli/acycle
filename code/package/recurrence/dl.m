function [a_out, b_out]=dl(varargin)
% DL   Mean of the diagonal line lengths and their distribution.
%    A=DL(X) computes the mean of the length of the diagonal 
%    line structures in a recurrence plot using a specific
%    algorithums (see below).
%
%    [A B]=DL(X) computes the mean A and the lengths of the
%    found diagonal lines, stored in vector B. In order to get  
%    the histogramme of the line lengths, simply call 
%    HIST(B,[1 MAX(B)]).
%
%    ...=DL(X,method) uses the specified method for considering
%    border lines (lines starting and ending at a border of the RP).
%
%    Methods regarding considering border lines.
%      'all'    - (Default) Considers all individual lengths of 
%                 border lines.
%      'censi'  - Correction schema for border lines as proposed by 
%                 Censi et al. 2004, in which the length of the 
%                 longest border line is used for all border lines
%                 (recommended for cyclical signals).
%      'kelo'   - Correction schema for border lines using KEep LOngest 
%                 diagonal line (KELO), in which only the longest border 
%                 line (in each triangle) of the RP is considered but 
%                 all other border lines are discarded.
%      'semi'   - Relaxing the definition of border lines: not only lines 
%                 starting AND ending at a border of the RP, but also 
%                 semi border lines, which are lines that start or end 
%                 at a border of the RP but have the corresponding
%                 ending or starting not at the border, are count.
%                 Has only effect for 'censi' or 'kelo' method.
%
%    Remark: In Censi et al. 2004, the length of the LOI was considered
%    to be the longest borderline. Here we use a modification by 
%    excluding the LOI from the set of borderlines. This usually results
%    in a shorter length of the border lines than in the original
%    Censi approach. But this would allow us to use this correction
%    schema also for non-cyclical signals without strange effects.
%
%    Examples: a = sin(linspace(0,5*2*pi,1050));
%              X = crp(a,2,50,.2,'nonorm','nogui');
%              [l1 l_dist1] = dl(X,'all'); % considering all border lines
%              [l2 l_dist2] = dl(X,'censi'); % apply Censi correction for border lines
%              [l3 l_dist3] = dl(X,'kelo'); % apply KELO correction for border lines
%              subplot(3,1,1)
%              hist(l_dist1,200)
%              title(sprintf('considering all border lines, l=%.1f',l1))
%              subplot(3,1,2)
%              hist(l_dist2,200)
%              title(sprintf('Censi correction, l=%.1f',l2))
%              subplot(3,1,3)
%              hist(l_dist3,200)
%              title(sprintf('KELO correction, l=%.1f',l3))
%
%    See also CRQA, TT.
%
%    References: 
%    Censi, F., et al.:
%    Proposed corrections for the quantification of coupling patterns by 
%    recurrence plots, IEEE Trans. Biomed. Eng., 51, 2004.
%
%    Kraemer, K. H., Marwan, N.:
%    Border effect corrections for diagonal line based recurrence 
%    quantification analysis measures, Phys. Lett. A, 383, 2019.

% Copyright (c) 2008-
% Norbert Marwan, Potsdam Institute for Climate Impact Research, Germany
% http://www.pik-potsdam.de
%
% Copyright (c) 2001-2008
% Norbert Marwan, Potsdam University, Germany
% http://www.agnld.uni-potsdam.de
%
% $Date: 2021/11/25 11:04:49 $
% $Revision: 3.9 $
%
% $Log: dl.m,v $
% Revision 3.9  2021/11/25 11:04:49  marwan
% bug in GUI in crqa fixed
%
% Revision 3.8  2021/11/23 13:49:06  marwan
% change dl function to use 'all' as default.
% include borderline corrections into crqa
%
% Revision 3.7  2021/11/23 12:05:12  marwan
% merging dl_censi and dl_kelo into the standard dl function
%
% Revision 3.6  2016/03/03 14:57:40  marwan
% updated input/output check (because Mathworks is removing downwards compatibility)
% bug in crqad_big fixed (calculation of xcf).
%
% Revision 3.5  2015/09/24 11:55:02  marwan
% fixed broken compatibility with MATLAB 2015b
%
% Revision 3.4  2009/03/24 08:32:09  marwan
% copyright address changed
%
% Revision 3.3  2005/11/23 07:29:14  marwan
% help text updated
%
% Revision 3.2  2005/03/16 11:19:02  marwan
% help text modified
%
% Revision 3.1  2004/11/10 07:07:35  marwan
% initial import
%
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or any later version.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check and read the input
narginchk(1,2)
nargoutchk(0,2)

% default values
method = 'all';
style = 'normal';

warning off
X = logical(varargin{1});
check_style = {'normal','semi'}; % borderline-style
check_meth = {'all','censi','kelo'}; % correction method

i_char=find(cellfun('isclass',varargin,'char'));

for i = i_char
   
   % check which borderline-style to be used
   if strcmpi(varargin{i},'semi'), style = 'semi'; end
   % check which correction method to be used
   if strcmpi(varargin{i},'all')
      method = 'all';
   elseif strcmpi(varargin{i},'censi')
      method = 'censi';
   elseif strcmpi(varargin{i},'kelo')
      method = 'kelo'; 
   end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% calculate diagonal lines
switch(method)
   case 'all'
      [a b] = dl_all(X);
   case 'censi'
      [a b] = dl_censi(X,style);
   case 'kelo'
      [a b] = dl_kelo(X,style);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% output
if nargout==2
     b_out=b;
end

if nargout>0
     a_out=a;
else
     NaN
end

warning on
