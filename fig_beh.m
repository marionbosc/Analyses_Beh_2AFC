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

function f1 = fig_beh(SessionData)
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
ndxError = SessionData.Custom.MissedChoice==1 | SessionData.Custom.EarlyWithdrawal==1 | SessionData.Custom.FixBroke==1; % Error = other beh mistake 
ndxCatch = SessionData.Custom.CatchTrial(1:end);
Pct_False = [];Pct_Error = [];    
for i=1:Nbbin
    debut = Xplot(i)+1; 
    if debut + 49 < size(SessionData.Custom.ChoiceLeft,2)
        fin = debut+49;
    else
        fin = size(SessionData.Custom.ChoiceLeft,2);
    end
    Pct_False = [Pct_False sum(ndxFalse(debut:fin))/sum(ndxAllDone(debut:fin))*100];
    Pct_Error = [Pct_Error sum(ndxError(debut:fin))/size(debut:fin,2)*100];
end

% Donnees moyenne:
Tot_False = num2str(sum(ndxFalse)/sum(ndxAllDone)*100);
Tot_Error = num2str(sum(ndxError)/sum(ndxAllDone)*100);

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
subplot(2,3,1); hold on;
yyaxis left
% ligne moyenne essais faux (mauvais port de reponse)
plot(Xplot,Pct_False, 'LineStyle','-','Color','r','Visible','on','LineWidth',2); 
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
title({['Performance  ' SessionData.SessionDate];['WS = ' Tot_False '% /Error = ' Tot_Error ' %']},'fontsize',12);    
xlabel('Trial number','fontsize',14);hold off;    

clear ndx* Tot*
%%  Composition of the training session (2)

Biais = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.ChoiceCorrect==1);
Biais_Olf = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==1)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==1);
Biais_Aud = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==2)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==2);

% Figure distribution des essais de la session par Niveaux de difficulte par modalite
subplot(2,3,2); hold on;
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis left
    h=histogram(SessionData.Custom.DV(SessionData.Custom.Modality==1),'BinWidth',0.01,...
        'FaceColor','w','EdgeColor',[0.3 0.75 0.93]);hold on
	Nb_EWD_Olf = sum(SessionData.Custom.EarlyWithdrawal==1&SessionData.Custom.Modality==1);
    Nb_MissedChoice_Olf = sum(SessionData.Custom.MissedChoice==1&SessionData.Custom.Modality==1);
    Nb_SkippedFB_Olf = sum(SessionData.Custom.SkippedFeedback==1&SessionData.Custom.Modality==1);
    ylabel('Olfactory trial counts','fontsize',14);
end
if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis right
    histogram(SessionData.Custom.DVlog(SessionData.Custom.Modality==2),'BinWidth',0.01,...
       'FaceColor','w','EdgeColor',[1 0.5 0.2]);
    Nb_EWD_Aud = sum(SessionData.Custom.EarlyWithdrawal==1&SessionData.Custom.Modality==2);
    Nb_MissedChoice_Aud = sum(SessionData.Custom.MissedChoice==1&SessionData.Custom.Modality==2);
    Nb_SkippedFB_Aud = sum(SessionData.Custom.SkippedFeedback==1&SessionData.Custom.Modality==2);
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

% Datas:
Nb_FixBroke = sum(SessionData.Custom.FixBroke==1);
Nb_EWD = sum(SessionData.Custom.EarlyWithdrawal==1);
Nb_MissedChoice = sum(SessionData.Custom.MissedChoice==1);
Nb_SkippedFB = sum(SessionData.Custom.SkippedFeedback==1);
Nb_CatchTrials= sum(SessionData.Custom.CatchTrial==1);
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

clearvars -except SessionData f1

%% Distribution des WT for left vs right side for correct catch trials (4)

% id des essais
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;
ndxLeft = SessionData.Custom.ChoiceLeft == 1;
ndxRight = SessionData.Custom.ChoiceLeft == 0;

if sum(ndxCatch)>10
    % Recup datas à exclure de l'analyse:
    if SessionData.Settings.GUI.CatchError ==1
        ndxExclude = SessionData.Custom.ChoiceCorrect == 0; %exclude error trials if they are set on catch
    else
        ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
    end

    % Proba to skip the FB for each side:
    LeftSkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==1)/sum(~SessionData.Custom.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==1)*100,2));
    RightSkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==0)/sum(~SessionData.Custom.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==0)*100,2));

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
    title({'Feedback delay';['Proba skip FB Left= ' LeftSkip '/Right= ' RightSkip ' %']},'fontsize',12);
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

clearvars -except SessionData f1

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
    A = histogram(SessionData.Custom.ST(ndxL&SessionData.Custom.ChoiceCorrect==1)*1000,...
        'BinWidth',50); hold on; %'FaceColor','g','EdgeColor','g',
    JA = get(A,'child');
    set(JA,'FaceAlpha',0.2)
    % Essais INTERMEDIAIRES
    B = histogram(SessionData.Custom.ST(ndxM&SessionData.Custom.ChoiceCorrect==1)*1000,...
        'BinWidth',50); hold on; %'FaceColor','y','EdgeColor','y',
    JB = get(B,'child');
    set(JB,'FaceAlpha',0.2)
    % Essais DIFFICILES
    C = histogram(SessionData.Custom.ST(ndxH&SessionData.Custom.ChoiceCorrect==1)*1000,...
        'BinWidth',50); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    % Essais Fifty50
    D = histogram(SessionData.Custom.ST(ndxF&SessionData.Custom.ChoiceCorrect==1)*1000,...
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
    
    clearvars -except SessionData f1
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
%     A = histogram(SessionData.Custom.ST(ndxL&SessionData.Custom.ChoiceCorrect==1)*1000,...
%         'BinWidth',50); hold on; %'FaceColor','g','EdgeColor','g',
%     JA = get(A,'child');
%     set(JA,'FaceAlpha',0.2)
%     % Essais INTERMEDIAIRES
%     B = histogram(SessionData.Custom.ST(ndxM&SessionData.Custom.ChoiceCorrect==1)*1000,...
%         'BinWidth',50); hold on; %'FaceColor','y','EdgeColor','y',
%     JB = get(B,'child');
%     set(JB,'FaceAlpha',0.2)
%     % Essais DIFFICILES
%     C = histogram(SessionData.Custom.ST(ndxH&SessionData.Custom.ChoiceCorrect==1)*1000,...
%         'BinWidth',50); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
%     JC = get(C,'child');
%     set(JC,'FaceAlpha',0.2)
%     % Essais Fifty50
%     D = histogram(SessionData.Custom.ST(ndxF&SessionData.Custom.ChoiceCorrect==1)*1000,...
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

% id des essais
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;

maxXlim = max(SessionData.Custom.FeedbackTime)*1.05;
if maxXlim>12
    maxXlim=12;
end

% Recup datas à exclure de l'analyse:
if SessionData.Settings.GUI.CatchError ==0
    ndxExclude = SessionData.Custom.ChoiceCorrect == 0; % exclude error trials if they are not set on catch
else
    ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
end

% Proba to skip the FB for correct trials and error trials:
CorrectSkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&ndxCorrect)...
    /sum(~SessionData.Custom.CatchTrial&~ndxExclude&ndxCorrect),2)*100);
ErrorSkip = num2str(round(sum(SessionData.Custom.FeedbackTime<0.5&~ndxExclude&ndxFalse)...
    /sum(~SessionData.Custom.CatchTrial&~ndxExclude&ndxFalse),2)*100);

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
title({'Feedback delay';['Proba skip FB Correct trials= ' CorrectSkip ' % / Wrong side trials= ' ErrorSkip ' %']},'fontsize',12);
xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);
xlim([0 maxXlim]);hold off;

clearvars -except SessionData f1
