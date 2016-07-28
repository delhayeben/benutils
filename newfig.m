function ff=newfig(name,varargin)

old=findobj('name',name);
delete(old);
f=figure('name',name,varargin{:});

if(nargout==1)
    ff=f;
end