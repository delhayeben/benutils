function [cvrmse, error]=loocv(X,y)

[Q, R] = qr(X,0);
E = X/R;

% loocv
yh=X*(R\(Q'*y));
l=(1 - sum((E.*E),2));

error=(y - yh)./l;
cvrmse = sqrt(nanmean((error).^2));

