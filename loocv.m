function [cvrmse, error]=loocv(X,y,lambda)

[n,p]=size(X);
% lambda is for ridge regression
if nargin>2 % if we have a lambda, extend X and y
    X=[X;eye(p)*sqrt(lambda)];
    y=[y;zeros(p,1)];
end

% ordinary LS
[Q, R] = qr(X,0);
E = X/R;

% loocv
yh=X*(R\(Q'*y)); % LS estimate
l=sum(E.*E,2); % leverage


error=(y(1:n) - yh(1:n))./(1-l(1:n));
cvrmse = sqrt(nanmean((error(1:n)).^2));

