% function trialSwitcher(plotfun,ntrials,name,initial,screen)
%
% enables to rapidly switch between trials when ploting some analyses
% plots data according to a ploting function and adds a sliders to switch
% between trials
%
%  INPUTS (mandatory) :
%   plotfun: the function called to plot the data
%    - plotfun has 1 input parameter, id, selecting the trial number
%    - plotfun can be a cell vector of multiple functions handles
%          (see advanced example)
%   ntrials: (nsliders,1), the max number of trials (the max id can reach)
%
%  INPUTS (optionnal):
%   name {nsliders,1}: a string for the name of the sliders
%   initial (nsliders,1): the initial position of each slider (default = 1)
%   screen (logical): adds a button to save snapshots of all trials to png
%
%
% Basic example:
%   x=linspace(0,20,200)';
%   phi=linspace(0,pi,6); % represents 6 different trials
%   y=sin(bsxfun(@plus,x,phi)); % 6 differents responses
%
%   plotfun=@(id) plot(x,y(:,id)); % create plot function
%   trialSwitcher(plotfun,length(phi)) % run trialSwitcher
%
% Advanced example (basic example continued):
%   z=cos(bsxfun(@plus,x,phi));
%   ax=[subplot(211) subplot(212)];
%
%   plotfun2{1}=@(id) plot(ax(1),x,y(:,id(1)));
%   plotfun2{2}=@(id) plot(ax(2),x,z(:,id(2)));
%   trialSwitcher(plotfun2,[1 1]*length(phi),{'T1','T2'},[1 5])
%
% A compact way to define a cell vector of function handles
%   plotfun2={
%     @(id) plot(ax(1),x,y(:,id(1)))
%     @(id) plot(ax(2),x,z(:,id(2)))
%     ...
%     };

function sliderh=trialSwitcher(plotfun,ntrials,name,initial,screen)

% check inputs
if(nargin<2)
  error('There should be at least 2 input: plotfun and ntrials')
end
if(~isvector(ntrials)), error('ntrials should be a vector');end
if(nargin<3), name=cell(size(ntrials));end % no slider name
if(ischar(name)), name={name}; end % in case of single slide name
if(nargin<4) % set initial state
  curr_state=ones(size(ntrials));
else
  curr_state=initial;
end
if(nargin<5), screen=0;end

% adds sliders
nslider=length(ntrials);
for ii=1:nslider
  slidh(ii)=uicontrol('sty','slider','call',{@callbckfun,ii},...
    'pos',[(ii-1)*270+70 3 160 15],...
    'min',1,'max',ntrials(ii),'val',curr_state(ii),...
    'sliderstep',[1/(ntrials(ii)) 3/(ntrials(ii))]);
  uicontrol('sty','text','string',name{ii},...
    'pos',[(ii-1)*270+0 5 70 15],...
    'fontsize',11);
  edith(ii)=uicontrol('sty','edit','string',num2str(curr_state(ii)),...
    'pos',[(ii-1)*270+230 3 35 15],...
    'fontsize',11,'call',{@callbckfun,ii});
  uicontrol('sty','pushbutton','string','>','pos',[(ii-1)*270+275 3 20 15],...
    'fontsize',11,'call',@playbutcb);
end

% adds screenshot button
if(screen)
  uicontrol('sty','pushb','pos',[530 12 15 15],'call',{@screenshotcb});
  figname=uicontrol('sty','edit','pos',[460 12 70 15]);
end

% in case of cell vector of function handles, apply cellfun trick
if(iscell(plotfun))
  plotfun=@(idx) cellfun(@(f) f(idx),plotfun);
end

% run plotfun
plotfun(curr_state);

%% callbacks
% slider callback
  function callbckfun(source,~,id)
    switch source.Style
      case 'edit'
        idx=str2double(source.String);
        if(idx<1), idx=1; end
        if(idx>ntrials(id)), idx=ntrials(id); end
        curr_state(id)=idx;
      case 'slider'
        curr_state(id)=round(source.Value);
    end
    edith(id).String=num2str(curr_state(id));
    slidh(id).Value=curr_state(id);
    plotfun(curr_state);
  end

  function playbutcb(~,~)
    if(curr_state==ntrials(1))
      curr_state=1;
    end
    for jj=curr_state:ntrials(1)
      curr_state=jj;
      edith(1).String=num2str(curr_state(1));
      slidh(1).Value=curr_state(1);
      plotfun(curr_state)
      pause(0.1)
    end
  end

% screenshot callback
  function screenshotcb(~,~)
    % activate screenshot (and save original status)
    status=screenshot;
    screenshot(2);
    
    savestates=curr_state;
    str=figname.String;
    if(~isempty(str))
      for jj=1:ntrials(1)
        plotfun([jj curr_state(2:end)]);
        screenshot(gcf,[str num2str(jj)],'png');
      end
      plotfun(savestates);
    end
    
    % set screenshot status back to original
    screenshot(status);
  end

if(nargout==1)
  sliderh=slidh;
end
end