% Wrapper to infEP to remain backwards compatible.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch 2016-12-14.

function varargout = infFITC_EP(varargin)
varargout = cell(nargout, 1); [varargout{:}] = infEP(varargin{:});