function [outputs,argval]=parseargpair(inputs,name,default)

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