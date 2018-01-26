% function ff=newfig(name,[param-pairs])
% 
% creates a new figure with default publication parameter
% 
% if you give a specific name to the figure, next time you call the
% function the existing figures with the same name will be first closed.
%
% ['param',value] lets you set param-value pairs to the figure according to
%                   the figure properties

function ff=newfig(name,varargin)

publicationparam={
    'DefaultAxesTickDirMode'        'manual'
    'DefaultAxesTickDir'            'out'
    'DefaultLineLineWidth'          1.5
    'DefaultAxesLineWidth'          1
    'DefaultAxesTickLength'         [0.015 0.015]
    'DefaultAxesFontSize'           8
    'DefaultAxesTitleFontSize'      1.2
    'DefaultAxesLabelFontSize'      1.2
    'DefaultLineMarkerSize'         6
    'Unit'             'centimeter'
    'Position'         [17 14 8.5 6.3]
    }';

if(~exist('name','var') || isempty(name))
    name=num2str(round(rand*1e6));
else
    disp(name)
    old=findobj('name',name);
    delete(old);
end

f=figure('name',name,publicationparam{:},varargin{:});


if(nargout==1)
    ff=f;
end