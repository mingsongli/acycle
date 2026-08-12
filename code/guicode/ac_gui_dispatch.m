function ac_gui_dispatch(hObject,eventdata,callbackName)
%AC_GUI_DISPATCH Invoke an AC callback without retaining an AC.m closure.
%
% Graphics objects can outlive a reloaded AC.m during development. Keeping
% the dispatcher in this standalone file lets web-backed menu controls call
% the current AC.m implementation instead of a stale anonymous local handle.

if nargin < 3 || ~(ischar(callbackName) || ...
        (isstring(callbackName) && isscalar(callbackName)))
    error('Acycle:GUI:InvalidCallbackName', ...
        'An AC callback name is required.');
end
if isstring(callbackName)
    callbackName = char(callbackName);
end

AC('AC_dispatch',callbackName,hObject,eventdata);
end
