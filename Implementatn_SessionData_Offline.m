%% Script implementation datas comportement pour analyses
%
%
% (1) Ajout de champs generaux:
% - Date de la manip
% - Nom du fichier de donnee de la manip
% - Chemin du dossier contenant le fichier de donnee pour enregistrement
% - Index indiquant structure de donnees pour une seule manip seulement
%
% (2) Ajustement de la taille de chaque champ de Custom pour qu'ils soient tous
% egaux a SessionData.Custom.ChoiceLeft (nb essais total - 1)
%
% (3) Ajout et implementation de champ par essai:
% - SessionData.Custom.MissedChoice
% - SessionData.Custom.StimulusDuration
% - SessionData.Custom.Modality
% - SessionData.Custom.TrialTypes
% - SessionData.Custom.SkippedFeedback
%
% (4) Enregistrement des donnees implementees
%
%

%% (1) Ajout de champs generaux:
    
% Ajout de la date de la session dans SessionData:
if isfield(SessionData, 'SessionDate')==0
    prompt = {'Date session= '}; 
    if ~iscell(filename)
        dlg_title = filename(12:end);
    elseif iscell(filename)
        dlg_title = filename{manip}(12:end);
    end
    numlines = 1;
    def = {'17'}; Date = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  
    SessionData.SessionDate = Date;
end


% Ajout du nom du fichier de donnees de la session dans SessionData:
if isfield(SessionData, 'filename')==0 
    if ~iscell(filename)
        SessionData.filename = filename;
        clear filename
    elseif iscell(filename)
        SessionData.filename = filename{manip};
    end
end

% Ajout du chemin du fichier de donnees de la session dans SessionData:
if exist('pathname','var')
    if ~iscell(pathname)
        SessionData.pathname = pathname;
        clear pathname
    elseif iscell(pathname)
        SessionData.pathname = pathname{manip};
    end
end

% Ajout de l'index manip DayvsWeek pour distinguer les datas par jour
% ou combinees sur plusieurs jours
SessionData.DayvsWeek = 1;

%% (2) Ajustement de la taille de chaque champ de Custom

% Ajustement de la taille des champs de SessionData.Custom
if size(SessionData.Custom.ChoiceLeft,2) < SessionData.nTrials
    SessionData.nTrials = size(SessionData.Custom.ChoiceLeft,2);
    SessionData.Custom.BlockNumber = SessionData.Custom.BlockNumber(1:SessionData.nTrials);
    SessionData.Custom.BlockTrial = SessionData.Custom.BlockTrial(1:SessionData.nTrials);
    SessionData.Custom.ChoiceLeft = SessionData.Custom.ChoiceLeft(1:SessionData.nTrials);
    SessionData.Custom.ChoiceCorrect = SessionData.Custom.ChoiceCorrect(1:SessionData.nTrials);
    SessionData.Custom.Feedback = SessionData.Custom.Feedback(1:SessionData.nTrials);
    SessionData.Custom.FeedbackTime = SessionData.Custom.FeedbackTime(1:SessionData.nTrials);
    SessionData.Custom.FixBroke = SessionData.Custom.FixBroke(1:SessionData.nTrials);
    SessionData.Custom.EarlyWithdrawal = SessionData.Custom.EarlyWithdrawal(1:SessionData.nTrials);
    SessionData.Custom.FixDur = SessionData.Custom.FixDur(1:SessionData.nTrials);
    SessionData.Custom.MT = SessionData.Custom.MT(1:SessionData.nTrials);
    SessionData.Custom.CatchTrial = SessionData.Custom.CatchTrial(1:SessionData.nTrials);
    SessionData.Custom.OdorFracA = SessionData.Custom.OdorFracA(1:SessionData.nTrials)';
    SessionData.Custom.OdorID = SessionData.Custom.OdorID(1:SessionData.nTrials)';
    SessionData.Custom.OdorPair = SessionData.Custom.OdorPair(1:SessionData.nTrials);
    SessionData.Custom.ST = SessionData.Custom.ST(1:SessionData.nTrials);
    SessionData.Custom.Rewarded = SessionData.Custom.Rewarded(1:SessionData.nTrials);
    SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(1:SessionData.nTrials,:)';
    SessionData.Custom.TrialNumber = SessionData.Custom.TrialNumber(1:SessionData.nTrials);
    SessionData.Custom.AuditoryTrial = SessionData.Custom.AuditoryTrial(1:SessionData.nTrials);
    SessionData.Custom.AuditoryOmega = SessionData.Custom.AuditoryOmega(1:SessionData.nTrials);
    SessionData.Custom.LeftClickRate = SessionData.Custom.LeftClickRate(1:SessionData.nTrials);
    SessionData.Custom.RightClickRate = SessionData.Custom.RightClickRate(1:SessionData.nTrials);
    SessionData.Custom.LeftClickTrain = SessionData.Custom.LeftClickTrain(1:SessionData.nTrials);
    SessionData.Custom.RightClickTrain = SessionData.Custom.RightClickTrain(1:SessionData.nTrials);
    SessionData.Custom.MoreLeftClicks = SessionData.Custom.MoreLeftClicks(1:SessionData.nTrials);
    SessionData.Custom.DV = SessionData.Custom.DV(1:SessionData.nTrials);
    SessionData.Custom.StimDelay = SessionData.Custom.StimDelay(1:SessionData.nTrials);
    SessionData.Custom.FeedbackDelay = SessionData.Custom.FeedbackDelay(1:SessionData.nTrials);
    SessionData.Custom.MinSampleAud = SessionData.Custom.MinSampleAud(1:SessionData.nTrials);
end
    
%% (3) Calcul des variables manquantes pour chaque essai et implementation de la structure SessionData    

if ~isfield(SessionData.Custom, 'MissedChoice') ...
        || ~isfield(SessionData.Custom, 'StimulusDuration') ...
        || ~isfield(SessionData.Custom, 'Modality') ...
        || ~isfield(SessionData.Custom, 'TrialTypes') ...
        || ~isfield(SessionData.Custom, 'SkippedFeedback') ...
        || ~isfield(SessionData.Custom, 'GracePeriod')
        
    
    % Calcul des pourcentages d'odeur utilises pendant la session:
    PctOdorA_used = unique(SessionData.Custom.OdorFracA(~isnan(SessionData.Custom.OdorFracA)));
    if size(PctOdorA_used,1)>7
        d = dialog('Position',[300 300 250 100],'Name','Error');

        txt = uicontrol('Parent',d,'Style','text','Position',[20 80 200 20],...
                   'String','Number of ambiguity level > 3');

        btn = uicontrol('Parent',d,'Position',[85 20 70 25],'String','Close',...
                   'Callback','delete(gcf)');
       clear d txt btn
    end

    for iTrial = 1 : SessionData.nTrials     
        %% Standard values
        SessionData.Custom.MissedChoice(iTrial) = false;
        SessionData.Custom.StimulusDuration(iTrial) = NaN;
        SessionData.Custom.Modality(iTrial)= 0;
        SessionData.Custom.TrialTypes(iTrial) = 0;
        SessionData.Custom.SkippedFeedback(iTrial)=false;
        SessionData.Custom.GracePeriod(1:50,iTrial) = NaN(50,1);
        nb_graceperiod = 0;
        statesThisTrial = SessionData.RawData.OriginalStateNamesByNumber{iTrial}(SessionData.RawData.OriginalStateData{iTrial});

        % Duree du stimulus (temps durant lequel le stimulus a ete presente)
        if any(strcmp('stimulus_delivery_min',statesThisTrial))
            if any(strcmp('stimulus_delivery',statesThisTrial))
                SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery_min(1,1);
            end
        end

        % essai missed_choice
        if any(strcmp('wait_Sin',statesThisTrial))
            if ~any(strcmp('start_Lin',statesThisTrial))
                if ~any(strcmp('start_Rin',statesThisTrial))
                    SessionData.Custom.MissedChoice(iTrial) = true;
                end
            end
        end
  
        % Modalite sensorielle de l'essai:
        if SessionData.Custom.AuditoryTrial(iTrial)
            SessionData.Custom.Modality(iTrial)=2;
        else
            SessionData.Custom.Modality(iTrial)=1;
        end
        
        % Trial type: niveau de difficulte des essais olfactifs
        if SessionData.Custom.Modality(iTrial)==1
            if SessionData.Custom.OdorFracA(iTrial) == 50
                SessionData.Custom.TrialTypes(iTrial) = 7;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(1)
                SessionData.Custom.TrialTypes(iTrial) = 2;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(2)
                SessionData.Custom.TrialTypes(iTrial) = 4;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(3)
                SessionData.Custom.TrialTypes(iTrial) = 6;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(4)
                SessionData.Custom.TrialTypes(iTrial) = 5;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(5)
                SessionData.Custom.TrialTypes(iTrial) = 3;
            elseif SessionData.Custom.OdorFracA(iTrial) == PctOdorA_used(6)
                SessionData.Custom.TrialTypes(iTrial) = 1;
            end
        elseif SessionData.Custom.Modality(iTrial)==2
            SessionData.Custom.TrialTypes(iTrial) = NaN;  
        end
        
        % Essai Skipped feedback:
        if any(strcmp('skipped_feedback',statesThisTrial))
            SessionData.Custom.SkippedFeedback(iTrial)=true;
        end
        
        % Calcul grace period essais concernes:
        if any(strcmp('rewarded_Lin_grace',statesThisTrial))
            for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.rewarded_Lin_grace,1))
                SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.rewarded_Lin_grace(nb_graceperiod,2)...
                    -SessionData.RawEvents.Trial{iTrial}.States.rewarded_Lin_grace(nb_graceperiod,1));
            end
        elseif any(strcmp('rewarded_Rin_grace',statesThisTrial))
            for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.rewarded_Rin_grace,1))
                SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.rewarded_Rin_grace(nb_graceperiod,2)...
                    -SessionData.RawEvents.Trial{iTrial}.States.rewarded_Rin_grace(nb_graceperiod,1));
            end
        elseif any(strcmp('unrewarded_Lin_grace',statesThisTrial))
            for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Lin_grace,1))
                SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Lin_grace(nb_graceperiod,2)...
                    -SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Lin_grace(nb_graceperiod,1));
            end
        elseif any(strcmp('unrewarded_Rin_grace',statesThisTrial))
             for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Rin_grace,1))
                SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Rin_grace(nb_graceperiod,2)...
                    -SessionData.RawEvents.Trial{iTrial}.States.unrewarded_Rin_grace(nb_graceperiod,1));
            end
        else 
        end          
        
        clear statesThisTrial
    end                
end

% Calcul des WT normalises par le WT catch moyen de la session
SessionData = normWT(SessionData,1);

% Calcul de l'index DVlog (distrib logaritmq des index de difficulte
SessionData = DVlog(SessionData);

% Get and format time of each trial begining in time value
if ~isfield(SessionData.Custom, 'TrialStart')
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
end

%% Enregistrement des datas implementees
cd(SessionData.pathname)
save(SessionData.filename,'SessionData');

