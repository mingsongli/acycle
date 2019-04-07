function foldername = strrep2(filename, pre, post)
% remove HTML style
% example
%  foldername = strrep2(filename,'<HTML><FONT color="blue">','</FONT></HTML>');

%pre  = '<HTML><FONT color="blue">';
%post = '</FONT></HTML>';
try
    % if filename is a HTML name
    filename = strrep(filename,pre,'');
    filename = strrep(filename,post,'');
    foldername = filename;
catch
    % if file name is a pure name
    filename = filename;
    foldername = filename;
end