%% f(WT) = accuracy for catch trials only 
%
% Input:
% - Dataset --> SessionData
% - Sensory modality : 1 = Olfactory / 2 = Auditory --> Modality
% - WT data raw (0) or normalized per session (1)
% - Coordonnees subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - Extra text in the title
% - Percentile used to determine Short vs Long WT
% - Nb of bin to discretize data (Auditory only)
%

function ShvsLgWT_fig(SessionData, Modality, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Percentile,nbBin)
%% Parametres de la figures:
if Modality == 1
    Sensory_Modality = 'Olfactory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0]; 
    xmin = 0; xmax = 100;
    xlabel = 'DV';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xlabel = 'Binaural contrast';
elseif Modality == 3
    Sensory_Modality = 'Auditory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0]; 
    xmin = -1; xmax = 1;
    xlabel = 'DV';
end

% Figure vevaiometric f(DV)=WT
ShvsLg = subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on

%% Recup data

% Recup DV 
if Modality ==1
    DV = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
    ndxModality = SessionData.Custom.Modality==Modality;
elseif Modality ==2
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Calculs Bins de difficulte
    BinIdx = discretize(DV,linspace(-1,1,nbBin+1));
    ndxModality = SessionData.Custom.Modality==Modality;
elseif Modality == 3
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    ndxModality = SessionData.Custom.Modality==2;
end

% Index essais 
ndxNan = isnan(SessionData.Custom.ChoiceLeft); % Essais non repondu
ndxCatch = SessionData.Custom.CatchTrial;

% Recup WT normalises:
if NormorNot == 1
    Percentile_WT = prctile(SessionData.Custom.FeedbackTimeNorm(ndxModality&ndxCatch),Percentile);
    ndxlongWT = SessionData.Custom.FeedbackTimeNorm>Percentile_WT;
    ndxshortWT = SessionData.Custom.FeedbackTimeNorm<Percentile_WT;
else
    Percentile_WT = prctile(SessionData.Custom.FeedbackTime(ndxModality&ndxCatch),Percentile);
    ndxlongWT = SessionData.Custom.FeedbackTime>Percentile_WT;
    ndxshortWT = SessionData.Custom.FeedbackTime<Percentile_WT;
end

% Calcul pourcent choix gauche par type d'essai
if Modality ==1 || Modality == 3
    % Long WT
    PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
    PsycX = unique(DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT));
    PsycX_L = PsycX(~isnan(PsycX));
    
    % Short WT
    PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
    PsycX = unique(DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT));
    PsycX_S = PsycX(~isnan(PsycX));
elseif Modality == 2
    % Long WT
    PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),BinIdx(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
    PsycX = unique(BinIdx(ndxModality&~ndxNan&ndxCatch&ndxlongWT))/nbBin*2-1-1/nbBin;
    PsycX_L = PsycX(~isnan(PsycX));

    % Short WT
    PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),BinIdx(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
    PsycX = unique(BinIdx(ndxModality&~ndxNan&ndxCatch&ndxshortWT))/nbBin*2-1-1/nbBin;
    PsycX_S = PsycX(~isnan(PsycX));    
end

% Donnees plot (courbe fit points)
% Long WT
Psyc_L.YData = PsycY_L;
Psyc_L.XData = PsycX_L;
if sum(ndxModality&~ndxNan&ndxCatch&ndxlongWT) > 1
    PsycFit_L.XData = linspace(min(DV),max(DV),100);
    [Fit,~,Stat]=glmfit(DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),...
        SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT)','binomial');
    [PsycFit_L.YData,CILow_L,CIHigh_L] = glmval(Fit,linspace(min(DV),max(DV),100),'logit',Stat);
end

% Short WT
Psyc_S.YData = PsycY_S;
Psyc_S.XData = PsycX_S;
if sum(ndxModality&~ndxNan&ndxCatch&ndxshortWT) > 1
    PsycFit_S.XData = linspace(min(DV),max(DV),100);
    [Fit,~,Stat]=glmfit(DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),...
        SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT)','binomial');
    [PsycFit_S.YData,CILow_S,CIHigh_S] = glmval(Fit,linspace(min(DV),max(DV),100),'logit',Stat);
    clear Fit Stat
end

%% Figure:

plot(Psyc_L.XData,Psyc_L.YData,'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b',...
    'MarkerSize',4,'Visible','on');
plot(Psyc_S.XData,Psyc_S.YData,'LineStyle','none','Marker','o','MarkerEdge','m','MarkerFace','m',...
    'MarkerSize',4,'Visible','on');
% Courbe fit donnees perf 
plot(PsycFit_L.XData,PsycFit_L.YData,'color','b','Visible','on');
ciplot(PsycFit_L.YData-CILow_L,PsycFit_L.YData+CIHigh_L,PsycFit_L.XData,'b',0.3);
plot(PsycFit_S.XData,PsycFit_S.YData,'color','m','Visible','on');
ciplot(PsycFit_S.YData-CILow_S,PsycFit_S.YData+CIHigh_S,PsycFit_S.XData,'m',0.3);
plot([xmin, xmax],[0.5 0.5],'--','color',[.7,.7 .7]);
p = plot([xmin+(xmax-xmin)/2 xmin+(xmax-xmin)/2],[0 1],'--','color',[.7,.7 .7]);
p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
% Legendes et axes
ylim([0 1]);
xlim ([xmin, xmax]);
leg = legend(['Long WT n = ',num2str(sum(ndxModality&~ndxNan&ndxCatch&ndxlongWT))],['Short WT n = ',num2str(sum(ndxModality&~ndxNan&ndxCatch&ndxshortWT))],'Location','SouthEast');
title({['Psychometric ' Sensory_Modality  ' ' TitleExtra]; [num2str(Percentile) 'th percentile catch trials WT = ' num2str(round(Percentile_WT,2))]},'fontsize',12);
leg.FontSize = 10; legend('boxoff');
p.Parent.XLabel.String = xlabel; p.Parent.XLabel.FontSize =14;
p.Parent.YLabel.String = 'Left choice'; p.Parent.YLabel.FontSize =14;
hold off;

