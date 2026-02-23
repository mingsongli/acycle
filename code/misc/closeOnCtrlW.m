function closeOnCtrlW(src, evt)
% Close figure with Ctrl+W or Command+W.
try
    key = lower(string(evt.Key));
    mods = lower(string(evt.Modifier));
    isCtrlW = key == "w" && any(mods == "control");
    isCmdW = key == "w" && any(mods == "command");
    if isCtrlW || isCmdW
        delete(src);
    end
catch
end
end
