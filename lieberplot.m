% lieberplot([ax,][x,]y[,'Name',Value])
%
% ax (optionnal): the axis to plot the data on
% x  (optionnal): the central point for each data bin (otherwise 1:size(y,2))
% y  : the data (each column is a separate cloud)
% ...(optionnal): add pairs of arguments to send to the plot function
%                ('Name',Value       ex: 'color',[.6 .6 .6])
%    - 'bar','on' or 'off', adds a bar plot on background of the dot could
%         (default='on')

function h=lieberplot(varargin)

% example: just run the function with no parameters
if nargin==0
  varargin{1}=(1:7)*5;
  varargin{2}=[2*randn(100,4) 5*rand(100,3)]+3*randn(1,7);
  varargin{2}=varargin{2}(:,randperm(7));
end

% deals with the axis: if none is provided, plot on current axis
if(ishandle(varargin{1}) & length(varargin{1})==1)
  ax=varargin{1}; varargin(1)=[];
else
  ax=gca;
end

% deals with inputs:
if(length(varargin)>1 && isnumeric(varargin{2}))
  x=varargin{1};
  y=varargin{2};
  varargin(1:2)=[];
else
  y=varargin{1};
  varargin(1)=[];
  x=1:size(y,2);
end

% check pairs of optionnal arguments
if (mod(length(varargin),2)~=0 || ~iscellstr(varargin(1:2:end)))
  error('Uncorrect pairs of arguments')
end

[fun,varargin]=parseargpair(varargin,'fun',@nanmean);
[logscale,varargin]=parseargpair(varargin,'log',0);
[bar_on,varargin]=parseargpair(varargin,'bar',1);
[bar_width,varargin]=parseargpair(varargin,'barwidth',.8);
[bar_color,varargin]=parseargpair(varargin,'barcolor','none');
[link_on,varargin]=parseargpair(varargin,'link',0); % link between dots
[highlight_on,varargin]=parseargpair(varargin,'highlight',0); % idx to highlight some dots
[semline,varargin]=parseargpair(varargin,'sem_line',0); % add sem vertical lines 
[showsign,varargin]=parseargpair(varargin,'showsign',0); % add sem vertical lines 
% (the value is a coef to multiply the sem, for instance 1.96 for conf int)

% mean x spacing
if(length(x)==1)
  width=1/6*bar_width/.8;
else
  width=mean(diff(x))/6*bar_width/.8;
end

% log scale
if(logscale), z=log(y); else  z=y; end

% computing the x coordinates
xcoord=zeros(size(y));
for ii=1:size(x,2)
  [N,edges] = histcounts(z(:,ii));
  Y = discretize(z(:,ii),edges);
  w=N/max(N)*width;
  for jj=1:length(N)
    xcoord(Y==jj,ii)=x(ii)-w(jj)+(0:N(jj)-1).*2*w(jj)./N(jj);
  end
end

% the plot itself
holdstatus=get(ax,'nextplot');
if(bar_on)
  bar(ax,x,fun(y),bar_width,'facecolor',bar_color)
  set(ax,'nextplot','add');
end
if link_on
  plot(ax,xcoord',y','-','col',[1 1 1]*.7);
  set(ax,'colororderindex',1)
end
if highlight_on
  plot(ax,xcoord(highlight_on,:)',y(highlight_on,:)','-','col',[0 0 0],...
    'linew',1.5);
  set(ax,'colororderindex',1)
end
if semline
  val=sem(y);
  plot(ax,[x;x],(fun(y)+val.*[-1;1]*semline),'k')
end
if showsign
  for ii=1:length(x)
    [~,p]=ttest(y(:,ii));
    text(ax,x(ii),showsign,pval2star(p),'hor','cen')
  end
end

hh=plot(ax,xcoord,y,'.',varargin{:});
set(ax,'box','off','nextplot',holdstatus)


if nargout==1
  h=hh;
end