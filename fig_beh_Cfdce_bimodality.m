%% Panel figures analyses donnees comportement
%
% Psyc Olfactory (1)
% Psyc Auditory (2)
% Vevaiometric olfactory trials (3)
% Vevaiometric auditory trials (4)
% Distribution des WT correct vs wrong side trials for olfactory trials (5)
% Distribution des WT correct vs wrong side trials for auditory trials(6)
%  (7)
%  (8)
%

function f1=fig_beh_Cfdce_bimodality(SessionData)
%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);

%% Psyc Olfactory (1)

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1 
    [SessionData] = Psychometric_fig(SessionData, 1,2,4,1);  
end
%% Psyc Auditory (2)

if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    [SessionData] = Psychometric_fig(SessionData, 2,2,4,2);
end
%% Vevaiometric olfactory trials (3)
try
    Vevaiometric_fig(SessionData, 1,2,4,3);
end
%% Vevaiometric auditory trials (4)
try 
    Vevaiometric_fig(SessionData, 2,2,4,4);
end
%% Distribution des WT for correct vs error trials (5) --> Olfactory trials

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % id des essais
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0;
    ndxOlf = SessionData.Custom.Modality==1;
    %ndxAud = SessionData.Custom.Modality==2;

    % Recup datas à exclure de l'analyse:
    if SessionData.Settings.GUI.CatchError ==1
        ndxExclude = SessionData.Custom.ChoiceCorrect == 0; %exclude error trials if they are set on catch
    else
        ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
    end

    % Proba to skip the FB for each modality:
    OlfactorySkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&ndxOlf)/sum(~SessionData.Custom.CatchTrial&ndxOlf),2));

    % Figure distribution temps d'attente recompense essais recompense ou non
    subplot(2,4,5); hold on;

    % Essais Correct olfactif
    A = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxOlf),...
        'BinWidth',0.1); hold on; %'FaceColor','g','EdgeColor','g',
    JA = get(A,'child');
    set(JA,'FaceAlpha',0.2)
    % Essais Faux olfactif
    B = histogram(SessionData.Custom.FeedbackTime(ndxFalse&ndxOlf),...
        'BinWidth',0.1); hold on; %'FaceColor','y','EdgeColor','y',
    JB = get(B,'child');
    set(JB,'FaceAlpha',0.2)
    % Legendes et axes
    legend('Correct Olfactory','WS Olfactory',...
            'Location','NorthEast'); 
    title({'Feedback delay';['Proba skip FB Olfactory trials= ' OlfactorySkip ' %']},'fontsize',12);
    xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;
end

clearvars -except SessionData f1

%% Distribution des WT for correct vs error trials (6) --> Auditory trials

if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % id des essais
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0;
    ndxAud = SessionData.Custom.Modality==2;

    % Recup datas à exclure de l'analyse:
    if SessionData.Settings.GUI.CatchError ==1
        ndxExclude = SessionData.Custom.ChoiceCorrect == 0; %exclude error trials if they are set on catch
    else
        ndxExclude = false(1,size(SessionData.Custom.ChoiceLeft,2));
    end

    % Proba to skip the FB for each modality:
    AuditorySkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&~ndxExclude&ndxAud)/sum(~SessionData.Custom.CatchTrial&ndxAud),2));

    % Figure distribution temps d'attente recompense essais recompense ou non
    subplot(2,4,6); hold on;
    % Essais Correct Auditif
    C = histogram(SessionData.Custom.FeedbackTime(ndxCorrect&ndxAud),...
        'FaceColor',[0.3 0.3 0.3],'EdgeColor','k','BinWidth',0.1); hold on; %
    JC = get(C,'child');
    set(JC,'FaceAlpha',0.2)
    % Essais Faux Auditif
    D = histogram(SessionData.Custom.FeedbackTime(ndxFalse&ndxAud),...
        'FaceColor','m','EdgeColor','r','BinWidth',0.1); hold on; %
    JD = get(D,'child');
    set(JD,'FaceAlpha',0.2)
    % Legendes et axes
    legend('Correct Auditory','WS Auditory',...
            'Location','NorthEast');
end

title({'Feedback delay';['Proba skip FB Auditory trials= ' AuditorySkip ' %']},'fontsize',12);
xlabel('Time (s)','fontsize',14);ylabel('trial counts','fontsize',14);hold off;

clearvars -except SessionData f1

%% Mean/Median WT Correct catch and error for each modality

% --> A IMPLEMENTER



