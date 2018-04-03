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
function SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,manip)
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
% Get SessionData.Custom Fieldnames:
CustomFields = fieldnames(SessionData.Custom);
WeirdFields = {'RewardMagnitude' ;'OdorID';'Rig';'Subject';'PsychotoolboxStartup';'OlfactometerStartup';...
    'LeftClickRate';'RightClickRate';'RightClickTrain';'LeftClickTrain';'FreqStimulus';...
    'PulsePalParamStimulus';'PulsePalParamFeedback'};

% Ajustement de la taille des champs de SessionData.Custom
SessionData.nTrials = size(SessionData.Custom.ChoiceLeft,2);
for field = 1: size (CustomFields,1)
    if ~any(strcmp(CustomFields{field},WeirdFields)) && size(SessionData.Custom.(CustomFields{field}),2)>=SessionData.nTrials
        SessionData.Custom.(CustomFields{field}) = SessionData.Custom.(CustomFields{field})(1:SessionData.nTrials);
    elseif strcmp(CustomFields{field},'RewardMagnitude')
        if find(max(size(SessionData.Custom.RewardMagnitude))==size(SessionData.Custom.RewardMagnitude))==2
            SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(:,1:SessionData.nTrials);
        else
            SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'LeftClickRate')
        if find(max(size(SessionData.Custom.LeftClickRate))==size(SessionData.Custom.LeftClickRate))==2
            SessionData.Custom.LeftClickRate = SessionData.Custom.LeftClickRate(:,1:SessionData.nTrials);
        else
            SessionData.Custom.LeftClickRate = SessionData.Custom.LeftClickRate(1:SessionData.nTrials,:)';
        end

    elseif strcmp(CustomFields{field},'RightClickRate')
        if find(max(size(SessionData.Custom.RightClickRate))==size(SessionData.Custom.RightClickRate))==2
            SessionData.Custom.RightClickRate = SessionData.Custom.RightClickRate(:,1:SessionData.nTrials);
        else
            SessionData.Custom.RightClickRate = SessionData.Custom.RightClickRate(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'LeftClickTrain')
        if find(max(size(SessionData.Custom.LeftClickTrain))==size(SessionData.Custom.LeftClickTrain))==2
            SessionData.Custom.LeftClickTrain = SessionData.Custom.LeftClickTrain(:,1:SessionData.nTrials);
        else
            SessionData.Custom.LeftClickTrain = SessionData.Custom.LeftClickTrain(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'RightClickTrain')
        if find(max(size(SessionData.Custom.RightClickTrain))==size(SessionData.Custom.RightClickTrain))==2
            SessionData.Custom.RightClickTrain = SessionData.Custom.RightClickTrain(:,1:SessionData.nTrials);
        else
            SessionData.Custom.RightClickTrain = SessionData.Custom.RightClickTrain(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'OdorID')
        if find(max(size(SessionData.Custom.OdorID))==size(SessionData.Custom.OdorID))==2
            SessionData.Custom.OdorID = SessionData.Custom.OdorID(:,1:SessionData.nTrials);
        else
            SessionData.Custom.OdorID = SessionData.Custom.OdorID(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'OdorFracA')
        if find(max(size(SessionData.Custom.OdorFracA))==size(SessionData.Custom.OdorFracA))==2
            SessionData.Custom.OdorFracA = SessionData.Custom.OdorFracA(:,1:SessionData.nTrials);
        else
            SessionData.Custom.OdorFracA = SessionData.Custom.OdorFracA(1:SessionData.nTrials,:)';
        end
    end
end
    
%% (3) Calcul des variables manquantes pour chaque essai et implementation de la structure SessionData    

if sum(strcmp(SessionData.Protocol, {'Dual2AFC', 'Mouse2AFC'})) 
        
    if ~isfield(SessionData.Custom, 'MissedChoice') ...
            || ~isfield(SessionData.Custom, 'StimulusDuration') ...
            || ~isfield(SessionData.Custom, 'Modality') ... %|| ~isfield(SessionData.Custom, 'TrialTypes') ...     
            || ~isfield(SessionData.Custom, 'SkippedFeedback') ...
            || ~isfield(SessionData.Custom, 'GracePeriod')

        if isfield(SessionData.Custom,'OdorFracA')
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
        end
        
        if strcmp(SessionData.Protocol, {'Dual2AFC'})
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
        elseif strcmp(SessionData.Protocol, {'Mouse2AFC'})
            for iTrial = 1 : SessionData.nTrials     
                %% Standard values
                SessionData.Custom.StimulusDuration(iTrial) = NaN;
                SessionData.Custom.Modality(iTrial)= 0;
                SessionData.Custom.SkippedFeedback(iTrial)=false;
                SessionData.Custom.GracePeriod(1:50,iTrial) = NaN(50,1);
                nb_graceperiod = 0;
                statesThisTrial = SessionData.RawData.OriginalStateNamesByNumber{iTrial}(SessionData.RawData.OriginalStateData{iTrial});
            
                % Duree du stimulus (temps durant lequel le stimulus a ete presente)
                if any(strcmp('stimulus_delivery',statesThisTrial))
                    if any(strcmp('CenterPortRewardDelivery',statesThisTrial))
                        SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.CenterPortRewardDelivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,1);
                    else
                        SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,1);
                    end
                end

                % Modalite sensorielle de l'essai:
                if SessionData.Custom.AuditoryTrial(iTrial)
                    SessionData.Custom.Modality(iTrial)=2;
                else
                    SessionData.Custom.Modality(iTrial)=1;
                end
                
                 % Essai Skipped feedback:
                if any(strcmp('timeOut_SkippedFeedback',statesThisTrial))
                    SessionData.Custom.SkippedFeedback(iTrial)=true;
                end

                % Calcul grace period essais concernes:
                if any(strcmp('RewardGrace',statesThisTrial))
                    for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.RewardGrace,1))
                        SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.RewardGrace(nb_graceperiod,2)...
                            -SessionData.RawEvents.Trial{iTrial}.States.RewardGrace(nb_graceperiod,1));
                    end
                elseif any(strcmp('PunishGrace',statesThisTrial))
                    for nb_graceperiod =  nb_graceperiod + (1: size(SessionData.RawEvents.Trial{iTrial}.States.PunishGrace,1))
                        SessionData.Custom.GracePeriod(nb_graceperiod,iTrial) = (SessionData.RawEvents.Trial{iTrial}.States.PunishGrace(nb_graceperiod,2)...
                            -SessionData.RawEvents.Trial{iTrial}.States.PunishGrace(nb_graceperiod,1));
                    end  
                end          

                clear statesThisTrial
            end
                     
        end
        
    end

    % Calcul des WT normalises par le WT catch moyen de la session
    ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
    if sum(ndxCatch)>10
        ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
        ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
        medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
        % Normalisation WT par WT moyen session
        SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
        SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
        SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;
    end

    % Calcul de l'index DVlog (distrib logaritmq des index de difficulte
    if isfield(SessionData.Custom, 'DVlog')==0   
        for essai = 1:size(SessionData.Custom.ChoiceLeft,2)
            if SessionData.Custom.Modality(essai)==2
                % Implementation DVlog
                SessionData.Custom.DVlog(essai) = -log10(length(SessionData.Custom.RightClickTrain{essai})/length(SessionData.Custom.LeftClickTrain{essai}));
            else
                SessionData.Custom.DVlog(essai) = NaN;
            end
        end
    end

    % Get and format time of each trial begining in time value
    if ~isfield(SessionData.Custom, 'TrialStart')
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
    end
    
elseif strcmp(SessionData.Protocol, 'NosePoke')
% A implementer
end
%% Enregistrement des datas implementees
cd(SessionData.pathname)
save(SessionData.filename,'SessionData');
end

