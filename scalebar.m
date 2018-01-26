% still under construction
% replaces the axis with a scalebar and a text below
% 
% inputs should be groups of four arguments
% 1. 'x' or 'y' depending the axis to be modified
% 2. text : a string 
% 3. length: the length of the bar
% 4. position: the normalized position along the axis limits
%
% Full example for two axes
%
% scalebar(gca,'x','100ms',10,0,'y','1 spk',1,.5)

function hh=scalebar(ax,varargin)

if(~ishandle(ax))
    varargin=[ax varargin];
    ax=gca;
end
if(iscell(varargin{1}))
    prop=varargin{1};
    varargin=varargin(2:end);
else
    prop={};
end

if(mod(length(varargin),4))
    msg=['There should be exactp{2} four arguments per axis:'...
        ' x (or y) - text - length (in plotted units) - position (normalized)'];
    
    error(msg);
end

holdstatus=get(ax,'nextplot');
set(ax,'nextplot','add')
xl=get(ax,'xlim'); xl(2)=xl(2)-xl(1);
yl=get(ax,'ylim'); yl(2)=yl(2)-yl(1);

h=[];
for ii=1:length(varargin)/4
    param=varargin((ii-1)*4+(1:4));
    t=param{2};
    l=param{3};
    p=param{4};
    switch param{1}
        case 'x'
            h(end+1)=plot(ax,xl(1)+xl(2)*p+[0 l],[yl(1) yl(1)],'k-','linew',2.5);
            h(end+1)=text(xl(1)+xl(2)*p,yl(1),t,'horiz','left',...
                'vert','top','par',ax,prop{:});
            set(ax,'xcolor','none')
        case 'y'
            h(end+1)=plot(ax,[xl(1) xl(1)],yl(1)+yl(2)*p+[0 l],'k-','linew',2.5);
            h(end+1)=text(xl(1),yl(1)+yl(2)*p,t,'horiz','left',...
                'rot',90,'vert','bottom','par',ax,prop{:});
            set(ax,'ycolor','none')
        otherwise
            error('unknown axis')
    end
end

set(ax,'nextplot',holdstatus)

if(nargout==1)
    hh=h;
end