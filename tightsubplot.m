function tightsubplot(ax,varargin)
% function tightsubplot(ax,rc,[param-pairs])
%
% adjust to subplot such that a minimal amount of white space is left
% each subplot size is maximized according to the rule that they all keep
% aligned
%
% ax is a linear vector of all axis handles
%      (ex: ax=[subplot(131) subplot(132) subpplot(133)])
%
% rc is the number of rows and columns of the subplot
%     if ax was created with subplot_ax function, rc is optional
%
% ['gap',value] is an arbitrary spacing between subplot (norm to fig size)
%   if gap is scalar, the same horizontal and vertical spacing is applied
%   if gap is a vector, [horiz vert] gap is applied
%
% ['margins',value] are the outer margins (norm to fig size)
%   if margings is scalar, the margins on all sides
%   if margins is a 2-el vector, [horiz vert] margins are applied
%   if margins is a 4-el vector, [left bottom right top] margins are applied
%
% ['showboxes',logical] shows the outer limits of each subplot
%   in black before and in red after tightsubplot adjusted the values
%
% ['remticklab',value] remove tick labels that are repetead
%                        (i.e. not on left column or bottom line)
%   if remticklab is a scalar, it applies to x and y labels
%   if remticklab is a 2-el vector, it applies respectively to x and y
%
drawnow

if(~isempty(varargin) && isnumeric(varargin{1}))
  rc=varargin{1};
  varargin=varargin(2:end);
  merge=[];
else
  rc=get(ax(1),'SubplotFormat');
  merge=get(ax(1),'SubplotMerge');
end

p=inputParser;
p.addParameter('gap',0);
p.addParameter('margins',0);
p.addParameter('showboxes',0);
p.addParameter('remticklab',0);
p.parse(varargin{:});

gap=p.Results.gap;
margins=p.Results.margins;
showboxes=p.Results.showboxes;
remticklab=p.Results.remticklab;

% re-arrange it such that the matrix looks like the layout
ax=flipud(reshape(ax,rc([2 1]))');

% expand gap and margins
if(isscalar(gap)),          gap=[1 1]*gap;                  end
if(isscalar(margins)),      margins=[1 1 1 1]*margins;      end
if(length(margins)==2),     margins=margins([1 2 1 2]);     end
if(isscalar(remticklab)),   remticklab=remticklab([1 1]);   end


if(remticklab(1)), set(ax(2:end,:),'xticklabel',[]); end
if(remticklab(2)), set(ax(:,2:end),'yticklabel',[]); end

if(remticklab(1)), set(ax(2:end,:),'xticklabel',[]); end
if(remticklab(2)), set(ax(:,2:end),'yticklabel',[]); end

if(~isempty(merge))
  el=flipud(reshape(1:prod(rc),rc(2),rc(1))');
  lm=length(merge);
  midx=cell(lm,1);
  mi=zeros(lm,2);
  mj=zeros(lm,2);
  for ii=1:lm
    [a,b]=find(ismember(el,merge{ii}));
    mi(ii,:)=[min(a) max(a)];     
    mj(ii,:)=[min(b) max(b)];
    % trick to convert index to matrix instead of layout
    midx{ii}=find(ismember(el,el(mi(ii,1):mi(ii,2),mj(ii,1):mj(ii,2))));
  end
else
  midx=[];
end
[ins,pos,out,outlim]=getLim(ax,midx);

if(showboxes)
  for ii=1:prod(rc)
    val=out{ii}; val(val<0)=0;val(val>1)=1;
    annotation('rectangle',val,'linestyle','--');
  end
end

% sometimes, tightinset value change when you change position value
% iterate to converge to no change
itnum=0;
while(1)
  itnum=itnum+1;
  % width gain
  Mx=max(cellfun(@(x) x(3),outlim),[],1);
  mx=min(cellfun(@(x) x(1),outlim),[],1);
  Mx(isnan(Mx))=0;
  mx(isnan(mx))=0;
  xw=(1-sum(Mx-mx)-gap(1)*(rc(2)-1)-sum(margins([1 3])))/rc(2);
  xg=mx-[0 Mx(1:end-1)]-[margins(1) gap(1)*ones(1,rc(2)-1)];
  
  
  % height gain
  My=max(cellfun(@(x) x(4),outlim),[],2)';
  my=min(cellfun(@(x) x(2),outlim),[],2)';
  My(isnan(My))=0;
  my(isnan(my))=0;
  yw=(1-sum(My-my)-gap(2)*(rc(1)-1)-sum(margins([2 4])))/rc(1);
  yg=my-[0 My(1:end-1)]-[margins(2) gap(2)*ones(1,rc(1)-1)];
  
  for ii=1:rc(1)
    for jj=1:rc(2)
      % if elements are merged, correct for it.
      ismergedel=false;
      if(~isempty(merge))
        for kk=1:size(mi,1)
          if(ii>=mi(kk,1) && ii<=mi(kk,2) && ...
              jj>=mj(kk,1) && jj<=mj(kk,2))
            ismergedel=true;
            break;
          end
        end
        
      end
      if ismergedel
        if(ii==mi(kk,1) && jj==mj(kk,1))
          val=[xw*(jj-1)-sum(xg(1:jj)) yw*(ii-1)-sum(yg(1:ii))...
            xw*(diff(mj(kk,:))+1)-sum(xg(mj(kk,1)+1:mj(kk,2)))...
            yw*(diff(mi(kk,:))+1)-sum(yg(mi(kk,1)+1:mi(kk,2)))];
          set(ax(ii,jj),'position',pos{ii,jj}+val)
        end
      else
        val=[xw*(jj-1)-sum(xg(1:jj)) yw*(ii-1)-sum(yg(1:ii))...
          xw yw];
        set(ax(ii,jj),'position',pos{ii,jj}+val)
      end
    end
  end
  
  [insnew,pos,out,outlim]=getLim(ax,midx);
  
  % if no change
  if(sum(column(abs(cat(1,ins{:})-cat(1,insnew{:}))))<.0001)
    break
  end
  % or if iteration too much
  if(itnum==10)
    disp('Could not converge to a stable and optimized arrangement')
    break;
  end
  ins=insnew;
  
  if(showboxes)
    for ii=1:prod(rc)
      val=out{ii};val(val<0)=0;val(val>1)=1;
      annotation('rectangle',val,'color','g','linestyle','--')
    end
  end
end

if(showboxes)
  for ii=1:prod(rc)
    val=out{ii};val(val<0)=0;val(val>1)=1;
    annotation('rectangle',val,'color','r','linestyle','--')
  end
end
end

function [ins,pos,out,outlim]=getLim(ax,mergeel)

pos=arrayfun(@(x) get(x,'position'),ax,'uni',0);
ins=arrayfun(@(x) get(x,'tightinset'),ax,'uni',0);
out=cellfun(@(x,y) x+[-y(1:2) y(1:2)+y(3:4)],pos,ins,'uni',0);
outlim=cellfun(@(x) [x(1:2) x(1:2)+x(3:4)],out,'uni',0);

% if elements are merged, consider only the lower left and upper right
% extremes, other values set to nan
if(~isempty(mergeel))
  for ii=1:length(mergeel)
    outlim(mergeel{ii}(2:end-1))=cellfun(@(x) x*nan,outlim(mergeel{ii}(2:end-1)),'uni',0);
    outlim{mergeel{ii}(1)}=outlim{mergeel{ii}(1)}.*[1 1 nan nan];
    outlim{mergeel{ii}(end)}=outlim{mergeel{ii}(end)}.*[nan nan 1 1];
  end
end
end