function siz=subplot_size(n)

nr=floor(sqrt(n));
nc=ceil(n/nr);

siz=[nr nc];