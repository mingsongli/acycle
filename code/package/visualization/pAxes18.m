function pAxes18(varargin)
if length(varargin)<2
    tax=gca;themeName=varargin{1};
else
    tax=varargin{1};themeName=varargin{2};
end
axesTheme=load('axesTheme.mat');
axesTheme=axesTheme.theme;

setAxesTheme(tax,axesTheme,themeName);

% 坐标区域修饰基础函数
function setAxesTheme(tAxes,axesTheme,Name)
ax=tAxes;
if isempty(ax)
    ax=gca;
end
% 读取函数信息
sli=0;slii=0;
tBaseStr=axesTheme.(Name);
tBaseFunc=axesTheme.([Name,'_F']);
eval([tBaseStr{:}])

if ~isempty(tBaseFunc)
    % 设置鼠标移动回调
    oriFunc=ax.Parent.WindowButtonMotionFcn;
    set(ax.Parent,'WindowButtonMotionFcn',@bt_move_axes);
end

% 鼠标移动回调函数
    function bt_move_axes(~,~)
        oriFunc();
        eval([tBaseFunc{:}])
    end
end
end