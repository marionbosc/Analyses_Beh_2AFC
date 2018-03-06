%% Panel figures analyses donnees comportement
%
% Performance/WT au cours de la session (1)
% Composition of the training session (2)
% Grace period distribution (3)
% Distribution des WT for each response port (left vs right) (4)
% Distribution des durees de sampling (RT) selon DV essais olfactifs corrects (5)
% Distribution des durees de sampling (RT) selon DV essais auditifs corrects (6) --> a implementer 
% Distribution des WT for correct (rewarded, skipped and catch) and error trials (7)
% (8)
%

function [f1,Error] = fig_beh(SessionData)
%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);


%% Performance au cours de la session (1)

% Nombre de points dans l'analyse
Xplot = 0:50:size(SessionData.Custom.ChoiceLeft,2);
Nbbin = size(Xplot,2);

% Pourcentage d'essais corrects au fur et a mesure de la session
ndxAllDone = SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxFalse = SessionData.Custom.ChoiceCorrect==0; % False = wrong response port
ndxError = isnan(SessionData.Custom.ChoiceCorrect); % Error = other beh mistake 
ndxCatch = SessionData.Custom.CatchTrial;
ndxLeft = SessionData.Custom.ChoiceLeft == 1;
ndxRight = SessionData.Custom.ChoiceLeft == 0;
ndxSkippedFB = SessionData.Custom.SkippedFeedback;

Pct_WS = [];Pct_Error = [];    
for i=1:Nbbin
    debut = Xplot(i)+1; 
    if debut + 49 < size(SessionData.Custom.ChoiceLeft,2)
       fin = debut+49;
    else
       fin = size(SessionData.Custom.ChoiceLeft,2);
    end
    Pct_WS = [Pct_WS sum(ndxFalse(debut:fin))/sum(ndxAllDone(debut:fin))*100];
    Pct_Error = [Pct_Error sum(ndxError(debut:fin))/size(debut:fin,2)*100];
end

% Donnees moyenne:
Error.WS = num2str(round(sum(ndxFalse)/sum(ndxAllDone)*100));
Error.Total = num2str(round(sum(ndxError)/SessionData.nTrials*100));
Error.FixBroke = num2str(round(sum(SessionData.Custom.FixBroke)/SessionData.nTrials*100));
Error.EWD  = num2str(round(sum(SessionData.Custom.EarlyWithdrawal)/SessionData.nTrials*100));
Error.SkippedFB  = num2str(round(sum(ndxSkippedFB)/sum(ndxAllDone)*100));
Error.SkippedPosFB  = num2str(round(sum((ndxSkippedFB&ndxCorrect&~ndxCatch))/sum(ndxCorrect&~ndxCatch)*100));
if SessionData.Settings.GUI.CatchError == 0
    Error.SkippedNegFB  = num2str(round(sum((ndxSkippedFB&ndxFalse))/sum(ndxFalse)*100));
else
    Error.SkippedNegFB  = num2str(round(sum(ndxFalse&SessionData.Custom.FeedbackTime<0.5)/sum(ndxFalse)*100));
end
Error.SkippedLeftFB  = num2str(round(sum((ndxSkippedFB&ndxLeft&ndxCorrect))/sum(ndxLeft&ndxCorrect)*100));
Error.SkippedRightFB  = num2str(round(sum((ndxSkippedFB&ndxRight&ndxCorrect))/sum(ndxRight&ndxCorrect)*100));

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
subplot(2,3,1); hold on;
yyaxis left
% ligne moyenne essais faux (mauvais port de reponse)
plot(Xplot,Pct_WS, 'LineStyle','-','Color','r','Visible','on','LineWidth',2); 
% ligne moyenne essais correct catch 
p=plot(Xplot,Pct_Error,'LineStyle','-','Color','k','Visible','on','LineWidth',2);
ylim([0 100]); 
p.Parent.YColor = [0 0 0];
ylabel('Percent of trials','fontsize',14);
if sum(ndxCatch)>10
    WT_Catch = []; clear Xplot i
    Xplot = 0:100:size(SessionData.Custom.ChoiceLeft,2);
    Nbbin = size(Xplot,2);
    for i=1:Nbbin
        debut = Xplot(i)+1; 
        if debut + 99 < size(SessionData.Custom.ChoiceLeft,2)
            fin = debut+99;
        else
            fin = size(SessionData.Custom.ChoiceLeft,2);
        end
        medWT = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch(debut:fin)));
        if ~isempty(medWT)
            WT_Catch = [WT_Catch medWT];
        else
           WT_Catch = [WT_Catch NaN]; 
        end
    end
    yyaxis right
    % ligne moyenne essais faux (mauvais port de reponse)
    plot(Xplot,WT_Catch, 'LineStyle','-','Color','m','Visible','on','LineWidth',2); 
    ylabel('Mean WT (s)','fontsize',14);
    % Legendes et axes
    legend('Wrong side ','Error ','Catch','Location','NorthEast');
    p.Parent.YColor = [0 0 0];
else
    % Legendes et axes
    legend('Wrong side ','Error ','Location','NorthEast');
    yyaxis right
    p.Parent.YColor = [1 1 1];
end
title({['Performance  ' SessionData.SessionDate];['WS = ' Error.WS '% /Error = ' Error.Total ' %']},'fontsize',12);    
xlabel('Trial number','fontsize',14);hold off;    

%%  Composition of the training session (2)

Biais = sum(ndxLeft&ndxCorrect)/sum(ndxCorrect);
Biais_Olf = sum(ndxLeft&ndxCorrect&SessionData.Custom.Modality==1)/sum(ndxCorrect&SessionData.Custom.Modality==1);
Biais_Aud = sum(ndxLeft&ndxCorrect&SessionData.Custom.Modality==2)/sum(ndxCorrect&SessionData.Custom.Modality==2);

% Figure distribution des essais de la session par Niveaux de difficulte par modalite
subplot(2,3,2); hold on;
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis left
    h=histogram(SessionData.Custom.DV(SessionData.Custom.Modality==1),'BinWidth',0.01,...
        'FaceColor','w','EdgeColor',[0.3 0.75 0.93]);hold on
% 	Nb_EWD_Olf = sum(SessionData.Custom.EarlyWithdrawal==1&SessionData.Custom.Modality==1);
%     Nb_MissedChoice_Olf = sum(SessionData.Custom.MissedChoice==1&SessionData.Custom.Modality==1);
%     Nb_SkippedFB_Olf = sum(SessionData.Custom.SkippedFeedback==1&SessionData.Custom.Modality==1);
    ylabel('Olfactory trial counts','fontsize',14);
end
if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis right
    histogram(SessionData.Custom.DVlog(SessionData.Custom.Modality==2),'BinWidth',0.01,...
       'FaceColor','w','EdgeColor',[1 0.5 0.2]);
%     Nb_EWD_Aud = sum(SessionData.Custom.EarlyWithdrawal==1&SessionData.Custom.Modality==2);
%     Nb_MissedChoice_Aud = sum(SessionData.Custom.MissedChoice==1&SessionData.Custom.Modality==2);
%     Nb_SkippedFB_Aud = sum(SessionData.Custom.SkippedFeedback==1&SessionData.Custom.Modality==2);
    ylabel('Auditory trial counts','fontsize',14);
end
xlim ([-1.05, 1.05]);

% Legendes et axes
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        legend('Olfactory trials','Auditory trials',...
            'Location','North');
    else
       legend('Olfactory trials',...
            'Location','North'); 
    end
else 
    legend('Auditory trials',...
        'Location','North');
end
title({'Trials DV';['Biais olf = ' num2str(Biais_Olf) ' /aud = ' num2str(Biais_Aud)]},'fontsize',12);    
xlabel('DV','fontsize',14);hold off;

%% Distribution des Reward Grace Delay de la session pour verif si grace delay suffisamment long (3)

% Recup des datas:
GraceDelay = SessionData.Custom.GracePeriod(~isnan(SessionData.Custom.GracePeriod));

% Figure:
subplot(2,3,3); hold on
h=histogram(GraceDelay,...
    'FaceColor','b','EdgeColor','b','BinWidth',0.01);
h.Parent.XAxis.FontSize = 10; h.Parent.YAxis.FontSize = 10;
if SessionData.DayvsWeek == 1
    SessionGD = SessionData.Settings.GUI.FeedbackDelayGrace;
    plot([SessionGD SessionGD],[0 max(h.Values)],'--r','LineWidth',1);
end
title('Distribution of grace period ','fontsize',12);
xlabel('Grace period (s)','fontsize',14);
ylabel('trial counts','fontsize',14);

clearvars -except SessionData f1 ndx* Error

%% Distribution des WT for left vs right side for correct catch trials (4)

if sum(ndxCatch)>10
    
    subplot(2,4,5); hold on;
    % Essais correct pointes a gauche
    C = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxCatch&ndxLeft),...
        'BinWidth',0.100); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    C.Parent.XAxis.FontSize = 10; C.Parent.YAxis.FontSize = 10;
    % Essais correct pointes a droite 
    D = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxCatch&ndxRight),...
        'FaceColor','k','EdgeColor','k','BinWidth',0.100); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)
    D.Parent.XAxis.FontSize = 10; D.Parent.YAxis.FontSize = 10;


    % Legendes et axes
    leg = legend('Left port','Right port',...
                'Location','NorthEast');
    leg.FontSize = 10; legend('boxoff');
    title({'Feedback delay';['Proba skip FB Left= ' Error.SkippedLeftFB '/Right= ' Error.SkippedRightFB ' %']},'fontsize',12);
    xlabel('Time (s)','fontsize',14);ylabel('correct catch trial counts','fontsize',14);hold off;
else
    %% Psyc Olfactory (1)
    if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1 
        [SessionData] = Psychometric_fig(SessionData, 1,2,4,5);  
    end
    %% Psyc Auditory (2)
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        [SessionData] = Psychometric_fig(SessionData, 2,2,4,5);
    end
end

clearvars -except SessionData f1 ndx* Error

%% Distribution des durees de sampling (RT) selon DV essais olfactifs corrects (5)

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % Recup des differents niveaux de difficultes
    ndxL = SessionData.Custom.TrialTypes==1| SessionData.Custom.TrialTypes==2;
    ndxM = SessionData.Custom.TrialTypes==3| SessionData.Custom.TrialTypes==4;
    ndxH = SessionData.Custom.TrialTypes==5| SessionData.Custom.TrialTypes==6;
    ndxF = SessionData.Custom.TrialTypes==7| SessionData.Custom.TrialTypes==8;

    % Recup pourcentage odeurs chaque niveau:
    Mix_L = unique(SessionData.Custom.OdorFracA(ndxL&~isnan(SessionData.Custom.OdorFracA)));
    Mix_M = unique(SessionData.Custom.OdorFracA(ndxM&~isnan(SessionData.Custom.OdorFracA)));
    Mix_H = unique(SessionData.Custom.OdorFracA(ndxH&~isnan(SessionData.Custom.OdorFracA)));
    Mix_F = unique(SessionData.Custom.OdorFracA(ndxF&~isnan(SessionData.Custom.OdorFracA)));

    % Figure distribution temps d'attente recompense essais recompense ou non
    subplot(2,4,6); hold on;
    % Essais FACILES
    A = histogram(SessionData.Custom.ST(ndxL&ndxCorrect)*1000,...
        'BinWidth',50); hold on; %'FaceColor','g','EdgeColor','g',
    JA = get(A,'child');
    set(JA,'FaceAlpha',0.2)
    % Essais INTERMEDIAIRES
    B = histogram(SessionData.Custom.ST(ndxM&ndxCorrect)*1000,...
        'BinWidth',50); hold on; %'FaceColor','y','EdgeColor','y',
    JB = get(B,'child');
    set(JB,'FaceAlpha',0.2)
    % Essais DIFFICILES
    C = histogram(SessionData.Custom.ST(ndxH&ndxCorrect)*1000,...
        'BinWidth',50); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    % Essais Fifty50
    D = histogram(SessionData.Custom.ST(ndxF&ndxCorrect)*1000,...
        'FaceColor','k','EdgeColor','k','BinWidth',50); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)

    % Legendes et axes
    legend([num2str(min(Mix_L)) '/' num2str(max(Mix_L))],...
        [num2str(min(Mix_M)) '/' num2str(max(Mix_M))],...
        [num2str(min(Mix_H)) '/' num2str(max(Mix_H))],...
        [num2str(min(Mix_F)) '/' num2str(max(Mix_F))],'Location','NorthEast');
    if sum(SessionData.Custom.EarlyWithdrawal)>0
        % Proba to withdraw early for each DV:
        EW_L = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxL)/sum(ndxL),2));
        EW_M = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxM)/sum(ndxM),2));
        EW_H = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxH)/sum(ndxH),2));
        EW_F = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxF)/sum(ndxF),2));

        title({'Reaction time correct trials';['Proba EWD ' num2str(min(Mix_L)) '/' num2str(max(Mix_L)) '=' EW_L '; ',...
            num2str(min(Mix_M)) '/' num2str(max(Mix_M)) '=' EW_M '; ',...
            num2str(min(Mix_H)) '/' num2str(max(Mix_H)) '=' EW_H '; ',...
            num2str(min(Mix_F)) '/' num2str(max(Mix_F)) '=' EW_F ]},'fontsize',12);
    else
        title('Reaction time','fontsize',12);
    end
    xlabel('Time (ms)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;
    
    clearvars -except SessionData f1 ndx* Error
end
%% Distribution des durees de sampling (RT) selon DV essais auditifs corrects (6)

% A IMPLEMENTER 

% if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
%     % Recup des differents niveaux de difficultes
%     ndxL = SessionData.Custom.TrialTypes==1| SessionData.Custom.TrialTypes==2;
%     ndxM = SessionData.Custom.TrialTypes==3| SessionData.Custom.TrialTypes==4;
%     ndxH = SessionData.Custom.TrialTypes==5| SessionData.Custom.TrialTypes==6;
%     ndxF = SessionData.Custom.TrialTypes==7| SessionData.Custom.TrialTypes==8;
% 
%     % Recup pourcentage odeurs chaque niveau:
%     Mix_L = unique(SessionData.Custom.OdorFracA(ndxL&~isnan(SessionData.Custom.OdorFracA)));
%     Mix_M = unique(SessionData.Custom.OdorFracA(ndxM&~isnan(SessionData.Custom.OdorFracA)));
%     Mix_H = unique(SessionData.Custom.OdorFracA(ndxH&~isnan(SessionData.Custom.OdorFracA)));
%     Mix_F = unique(SessionData.Custom.OdorFracA(ndxF&~isnan(SessionData.Custom.OdorFracA)));
% 
%     % Figure distribution temps d'attente recompense essais recompense ou non
%     subplot(2,4,7); hold on;
%     % Essais FACILES
%     A = histogram(SessionData.Custom.ST(ndxL&ndxCorrect)*1000,...
%         'BinWidth',50); hold on; %'FaceColor','g','EdgeColor','g',
%     JA = get(A,'child');
%     set(JA,'FaceAlpha',0.2)
%     % Essais INTERMEDIAIRES
%     B = histogram(SessionData.Custom.ST(ndxM&ndxCorrect)*1000,...
%         'BinWidth',50); hold on; %'FaceColor','y','EdgeColor','y',
%     JB = get(B,'child');
%     set(JB,'FaceAlpha',0.2)
%     % Essais DIFFICILES
%     C = histogram(SessionData.Custom.ST(ndxH&ndxCorrect)*1000,...
%         'BinWidth',50); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
%     JC = get(C,'child');
%     set(JC,'FaceAlpha',0.2)
%     % Essais Fifty50
%     D = histogram(SessionData.Custom.ST(ndxF&ndxCorrect)*1000,...
%         'FaceColor','k','EdgeColor','k','BinWidth',50); hold on; %
%     JD = get(D,'child');
%     set(JD,'FaceAlpha',0.2)
% 
%     % Legendes et axes
%     legend([num2str(min(Mix_L)) '/' num2str(max(Mix_L))],...
%         [num2str(min(Mix_M)) '/' num2str(max(Mix_M))],...
%         [num2str(min(Mix_H)) '/' num2str(max(Mix_H))],...
%         [num2str(min(Mix_F)) '/' num2str(max(Mix_F))],'Location','NorthEast');
%     if sum(SessionData.Custom.EarlyWithdrawal)>0
%         % Proba to withdraw early for each DV:
%         EW_L = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxL)/sum(ndxL),2));
%         EW_M = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxM)/sum(ndxM),2));
%         EW_H = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxH)/sum(ndxH),2));
%         EW_F = num2str(round(sum(SessionData.Custom.EarlyWithdrawal&ndxF)/sum(ndxF),2));
% 
%         title({'Reaction time correct trials';['Proba EWD ' num2str(min(Mix_L)) '/' num2str(max(Mix_L)) '=' EW_L '; ',...
%             num2str(min(Mix_M)) '/' num2str(max(Mix_M)) '=' EW_M '; ',...
%             num2str(min(Mix_H)) '/' num2str(max(Mix_H)) '=' EW_H '; ',...
%             num2str(min(Mix_F)) '/' num2str(max(Mix_F)) '=' EW_F ]},'fontsize',12);
%     else
%         title('Reaction time','fontsize',12);
%     end
%     xlabel('Time (ms)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;
% 
%     clearvars -except SessionData
% end

%% Distribution des WT for correct (rewarded, catched and skipped) vs error trials (7)

maxXlim = max(SessionData.Custom.FeedbackTime)*1.05;
if maxXlim>12
    maxXlim=12;
end

% Figure distribution temps d'attente recompense essais recompense ou non
subplot(2,4,8); hold on;
% Essais Correct Recompense
C = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&SessionData.Custom.Feedback),...
    'FaceColor','g','EdgeColor','g','BinWidth',0.1); hold on; %
C.FaceAlpha=0.3;
% Essais Faux 
D = histogram(SessionData.Custom.FeedbackTime(ndxFalse),...
    'FaceColor','m','EdgeColor','m','BinWidth',0.1); hold on; %
D.FaceAlpha=0.3;
% Essais Correct Skipped FB 
E = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial),...
    'FaceColor','c','EdgeColor','c','BinWidth',0.1); hold on; %
E.FaceAlpha=0.3;
% Essais Correct Catched
F = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&SessionData.Custom.CatchTrial),...
    'FaceColor','y','EdgeColor','y','BinWidth',0.1); hold on; %
F.FaceAlpha=0.3;
% Legendes et axes
legend(['Correct rewarded n= ' num2str(sum(ndxCorrect&SessionData.Custom.Feedback))],...
    ['WS n= ' num2str(sum(ndxFalse))],...
    ['Correct Skipped FB n= ' num2str(sum(ndxCorrect&~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial))],...
    ['Correct Catched n= ' num2str(sum(ndxCorrect&SessionData.Custom.CatchTrial))],...
        'Location','NorthEast');
title({'Feedback delay';['Proba skip FB Correct trials= ' Error.SkippedPosFB ' % / Wrong side trials= ' Error.SkippedNegFB ' %']},'fontsize',12);
xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);
xlim([0 maxXlim]);hold off;

clearvars -except SessionData f1 Error
