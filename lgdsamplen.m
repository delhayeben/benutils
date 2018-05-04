function lgdsamplen(hic,pct)

% 1. is text
% 2. is line
% 3. is point

ii=1;
while 1
    if(length(hic)<ii), break; end
    val=get(hic(ii),'type');
    if(strcmp(val,'hggroup') || strcmp(val,'group'))
        child=hic(ii).Children;
        hic(end+(1:length(child)))=child;
    end
    ii=ii+1;
end

lh=length(hic);
type=zeros(lh,1);
pos=cell(lh,1);

for ii=1: lh   
    val=get(hic(ii),'type');
    if(strcmp(val,'hggroup') || strcmp(val,'group'))
        continue
    end
    if(strcmp(val,'text'))
        type(ii)=1;
        pos{ii}=get(hic(ii),'Position');
    elseif(strcmp(get(hic(ii),'LineStyle'),'none'))
        type(ii)=3;
        pos{ii}=get(hic(ii),'XData');
    else
        type(ii)=2;
        pos{ii}=get(hic(ii),'XData');
    end
    
    ii=ii+1;
end


        
val=find(type==2,1);
shift=diff(pos{val})*(1-pct);

for ii=1:lh
    switch type(ii)
        case 1
            set(hic(ii),'Position',pos{ii}+[-shift 0 0]);
        case 2
            set(hic(ii),'XData',pos{ii}+[0 -shift]);
        case 3
            set(hic(ii),'XData',pos{ii}+[-shift/2]);
    end
end