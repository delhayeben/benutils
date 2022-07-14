function dND = nddiag(ndarray,k,dim1,dim2)

if(~exist('k','var')), k=0; end
if(~exist('dim1','var')),    dim1=1; end
if(~exist('dim2','var')),    dim2=2; end

siz = size(ndarray);
%% check that the matrix is square along d1 and d2
if(siz(dim1)~=siz(dim2))
    error('matrix along dim1 and dim2 is not square')
end
msiz=siz(dim1);
%% Permute the ND matrix such that row x column are upfront:
permseq = 1:length(siz);
%Swap One Element at a time:
permseq([1,dim1]) = permseq([dim1,1]);
permseq([2,dim2]) = permseq([dim2,2]);

ndarray = permute(ndarray,permseq);
newsiz=siz(permseq);

%% Reshape the matrix such that it is [d1 d2 x]
otherdims=prod(newsiz(3:end));
ndarray = reshape(ndarray,msiz,msiz,otherdims);
%% find the right indices and extract them and reshape
idx = repmat(diag(true(msiz-abs(k),1),k),[1 1 otherdims]);
dND = reshape(ndarray(idx),[msiz-abs(k) 1 newsiz(3:end)]); 

%% Put the Dimension Sequence Back to their original locations:
dND = ipermute(dND,permseq);
end