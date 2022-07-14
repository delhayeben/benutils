% function screenshot(filenamewithoutextension)
% OR
% function screenshot(fig,filenamewithoutextension)
% OR
% function screenshot(fig,filenamewithoutextension,format)
% OR
% function screenshot
% OR
% function screenshot(flag)
%
% Takes a screenshot of the current fig (OR figure 'fig')
% - specify 'filenamewithoutextension' without extension
% - you can specify a figure handles with 'fig'
% - you can choose either 'pdf' or 'png' as an output format (default: png)
% - output dimension are the current figure dimensions
%
% Using flag parameter, you can activate/disactivate screenshots
%  flag=0 => disables screenshots
%  flag=1 => enables screenshots for 5 min (and then sets flag to 0)
%  flag=2 => screenshot are always enabled (default behavior)
%  flag=3 => switch status from 0 to 1 or 1 to 0
%  flag=4 => enables screenshots for 1 shot
%  flag>4 => enables screenshots for "flag" min
% Flag status remains even after closing matlab

function status=screenshot(flagorfig,filnamwithoutext,format,varargin)

% setup/retrieve global variables
persistent pers_screenshotflag 
% 0=disabled, 1=enabled timed, 2=enabled always, 3=one shot
persistent pers_screenshottim
if(isempty(pers_screenshotflag))
  pers_screenshotflag=2;
end

% One numeric argument: modify screenshot flag
if(nargin==1 && ~ischar(flagorfig))
  % first delete all prev callback timers
  if(isobject(pers_screenshottim))
    stop(pers_screenshottim)
    delete(pers_screenshottim)
    pers_screenshottim=[];
  end
  
  if(flagorfig==3) % special case, switch between 1 and 0
    if(pers_screenshotflag>0)
      flagorfig=0;
    else
      flagorfig=1;
    end
  end
  
  if(flagorfig==0) % disable
    disp('Screenshots disabled')
  elseif(flagorfig==1) % enable for 5 min
    % create a timer to disactivate screenshots later
    tim = timer;
    tim.ExecutionMode='singleShot';
    tim.TimerFcn = @(x,y) screenshot(0);
    tim.StartDelay = 300; % (5 min)
    disp('Screenshots have been activated for 5 minutes')
    pers_screenshottim=tim;
    start(tim)
  elseif(flagorfig==2) % activate all time
    disp('Screenshots activated all time.')
  elseif(flagorfig==4)
    disp('Screenshot activated for ONE shot')
    flagorfig=3;
  elseif(flagorfig>4 && flagorfig==round(flagorfig))
    % create a timer to disactivate screenshots later
    tim = timer;
    tim.ExecutionMode='singleShot';
    tim.TimerFcn = @(x,y) screenshot(0);
    tim.StartDelay = flagorfig*60; % (5 min)
    disp(['Screenshots have been activated for '...
      num2str(flagorfig) ' minutes'])
    pers_screenshottim=tim;
    start(tim)
  end
  
  pers_screenshotflag=flagorfig;
  return
end

% no argument: get status
if(nargin==0)
  switch pers_screenshotflag
    case 0
      disp('Screenshots disabled');
    case 1
      disp('Screenshots activated temporarily')
    case 2
      disp('Screenshots activated all time.')
    case 3
      disp('Screenshots activated for ONE shot.')
    otherwise
      disp('Weird.')
  end
  if nargout==1
    status=pers_screenshotflag;
  end
  return
end

% Other cases, check if going further
if(pers_screenshotflag==0)
  %disp('no screenshot')
  return
end

% default behavior: png
if(nargin<3)
  format='png';
end

% if figure handle not provided, shift arguments
if(~ishandle(flagorfig))
  if(nargin<2)
    format='png';
  else
    format=filnamwithoutext;
  end
  filnamwithoutext=flagorfig;
  flagorfig=gcf;
end

[resolution,varargin]=parseargpair(varargin,'resolution',300);

% if file already exists, create a backup
filewithext=[filnamwithoutext '.' format];
if(exist(filewithext,'file'))
  [filepath,name] = fileparts(filnamwithoutext);
  backfolder=[filepath '/old/'];
  if(~exist(backfolder,'dir'))
    mkdir(backfolder)
  end
  a=dir([backfolder name '_*.' format]);
  movefile(filewithext,[backfolder name '_' num2str(length(a)+1) '.' format])
end

% hide all uicontrols (in case of GUI's)
uic=findobj(flagorfig,'type','UIControl');
set(uic,'visible','off')

% save figure properties
figprop=get(flagorfig);

% set figure properties for screenshot
set(flagorfig,'PaperPositionMode','auto','Units','inches');
pos=get(flagorfig,'pos');
set(flagorfig,'PaperSize',[pos(3), pos(4)])
set(flagorfig,'InvertHardcopy','off') % keep all other visual porperties

% print command depending on output format
switch format
  case 'pdf'
    set(flagorfig,'color','none','renderer','Painters') % set trans background
    hax=findobj(flagorfig,'type','axes');
    col=get(hax,'color'); if(isnumeric(col) || ischar(col)),col={col};end
    set(hax(cellfun(@(x) isequal(x,[1 1 1]),col)),...
      'color','none');
    print(flagorfig,[filnamwithoutext '.pdf'],'-dpdf','-r0')
  case 'png'
    set(flagorfig,'color','w') % set white background
    print(flagorfig,[filnamwithoutext '.png'],'-dpng',['-r' num2str(resolution)])
    
    % if imagemagick installed, remove white background
    %         [s,~]=system('where convert.exe');
    %         if(~s)
    %             file=[filnamwithoutext '.' format];
    %             cmd=['convert ' filnamwithoutext ...
    %                 '.png -transparent white '...
    %                 filnamwithoutext  '.png'];
    %             [~,~]=system(cmd);
    %         end
    
  otherwise
    disp('unknown format, abord...');
end

% show uicontrols back
set(uic,'visible','on');

% reset figure properties to normal
set(flagorfig,'PaperPositionMode',figprop.PaperPositionMode)
set(flagorfig,'Units',figprop.Units)
set(flagorfig,'PaperSize',figprop.PaperSize)
set(flagorfig,'color',figprop.Color)
set(flagorfig,'InvertHardcopy',figprop.InvertHardcopy)

disp(['SCREENSHOT SAVED : ' filnamwithoutext '.' format])

if(pers_screenshotflag==3) % if screenshot were enabled for 1 shot, disable
  pers_screenshotflag=0;
  disp('Screenshots disabled');
end
return

% add tag (if imagemagick installed)
stack=dbstack(1);
if(~isempty(stack) && strcmp('png',format))
  orig_script=stack(1).file;
  [s,~]=system('where convert.exe');
  if(~s)
    file=[filnamwithoutext '.' format];
    cmd=['convert ' file ' -set tag: "' orig_script '" ' file];
    [~,~]=system(cmd);
    % you can read the tag using
    % identify -format '"%[tag:]"\n' filename+ext
  end
end

end
function [argval,outputs]=parseargpair(inputs,name,default)

if(nargin<3 || ~exist('default','var'))
  default=[];
end

argnum=find(strcmp(name,inputs));
if(~isempty(argnum) && length(argnum)==1)
  argval=inputs{argnum+1};
  inputs(argnum+(0:1))=[];
else
  argval=default;
end

outputs=inputs;

end