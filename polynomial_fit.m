%% Polynomial fit
%
% d = degree of the fitting equation
% linear regression if d = 1
%
% Yfit = Y value predicted by the fitting function
%


function [p, Yfit, rsq, R2adjusted,Formula] = polynomial_fit(X,Y,d)

p = polyfit(X,Y,d);

Yfit = polyval(p,X);

Formula = [];
Factor = d;
for i = 1:d+1
    Formula = [Formula '+' [num2str(p(i)) '*(X.^' num2str(Factor) ')' ]];
    Factor = Factor-1;
end

yresid = Y - Yfit;
SSresid = sum(yresid.^2);
SStotal = (length(Y)-1) * var(Y);
rsq = 1 - SSresid/SStotal;
n = size(Y,2); 
R2adjusted = 1 - (SSresid / SStotal)*((n-1)/(n-d-1));