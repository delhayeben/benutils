% Replaces the conventional text fonction to add text on a plot
% Two improvements:
% - x,y are specified by normalized values ([0,1] is the graph limits)
% - ax is an optionnal first argument to specify the axes
% 

function textnorm(ax,x,y,textstr,varargin)

if(~ishandle(ax))
    if(exist('textstr','var'))
        varargin=[textstr varargin{:}];
    end
    textstr=y;
    y=x;
    x=ax;
    ax=gca;
end

if(~ischar(textstr))
    error('Text (third) parameter should be a string !')
end

xl=get(ax,'xlim');
yl=get(ax,'ylim');

text(xl(1)+(xl(2)-xl(1))*x,yl(1)+(yl(2)-yl(1))*y,textstr,'par',ax,varargin{:});