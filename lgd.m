% still under construction


function h=lgd(varargin)

[hh,data]=legend(varargin{:});
texts=data(1:end/3);
lines=data(end/3+1:2:end);
points=data(end/3+2:2:end);
colors={lines.Color};

for ii=1:length(colors)
    texts(ii).Position(1)=0.05;
    texts(ii).Color=colors{ii};
    texts(ii).FontWeight='bold';
end

lw=lines(ii).XData;
delete(lines)
delete(points)

% hh.Units='pixels';
% pos=hh.Position;
% pos(3)=pos(3)*(1-diff(lw));
% hh.Position=pos;

hh.Box='off';

if(nargout==1)
    h=hh;
end