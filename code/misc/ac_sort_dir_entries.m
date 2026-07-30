function sortedEntries = ac_sort_dir_entries(entries,sortMode)
%AC_SORT_DIR_ENTRIES Sort Acycle's main directory listing.
%
% Name modes are case-insensitive while preserving each displayed name.
% Date modes use DIR's numeric modification timestamp (datenum), not the
% formatted date text and not file access/open time.

if nargin < 1 || isempty(entries)
    sortedEntries = entries;
    return
end
if nargin < 2 || isempty(sortMode)
    sortMode = 4;
end

switch sortMode
    case 1
        keys = lower(string({entries.name}));
        direction = 'ascend';
    case 2
        keys = lower(string({entries.name}));
        direction = 'descend';
    case 3
        keys = [entries.datenum];
        direction = 'ascend';
    case 4
        keys = [entries.datenum];
        direction = 'descend';
    case 5
        keys = [entries.bytes];
        direction = 'ascend';
    case 6
        keys = [entries.bytes];
        direction = 'descend';
    otherwise
        keys = [entries.datenum];
        direction = 'descend';
end

[~,order] = sort(keys,direction);
sortedEntries = entries(order);
end
