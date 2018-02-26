function ax = subplot_ax(rows,columns,varargin)
%SUBPLOT_AX Create rows*columns subplots and return their handles.
%
% input: rows: number of rows
%        columns: number of columns
%        varargin: pairs of parameters to "set" to all subplots
%
%        rows can also be used
%          - as a two digit scalar: 44 is for 4 rows and 4 columns
%          - as 2 two elements vector: first element is rows, sencond is
%             columns
%        in that case, the argument column is concatenated with varargin.

% DO NOT PRE-ALLOCATE, in order to obtain handle objects in recent Matlab
% version
%ax = zeros(rows*columns,1);


% handle inputs
if(nargin==1 || ~isscalar(columns))
    % cat columns with varargin
    if(exist('columns','var') && ~isempty(columns))
        varargin=[columns varargin];
    end
    
    % scalar rows
    if(isscalar(rows))
        if(rows>99)
            error('Single argument option does not support more than 9 by 9 subplots')
        end
        if(rows<11)
            error('Single argument: should have at least 1 row and 1 column')
        end
        columns=rem(rows,10);         rows=floor(rows/10);
        % two element vector
    elseif(isvector(rows) && length(rows)==2)
        columns=rows(2);              rows=rows(1);
        % otherwise throw error
    else
        error('Rows should be either a scalar or a vector of 2 elements')
    end
end
if(rows<1 || columns<1)
    error('Subplots should have at least 1 row and 1 column')
end

% create subplot
ax = column(gobjects(rows,columns));
for ii = 1:(rows*columns)
    ax(ii) = subplot(rows,columns,ii);
end

% tag subplot format
try
    hProp = addprop(ax(1),'SubplotFormat');
    set(ax(1),'SubplotFormat',[rows columns]);
    hProp.SetAccess = 'private';
catch
    disp('something went wrong with the tags');
end


% set properties
if(exist('varargin','var') && ~isempty(varargin))
    set(ax,varargin{:})
end

% add double clic callback for tightsubplot
hfig=ax.Parent;
set(hfig,'WindowButtonDownFcn',@cliccb)

    function cliccb(handle,~)
        % if double click
        if(strcmp(get(handle,'SelectionType'),'open'))
            % check if double click is outside the axis
            figunits=get(handle,'units'); set(handle,'units','norm')
            xycur=get(handle,'CurrentPoint');
            in=false;
            for jj=1:length(ax)
                pax=get(ax(jj),'pos');
                xyax=[pax(1:2);pax(1:2)+[pax(3) 0];...
                    pax(1:2)+[pax(3) pax(4)];pax(1:2)+[0 pax(4)]];
                in=inpolygon(xycur(1),xycur(2),xyax(:,1),xyax(:,2));
                if(in)
                    set(handle,'units',figunits);
                    return
                end
            end
            % apply the tightsubplot function
            tightsubplot(flipud(handle.Children))
            set(handle,'units',figunits);
        end
    end

end



