function ii = getlisti(list,str_i)
% get order of the str_i in the list
% Mingsong Li, 2018 Penn State
ii = 1;
[a, ~] = size(list);

for i = 1:a
    if strcmp(list(i), str_i)
        ii = i;
    end
end
