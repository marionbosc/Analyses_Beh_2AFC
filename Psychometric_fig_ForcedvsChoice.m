%% Script/fonction pour calcul et figure Psychometric:
%
%
% Input:
% - Dataset --> SessionData
% - Modalite sensorielle: 1 = Olfaction / 2 = Audition --> Modality
% - Coordonnees subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)

function [SessionData,Perf] = Psychometric_fig_ForcedvsChoice(SessionData, Modality,nb_row_fig,nb_col_fig,positn_fig)
%% Psyc Auditory modality
% Recup DV essais audit
AudDV = SessionData.Custom.DVlog(1:numel(SessionData.Custom.ChoiceLeft));
% Index essais audit
ndxAud = SessionData.Custom.Modality==Modality;
% Index essais sans reponse (ChoiceLeft = NaN)
ndxNan = isnan(SessionData.Custom.ChoiceLeft);
% Index essais forced vs choice:
ndxChoice = SessionData.Custom.ForcedLEDTrial(1:numel(SessionData.Custom.ChoiceLeft))==0;
ndxForced = SessionData.Custom.ForcedLEDTrial(1:numel(SessionData.Custom.ChoiceLeft))==1;
Pct_Forced =  sum(ndxForced)/(sum([ndxForced ndxChoice]))*100;     
% Calculs Bins de difficulte
AudBin = 12;
BinIdx = discretize(AudDV,linspace(min(AudDV),max(AudDV),AudBin+1));

% Choice trials
PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan&ndxChoice),BinIdx(ndxAud&~ndxNan&ndxChoice),'mean');
PsycX = unique(BinIdx(ndxAud&~ndxNan&ndxChoice))/AudBin*2-1-1/AudBin;              
PsycAud.YData = PsycY;
PsycAud.XData = PsycX;
if sum(ndxAud&~ndxNan&ndxChoice) > 1
    PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
    PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan&ndxChoice),...
        SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan&ndxChoice)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
end

% Forced trials
PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan&ndxForced),BinIdx(ndxAud&~ndxNan&ndxForced),'mean');
PsycX = unique(BinIdx(ndxAud&~ndxNan&ndxForced))/AudBin*2-1-1/AudBin;              
PsycAudForced.YData = PsycY;
PsycAudForced.XData = PsycX;
if sum(ndxAud&~ndxNan&ndxForced) > 1
    PsycAudForcedFit.XData = linspace(min(AudDV),max(AudDV),100);
    PsycAudForcedFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan&ndxForced),...
        SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan&ndxForced)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
end

% Calcul Bias dans la modalite
if sum(SessionData.Custom.ForcedLEDTrial==0)>10
    ndxModality = SessionData.Custom.AuditoryTrial & SessionData.Custom.ForcedLEDTrial==0;
else
    ndxModality = SessionData.Custom.AuditoryTrial & SessionData.Custom.ForcedLEDTrial==1;
end
ndxLeftRewd = SessionData.Custom.ChoiceCorrect == 1  & SessionData.Custom.ChoiceLeft == 1;
ndxLeftRewDone = SessionData.Custom.LeftRewarded==1 & ~isnan(SessionData.Custom.ChoiceLeft);
ndxRightRewd = SessionData.Custom.ChoiceCorrect == 1  & SessionData.Custom.ChoiceLeft == 0;
ndxRightRewDone = SessionData.Custom.LeftRewarded==0 & ~isnan(SessionData.Custom.ChoiceLeft);
Perf.Left = sum(ndxModality & ndxLeftRewd)/sum(ndxModality & ndxLeftRewDone);
Perf.Right = sum(ndxModality & ndxRightRewd)/sum(ndxModality & ndxRightRewDone);
Perf.Bias = (Perf.Left-Perf.Right)/2 + 0.5;

% Calcul performance par port de reponse (gauche/droite):
Perf.globale = sum(ndxModality & SessionData.Custom.ChoiceCorrect==1)/sum(ndxModality & ~isnan(SessionData.Custom.ChoiceCorrect)); 

% Figure perf audition: f(beta)= % left
subplot(nb_row_fig,nb_col_fig,positn_fig); hold on;
% points Perf/DV
if sum(SessionData.Custom.ForcedLEDTrial==0)>10
    p=plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k',...
    'MarkerSize',3,'Visible','on');
end
p=plot(PsycAudForced.XData,PsycAudForced.YData,'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g',...
        'MarkerSize',3,'Visible','on');

% Courbe fittee donnees perf 
if sum(SessionData.Custom.ForcedLEDTrial==0)>10
    plot(PsycAudFit.XData,PsycAudFit.YData,'color','k','Visible','on');
end
plot(PsycAudForcedFit.XData,PsycAudForcedFit.YData,'color','g','Visible','on');
plot([min(p.XData)-0.05, max(p.XData)+0.05],[0.5 0.5],'--','color',[.7,.7 .7]);
plot([0 0],[-.05 1.05],'--','color',[.7,.7 .7]);
% Legendes et axes
p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
ylim([-.05 1.05]);xlim ([min(p.XData)-0.05, max(p.XData)+0.05]);
title({['Psychometric Aud  ' SessionData.Custom.Subject '  ' SessionData.SessionDate];...
    ['Side Bias toward left = ' num2str(round(Perf.Bias,2))];...
    ['% Success L = ' num2str(round(Perf.Left,2)) ...
    ' / R = ' num2str(round(Perf.Right,2)) ...
    ' / all = ' num2str(round(Perf.globale,2))]},'fontsize',12);
xlabel('-log(DV)','fontsize',14);ylabel('% left','fontsize',14);hold off;
legend('Choice trials',['Forced trials (' num2str(round(Pct_Forced)) '%)'],'Location','NorthWest');
legend('boxoff');  
clearvars -except SessionData  Perf
end

