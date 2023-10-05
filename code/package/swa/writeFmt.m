function [writeErrFlag]=writeFmt(unitIn,formatIn,varargin)
% reproduces fortran's formatted write statements
 global unit2fid ; crlf=char(10); if ispc, crlf=[char(13),crlf]; end
 %translate unitIn to fidIn
 if isnumeric(unitIn)
  if isempty(unit2fid)
   fidIn=1;
  else
   fidRow=find(unit2fid(:,1)==unitIn,1,'last');
   if isempty(fidRow)
    if unitIn==6 || unitIn==1
     fidIn=1;
    else %fortran writes text files like fort.3 in these cases
     warning(['unknown fid in writeFmt',]);
     thismlfid=fopen(strtrim(['matl.',num2str(unitIn)]),'w+');
     unit2fid=[unit2fid;unitIn,thismlfid];
     fidIn=unit2fid(fidRow,2);
    end
   else
    fidIn=unit2fid(fidRow,2);
   end
  end % if isempty(unit2fid)
 else %internal write, pass the string through
  fidIn=unitIn;
 end
 if isempty(formatIn), formatIn='\n'; end
 %for i=1:length(varargin),  varargin{i}=strtrim(varargin{i}); end
 varargin=strtrim(varargin);
 %extract format fields from formatIn
 percents=find(formatIn=='%');
 if isempty(percents) && ~isempty(inputname(2)) && ~isempty(varargin) %try to convert manually if formatIn was a variable at conversion time
 %if isempty(percents) & ~isempty(inputname(2))
  if isempty(find(formatIn==''''))
   formatIn=lower(regexprep(formatIn,{'(',')','([, ])(\w)(\d*\.*\d*)',','},{',',',','$1%$3$2',''})); percents=find(formatIn=='%');
  end % if isempty(find(formatIn==''''))
 end % if isempty(percents) %try to convert manually
 formatInLetters=find(isletter(formatIn));
 formatFields={}; ffWithFormat=[];
 if ~isempty(percents)
  if percents(1)>1
   formatFields{1}=formatIn(1:percents(1)-1);
  end
  for ii=1:length(percents)
   if length(formatIn)>percents(ii) && formatIn(percents(ii)+1)=='%', continue, end
   nextLetter=formatInLetters(find(formatInLetters>percents(ii),1,'first'));
   if strcmpi(formatIn(nextLetter),'l'), formatIn(nextLetter)='d'; end
   formatFields{length(formatFields)+1}=formatIn(percents(ii):nextLetter);
   if ~any(formatFields{length(formatFields)}=='t') && ~any(formatFields{length(formatFields)}=='x')
    ffWithFormat=[ffWithFormat,length(formatFields)];
   end
   if ii==length(percents)
    if length(formatIn)>nextLetter
     formatFields{length(formatFields)+1}=formatIn(nextLetter+1:end);
    end
   else
    if percents(ii+1)>nextLetter+1
     formatFields{length(formatFields)+1}=formatIn(nextLetter+1:percents(ii+1)-1);
    end
   end
  end % for ii=1:length(percents)
 else %must be just a string to echo to file
  formatFields{1}=formatIn;
 end % if ~isempty(percents)
 %Now form the IO list for assigning the calling workspace
 for ii=length(varargin):-1:1
  if iscell(varargin{ii}) %an implied do loop, make a list
   ;%build in functionality for a nested loop
   for kk=(length(varargin{ii})-4):-1:1
    if iscell(varargin{ii}{kk})
     IDL(1)=evalin('caller',varargin{ii}{kk}{end-2});
     IDL(2)=evalin('caller',varargin{ii}{kk}{end-1});
     IDL(3)=evalin('caller',varargin{ii}{kk}{end  });
     vt={}; clk=length(varargin{ii}{kk});
     for jj=IDL(1):IDL(2):IDL(3)
      for mm=1:clk-4
       vt={vt{:},regexprep(varargin{ii}{kk}{mm},...
                           ['\<',varargin{ii}{kk}{clk-3},'\>'],sprintf('%d',jj))};
      end % for mm=1:length(varargin{ii}{kk})-1
     end
     varargin{ii}={varargin{ii}{1:kk-1},vt{:},varargin{ii}{kk+1:end}};
    end % for kk=1:length(varargin{ii})-4
   end % if any(cellfun('isclass',
  end % if iscell(varargin{ii}) %an implied do loop,
 end % for ii=1:length(varargin)
 IOlist={}; IDLff={};
 for ii=1:length(varargin)
  if iscell(varargin{ii}) %an implied do loop, make a list
   IDL(1)=evalin('caller',varargin{ii}{end-2});
   IDL(2)=evalin('caller',varargin{ii}{end-1});
   IDL(3)=evalin('caller',varargin{ii}{end  });
   cl=length(varargin{ii});
   for jj=IDL(1):IDL(2):IDL(3)
    for kk=1:cl-4
     IOlist={IOlist{:},regexprep(varargin{ii}{kk},...
                                 ['\<',varargin{ii}{cl-3},'\>'],sprintf('%d',jj))};
     if varargin{ii}{kk}(1)==''''
      IDLff={IDLff{:},'%c'};
     else
      IDLff={IDLff{:},'%g'};
     end
    end % for kk=1:cl-4
   end
   formatFields={formatFields{1:ii-1},IDLff{:},formatFields{ii+1:end}};
   ffWithFormat=[ffWithFormat(1:ii-1),[1:length(IDLff)]+ffWithFormat(ii)-1,ffWithFormat(ii+1:end)+length(IDLff)-1];
  elseif ischar(varargin{ii}) %regular string input, so one IOlist item per element of array
                              %assume no vector indexing on non scalars with subscripts
                              %if this is a value rather than an array, then no index
   if ~isempty(regexp(varargin{ii},'[\(\{\*\/\-\+\^]|^[0-9\.]')) || ...
        evalin('caller',['ischar(',varargin{ii},')'])
    IOlist={IOlist{:},varargin{ii}};
   else
    %assume this is a single variable, with at least size of 1
    varSize=evalin('caller',['prod(size(',varargin{ii},'))']);
    if varSize>0
     cellArray=evalin('caller',['iscell(',varargin{ii},')']);
     IDLff={};
     for jj=1:varSize
      if cellArray
       IOlist={IOlist{:},[varargin{ii},'{',sprintf('%d',jj),'}']};IDLff={IDLff{:},'%c'};
      else
       IOlist={IOlist{:},[varargin{ii},'(',sprintf('%d',jj),')']};IDLff={IDLff{:},'%g'};
      end
     end % for jj=1:evalin('caller',
     if length(IDLff)>1&0 %TODO
      formatFields={formatFields{1:ffWithFormat(ii)-1},IDLff{:},formatFields{ii+1:end}};
      ffWithFormat=[ffWithFormat(1:ii-1),[1:length(IDLff)]+ffWithFormat(ii)-1,ffWithFormat(ii+1:end)+length(IDLff)-1];
     end
    else
     IOlist={IOlist{:},varargin{ii}};
    end
   end % if any(varargin{ii}=='(')
  else
   warning('writeFmt didn''t understand what it was given')
   (varargin{ii})
   return
  end
 end % for ii=1:length(varargin)

 %now start assigning
 writeErrFlag=false;  nFF=length(formatFields);  whereFF=1;  dataLine='';
 %write out any fields not containing format specs
 for jj=whereFF:nFF
  if ~any(jj==ffWithFormat)
   if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
    %pad dataLine with spaces out to tab#
    tlen=str2num(formatFields{jj}(2:end-1));
    if tlen>length(dataLine)
     dataLine=[dataLine,repmat(' ',1,tlen-length(dataLine))];
     %dataLine=[dataLine,repmat(' ',1,tlen-(length(dataLine)-find(dataLine==char(10),1,'last'))-1)];
    end
   elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
    tlen=str2num(formatFields{jj}(2:end-1));
    dataLine=[dataLine,repmat(' ',1,tlen-1)];
   else
    dataLine=[dataLine,sprintf(formatFields{jj})];
   end
   whereFF=whereFF+1;
  else
   break
  end % if ~any(jj==ffWithFormat)
 end % for jj=whereFF+1:nFF
 for ii=1:length(IOlist)
  for jj=whereFF:nFF
   if ~any(jj==ffWithFormat)
    if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
     %pad dataLine with spaces out to tab#
     tlen=str2num(formatFields{jj}(2:end-1));
     if tlen>length(dataLine)
      dataLine=[dataLine,repmat(' ',1,tlen-length(dataLine))];
     end
    elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
     tlen=str2num(formatFields{jj}(2:end-1));
     dataLine=[dataLine,repmat(' ',1,tlen-1)];
    else
     dataLine=[dataLine,sprintf(formatFields{jj})];
    end
    whereFF=whereFF+1;
   else
    break
   end % if ~any(jj==ffWithFormat)
  end % for jj=whereFF+1:nFF
      %Now go for the next in the IOlist
  switch formatFields{whereFF}(end)
    case {'f','g','u','i','l','d','e','z'}
      if strcmp(formatFields{whereFF}(end),'f') && whereFF<nFF && formatFields{whereFF+1}(1)=='p' && length(formatFields{whereFF+1})>1 && all(isnumber(formatFields{whereFF+1}(2:end))), pfact=formatFields{whereFF+1}(2:end); else; pfact='0'; end
      %formatFields{whereFF}=regexprep(formatFields{whereFF},{'f','z'},{'g','x'},'ignorecase');
      dataLine=[dataLine,evalin('caller',['sprintf(''',strrep(formatFields{whereFF},'*',''),''',(',IOlist{ii},')*10^',pfact,');'])];
      if pfact~='0'; whereFF=whereFF+1; end
    case {'c'}
      charWidth=sscanf(formatFields{whereFF}(2:end-1),'%d');
      tempStr=evalin('caller',IOlist{ii});
      if length(tempStr)>charWidth, tempStr=tempStr(1:charWidth); end
      dataLine=[dataLine,tempStr];
      if charWidth>length(tempStr)
       dataLine=[dataLine,repmat(' ',1,charWidth-length(tempStr))];
      end
    case {'x'}
      charWidth=str2num(formatFields{whereFF}(2:end-1));
      dataLine=[dataLine,repmat(' ',1,charWidth)];
  end
  if all(formatFields{whereFF}~='*'), whereFF=whereFF+1; end
  %whereFF=whereFF+1;
  for jj=whereFF:nFF
   if ~any(jj==ffWithFormat)
    if any(formatFields{jj}=='t') && any(formatFields{jj}=='%')
     %pad dataLine with spaces out to tab#
     tlen=str2num(formatFields{jj}(2:end-1));
     if tlen>length(dataLine)
      dataLine=[dataLine,repmat(' ',1,tlen-length(dataLine))];
     end
    elseif any(formatFields{jj}=='x') && any(formatFields{jj}=='%')
     tlen=str2num(formatFields{jj}(2:end-1));
     dataLine=[dataLine,repmat(' ',1,tlen-1)];
    else
     dataLine=[dataLine,sprintf(formatFields{jj})];
    end
    whereFF=whereFF+1;
   else
    break
   end % if ~any(jj==ffWithFormat)
  end % for jj=whereFF+1:nFF
  if whereFF>nFF %add carriage return and start over with ff
   if ~strcmp(formatIn(end),'$')
    dataLine=[dataLine,crlf];
   else
    dataLine=dataLine(1:end-1);
   end
   whereFF=1;
  end
 end
 if whereFF~=1
  dataLine=[dataLine,crlf];
 end 
 %now write it out to file or set it to the incoming string
 if isnumeric(fidIn) %fidIn is a file ID
  try
   fprintf(fidIn,'%s',dataLine);
  catch
   writeErrFlag=true;
  end
 elseif ischar(fidIn) %they are trying to write to a string
  if isempty(inputname(1))
   if any(fidIn=='(') && any(fidIn==')') && any(fidIn==':')
    strVar=fidIn(1:find(~isletter(fidIn),1,'first')-1);
    lowB=fidIn(find(fidIn=='(',1,'first')+1:find(fidIn==':',1,'first')-1);
    uppB=fidIn(find(fidIn==':',1,'first')+1:find(fidIn==')',1,'last')-1);
    evalin('caller',strrep([strVar,'=strAssign(',strVar,',[',lowB,'],[',uppB,'],''',...
                        dataLine,''');'],crlf,''));
   else
    evalin('caller',strrep([fidIn,'=''',dataLine,''';'],crlf,''));
   end
  else
   evalin('caller',strrep([inputname(1),'(1:length(''',dataLine,'''))=''',dataLine,''';'],crlf,''));
  end
 end % if isnumeric(fidIn)
end % function [writeErrFlag,
