function [cvrmse, err,coefLS]=loocv(X,y,lambda)

[n,p]=size(X);
% lambda is for ridge regression
if nargin>2 && lambda ~= 0% if we have a lambda, extend X and y
    lambda=abs(lambda);
    X=[X;eye(p)*sqrt(lambda)];
    y=[y;zeros(p,1)];
end

% ordinary LS
[Q, R] = qr(X,0);
E = X/R;

coefLS=R\(Q'*y);
yh=X*coefLS; % LS estimate
l=sum(E.*E,2); % leverage

% loocv
err=(y(1:n) - yh(1:n))./(1-l(1:n));
cvrmse = sqrt(nanmean((err(1:n)).^2));

