function ac_update_listbox_acmain(hListbox,names,isDir)
% Update the AC main file list with blue folder names.

if nargin < 2 || isempty(names)
    names = {};
end
if nargin < 3 || isempty(isDir)
    isDir = false(size(names));
end

names = cellstr(names);
isDir = logical(isDir);

try
    set(hListbox,'UserData',struct('names',{names},'isDir',isDir));
catch
end

if ac_has_items_property(hListbox)
    ac_update_uilistbox(hListbox,names,isDir);
else
    ac_update_drawn_listbox(hListbox,names,isDir);
end

end

function tf = ac_has_items_property(hListbox)
tf = false;
try
    tf = isprop(hListbox,'Items');
catch
end
end

function ac_update_uilistbox(hListbox,names,isDir)
hListbox.Items = names;
if isempty(names)
    hListbox.Value = {};
else
    try
        if isprop(hListbox,'Multiselect') && strcmpi(hListbox.Multiselect,'on')
            hListbox.Value = names(1);
        else
            hListbox.Value = names{1};
        end
    catch
        hListbox.Value = names{1};
    end
end

try
    removeStyle(hListbox);
    folderStyle = uistyle('FontColor',[0 0 1]);
    folderIdx = find(isDir);
    if ~isempty(folderIdx)
        addStyle(hListbox,folderStyle,'item',folderIdx);
    end
catch
end
end

function ac_update_drawn_listbox(hListbox,names,isDir)
ac_delete_stale_java_overlay(hListbox);

try
    set(hListbox,'String',names,'Value',[],'Visible','off');
catch
end

[hPanel,hAxes,hSlider] = ac_ensure_drawn_listbox(hListbox);
if isempty(hPanel) || ~isgraphics(hPanel)
    try
        set(hListbox,'Visible','on');
    catch
    end
    return
end

setappdata(hListbox,'ACListNames',names);
setappdata(hListbox,'ACListIsDir',isDir);
setappdata(hListbox,'ACListTopIndex',1);
setappdata(hListbox,'ACListSelected',[]);
setappdata(hListbox,'ACListAnchor',[]);
setappdata(hListbox,'ACListLastClickIndex',[]);
setappdata(hListbox,'ACListLastClickTic',[]);
setappdata(hListbox,'ACListScrollFcn', ...
    @(rowDelta)ac_scroll_drawn_listbox(hListbox,rowDelta));

ac_sync_drawn_position(hListbox,hPanel);
ac_render_drawn_listbox(hListbox,hAxes,hSlider);
end

function ac_delete_stale_java_overlay(hListbox)
try
    parent = get(hListbox,'Parent');
    stale = findall(parent,'Tag','listbox_acmain_java');
    if ~isempty(stale)
        delete(stale);
    end
catch
end

staleAppdata = {'ACJavaListbox','ACJavaListboxContainer','ACJavaListboxCallbackHandle'};
for i = 1:numel(staleAppdata)
    try
        if isappdata(hListbox,staleAppdata{i})
            rmappdata(hListbox,staleAppdata{i});
        end
    catch
    end
end
end

function [hPanel,hAxes,hSlider] = ac_ensure_drawn_listbox(hListbox)
hPanel = [];
hAxes = [];
hSlider = [];

try
    hPanel = getappdata(hListbox,'ACDrawnListboxPanel');
    hAxes = getappdata(hListbox,'ACDrawnListboxAxes');
    hSlider = getappdata(hListbox,'ACDrawnListboxSlider');
    if isgraphics(hPanel) && isgraphics(hAxes) && isgraphics(hSlider)
        return
    end
catch
end

try
    parent = get(hListbox,'Parent');
    hPanel = uipanel('Parent',parent, ...
        'Units',get(hListbox,'Units'), ...
        'Position',get(hListbox,'Position'), ...
        'BorderType','line', ...
        'BackgroundColor','white', ...
        'Tag','listbox_acmain_drawn');
    hAxes = axes('Parent',hPanel, ...
        'Units','normalized', ...
        'Position',[0 0 0.965 1], ...
        'Visible','off', ...
        'Color','white', ...
        'XLim',[0 1], ...
        'YLim',[0 1], ...
        'YDir','reverse');
    hSlider = uicontrol('Parent',hPanel, ...
        'Style','slider', ...
        'Units','normalized', ...
        'Position',[0.965 0 0.035 1], ...
        'Visible','off', ...
        'Callback',@(src,evt)ac_slider_callback(hListbox));
    setappdata(hListbox,'ACDrawnListboxPanel',hPanel);
    setappdata(hListbox,'ACDrawnListboxAxes',hAxes);
    setappdata(hListbox,'ACDrawnListboxSlider',hSlider);
catch
    hPanel = [];
    hAxes = [];
    hSlider = [];
end
end

function ac_sync_drawn_position(hListbox,hPanel)
try
    set(hPanel,'Units',get(hListbox,'Units'),'Position',get(hListbox,'Position'),'Visible','on');
    uistack(hPanel,'top');
catch
end
end

function ac_render_drawn_listbox(hListbox,hAxes,hSlider)
if nargin < 2 || isempty(hAxes) || ~isgraphics(hAxes)
    hAxes = getappdata(hListbox,'ACDrawnListboxAxes');
end
if nargin < 3 || isempty(hSlider) || ~isgraphics(hSlider)
    hSlider = getappdata(hListbox,'ACDrawnListboxSlider');
end
if isempty(hAxes) || isempty(hSlider) || ~isgraphics(hAxes) || ~isgraphics(hSlider)
    return
end

names = getappdata(hListbox,'ACListNames');
isDir = getappdata(hListbox,'ACListIsDir');
selected = getappdata(hListbox,'ACListSelected');
if isempty(names)
    names = {};
end
if isempty(isDir)
    isDir = false(size(names));
end
if isempty(selected)
    selected = [];
end

visibleRows = ac_visible_rows(hListbox);
n = numel(names);
maxTop = max(1,n-visibleRows+1);
topIndex = getappdata(hListbox,'ACListTopIndex');
if isempty(topIndex)
    topIndex = 1;
end
topIndex = min(max(1,round(topIndex)),maxTop);
setappdata(hListbox,'ACListTopIndex',topIndex);

if n > visibleRows
    sliderRange = maxTop - 1;
    set(hSlider,'Visible','on', ...
        'Min',1, ...
        'Max',maxTop, ...
        'Value',ac_flip_scroll_index(topIndex,maxTop), ...
        'SliderStep',[min(1,1/sliderRange), ...
        min(1,visibleRows/sliderRange)]);
    set(hAxes,'Position',[0 0 0.965 1]);
else
    set(hSlider,'Visible','off');
    set(hAxes,'Position',[0 0 1 1]);
end

cla(hAxes);
set(hAxes, ...
    'XLim',[0 1], ...
    'YLim',[0 visibleRows], ...
    'YDir','reverse', ...
    'Visible','off', ...
    'ButtonDownFcn',{@ac_axes_click,hListbox});

listFontSize = get(hListbox,'FontSize');

lastIndex = min(n,topIndex+visibleRows-1);
row = 0;
for idx = topIndex:lastIndex
    row = row + 1;
    isSelected = any(selected == idx);
    if isSelected
        rowColor = [0.18 0.40 0.90];
        color = [1 1 1];
    elseif isDir(idx)
        rowColor = [1 1 1];
        color = [0 0 1];
    else
        rowColor = [1 1 1];
        color = [0 0 0];
    end
    rectangle('Parent',hAxes, ...
        'Position',[0 row-1 1 1], ...
        'FaceColor',rowColor, ...
        'EdgeColor','none', ...
        'Tag','ACListRowBackground', ...
        'UserData',idx, ...
        'PickableParts','all', ...
        'ButtonDownFcn',{@ac_row_click,hListbox,idx});
    text('Parent',hAxes, ...
        'String',names{idx}, ...
        'Interpreter','none', ...
        'FontUnits','points', ...
        'FontSize',listFontSize, ...
        'Units','data', ...
        'Position',[0 row-0.5 0], ...
        'VerticalAlignment','middle', ...
        'HorizontalAlignment','left', ...
        'Color',color, ...
        'Clipping','on', ...
        'HitTest','on', ...
        'Tag','ACListRowText', ...
        'UserData',idx, ...
        'PickableParts','all', ...
        'ButtonDownFcn',{@ac_row_click,hListbox,idx});
end
end

function ac_update_drawn_selection(hListbox)
% Keep the row graphics alive between the first and second mouse press.
% Recreating them here breaks double-click delivery in MATLAB R2025b.
try
    hAxes = getappdata(hListbox,'ACDrawnListboxAxes');
    selected = getappdata(hListbox,'ACListSelected');
    isDir = getappdata(hListbox,'ACListIsDir');
    if isempty(hAxes) || ~isgraphics(hAxes)
        return
    end
    if isempty(selected)
        selected = [];
    end

    rowBackgrounds = findall(hAxes,'Type','rectangle', ...
        'Tag','ACListRowBackground');
    for rowIndex = 1:numel(rowBackgrounds)
        itemIndex = get(rowBackgrounds(rowIndex),'UserData');
        if any(selected == itemIndex)
            rowColor = [0.18 0.40 0.90];
        else
            rowColor = [1 1 1];
        end
        set(rowBackgrounds(rowIndex),'FaceColor',rowColor);
    end

    rowTexts = findall(hAxes,'Type','text','Tag','ACListRowText');
    for rowIndex = 1:numel(rowTexts)
        itemIndex = get(rowTexts(rowIndex),'UserData');
        if any(selected == itemIndex)
            textColor = [1 1 1];
        elseif itemIndex <= numel(isDir) && isDir(itemIndex)
            textColor = [0 0 1];
        else
            textColor = [0 0 0];
        end
        set(rowTexts(rowIndex),'Color',textColor);
    end
catch
end
end

function rows = ac_visible_rows(hListbox)
rows = 12;
try
    rowHeight = getappdata(hListbox,'ACListRowHeight');
    if isempty(rowHeight) || ~isnumeric(rowHeight) || ...
            ~isscalar(rowHeight) || ~isfinite(rowHeight) || rowHeight <= 0
        return
    end
    pos = getpixelposition(hListbox,true);
    rows = max(1,floor(pos(4)/rowHeight));
catch
end
end

function ac_slider_callback(hListbox)
try
    hSlider = getappdata(hListbox,'ACDrawnListboxSlider');
    maxTop = round(get(hSlider,'Max'));
    sliderValue = round(get(hSlider,'Value'));
    setappdata(hListbox,'ACListTopIndex', ...
        ac_flip_scroll_index(sliderValue,maxTop));
    setappdata(hListbox,'ACListLastClickIndex',[]);
    setappdata(hListbox,'ACListLastClickTic',[]);
    ac_render_drawn_listbox(hListbox);
catch
end
end

function ac_scroll_drawn_listbox(hListbox,rowDelta)
try
    names = getappdata(hListbox,'ACListNames');
    if isempty(names) || isempty(rowDelta) || rowDelta == 0
        return
    end

    visibleRows = ac_visible_rows(hListbox);
    maxTop = max(1,numel(names)-visibleRows+1);
    topIndex = getappdata(hListbox,'ACListTopIndex');
    if isempty(topIndex)
        topIndex = 1;
    end
    topIndex = min(max(1,round(topIndex + rowDelta)),maxTop);
    setappdata(hListbox,'ACListTopIndex',topIndex);
    setappdata(hListbox,'ACListLastClickIndex',[]);
    setappdata(hListbox,'ACListLastClickTic',[]);

    hSlider = getappdata(hListbox,'ACDrawnListboxSlider');
    if ~isempty(hSlider) && isgraphics(hSlider)
        set(hSlider,'Value',ac_flip_scroll_index(topIndex,maxTop));
    end
    ac_render_drawn_listbox(hListbox);
catch
end
end

function flippedIndex = ac_flip_scroll_index(index,maxTop)
maxTop = max(1,round(maxTop));
index = min(max(1,round(index)),maxTop);
flippedIndex = maxTop-index+1;
end

function ac_axes_click(hAxes,evt,hListbox)
try
    names = getappdata(hListbox,'ACListNames');
    topIndex = getappdata(hListbox,'ACListTopIndex');
    cp = get(hAxes,'CurrentPoint');
    row = floor(cp(1,2)) + 1;
    idx = topIndex + row - 1;
    if idx >= 1 && idx <= numel(names)
        ac_row_click(hAxes,evt,hListbox,idx);
    end
catch
end
end

function ac_row_click(src,evt,hListbox,idx)
fig = ancestor(hListbox,'figure');
isDoubleClick = ac_is_double_click(fig,hListbox,idx);
selected = getappdata(hListbox,'ACListSelected');
anchor = getappdata(hListbox,'ACListAnchor');
if isempty(selected)
    selected = [];
end

mods = {};
try
    mods = get(fig,'CurrentModifier');
catch
end
if ischar(mods)
    mods = {mods};
end

if any(strcmpi(mods,'shift')) && ~isempty(anchor)
    selected = min(anchor,idx):max(anchor,idx);
elseif any(strcmpi(mods,'command')) || any(strcmpi(mods,'control'))
    if any(selected == idx)
        selected(selected == idx) = [];
    else
        selected = unique([selected idx]);
    end
    anchor = idx;
else
    selected = idx;
    anchor = idx;
end

if isempty(selected)
    value = [];
else
    value = selected;
end

try
    set(hListbox,'Value',value);
catch
end
setappdata(hListbox,'ACListSelected',selected);
setappdata(hListbox,'ACListAnchor',anchor);
ac_update_drawn_selection(hListbox);

if isDoubleClick
    try
        setappdata(hListbox,'ACForceDoubleClick',true);
    catch
    end
    try
        handles = guidata(fig);
        AC('listbox_acmain_Callback',hListbox,[],handles);
    catch
    end
else
    try
        handles = guidata(fig);
        handles.index_selected = selected;
        guidata(hListbox,handles);
    catch
    end
end
end

function isDoubleClick = ac_is_double_click(fig,hListbox,idx)
% SelectionType handles two clicks on the same graphics object.  Also
% track the logical row so a click on its text followed by one on its
% background is still treated as a double-click.
isDoubleClick = false;
try
    isDoubleClick = strcmp(get(fig,'SelectionType'),'open');
catch
end

lastIndex = [];
lastClickTic = [];
try
    lastIndex = getappdata(hListbox,'ACListLastClickIndex');
    lastClickTic = getappdata(hListbox,'ACListLastClickTic');
catch
end

if ~isDoubleClick && isequal(lastIndex,idx) && ~isempty(lastClickTic)
    try
        isDoubleClick = toc(lastClickTic) <= 0.5;
    catch
    end
end

if isDoubleClick
    setappdata(hListbox,'ACListLastClickIndex',[]);
    setappdata(hListbox,'ACListLastClickTic',[]);
else
    setappdata(hListbox,'ACListLastClickIndex',idx);
    setappdata(hListbox,'ACListLastClickTic',tic);
end
end
