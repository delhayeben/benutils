function labelsubplot(ax,varargin)
if(~ishandle(ax))
  error('first argument should be an axis (array)')
end
nax=length(ax(:));

args=varargin;
[args,skipval]=extractparam(args,'skip',0);
[args,offsetval]=extractparam(args,'offset',zeros(length(ax),2));

% in case of merged cells (created with subplot_ax)
if(isprop(ax(1),'SubplotMerge'))
  rc=ax(1).SubplotFormat;
  mergecell=ax(1).SubplotMerge;
  el=reshape(1:prod(rc),rc(2),rc(1))';
  for ii=1:length(mergecell)
    [i,j]=find(ismember(el,mergecell{ii}));
    mergedel=el(min(i):max(i),min(j):max(j))';
    skipval=[skipval(:); mergedel(2:end)'];
  end
end

siz=size(offsetval);
if(siz(2)~=2)
  error('offset value should have 2 columns, for x and y');
end
if(siz(1)==1)
  offsetval=repmat(offsetval,nax,2);
elseif(siz(1)~=nax)
  error('offset value should have 1 or n rows, n being the length of ax');
end

jj=0;
for ii=1:length(ax)
  if(~ismember(skipval,ii))
    jj=jj+1;
    textnorm(ax(ii),-.2+offsetval(jj,1),1+offsetval(jj,2),...
      char(64+jj),'fontsize',16,'vert','bott',args{:})
  end
end
end

function [outputs,argval]=extractparam(inputs,name,default)

argnum=find(strcmp(name,inputs));
if(~isempty(argnum) && length(argnum)==1)
  argval=inputs{argnum+1};
  inputs(argnum+(0:1))=[];
else
  argval=default;
end

outputs=inputs;

end