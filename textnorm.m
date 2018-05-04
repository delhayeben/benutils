% Replaces the conventional text fonction to add text on a plot
% Two improvements:
% - x,y are specified by normalized values ([0,1] is the graph limits)
% - ax is an optionnal first argument to specify the axes
% 

function h=textnorm(ax,x,y,textstr,varargin)

if(~ishandle(ax))
    if(exist('textstr','var'))
        varargin=[textstr varargin{:}];
    end
    textstr=y;
    y=x;
    x=ax;
    ax=gca;
end

if(~ischar(textstr)),error('Text (3rd) parameter should be a string!');end

xl=get(ax,'xlim');
yl=get(ax,'ylim');

xscale=get(ax,'xscale'); 
yscale=get(ax,'yscale'); 

if(strcmp(xscale,'log')), xl=log(xl);end
if(strcmp(yscale,'log')), yl=log(yl);end

xpos=xl(1)+(xl(2)-xl(1))*x;
ypos=yl(1)+(yl(2)-yl(1))*y;

if(strcmp(xscale,'log')), xpos=exp(xpos);end
if(strcmp(yscale,'log')), ypos=exp(ypos);end

hh=text(xpos,ypos,textstr,'par',ax,varargin{:});

if(nargout==1)
    h=hh;
end