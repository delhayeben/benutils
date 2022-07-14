function xyfig=annotcoord(ax,xyax)


switch ax.Type
  case 'axes'
    pos=ax.Position;
    xl=ax.XLim;
    yl=ax.YLim;
    
    if(any(xyax(:,1)<xl(1) | xyax(:,1)>xl(2) |...
        xyax(:,2)<yl(1) | xyax(:,2)>yl(2)))
      error('out of range')
    end
    
    xyfig=[pos(1)+pos(3)*(xyax(:,1)-xl(1))/diff(xl)...
      pos(2)+pos(4)*(xyax(:,2)-yl(1))/diff(yl)];
    
  case 'polaraxes'
    pos=ax.Position
    tl=ax.ThetaLim
    rl=ax.RLim
    
    if(any(xyax(:,1)<tl(1) | xyax(:,1)>tl(2) |...
        xyax(:,2)<rl(1) | xyax(:,2)>rl(2)))
      error('out of range')
    end
    
    annotation('rectangle','pos',pos)
    
    error('not implemented yet...')
end