% function h=errorbarxy(varargin)
%
% inputs: - (optionnal) ax: axis handle
%         - x (array, data along dim 1, reps along dim 2)
%         - y (array, data along dim 1, reps along dim 2)
%         - pairs of argument compatible with plot function
%                   or 'cfun',@handle to specify function to compute center
%                   or 'vfun',@handle to specify function to compute
%                                                           variability
%
%   variability function can be one value (e.g. @(x) nanstd(x,2)), in that
%   case the errorbar are symetric up and down. It can also be two values
%   (e.g. @(x) deal(prctile(x,25,2),prctile(x,75,2))). In that case, the
%   errorbars are drawn from the lower (first) value to the higher (second)
%   value.

function h=errorbarxy(varargin)

if(ishandle(varargin{1})&& length(varargin{1})==1)
    ax=varargin{1}; varargin(1)=[];
else
    ax=gca;
end

x=varargin{1};
y=varargin{2};
varargin(1:2)=[];

if(mod(length(varargin),2)~=0)
    error('invalid argument pairs')
end

[cfun,varargin]=parseargpair(varargin,'cfun',@(x) nanmean(x,2));
[vfun,varargin]=parseargpair(varargin,'vfun',@(x) nanstd(x,0,2));
[ls,varargin]=parseargpair(varargin,'ls','.');

cx=cfun(x);
cy=cfun(y);

try
    [vx{1:2}]=vfun(x);
    [vy{1:2}]=vfun(y);
catch
    vx{1}=vfun(x);
    vy{1}=vfun(y);
end

holdstatus=get(ax,'nextplot');
currentcolidx=get(ax,'colororderindex');

if(length(vx)==1) % either gap
    h1=plot(ax,[cx cx]',[cy-vy{1} cy+vy{1}]','-',varargin{:});
    set(ax,'nextplot','add','colororderindex',currentcolidx)
    h2=plot(ax,[cx-vx{1} cx+vx{1}]',[cy cy]','-',varargin{:});
else % or interval
    h1=plot(ax,[cx cx]',[vy{1} vy{2}]','-',varargin{:});
    set(ax,'nextplot','add','colororderindex',currentcolidx)
    h2=plot(ax,[vx{1} vx{2}]',[cy cy]','-',varargin{:});
end

set(ax,'colororderindex',currentcolidx)
h3=plot(ax,[cx nan(size(cx))]',[cy nan(size(cy))]',ls,...
    'markersize',14,varargin{:});
set(ax,'nextplot',holdstatus)

if(nargout>0)
    h=[h1 h2 h3];
end