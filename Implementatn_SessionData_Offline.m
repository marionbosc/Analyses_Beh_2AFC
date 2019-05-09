%% Script implementation behavioral data in SessionData for offline analysis
%
%
% (1) Add general fields: 
% - Date of the session
% - Name of the data file
% - Path to the local (personal computer) folder containing the data to save data after change
% - Protocol name if it doesn't already exist
% - Index DayvsWeek  to distinguish data for one vs several concatenated session
%
% (2) Adjust the size of all the field to keep only the executed trials 
% (to remove the last trials set in advance for Bpod but not executed)
%
% (3) Add and implement offline behavioral fields that are missing, per trials: 
% - SessionData.Custom.MissedChoice --> trials sampled for the min
% requested but with no choice  made afterwards
% - SessionData.Custom.StimulusDuration --> real duration of the stimulus
% given during the trial
% - SessionData.Custom.Modality --> sensory modality used for the trial:
%    - 1 = olfatory
%    - 2 = auditory click task
%    - 3 = auditory frequency task (cloud of tone from Zador lab)
%    - 4 = we could add visual intensity for Larkum lab ... --> to discuss with Hatem
% - SessionData.Custom.TrialTypes : difficulty level of olfactory trials
% - SessionData.Custom.SkippedFeedback
% - SessionData.Custom.GracePeriod(s) duration(s)
% - SessionData.Custom.LeftRewarded  
%
% - Computation of normalized WT per session: WTnorm = WT - mean(WT(CatchTrials) per side
% - Computation of DVlog: log distrib of the Decision Variable  
% - Get and format time of each trial beginning in time value
%
% (4) Saving of implemented SessionData
%
%

function SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,manip)
%% (1) Add general fields in SessionData: 
    
% - Date of the session
if isfield(SessionData, 'SessionDate')==0
    prompt = {'Date session= '}; 
    if ~iscell(filename)
        dlg_title = filename(12:end);
    elseif iscell(filename)
        dlg_title = filename{manip}(end-23:end);
    end
    numlines = 1;
    def = {'19'}; Date = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  
    SessionData.SessionDate = Date;
end


% - Name of the data file
if isfield(SessionData, 'filename')==0 
    if ~iscell(filename)
        SessionData.filename = filename;
        clear filename
    elseif iscell(filename)
        SessionData.filename = filename{manip};
    end
end

% - Path to the local (personal computer) folder containing the data
if exist('pathname','var')
    SessionData.pathname = pathname;
    clear pathname
end

% - Protocol name if it doesn't already exist
if ~isfield(SessionData,'Protocol') || isempty(SessionData.Protocol)
    % GUI to give the name of the Protocol (not automatically saved on Ubuntu) 
    prompt = {'Bpod protocol = '}; dlg_title = 'Protocol?'; numlines = 1;
    def = {'Dual2AFC'}; 
    SessionData.Protocol = cell2mat(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt
end

% - Index DayvsWeek  to distinguish data for one vs several concatenated session
SessionData.DayvsWeek = 1;

%% (2) Adjust the size of all the field for them to match the real number of executed trials
% Get SessionData.Custom Fieldnames:
CustomFields = fieldnames(SessionData.Custom);

% Set a list of fields that required a special treatment
WeirdFields = {'RewardMagnitude' ;'GracePeriod';'OdorID';'Rig';'Subject';'PsychotoolboxStartup';'OlfactometerStartup';...
    'LeftClickRate';'RightClickRate';'RightClickTrain';'LeftClickTrain';'FreqStimulus';...
    'PulsePalParamStimulus';'PulsePalParamFeedback'};

% Adjust the size of fiels to keep only the executed trials: 
SessionData.nTrials = size(SessionData.Custom.ChoiceLeft,2);
for field = 1: size (CustomFields,1)
    % Case of the regular fields
    if ~any(strcmp(CustomFields{field},WeirdFields)) && size(SessionData.Custom.(CustomFields{field}),2)>=SessionData.nTrials
        SessionData.Custom.(CustomFields{field}) = SessionData.Custom.(CustomFields{field})(1:SessionData.nTrials);
    % Case of all the exception ("weird fields")
    elseif strcmp(CustomFields{field},'RewardMagnitude')
        if find(size(SessionData.Custom.RewardMagnitude)==2)==1
            SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(:,1:SessionData.nTrials);
        else
            SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(1:SessionData.nTrials,:)';
        end
    elseif strcmp(CustomFields{field},'GracePeriod')     
        if find(size(SessionData.Custom.GracePeriod)==50)==1  
            SessionData.Custom.GracePeriod = SessionData.Custom.GracePeriod(:,1:SessionData.nTrials);
        else
            SessionData.Custom.GracePeriod = SessionData.Custom.GracePeriod(1:SessionData.nTrials,:)';
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
    
%% (3) Add and implement offline behavioral fields that are missing in SessionData.Custom, per trials:

% Field implementation applies only for Protocols Dual2AFC and Mouse2AFC
if sum(strcmp(SessionData.Protocol, {'Dual2AFC', 'Mouse2AFC'})) 
    
    % Check if any of the field to implement are missing (might already
    % have been implemented online at the end of the Protocol)
    if ~isfield(SessionData.Custom, 'MissedChoice') ...
            || ~isfield(SessionData.Custom, 'StimulusDuration') ...
            || ~isfield(SessionData.Custom, 'Modality') ... %|| ~isfield(SessionData.Custom, 'TrialTypes') ...     
            || ~isfield(SessionData.Custom, 'SkippedFeedback') ...
            || ~isfield(SessionData.Custom, 'GracePeriod')...
            || ~isfield(SessionData.Custom, 'LeftRewarded')

        if isfield(SessionData.Custom,'OdorFracA')
            % Retrieved all the percent of odor used during the session:
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
        
        % Case Protocol used = Dual2AFC:
        if strcmp(SessionData.Protocol, {'Dual2AFC'})
            for iTrial = 1 : SessionData.nTrials     
                %% Default values
                SessionData.Custom.MissedChoice(iTrial) = false;
                SessionData.Custom.StimulusDuration(iTrial) = NaN;
                SessionData.Custom.Modality(iTrial)= 0;
                SessionData.Custom.TrialTypes(iTrial) = 0;
                SessionData.Custom.SkippedFeedback(iTrial)=false;
                SessionData.Custom.GracePeriod(1:50,iTrial) = NaN(50,1);
                nb_graceperiod = 0;
                
                % Retrieval of all the states executed during the trial
                statesThisTrial = SessionData.RawData.OriginalStateNamesByNumber{iTrial}(SessionData.RawData.OriginalStateData{iTrial});

                % Duration of the stimulus presentation: 
                if any(strcmp('stimulus_delivery_min',statesThisTrial))
                    if any(strcmp('stimulus_delivery',statesThisTrial))
                        SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery_min(1,1);
                    end
                end

                % Missed_choice trials
                if any(strcmp('wait_Sin',statesThisTrial))
                    if ~any(strcmp('start_Lin',statesThisTrial))
                        if ~any(strcmp('start_Rin',statesThisTrial))
                            SessionData.Custom.MissedChoice(iTrial) = true;
                        end
                    end
                end

                % Sensory modality:
                if SessionData.Custom.AuditoryTrial(iTrial)
                    SessionData.Custom.Modality(iTrial)=2;
                else
                    SessionData.Custom.Modality(iTrial)=1;
                end
                
                % Trial type: difficulty level of olfactory trials
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

                % Skipped feedback trials:
                if any(strcmp('skipped_feedback',statesThisTrial))
                    SessionData.Custom.SkippedFeedback(iTrial)=true;
                end

                % GracePeriod(s) duration(s):
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
            
            % LeftRewarded field (if it doesn't exist)
            if ~isfield(SessionData.Custom, 'LeftRewarded')
                for iTrial = 1 : SessionData.nTrials
                    SessionData.Custom.LeftRewarded(iTrial) = NaN;
                    if length(SessionData.Custom.LeftClickTrain{iTrial}) > length(SessionData.Custom.RightClickTrain{iTrial})
                        SessionData.Custom.LeftRewarded(iTrial) = 1;
                    elseif length(SessionData.Custom.LeftClickTrain{iTrial}) < length(SessionData.Custom.RightClickTrain{iTrial})
                        SessionData.Custom.LeftRewarded(iTrial) = 0;
                    else
                        SessionData.Custom.LeftRewarded(iTrial) = rand<0.5;
                    end
                end
            end
        
        % Case Protocol used = Mouse2AFC (some state name changed between Dual2AFC and Mouse2AFC):
        elseif strcmp(SessionData.Protocol, {'Mouse2AFC'})
            for iTrial = 1 : SessionData.nTrials     
                %% Default values
                SessionData.Custom.StimulusDuration(iTrial) = NaN;
                SessionData.Custom.Modality(iTrial)= 0;
                SessionData.Custom.SkippedFeedback(iTrial)=false;
                SessionData.Custom.GracePeriod(1:50,iTrial) = NaN(50,1);
                nb_graceperiod = 0;
                
                % Retrieval of all the states executed during the trial
                statesThisTrial = SessionData.RawData.OriginalStateNamesByNumber{iTrial}(SessionData.RawData.OriginalStateData{iTrial});
            
                % Duration of the stimulus presentation: 
                if any(strcmp('stimulus_delivery',statesThisTrial))
                    if any(strcmp('CenterPortRewardDelivery',statesThisTrial))
                        SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.CenterPortRewardDelivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,1);
                    else
                        SessionData.Custom.StimulusDuration(iTrial) = SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,2) - SessionData.RawEvents.Trial{iTrial}.States.stimulus_delivery(1,1);
                    end
                end

                % Sensory modality:
                if isfield(SessionData.Custom , 'LightIntensityLeft')
                    SessionData.Custom.Modality(iTrial)=4;
                elseif SessionData.Custom.AuditoryTrial(iTrial)
                    SessionData.Custom.Modality(iTrial)=2;
                else
                    SessionData.Custom.Modality(iTrial)=1;
                end
                
                % Skipped feedback trials:
                if any(strcmp('timeOut_SkippedFeedback',statesThisTrial))
                    SessionData.Custom.SkippedFeedback(iTrial)=true;
                end

                % GracePeriod(s) duration(s):
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

    % Computation of normalized WT per session: WTnorm = WT - mean(WT(CatchTrials) per side
    ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
    if sum(ndxCatch)>10
        ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
        ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
        medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
        SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
        SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
        SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;
    end

    % Computation of DVlog: log distrib of the Decision Variable (for auditory click task only)
    if isfield(SessionData.Custom, 'DVlog')==0   
        for essai = 1:size(SessionData.Custom.ChoiceLeft,2)
            if SessionData.Custom.Modality(essai)==2
                SessionData.Custom.DVlog(essai) = -log10(length(SessionData.Custom.RightClickTrain{essai})/length(SessionData.Custom.LeftClickTrain{essai}));
            else
                SessionData.Custom.DVlog(essai) = NaN;
            end
        end
    end

    % Get and format time of each trial beginning in time value
    if ~isfield(SessionData.Custom, 'TrialStart')
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
    end
    
    % Set StartEasyTrial field in custom
     if ~isfield(SessionData.Custom, 'StartEasyTrial')
        SessionData = set_StartEasyTrial_field(SessionData);
     end
    
elseif strcmp(SessionData.Protocol, 'NosePoke')
% To implement...
end

%% Save implemented SessionData
cd(SessionData.pathname)
save(SessionData.filename,'SessionData');
end

