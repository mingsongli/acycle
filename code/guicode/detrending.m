function varargout = detrending(varargin)
% Single-file entry for detrending tool.
% Uses the existing detrending GUI implementation from prewhiten.m
[varargout{1:nargout}] = prewhiten(varargin{:});
end
