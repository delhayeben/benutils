% function varargout = getNthOutput(func,n,varargin)
%
% Returns the Nth output of a function (very useful in anonymous functions)
%
% Inputs: func: the function to call
%         n: a scalar (or vector) determining the index of outputs returned
%         varargin: the inputs of func
%
function varargout = getNthOutput(func,n,varargin)
    varargout = cell(max(n),1);
    [varargout{:}] = func(varargin{:});
    varargout = varargout(n);
end
