% function h=textnorm(ax,x,y,textstr,options)
% 
% Replaces the conventional text fonction to add text on a plot using
% normalized coordinates
%
% Create a callback to readjust the text position when the axis is zoomed
% or moved scaled or changed to log. So you don't have to worry about that.
%
% - x,y are specified by normalized values ([0,1] is the graph limits)
% - ax is an optionnal first argument to specify the axes
% - options: add any pair of arguments that you want to pass to the text
%   function
% - special options (single param): 'hl','hc','hr','vb','vm','vt'
%  are for 'horizatal', 'left'-'center'-'right'
%          'vertical', 'bottom'-'middle'-'top'

function h=textnorm(ax,x,y,textstr,varargin)

if(~isgraphics(ax,'axes'))
  if(exist('textstr','var'))
    varargin=[{textstr} varargin{:}];
  end
  textstr=y;
  y=x;
  x=ax;
  ax=gca;
end

if(~ischar(textstr) && ~iscell(textstr) && ~isstring(textstr))
  error('Text (3rd) parameter should be a string!');
end

optshort={'hl','hc','hr','vb','vm','vt'};
optlong={{'horiz' 'left'} {'horiz' 'center'} {'horiz' 'right'} ...
  {'vert' 'bot'} {'vert' 'mid'} {'vert' 'top'}};
for ii=1:length(optshort)
  pos=strcmp(varargin,optshort{ii});
  if(any(pos))
    varargin(pos)=[];
    varargin=[varargin optlong{ii}];
  end
end

[xpos,ypos]=norm2pos(ax,x,y);
hh=text(xpos,ypos,textstr,'par',ax,varargin{:});

% set callback to adjust to changes in axis limits
ax.addlistener('XLim','PostSet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
ax.addlistener('YLim','PostSet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
ax.addlistener('XScale','PostSet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
ax.addlistener('YScale','PostSet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
% useful for mouse zoom double click (but evil mix with Position listener)
%ax.addlistener('XLim','PostGet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
%ax.addlistener('YLim','PostGet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));
% when changing the position of a figure, the zoom might actually change
ax.addlistener('Position','PostGet',@(src,evnt) listener_cb(src,evnt,hh,ax,x,y));

if(nargout==1)
  h=hh;
end
end

function [xpos,ypos]=norm2pos(ax,x,y)
xl=double(get(ax,'xlim'));
yl=double(get(ax,'ylim'));

xscale=get(ax,'xscale');
yscale=get(ax,'yscale');

if(strcmp(xscale,'log')), xl=log(xl);end
if(strcmp(yscale,'log')), yl=log(yl);end

xpos=xl(1)+(xl(2)-xl(1))*x;
ypos=yl(1)+(yl(2)-yl(1))*y;

if(strcmp(xscale,'log')), xpos=exp(xpos);end
if(strcmp(yscale,'log')), ypos=exp(ypos);end
end

function listener_cb(~,~,hh,ax,x,y)
[xpos,ypos]=norm2pos(ax,x,y);
set(hh,'pos',[xpos,ypos,0])
end
