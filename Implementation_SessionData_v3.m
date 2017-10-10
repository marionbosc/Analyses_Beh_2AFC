%% Script analyses datas comportement rig de Paul (Dual2AFCv3)
%
% Adaptation du codes de Torben et Thiago aux donnees de Paul
%
%
% - Courbe vevaiometriques pour essais correct catch et erreur (catch)
%
%
%
%
%
%
%% Test si jour de manip deja analysee existe

% Recup nom animal et date
Date = datestr(SessionData.starttime,'yymmdd');
Nom = SessionData.animal;

% Chemin vers donnees implementees
path_analyses = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFCv3/Analyses/Datas_implemented';
if exist([path_analyses '/' Nom],'dir')==7 % verifie si dossier animal existe
    cd([path_analyses '/' Nom]);
else
    mkdir(path_analyses,Nom); % cree dossier animal
    cd([path_analyses '/' Nom]);
end
    

if exist(['SessionData_' Nom '_' Date '.mat'],'file')==0
%% Calcul des variables manquantes pour chaque essai et implementation de la structure SessionData

    for iTrial = 1 : SessionData.nTrials  
        %% Standard values
        SessionData.Custom.ChoiceLeft(iTrial) = NaN;
        SessionData.Custom.ChoiceCorrect(iTrial) = NaN;
        SessionData.Custom.Feedback(iTrial) = true;
        SessionData.Custom.FeedbackTime(iTrial) = NaN;
        SessionData.Custom.FixBroke(iTrial) = false;
        SessionData.Custom.EarlyWithdrawal(iTrial) = false;
        SessionData.Custom.MissedChoice(iTrial) = false;
        SessionData.Custom.FixDur(iTrial) = NaN;
        SessionData.Custom.MT(iTrial) = NaN;
        SessionData.Custom.ST(iTrial) = NaN;
        SessionData.Custom.StimulusDuration(iTrial) = NaN;
        SessionData.Custom.Rewarded(iTrial) = false;
        SessionData.Custom.TrialNumber(iTrial) = iTrial;
        statesThisTrial = SessionData.RawData.OriginalStateNamesByNumber{iTrial}(SessionData.RawData.OriginalStateData{iTrial});

        % Temps d'attente avant debut stimulus
        if any(strcmp('Delay',statesThisTrial))
            SessionData.Custom.FixDur(iTrial) = diff(SessionData.RawEvents.Trial{iTrial}.States.Delay);
        end

        % Temps de réaction = ST (temps durant lequel l'animal a echantillonne le stimulus)
        if any(strcmp('DeliverStimulus',statesThisTrial))
            if any(strcmp('StillSampling',statesThisTrial))
                SessionData.Custom.ST(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.WaitForResponse(1,2) - SessionData.RawEvents.Trial{iTrial}.States.DeliverStimulus(1,1);
                SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.StillSampling(1,2) - SessionData.RawEvents.Trial{iTrial}.States.DeliverStimulus(1,1);
            else
                SessionData.Custom.ST(iTrial) = diff(SessionData.RawEvents.Trial{iTrial}.States.DeliverStimulus);
            end
        end

        % Temps de mouvement = MT
        if any(strcmp('WaitForResponse',statesThisTrial))
            SessionData.Custom.MT(iTrial) = diff(SessionData.RawEvents.Trial{iTrial}.States.WaitForResponse);
        end

        % Performance = ChoiceCorrect, duree attente FB = FeedbackTime et
        % erreur = FixBroke/EarlyWithdrawal
        if any(strcmp('WaitForReward',statesThisTrial)) %  Essai correct
            SessionData.Custom.ChoiceCorrect(iTrial) = 1;
            FeedbackPortTimes = SessionData.RawEvents.Trial{iTrial}.States.WaitForReward;
            SessionData.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
        elseif any(strcmp('Punish',statesThisTrial)) % Essais incorrect
            SessionData.Custom.ChoiceCorrect(iTrial) = 0;
            FeedbackPortTimes = SessionData.RawEvents.Trial{iTrial}.States.StillWaiting;
            SessionData.Custom.FeedbackTime(iTrial) = FeedbackPortTimes(end,end)-FeedbackPortTimes(1,1);
        elseif any(strcmp('EarlyWithdrawal',statesThisTrial))
            SessionData.Custom.FixBroke(iTrial) = true;
        elseif any(strcmp('EarlyWithdrawalKill',statesThisTrial))
            SessionData.Custom.EarlyWithdrawal(iTrial) = true;
        end

        % essai missed_choice
        if any(strcmp('WaitForResponse',statesThisTrial))
            if ~any(strcmp('WaitForRewardStart',statesThisTrial))
                if ~any(strcmp('PunishStart',statesThisTrial))
                    SessionData.Custom.Feedback(iTrial) = false;
                    SessionData.Custom.MissedChoice(iTrial) = true;
                end
            end
        end

        % Feedback reçu = Feedback
        if any(strcmp('EndWait',statesThisTrial))
            SessionData.Custom.Feedback(iTrial) = false;
        end

        % Reward reçu = Rewarded
        if any(strcmp('Reward',statesThisTrial))
            SessionData.Custom.Rewarded(iTrial) = true;
        end

        % Port de reponse G selectionne = ChoiceLeft
        if SessionData.ChosenDirection(iTrial)==1
            SessionData.Custom.ChoiceLeft(iTrial) = 1;
        elseif SessionData.ChosenDirection(iTrial)==2
            SessionData.Custom.ChoiceLeft(iTrial) = 0;
        end

        % Niveau de difficulté de l'essai = DV
        if SessionData.Modality(iTrial) ==1 % essai olfactif
            SessionData.Custom.DV(iTrial) = (2 * SessionData.TrialOdor(iTrial) -100)/100;
        elseif SessionData.Modality(iTrial) ==2 % essai auditif
            SessionData.Custom.DV(iTrial) = (SessionData.NLeftClicks(iTrial) - SessionData.NRightClicks(iTrial))/ (SessionData.NLeftClicks(iTrial) + SessionData.NRightClicks(iTrial));
        end
    end
    
    % Enregistrement des datas implementees
    save(['SessionData_' Nom '_' Date '.mat'],'SessionData');

else
    load(['SessionData_' Nom '_' Date '.mat']);
end

%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);

%% Psyc Olfactory (1)

% Recup datas
OdorFracA = SessionData.TrialOdor(1:SessionData.nTrials);
ndxOlf = SessionData.Modality==1; 

if isfield(SessionData.Custom,'BlockNumber')
    BlockNumber = SessionData.Custom.BlockNumber;
else
    BlockNumber = ones(SessionData.nTrials);
    SessionData.Custom.BlockNumber = BlockNumber;
end

setBlocks = reshape(unique(BlockNumber),1,[]); % STOPPED HERE
ndxNan = isnan(SessionData.Custom.ChoiceLeft);
            
for iBlock = setBlocks(end)
    ndxBlock = SessionData.Custom.BlockNumber(1:numel(SessionData.Custom.ChoiceLeft)) == iBlock;
    if any(ndxBlock)
        setStim = reshape(unique(OdorFracA(ndxBlock)),1,[]);
        psyc = nan(size(setStim));
        for iStim = setStim
            ndxStim = reshape(OdorFracA == iStim,1,[]);
            psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndxStim&~ndxNan&ndxBlock&ndxOlf))/...
                sum(ndxStim&~ndxNan&ndxBlock&ndxOlf);
        end
        PsycOlf(iBlock).XData = setStim;
        PsycOlf(iBlock).YData = psyc;
        PsycOlfFit(iBlock).XData = linspace(min(setStim),max(setStim),100);
        if sum(OdorFracA(ndxBlock&ndxOlf))>0
            PsycOlfFit(iBlock).YData = glmval(glmfit(OdorFracA(ndxBlock&ndxOlf),...
                SessionData.Custom.ChoiceLeft(ndxBlock&ndxOlf)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
        end
    end
end

                
% Figure perf olfaction: f(% Odor A)= % left
subplot(2,4,1); hold on;% f1=figure('units','normalized','position',[0,0,0.5,0.7]); hold on;
% Points perf/DV
plot(PsycOlf.XData,PsycOlf.YData, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','on');
% Courbe fittee donnees perf  
plot(PsycOlfFit.XData,PsycOlfFit.YData,'color','k','Visible','on');

% Legendes et axes
ylim([-.05 1.05]);xlim (100*[-.05 1.05]);
title(['Psychometric Olf  ' SessionData.animal '  ' Date],'fontsize',15);
xlabel('% odor A','fontsize',16);ylabel('% left','fontsize',16);hold off;

clear ndx* Psyc* Odor* 
% % Paul's version
% for i=1:8
%     if i ~= 4  || i ~= 5
%         Index(i,:)=SessionData.TrialOdor==SessionData.OdorRatio(i) & SessionData.Modality==1 & SessionData.SampledTrial==1;
%         Yolf(i)=sum(SessionData.ChosenDirection(Index(i,:)==1)==2)/sum(SessionData.ChosenDirection(Index(i,:)==1)~=3);
%         YolfErr(i)=1.96*sqrt(Yolf(i)*(1-Yolf(i))/sum(SessionData.ChosenDirection(Index(i,:)==1)~=3));
%     elseif i == 4
%         %i=4 
%         Index(i,:)=(SessionData.TrialOdor==Data.OdorRatio(i) | SessionData.TrialOdor==SessionData.OdorRatio(i+1)) & SessionData.Modality==1 & SessionData.SampledTrial==1;
%         Yolf(i)=sum(SessionData.ChosenDirection(Index(i,:)==1)==2)/sum(SessionData.ChosenDirection(Index(i,:)==1)~=3);
%         YolfErr(i)=1.96*sqrt(Yolf(i)*(1-Yolf(i))/sum(SessionData.ChosenDirection(Index(i,:)==1)~=3));
%     end
% end
% Yolf(5)=[];
% YolfErr(5)=[];
% errorbar(SessionData.OdorRatio([8,7,6,4,3,2,1]),Yolf,YolfErr,'-k','LineWidth',2)
% hold on 
% plot([50 50],[0 1],'-k')
% plot([0 100],[0.5 0.5],'-k')
% ylim([-.05 1.05]);xlim (100*[-.05 1.05]); %ylim([0 1])
% xlabel('Odor Ratio','fontsize',16);ylabel('P(Choose right)','fontsize',16);
% title(['Psychometric Olf      ' SessionData.animal '   ' SessionData.starttime],'fontsize',20);
% hold off;
%% Psyc Auditory (2)

AudDV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
ndxAud = SessionData.Modality==2;
ndxNan = isnan(SessionData.Custom.ChoiceLeft);
AudBin = 8;
BinIdx = discretize(AudDV,linspace(-1,1,AudBin+1));
PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*2-1-1/AudBin;
PsycAud.YData = PsycY;
PsycAud.XData = PsycX;
if sum(ndxAud&~ndxNan) > 1
    PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
    PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
        SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
end

% Figure perf audition: f(beta)= % left
subplot(2,4,2); hold on;
% points Perf/DV
plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k',...
    'MarkerSize',6,'Visible','on');
% Courbe fittee donnees perf 
plot(PsycAudFit.XData,PsycAudFit.YData,'color','k','Visible','on');
% Legendes et axes
ylim([-.05 1.05]);xlim ([-1.05, 1.05]);
title(['Psychometric Aud  ' SessionData.animal],'fontsize',15);
xlabel('beta','fontsize',16);ylabel('% left','fontsize',16);hold off;

clear ndx* Psyc* Aud*
%% Vevaiometric olfactory trials (3)

% Paramètres de la figure:
VevaiometricMinWT = 2; % FB time minimum pris en compte dans analyse WT
VevaiometricNBin = 8; % nb de bin de valeur DV
    
% Calcul/formatage des donnees
ndxOlf = SessionData.Modality(1:end) == 1 ; % Essais stimulus olfactif
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; %all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; %only correct catch trials
ndxMinWT = SessionData.Custom.FeedbackTime > VevaiometricMinWT;
DV = SessionData.Custom.DV(1:end);
DVNBin = VevaiometricNBin;
BinIdx = discretize(DV,linspace(-1,1,DVNBin+1)); % transfo valeur DV en valeur discrete comprise entre -1 et 1
WTerr = grpstats(SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxOlf),BinIdx(ndxError&ndxMinWT&ndxOlf),'mean')'; % calcul du WT moyen par bin de DV
WTcatch = grpstats(SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxOlf),BinIdx(ndxCorrectCatch&ndxMinWT&ndxOlf),'mean')';
Xerr = unique(BinIdx(ndxError&ndxMinWT&ndxOlf))/DVNBin*2-1-1/DVNBin; % normalise DV entre -1 et +1?
Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT&ndxOlf))/DVNBin*2-1-1/DVNBin; % normalise DV entre -1 et +1?

% Recup data a ploter:
VevaiometricErr.YData = WTerr;
VevaiometricErr.XData = Xerr;
VevaiometricCatch.YData = WTcatch;
VevaiometricCatch.XData = Xcatch;
VevaiometricPointsErr.YData = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxOlf);
VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT&ndxOlf);
VevaiometricPointsCatch.YData = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxOlf);
VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT&ndxOlf);

% Figure vevaiometric f(DV)=WT
subplot(2,4,3); hold on;
% ligne moyenne essais erreur (catch)
plot(VevaiometricErr.XData,VevaiometricErr.YData, 'LineStyle','-','Color','r','Visible','on','LineWidth',2); 
% ligne moyenne essais correct catch 
plot(VevaiometricCatch.XData,VevaiometricCatch.YData,'LineStyle','-','Color','g','Visible','on','LineWidth',2);
% points essais erreur (catch)
plot(VevaiometricPointsErr.XData,VevaiometricPointsErr.YData,'LineStyle','none','Color','r',...
    'Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','on','MarkerEdgeColor','r'); 
% points essais correct catch
plot(VevaiometricPointsCatch.XData,VevaiometricPointsCatch.YData,'LineStyle','none','Color','g',...
    'Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','on','MarkerEdgeColor','g'); 
% Legendes et axes
legend(['Error n = ',num2str(size(VevaiometricPointsErr.YData,2))],['Catch n = ',num2str(size(VevaiometricPointsCatch.YData,2))],'Location','SouthWest');
ylim([0 10]);xlim ([-1.05, 1.05]);
title(['Vevaiometric olfactory trials ' SessionData.animal],'fontsize',15);
xlabel('DV','fontsize',16);ylabel('WT (s)','fontsize',16);hold off;

clear Vevaiometric* WT* X* ndx*
%% Vevaiometric auditory trials (4)

% Paramètres de la figure:
VevaiometricMinWT = 2; % FB time minimum pris en compte dans analyse WT
VevaiometricNBin = 8; % nb de bin de valeur DV
    
% Calcul/formatage des donnees
ndxAud = SessionData.Modality(1:end) == 2 ; % Essais stimulus auditif
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; %all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; %only correct catch trials
ndxMinWT = SessionData.Custom.FeedbackTime > VevaiometricMinWT;
DV = SessionData.Custom.DV(1:end);
DVNBin = VevaiometricNBin;
BinIdx = discretize(DV,linspace(-1,1,DVNBin+1)); % transfo valeur DV en valeur discrete comprise entre -1 et 1
WTerr = grpstats(SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxAud),BinIdx(ndxError&ndxMinWT&ndxAud),'mean')'; % calcul du WT moyen par bin de DV
WTcatch = grpstats(SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxAud),BinIdx(ndxCorrectCatch&ndxMinWT&ndxAud),'mean')';
Xerr = unique(BinIdx(ndxError&ndxMinWT&ndxAud))/DVNBin*2-1-1/DVNBin; % normalise DV entre -1 et +1?
Xcatch = unique(BinIdx(ndxCorrectCatch&ndxMinWT&ndxAud))/DVNBin*2-1-1/DVNBin; % normalise DV entre -1 et +1?

% Recup data a ploter:
VevaiometricErr.YData = WTerr;
VevaiometricErr.XData = Xerr;
VevaiometricCatch.YData = WTcatch;
VevaiometricCatch.XData = Xcatch;
VevaiometricPointsErr.YData = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxAud);
VevaiometricPointsErr.XData = DV(ndxError&ndxMinWT&ndxAud);
VevaiometricPointsCatch.YData = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxAud);
VevaiometricPointsCatch.XData = DV(ndxCorrectCatch&ndxMinWT&ndxAud);

% Figure vevaiometric f(DV)=WT
subplot(2,4,4); hold on;
% ligne moyenne essais erreur (catch)
plot(VevaiometricErr.XData,VevaiometricErr.YData, 'LineStyle','-','Color','r','Visible','on','LineWidth',2); 
% ligne moyenne essais correct catch 
plot(VevaiometricCatch.XData,VevaiometricCatch.YData,'LineStyle','-','Color','g','Visible','on','LineWidth',2);
% points essais erreur (catch)
plot(VevaiometricPointsErr.XData,VevaiometricPointsErr.YData,'LineStyle','none','Color','r',...
    'Marker','o','MarkerFaceColor','r', 'MarkerSize',2,'Visible','on','MarkerEdgeColor','r'); 
% points essais correct catch
plot(VevaiometricPointsCatch.XData,VevaiometricPointsCatch.YData,'LineStyle','none','Color','g',...
    'Marker','o','MarkerFaceColor','g', 'MarkerSize',2,'Visible','on','MarkerEdgeColor','g'); 
% Legendes et axes
legend(['Error n = ',num2str(size(VevaiometricPointsErr.YData,2))],['Catch n = ',num2str(size(VevaiometricPointsCatch.YData,2))],'Location','SouthWest');
ylim([0 10]);xlim ([-1.05, 1.05]);
title(['Vevaiometric auditory trials ' SessionData.animal],'fontsize',15);
xlabel('DV','fontsize',16);ylabel('WT (s)','fontsize',16);hold off;

clear Vevaiometric* WT* X* ndx*
%% Distribution des durees de sampling (RT) selon DV essais olfactifs corrects (5)

% Recup des differents niveaux de difficultes
ndxL = SessionData.TrialTypes==1| SessionData.TrialTypes==2;
ndxM = SessionData.TrialTypes==3| SessionData.TrialTypes==4;
ndxH = SessionData.TrialTypes==5| SessionData.TrialTypes==6;
ndxF = SessionData.TrialTypes==7| SessionData.TrialTypes==8;

% Recup pourcentage odeurs chaque niveau:
Mix_L = unique(SessionData.TrialOdor(ndxL&~isnan(SessionData.TrialOdor)));
Mix_M = unique(SessionData.TrialOdor(ndxM&~isnan(SessionData.TrialOdor)));
Mix_H = unique(SessionData.TrialOdor(ndxH&~isnan(SessionData.TrialOdor)));
Mix_F = unique(SessionData.TrialOdor(ndxF&~isnan(SessionData.TrialOdor)));

% Figure distribution temps d'attente recompense essais recompense ou non
subplot(2,4,5); hold on;
% Essais FACILES
A = histogram(SessionData.Custom.ST(ndxL&SessionData.CorrectChoice)*1000,...
    'BinWidth',50); hold on; %'FaceColor','g','EdgeColor','g',
JA = get(A,'child');
set(JA,'FaceAlpha',0.2)
% Essais INTERMEDIAIRES
B = histogram(SessionData.Custom.ST(ndxM&SessionData.CorrectChoice)*1000,...
    'BinWidth',50); hold on; %'FaceColor','y','EdgeColor','y',
JB = get(B,'child');
set(JB,'FaceAlpha',0.2)
% Essais DIFFICILES
C = histogram(SessionData.Custom.ST(ndxH&SessionData.CorrectChoice)*1000,...
    'BinWidth',50); hold on; %'FaceColor',[1 0.5 0.2],'EdgeColor',[1 0.5 0.2],
JC = get(C,'child');
set(JC,'FaceAlpha',0.2)
% Essais Fifty50
D = histogram(SessionData.Custom.ST(ndxF&SessionData.CorrectChoice)*1000,...
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
    
    title({'Reaction time';['Proba to withdraw early ' num2str(min(Mix_L)) '/' num2str(max(Mix_L)) '=' EW_L '; ',...
        num2str(min(Mix_M)) '/' num2str(max(Mix_M)) '=' EW_M '; ',...
        num2str(min(Mix_H)) '/' num2str(max(Mix_H)) '=' EW_H '; ',...
        num2str(min(Mix_F)) '/' num2str(max(Mix_F)) '=' EW_F ]},'fontsize',15);
else
    title('Reaction time','fontsize',15);
end
xlabel('Time (ms)','fontsize',16);ylabel('trial counts','fontsize',16);hold off;
clear ndx* Mix* EW* J*
%% Distribution des temps d'attente du FB pour essais corrects (6)

% Recup datas à exclure de l'analyse:
if SessionData.ProtocolSettings.PunishmentSound==0
    ndxExclude = SessionData.CorrectChoice == 0; %exclude error trials if they are set on catch
else
    ndxExclude = false(1,SessionData.nTrials);
end

% Proba to skip the FB for each side:
LeftSkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==1)/sum(~SessionData.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==1),2));
RightSkip = num2str(round(sum(~SessionData.Custom.Feedback&~SessionData.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==0)/sum(~SessionData.CatchTrial&~ndxExclude&SessionData.Custom.ChoiceLeft==0),2));

% Figure distribution temps d'attente recompense essais recompense ou non
subplot(2,4,6); hold on;
% Essais non recompenses (endwait)
histogram(SessionData.Custom.FeedbackTime(~SessionData.Custom.Feedback&~SessionData.CatchTrial&~ndxExclude)*1000,...
    'BinWidth',100,'EdgeColor','none','FaceColor','r'); hold on;
% Essais recompenses 
histogram(SessionData.Custom.FeedbackTime(SessionData.Custom.Feedback&~SessionData.CatchTrial&~ndxExclude)*1000,...
    'BinWidth',50,'EdgeColor','none','FaceColor','b');
% Legendes et axes
legend('Not rewarded','Rewarded','Location','NorthEast');
title({'Feedback delay';['Proba skip FB Left= ' LeftSkip '/Right= ' RightSkip ' %']},'fontsize',15);
xlabel('Time (ms)','fontsize',16);ylabel('trial counts','fontsize',16);hold off;

clear ndx* LeftSkip RightSkip

%% Performance

% Nombre de points dans l'analyse
Xplot = 0:50:SessionData.nTrials;
Nbbin = size(Xplot,2);

% Pourcentage d'essais corrects au fur et a mesure de la session
ndxDone = SessionData.PunishedTrial&SessionData.CorrectChoice;
ndxFalse = SessionData.PunishedTrial;
ndxError = ~SessionData.PunishedTrial&~SessionData.CorrectChoice;

Pct_False = [];Pct_Error = [];
    
for i=1:Nbbin
    debut = Xplot(i)+1; 
    if debut + 49 < SessionData.nTrials
        fin = debut+49;
    else
        fin = SessionData.nTrials
    end
    Pct_False = [Pct_False sum(ndxFalse(debut:fin))/sum(ndxDone(debut:fin))*100];
    Pct_Error = [Pct_Error sum(ndxError(debut:fin))/size(debut:fin,2)*100];
end
    
    
    
    
    
    
    