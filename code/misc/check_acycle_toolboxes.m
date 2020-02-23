A={'Matlab toolboxes are'};

% Now go to each acycle folder that includes matlab codes run the following
% code

list = dir;
listn = size(list);
list_cell = struct2cell(list);
for i = 3:listn(1)
    i
    files      = list_cell{1,i};
    [fList,pList] = matlab.codetools.requiredFilesAndProducts(files);
    pl = {pList.Name}';
    listsize = size(pl);
    for j =1:listsize(1)
        A{end+1,1} = pl{j};
    end
end

% OKAY, I have 266 member cell including names of used toolboxes, let's
% remove duplicated elements

B = {A{2}};
for k =3:266
    C = A{k};
    if ~any(strcmp(B,C))
        B{end+1,1} = C;
    end
end

% Yeah, acycle needs ten toolboxes including Matlab itself
% 'MATLAB';'Signal Processing Toolbox';'Statistics and Machine Learning Toolbox';'Image Processing Toolbox';'Fuzzy Logic Toolbox';'Curve Fitting Toolbox';'Parallel Computing Toolbox';'MATLAB Parallel Server';'Polyspace Bug Finder';'Wavelet Toolbox'}