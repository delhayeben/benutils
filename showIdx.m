% function showIdx(h)
%
% shows line and point index when clicking on trace in the plot window
%
%  input: h is the handle of the plot
%
%  Example:
%    x=linspace(0,20,200)';
%    phi=linspace(0,pi,6);
%    y=sin(bsxfun(@plus,x,phi));
%
%    h=plot(x,y,'.-');
%    showIdx(h);
%    %
%    % OR (more compact)
%    %
%    showIdx(plot(x,y,'.-'))
%
% and then click on the traces


function hh=showIdx(h,names)
set(h,'ButtonDownFcn',@clickfun)
if(nargin<2)
    names=cell(length(h),1);
end
for ii=1:length(h)
    if(isempty(names{ii}))
        names{ii}=cellstr(num2str((1:length(h(ii).XData))'));
    end
end
if(nargout>0), hh=h; end

    function clickfun(lineh,clickh)
        % find closest point and extract index
        bcoord=clickh.IntersectionPoint(1:2);
        xs=diff(lineh.Parent.XLim); % correct for x and y different scales
        ys=diff(lineh.Parent.YLim);
        dxdy=bsxfun(@minus,[lineh.XData' lineh.YData'],bcoord);
        dist=hypot(dxdy(:,1)/xs,dxdy(:,2)/ys);
        pidx=getNthOutput(@min,2,dist);
        % set text message
        if(length(h)>1)
            str=['  L: ' num2str(find(h==lineh)) '  '];
        else
            str=[];
        end
        str=[str 'P: ' names{h==lineh}{pidx}];
        
        % show text
        texth = text(bcoord(1),bcoord(2),str,...
            'EdgeColor','k','BackgroundColor',[1 1 1 .1],'VerticalA','bottom');
        
        % change linewidth and type
        % Fetch all curve properties
        linep = get(lineh);
        
        set(lineh,'Linewidth',2*linep.LineWidth);
        
        % depending on line type, double point size
        if(isfield(linep,'MarkerSize')) % for
            set(lineh,'MarkerSize',2*linep.MarkerSize)
        else % for scatter plots
            set(lineh,'SizeData',2*linep.SizeData,'MarkerFaceColor','flat',...
                'MarkerEdgeColor','k')
        end
        
        pointh=line(lineh.XData(pidx),lineh.YData(pidx),'Marker','o',...
            'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',9);
        
        % set button release callback
        set(getParFig(lineh),'WindowButtonUpF',{@releasefun,[texth pointh],lineh,linep});
    end

    function releasefun(~,~,texth,lineh,linep)
        set(lineh,'Linewidth',linep.LineWidth)
        % depending on line type, double point size
        if(isfield(linep,'MarkerSize')) % for
            set(lineh,'MarkerSize',linep.MarkerSize)
        else % for scatter plots
            set(lineh,'SizeData',linep.SizeData,...
                'MarkerFaceColor',linep.MarkerFaceColor,...
                'MarkerEdgeColor',linep.MarkerEdgeColor)
        end
        delete(texth)
    end

    function fig = getParFig(fig)
        % If the object is a figure or figure descendent, return the figure.
        % Otherwise return [].
        while(~isempty(fig) && ~strcmp('figure', get(fig,'type')))
            fig = get(fig,'parent');
        end
    end

end