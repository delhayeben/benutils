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

function tightsubplot(ax,varargin)
if(~isempty(varargin) && isnumeric(varargin{1}))
    rc=varargin{1};
    varargin=varargin(2:end);
else
    rc=get(ax(1),'SubplotFormat');
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

pos=arrayfun(@(x) get(x,'position'),ax,'uni',0);
ins=arrayfun(@(x) get(x,'tightinset'),ax,'uni',0);
out=cellfun(@(x,y) x+[-y(1:2) y(1:2)+y(3:4)],pos,ins,'uni',0);

if(showboxes)
    for ii=1:prod(rc)
        val=out{ii}; val(val<0)=0;val(val>1)=1;
        annotation('rectangle',val);
    end
end

% sometimes, tightinset value change when you change position value
% iterate to converge to no change
itnum=0;
while(1) 
    itnum=itnum+1;
    % width
    Mx=max(cellfun(@(x) x(1)+x(3),out),[],1);
    mx=min(cellfun(@(x) x(1),out),[],1);
    xw=(1-sum(Mx-mx)-gap(1)*(rc(2)-1)-sum(margins([1 3])))/rc(2);
    xg=mx-[0 Mx(1:end-1)]-[margins(1) gap(1)*ones(1,rc(2)-1)];
    
    % height
    My=max(cellfun(@(x) x(2)+x(4),out),[],2)';
    my=min(cellfun(@(x) x(2),out),[],2)';
    yw=(1-sum(My-my)-gap(2)*(rc(1)-1)-sum(margins([2 4])))/rc(1);
    yg=my-[0 My(1:end-1)]-[margins(2) gap(2)*ones(1,rc(1)-1)];
    
    % return
    for ii=1:rc(1)
        for jj=1:rc(2)
            set(ax(ii,jj),'position',get(ax(ii,jj),'position')+...
                [xw*(jj-1)-sum(xg(1:jj)) yw*(ii-1)-sum(yg(1:ii))...
                xw yw]);
        end
    end
    
    insnew=arrayfun(@(x) get(x,'tightinset'),ax,'uni',0);
    if(sum(column(abs(cat(1,ins{:})-cat(1,insnew{:}))))<.001)
        break
    end
    pos=arrayfun(@(x) get(x,'position'),ax,'uni',0);
    out=cellfun(@(x,y) x+[-y(1:2) y(1:2)+y(3:4)],pos,insnew,'uni',0);
    ins=insnew;
    if(itnum==10)
        disp('Could not converge to a stable and optimized arrangement')
        break;
    end
end

if(showboxes)
    
    for ii=1:prod(rc)
        val=out{ii};val(val<0)=0;val(val>1)=1;
        annotation('rectangle',val,'color','r')
    end
end