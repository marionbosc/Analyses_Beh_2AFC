%% Plots to get an overview of the behavioral training session
%
% (1)  - Accuracy: percent of incorrect (wrong side) and execution-error
% trials along the training session (left axis)
%      - Catch trials WT along the training session for correct and incorrect trials (right axis)
% (2) Distribution of trials per Decision Variable (left right + difficulty of the discrimination) 
% (3) Distribution of trials per Grace period duration
% (4)  - Psychometric curve 
%      or (depending if the session contained Catch trials)
%      - Distribution des WT for each response port (left vs right)
% (5)  - Distribution of sampling duration for each DV of correct olfactory trials 
%      or
%      - Distribution of sampling duration for each DV of correct auditory trials --> not implemented yet...
%      or
%      - Distribution of correct and error catched trial WT if SessionDataWeek
% (6) Distribution of WT for correct (rewarded, skipped and catch) and error trials 
%

function [f1,Error] = fig_beh(SessionData,normornot)
%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);

% Default: use of raw FeedbackTime data
WTdata = 'FeedbackTime';
XLABEL = 'Waiting Time (s)';
% if use of normalized FeedbackTime data
if exist('normornot','var') && normornot==1 && isfield(SessionData.Custom,'FeedbackTimeNorm')
    WTdata = 'FeedbackTimeNorm';
    XLABEL = 'Normalized WT (s)';
end
%% (1) Accuracy and Catch trial WT during session 

%%%
% Slot duration and sliding window
Slot_duration_in_trial = 30;
Nbtrial_btw_sliding_slot = Slot_duration_in_trial/2;

% Empty array to collect data per time slot
Pct_WS = [];Pct_Error = []; Xplot=[];

% Trials index and percent of WS (wrong side or incorrect response) and Error
ndxAllDone = SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxFalse = SessionData.Custom.ChoiceCorrect==0; % False = wrong response port
ndxError = isnan(SessionData.Custom.ChoiceCorrect); % Error = other beh mistake 
ndxCatch = SessionData.Custom.CatchTrial& ~isnan(SessionData.Custom.FeedbackTime);
ndxLeft = SessionData.Custom.ChoiceLeft == 1;
ndxRight = SessionData.Custom.ChoiceLeft == 0;
ndxSkippedFB = SessionData.Custom.SkippedFeedback;

% Main loop to gather data per time point with a sliding window
bin = 1; lasttrial=max(SessionData.Custom.TrialNumber);
while bin > 0 % bin = 0 when all the trials have been elapsed (and the session is done)
    if bin == 1 % First bin
        id_debut = 1; id_fin = min(Slot_duration_in_trial,lasttrial);
        bin=2; % after the first bin
    else
        id_debut = min(id_debut+Nbtrial_btw_sliding_slot,lasttrial); id_fin =  min(id_fin + Nbtrial_btw_sliding_slot, lasttrial);   
    end
    
    % Xaxis:
    Xplot = [Xplot id_debut+Nbtrial_btw_sliding_slot];
    
    % Quantification of the performance during the time slot
    if id_fin-id_debut>5 || bin>1
        Pct_WS = [Pct_WS sum(ndxFalse(id_debut:id_fin))/sum(ndxAllDone(id_debut:id_fin))*100];
        Pct_Error = [Pct_Error sum(ndxError(id_debut:id_fin))/size(id_debut:id_fin,2)*100];        
    else
        Pct_WS = [Pct_WS NaN]; Pct_Error = [Pct_Error NaN]; % if not enough trials --> no datapoint
    end

     if id_fin == lasttrial %  if the bin is not the last one, the window keep sliding
        bin = 0;
     end 
end

% Percent for the session:
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

% Plot 
subplot(2,3,1); hold on;
% left axis
yyaxis left
% Plot for incorrect trials
plot(Xplot,smooth(Pct_WS), 'LineStyle','-','Color','r','Visible','on','LineWidth',1); 
% Plot for Error trials
p=plot(Xplot,smooth(Pct_Error),'LineStyle','-','Color','k','Visible','on','LineWidth',1);
ylim([0 100]); xlim([1 lasttrial]);
p.Parent.YColor = [0 0 0];
ylabel('Percent of trials','fontsize',14);
% right axis (case more than 10 catch trials during the session only)
if sum(ndxCatch)>10
    WT_Catch_Correct = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxCatch & ndxCorrect);
    WT_Catch_incorrect = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxFalse);
    clear Xplot i    
    yyaxis right
    % Catch correct WT
    plot(find(ndxCatch & ndxCorrect),WT_Catch_Correct,'+g', 'LineStyle','none','Visible','on','LineWidth',1); 
    % Catch incorrect WT
    plot(find(ndxFalse),WT_Catch_incorrect,'+r', 'LineStyle','none','Visible','on','LineWidth',1); 
    ylabel('WT (s)','fontsize',14);
    % Legends et axis
    legend('Wrong side ','Error ','Catch Correct', 'Catch Wrong side','Location','NorthWest');
    p.Parent.YColor = [0 0 0]; ylim([0 max([WT_Catch_Correct WT_Catch_incorrect])+1]);
else
    % Legends et axis without Catch trials
    legend('Wrong side ','Error ','Location','NorthWest');
    yyaxis right
    p.Parent.YColor = [1 1 1];
end
title({['Accuracy  ' SessionData.SessionDate];['WS = ' Error.WS '% /Error = ' Error.Total ' %']},'fontsize',12);    
xlabel('Trial number','fontsize',14);legend('boxoff');hold off;    

%% (2) Distribution of trials per Decision Variable
% Bias index during session per sensory modality and overall
Bias = sum(ndxLeft&ndxCorrect)/sum(ndxCorrect);
Bias_Olf = sum(ndxLeft&ndxCorrect&SessionData.Custom.Modality==1)/sum(ndxCorrect&SessionData.Custom.Modality==1);
Bias_Aud = sum(ndxLeft&ndxCorrect&SessionData.Custom.Modality==2)/sum(ndxCorrect&SessionData.Custom.Modality==2);

% Plot
subplot(2,3,2); hold on;
% Case more than 10% of olfactory trials
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis left
    h=histogram(SessionData.Custom.DV(SessionData.Custom.Modality==1),'BinWidth',0.01,...
        'FaceColor','w','EdgeColor',[0.3 0.75 0.93]);hold on
    ylabel('Olfactory trial counts','fontsize',14);
end
% Case more than 10% of auditory trials
if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    yyaxis right
    h2 = histogram(SessionData.Custom.DV(SessionData.Custom.Modality==2),'BinWidth',0.01,...
       'FaceColor','w','EdgeColor',[1 0.5 0.2]);
    ylabel('Auditory trial counts','fontsize',14);
end
% Case Larkum brightness task
if sum(SessionData.Custom.Modality==4)>10
    yyaxis right
    h2 = histogram(SessionData.Custom.DV(SessionData.Custom.Modality==4),'BinWidth',0.01,...
       'FaceColor','w','EdgeColor',[1 0.5 0.2]);
    ylabel('Brightness trial counts','fontsize',14);
end

xlim ([h2.BinLimits(1)-0.05,h2.BinLimits(2)+0.05]);

% Legends et axis
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        legend('Olfactory trials','Auditory trials',...
            'Location','North');
    else
       legend('Olfactory trials',...
            'Location','North'); 
    end
elseif  sum(SessionData.Custom.Modality==2) == size(SessionData.Custom.Modality,2)
    legend('Auditory trials',...
        'Location','North');
elseif sum(SessionData.Custom.Modality==4) == size(SessionData.Custom.Modality,2)
    legend('Visual trials',...
        'Location','North');
end
title({'Trials DV';['Bias = ' num2str(Bias)]},'fontsize',12); % olf = ' num2str(Biasopen _Olf) ' /
xlabel('DV','fontsize',14);hold off;

%% (3) Distribution of trials per Grace period duration

% Data retrieval:
GraceDelay = SessionData.Custom.GracePeriod(~isnan(SessionData.Custom.GracePeriod));

% Plot:
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

clearvars -except SessionData f1 ndx* Error WTdata XLABEL

%% (4) Distribution des WT for each response port (left vs right)

% Case Confidence session containing Catch trials 
if sum(ndxCatch)>10    
    subplot(2,4,5); hold on;
    % Correct trials on the left side
    C = histogram(SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxCorrect&ndxCatch&ndxLeft),...
        'BinWidth',0.500); hold on; 
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    C.Parent.XAxis.FontSize = 10; C.Parent.YAxis.FontSize = 10;
    % orrect trials on the right side 
    D = histogram(SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxCorrect&ndxCatch&ndxRight),...
        'FaceColor','k','EdgeColor','k','BinWidth',0.500); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)
    D.Parent.XAxis.FontSize = 10; D.Parent.YAxis.FontSize = 10;

    % Legends et axis
    leg = legend('Left port','Right port',...
                'Location','NorthEast');
    leg.FontSize = 10; legend('boxoff');
    title({'Feedback delay';['Proba skip FB Left= ' Error.SkippedLeftFB '/Right= ' Error.SkippedRightFB ' %']},'fontsize',12);
    xlabel(XLABEL,'fontsize',14);ylabel('correct catch trial counts','fontsize',14);hold off;
else
    %% (4) Psyc Olfactory 
    if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1 
        [SessionData] = Psychometric_fig(SessionData, 1,2,4,5);  
    end
    %% (4) Psyc Auditory 
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        if isfield(SessionData.Custom, 'ForcedLEDTrial')
            if sum(SessionData.Custom.ForcedLEDTrial)>10
                [SessionData] = Psychometric_fig_ForcedvsChoice(SessionData, 2,2,4,5);
            else
                [SessionData] = Psychometric_fig(SessionData, 2,2,4,5);
            end
        else
            [SessionData] = Psychometric_fig(SessionData, 2,2,4,5);
        end
    end
    %% (4) Psyc Brightness 
    if sum(SessionData.Custom.Modality==4) == size(SessionData.Custom.Modality,2)
        [SessionData] = Psychometric_fig(SessionData, 4,2,4,5);  
    end    

end

clearvars -except SessionData f1 ndx* Error  WTdata XLABEL
%% (5) Distribution of sampling duration for each DV of correct olfactory trials 

% Case more than 10% olfactory trials
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % Index of trials for all difficulty levels
    ndxL = SessionData.Custom.TrialTypes==1| SessionData.Custom.TrialTypes==2;
    ndxM = SessionData.Custom.TrialTypes==3| SessionData.Custom.TrialTypes==4;
    ndxH = SessionData.Custom.TrialTypes==5| SessionData.Custom.TrialTypes==6;
    ndxF = SessionData.Custom.TrialTypes==7| SessionData.Custom.TrialTypes==8;

    % Fraction of Odor A for each difficulty level:
    Mix_L = unique(SessionData.Custom.OdorFracA(ndxL&~isnan(SessionData.Custom.OdorFracA)));
    Mix_M = unique(SessionData.Custom.OdorFracA(ndxM&~isnan(SessionData.Custom.OdorFracA)));
    Mix_H = unique(SessionData.Custom.OdorFracA(ndxH&~isnan(SessionData.Custom.OdorFracA)));
    Mix_F = unique(SessionData.Custom.OdorFracA(ndxF&~isnan(SessionData.Custom.OdorFracA)));

    % Plot
    subplot(2,4,6); hold on;
    % Easy trials
    A = histogram(SessionData.Custom.ST(ndxL&ndxCorrect)*1000,...
        'BinWidth',50); hold on; 
    JA = get(A,'child');
    set(JA,'FaceAlpha',0.2)
    % Medium trials
    B = histogram(SessionData.Custom.ST(ndxM&ndxCorrect)*1000,...
        'BinWidth',50); hold on; 
    JB = get(B,'child');
    set(JB,'FaceAlpha',0.2)
    % Hard trials
    C = histogram(SessionData.Custom.ST(ndxH&ndxCorrect)*1000,...
        'BinWidth',50); hold on; 
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    % Fifty50 trials
    D = histogram(SessionData.Custom.ST(ndxF&ndxCorrect)*1000,...
        'FaceColor','k','EdgeColor','k','BinWidth',50); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)

    % Legends et axis
    legend([num2str(min(Mix_L)) '/' num2str(max(Mix_L))],...
        [num2str(min(Mix_M)) '/' num2str(max(Mix_M))],...
        [num2str(min(Mix_H)) '/' num2str(max(Mix_H))],...
        [num2str(min(Mix_F)) '/' num2str(max(Mix_F))],'Location','NorthEast');
    if sum(SessionData.Custom.EarlyWithdrawal)>0
        % Proba to EWD for each DV:
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
    
    clearvars -except SessionData f1 ndx* Error  WTdata XLABEL
    
    %% Distribution of correct and error catched trial WT if SessionDataWeek
elseif SessionData.DayvsWeek ==2 && SessionData.Settings.GUI.CatchError == 1
    subplot(2,3,5);hold on
    ndxCatched = SessionData.Custom.ChoiceCorrect==0 & SessionData.Custom.FeedbackTime<19;
    if sum(ndxCatched)>20
        D =histogram(SessionData.Custom.FeedbackTime(ndxCatched),'BinWidth',0.2,...
            'FaceColor','r','EdgeColor','r');
        JD = get(D,'child'); set(JD,'FaceAlpha',0.2)
        leg{1} = 'Error trials';
    end
    clear ndxCatched
    ndxCatched = SessionData.Custom.ChoiceCorrect==1 & SessionData.Custom.CatchTrial ...
        & SessionData.Custom.FeedbackTime<19;
    if sum(ndxCatched)>20
        E =histogram(SessionData.Custom.FeedbackTime(ndxCatched),'BinWidth',0.2,...
            'FaceColor','g','EdgeColor','g');
        JE = get(E,'child'); set(JE,'FaceAlpha',0.2)
        leg{2} = 'Correct trials';
    end
    ylabel('Trials count','fontsize',16); xlabel('WT (s)','fontsize',16);
    title('Catched trial WT','fontsize',14); legend(leg,'Location','NorthEast');
end
%% (6) Distribution of sampling duration for each DV of correct auditory trials 

% TO IMPLEMENT

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

%% (6) Distribution of WT for correct (rewarded, skipped and catch) and error trials

% Maximum limit of X axis
maxXlim = max(SessionData.Custom.FeedbackTime)*1.05;
if maxXlim>12
    maxXlim=12;
end

% Plot
subplot(2,4,8); hold on;
% Correct rewarded trials
C = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&SessionData.Custom.Feedback),...
    'FaceColor','g','EdgeColor','g','BinWidth',0.1); hold on; %
C.FaceAlpha=0.3;
% Incorrect trials
D = histogram(SessionData.Custom.FeedbackTime(ndxFalse),...
    'FaceColor','m','EdgeColor','m','BinWidth',0.1); hold on; %
D.FaceAlpha=0.3;
% Correct skipped FB (not catched) 
E = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial),...
    'FaceColor','c','EdgeColor','c','BinWidth',0.1); hold on; %
E.FaceAlpha=0.3;
% Correct catch trials
F = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&SessionData.Custom.CatchTrial),...
    'FaceColor','y','EdgeColor','y','BinWidth',0.1); hold on; %
F.FaceAlpha=0.3;
% Legends et axis
legend(['Correct rewarded n= ' num2str(sum(ndxCorrect&SessionData.Custom.Feedback))],...
    ['WS n= ' num2str(sum(ndxFalse))],...
    ['Correct Skipped FB n= ' num2str(sum(ndxCorrect&~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial))],...
    ['Correct Catched n= ' num2str(sum(ndxCorrect&SessionData.Custom.CatchTrial))],...
        'Location','NorthEast');
title({'Feedback delay';['Proba skip FB Correct trials= ' Error.SkippedPosFB ' % / Wrong side trials= ' Error.SkippedNegFB ' %']},'fontsize',12);
xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);
xlim([0 maxXlim]);hold off;

clearvars -except SessionData f1 Error
