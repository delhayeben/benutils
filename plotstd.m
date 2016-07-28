% function plotstd(x,y,fun,varargin)
%
% (optionnal) ax is the handle of the axes to plot in (otherwise uses gca)
% x : vector of absices
% y : matrix of ordinates (nbr of lines equal to length(x))
% fun : function handle that provides 2 outputs: central value and
% error value (leave it empty and it will compute mean and std)
% ex: fun=@(x) deal(nanmean(x,2),nanstd(x,1,2))
% varagin is pairs of additionnal parameter passed to the plot function.

function h=plotstd(varargin)

if(ishandle(varargin{1}))
    ax=varargin{1};
    varargin(1)=[];
else
    ax=gca;
end

x=varargin{1}(:);   varargin(1)=[];
y=varargin{1};  varargin(1)=[];

if(isempty(varargin) || isempty(varargin{1}))
    fun=@(x) deal(nanmean(x,2),nanstd(x,1,2));
    if(~isempty(varargin))
        varargin(1)=[];
    end
else
    fun=varargin{1};    varargin(1)=[];
end

x=x(:);
[ym,yv]=fun(y);

% remove nan
nanlines=sum(isnan([x,ym,yv]),2)>0;
x=x(~nanlines);ym=ym(~nanlines);yv=yv(~nanlines);

getstatus=get(ax,'nextplot');

hh=plot(ax,x,ym,varargin{:});
set(ax,'nextplot','add')

patch([x ; flipud(x)],[ym+yv;flipud(ym-yv)],hh.Color,...
   'edgecolor','none','FaceAlpha',.3,'parent',ax)
set(ax,'nextplot',getstatus,'box','off')

if(nargout==1)
    h=hh;
end