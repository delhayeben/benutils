function labelsubplot(ax,varargin)
if(~ishandle(ax))
  error('first argument should be an axis (array)')
end
[skipval,varargin]=parseargpair(varargin,'skip',[]);
% in case of merged cells (created with subplot_ax)
if(isprop(ax(1),'SubplotMerge'))
  rc=ax(1).SubplotFormat;
  mergecell=ax(1).SubplotMerge;
  el=reshape(1:prod(rc),rc(2),rc(1))';
  for ii=1:length(mergecell)
    [i,j]=find(ismember(el,mergecell{ii}));
    mergedel=el(min(i):max(i),min(j):max(j))';
    skipval=[skipval(:); column(mergedel(2:end))];
  end
end

axnums=setdiff(1:length(ax),skipval);
nax=length(axnums);
[offsetval,varargin]=parseargpair(varargin,'offset',zeros(nax,2));
[order,varargin]=parseargpair(varargin,'order',1:nax);
[note,varargin]=parseargpair(varargin,'note',[]);

siz=size(offsetval);

if(siz(2)~=2)
  error('offset value should have 2 columns, for x and y');
end
if(siz(1)==1)
  offsetval=repmat(offsetval,nax,1);
elseif(siz(1)~=nax)
  error('offset value should have 1 or n rows, n being the length of ax');
end
if(isempty(note))
  note=cell(nax,1);
end

for ii=1:nax
%     textnorm(ax(ii),0+offsetval(jj,1),1+offsetval(jj,2),...
%       char(64+jj),'fontsize',14,'vert','bott','horiz','right',args{:})
    pos=ax(axnums(order(ii))).Position;
%     y=ax(ii).TightInset;
%     pos=x+[-y(1:2) y(1:2)+y(3:4)];
    pos=[pos(1)+offsetval(ii,1) pos(2)+pos(4)+offsetval(ii,2) 0 0];
%     pos(1:2)=min(pos(1:2),.99999);
%     pos(1:2)=max(pos(1:2),.00001)

    txt=char(64+ii);
    if(~isempty(note{ii}))
      txt=[txt ' ' note{ii}];
    end
    annotation(ax(1).Parent,...
      'textbox',pos,...
      'String',txt,...
      'fontsize',14,'vert','bottom','horiz','right','margin',0,...
      'FitBoxToText','on','edgecolor','none',varargin{:})
end
end