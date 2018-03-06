%% Figure vevaiometric with both side together
%
% WORKS ONLY FOR AUDITORY MODALITY
%
% Input:
% - Dataset --> SessionData
% - Coordinates subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - plotpointornot = 1 --> plot all datas point / = 0 --> don't plot data points
% - plotCIornot = 1 --> plot fitting line and CI for them / = 0 --> don't plot CI line
%
%

function [SessionData] = miVevaiometric_fig(SessionData,nb_raw_fig,nb_col_fig,positn_fig,plotpointornot,plotCIornot)
%% Vevaiometric auditory trials DV log

VevaiometricMinWT = 2; % FB time minimum pris en compte dans analyse WT

% Calcul/formatage des donnees
ndxAud = SessionData.Custom.Modality(1:end) == 2 ; % Essais stimulus auditif
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; %all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; %only correct catch trials
ndxMinWT = SessionData.Custom.FeedbackTime > VevaiometricMinWT;

WTerr = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxAud); % recup WT essais erreur pointage a gauche
WTcatch = SessionData.Custom.FeedbackTimeNorm(ndxCorrectCatch&ndxMinWT&ndxAud); % recup WT essais catch pointage a gauche

DVerr = abs(SessionData.Custom.DVlog(ndxError&ndxMinWT&ndxAud)); % Recup DV essais erreur pointage a gauche
DVcatch = abs(SessionData.Custom.DVlog(ndxCorrectCatch&ndxMinWT&ndxAud)); % recup DV essais catch pointage a gauche 

% Data sorting: (reorg des WT selon classement DV croissant pour que DV soit continu):
[DVerr_sorted, e_sort] = sort(DVerr);
WTerr_sorted = WTerr(e_sort);

[DVcatch_sorted, c_sort] = sort(DVcatch);
WTcatch_sorted = WTcatch(c_sort);

% Remplacement des variables par les variables reorganisees:
DVerr= DVerr_sorted;
WTerr = WTerr_sorted;
DVcatch = DVcatch_sorted;
WTcatch = WTcatch_sorted;

% Recup data a ploter:
Scatter.err.YData = WTerr;
Scatter.catch.YData = WTcatch;
Scatter.err.XData = DVerr;
Scatter.catch.XData = DVcatch;
[CorrCoeff.err.r, CorrCoeff.err.p] = corrcoef(DVerr,WTerr);
[CorrCoeff.catch.r, CorrCoeff.catch.p] = corrcoef(DVcatch,WTcatch);
[Fit.err.r, Fit.err.p] = fit(DVerr',WTerr','poly1');
[Fit.catch.r, Fit.catch.p] = fit(DVcatch',WTcatch','poly1');
[pdint.err.r, pdint.err.p] = predint(Fit.err.r,DVerr',0.95,'functional','on');
[pdint.catch.r, pdint.catch.p] = predint(Fit.catch.r,DVcatch',0.95,'functional','on');

% Figure vevaiometric f(DV)=WT
subplot(nb_raw_fig,nb_col_fig,positn_fig);hold on; 
if plotpointornot == 1
    scatter(Scatter.err.XData,Scatter.err.YData,4,[1 0.6 0],...
         'Marker','o','MarkerFaceColor',[1 0.6 0],'Visible','on','MarkerEdgeColor',[1 0.6 0]);
    scatter(Scatter.catch.XData,Scatter.catch.YData,4,'g',...
         'Marker','o','MarkerFaceColor','g','Visible','on','MarkerEdgeColor','g');
end    
plot([0 1.6],[Fit.err.r.p1*0 + Fit.err.r.p2 Fit.err.r.p1*1.6 + Fit.err.r.p2],'r-','LineWidth',1.5);    
plot([0 1.6],[Fit.catch.r.p1*0 + Fit.catch.r.p2 Fit.catch.r.p1*1.6 + Fit.catch.r.p2],'-','Color', [0.23, 0.5, 0.17],'LineWidth',1.5); 
if plotCIornot ==1
    plot(DVerr',pdint.err.r,'r--','LineWidth',1.5);
    pl=plot(DVcatch',pdint.catch.r,'--','Color', [0.23, 0.5, 0.17],'LineWidth',1.5);
end
% Legendes et axes
pl(1).Parent.XAxis.FontSize = 10; pl(1).Parent.YAxis.FontSize = 10;
leg = legend(['Error n = ',num2str(size(Scatter.err.YData,2))...
    ' ; r = ' num2str(round(CorrCoeff.err.r(1,2),2)) ' / p = ' num2str(round(CorrCoeff.err.p(1,2),3))] ,...
    ['Catch n = ',num2str(size(Scatter.catch.YData,2))...
    ' ; r = ' num2str(round(CorrCoeff.catch.r(1,2),2)) ' / p = ' num2str(round(CorrCoeff.catch.p(1,2),3))],...
    'Location','NorthWest');
leg.FontSize = 12; legend('boxoff');
xlim ([0, 1.6]); %ylim([0 10]);
title(['Vevaiometric auditory trials ' SessionData.Custom.Subject],'fontsize',14);
xlabel('-log(DV)','fontsize',14);ylabel('Normalized WT (s)','fontsize',14);hold off;  

clearvars -except SessionData