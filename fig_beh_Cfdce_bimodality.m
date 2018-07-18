%% Plot confidence related behavioral analysis for both olfactory and auditory modalities 
%
% (1) Psyc Olfactory 
% (2) Psyc Auditory 
% (3) Vevaiometric olfactory trials 
% (4) Vevaiometric auditory trials 
% (5) Distribution of WT for correct vs incorrect (wrong side) trials for olfactory trials 
% (6) Distribution of WT fo correct vs incorrect (wrong side) trials for auditory trials
% (7)
% (8)
%

function f1=fig_beh_Cfdce_bimodality(SessionData)
%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);

%% (1) Psychometric curve Olfactory trials

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1 
    [SessionData] = Psychometric_fig(SessionData, 1,2,4,1);  
end
%% (2) Psychometric curve Auditory trials

if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    [SessionData] = Psychometric_fig(SessionData, 2,2,4,2);
end
%% (3) Vevaiometric curve olfactory trials 
try
    Vevaiometric_fig(SessionData, 1,2,4,3);
end
%% (4) Vevaiometric curve auditory trials 
try 
    Vevaiometric_fig(SessionData, 2,2,4,4);
end
%% (5) Distribution of WT for correct vs incorrect (wrong side) trials for olfactory trials 

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % id of trials 
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0;
    ndxOlf = SessionData.Custom.Modality==1;
    %ndxAud = SessionData.Custom.Modality==2;

    % Data to exclude from the analysis:
    if SessionData.Settings.GUI.CatchError ==1
        ndxExclude = SessionData.Custom.ChoiceCorrect == 0; % exclude error trials if they are set on catch
    else
        ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
    end

    % Proba to skip the FB for each modality:
    OlfactorySkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&ndxOlf)/sum(~SessionData.Custom.CatchTrial&ndxOlf),2));

    % Plot distribution WT trials rewarded or not 
    subplot(2,4,5); hold on;
    % Correct olfactory trials
    A = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxOlf),...
        'BinWidth',0.1); hold on; %'FaceColor','g','EdgeColor','g',
    JA = get(A,'child');
    set(JA,'FaceAlpha',0.2)
    % Incorrect olfactory trials
    B = histogram(SessionData.Custom.FeedbackTime(ndxFalse&ndxOlf),...
        'BinWidth',0.1); hold on; %'FaceColor','y','EdgeColor','y',
    JB = get(B,'child');
    set(JB,'FaceAlpha',0.2)
    % Legends et axis
    legend('Correct Olfactory','WS Olfactory',...
            'Location','NorthEast'); 
    title({'Feedback delay';['Proba skip FB Olfactory trials= ' OlfactorySkip ' %']},'fontsize',12);
    xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;
end

clearvars -except SessionData f1

%% (6) Distribution of WT for correct vs incorrect (wrong side) trials for auditory trials

if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % id of trials
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0;
    ndxAud = SessionData.Custom.Modality==2;

    % Data to exclude from the analysis:
    if SessionData.Settings.GUI.CatchError ==1
        ndxExclude = SessionData.Custom.ChoiceCorrect == 0; % exclude error trials if they are set on catch
    else
        ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
    end

    % Proba to skip the FB for each modality:
    AuditorySkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&ndxAud)/sum(~SessionData.Custom.CatchTrial&ndxAud),2));

    % Plot distribution WT trials rewarded or not 
    subplot(2,4,6); hold on;
    % Correct auditory trials
    C = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxAud),...
        'FaceColor',[0.3 0.3 0.3],'EdgeColor','k','BinWidth',0.1); hold on; %
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    % Incorrect auditory trials
    D = histogram(SessionData.Custom.FeedbackTime(ndxFalse&ndxAud),...
        'FaceColor','m','EdgeColor','r','BinWidth',0.1); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)
    % Legends et axis
    legend('Correct Auditory','WS Auditory',...
            'Location','NorthEast');
end

title({'Feedback delay';['Proba skip FB Auditory trials= ' AuditorySkip ' %']},'fontsize',12);
xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;

clearvars -except SessionData f1

%% Mean/Median WT Correct catch and error for each modality

% --> TO IMPLEMENT



