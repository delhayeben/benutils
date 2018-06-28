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

% 'bar' argument
bar_on=1;
bararg=find(strcmp('bar',varargin));
if(~isempty(bararg) && strcmp(varargin{bararg+1},'off'))
    bar_on=0;
    varargin(bararg+(0:1))=[];
end

% mean x spacing
if(length(x)==1), width=1/4; else, width=mean(diff(x))/4; end

% computing the x coordinates
xcoord=zeros(size(y));
for ii=1:length(x)
    [N,edges] = histcounts(y(:,ii));
    Y = discretize(y(:,ii),edges);
    w=N/max(N)*width;
    for jj=1:length(N)
        xcoord(Y==jj,ii)=x(ii)-w(jj)+(0:N(jj)-1).*2*w(jj)./N(jj);
    end
end

% the plot itself
holdstatus=get(ax,'nextplot');
if(bar_on)
    bar(ax,x,mean(y),'facecolor','none')
    set(ax,'nextplot','add');
end
hh=plot(ax,xcoord,y,'.',varargin{:});
set(ax,'box','off','nextplot',holdstatus)

if nargout==1
    h=hh;
end