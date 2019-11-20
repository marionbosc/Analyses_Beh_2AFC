function [PsycAud, PsycAudFit,fitresult,PsychoPlot] = dataPsychometric(DV, LeftChoice, nbBin, Colorplot)

if ~exist('Colorplot','var')
    Colorplot = [rand rand rand];
end
% Mean points
BinIdx = discretize(DV,linspace(min(DV),max(DV),nbBin+1));
PsycY = grpstats(LeftChoice,BinIdx,'mean');
PsycX = unique(BinIdx)/nbBin*2-1-1/nbBin;
PsycAud.YData = PsycY;
PsycAud.XData = PsycX;
% Fitting
PsycAudFit.XData = linspace(min(DV),max(DV),100);

% fit with log2 instead:
ft = fittype( '1./(1+exp(-(x-m)/sigma))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( ft );
opts.Display = 'Off';
opts.Lower = [ -1 0];
opts.StartPoint = [ 0 .5];
opts.Upper = [1 10];
[fitresult, ~] = fit( DV(:), double(LeftChoice(:)), ft, opts );
PsycAudFit.YData=feval(fitresult,PsycAudFit.XData);

% PsycAudFit.YData = glmval(glmfit(DV,...
%     LeftChoice,'binomial'),linspace(min(DV),max(DV),100),'logit');

if ~strcmp(Colorplot,'none')
    % points Perf/DV
    p=plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge',Colorplot,'MarkerFace',Colorplot,... 
        'MarkerSize',3,'Visible','on'); hold on; 
    % Fitting curve
    PsychoPlot = plot(PsycAudFit.XData,PsycAudFit.YData,'color',Colorplot,'Visible','on');%
end
