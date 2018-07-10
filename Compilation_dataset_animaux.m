%% Script recup et compilation dataset pour plusieurs animaux
%
% - Recup lien vers dataset des differents animaux à compiler
% - Construction structure datas population
%   * Chargement manip
%   * Concatenation des donnees de toutes les sessions
% - Enregistrement superstructure de donnees creee
% 
%

%% Recup nombre d'animaux a pooler:
prompt = {'N = '}; dlg_title = 'Nombre d animaux'; numlines = 1;
def = {'3'}; N = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt  

%% Recup dataset animaux a compiler
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC';
for animal = 1 : N
    cd(pathdatalocal);
    prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
    def = {'M'}; Nom{animal} = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  
    [filename{animal},pathname{animal}] = uigetfile([pathdatalocal '/' Nom{animal} '/Session Data/*.mat']);
end

%% GUI pour renseigner si enregistrement ou non du dataset cree
pathdataset = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC/dataset_animaux';

prompt = {'Enregistrement? = '}; dlg_title = 'Superstructure cree'; numlines = 1;
def = {'0'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Si enregistrement
if saving==1
    % GUI pour recup date du dataset compose
    prompt = {'Nom dataset = '}; dlg_title = 'Semaine'; numlines = 1;
    def = {'17'}; Nomdataset = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 

    SessionDataWeek.SessionDate = Nomdataset;
    SessionDataWeek.DayvsWeek = 2;

    cd(pathdataset)
    save(['AllDatafilename_' Nomdataset],'filename')
    save(['AllDatapathname_' Nomdataset],'pathname')
end

%% GUI selection manip a conserver:
% Cree fig avec checkbox pour chaque journee de manip
top = (20*size(filename,2))+30;
h.f = figure('Position',[100 100 top 500]);

for manip = 1:size(filename,2)
    h.c(manip) = uicontrol('style','checkbox', 'string',filename{manip},...
          'Value', 1,...
          'Position',[10 top 300 15]);
    top=top-20;
end

h.p = uicontrol('Style', 'pushbutton', 'string', 'Update dataset list',...
        'Position', [20 20 100 20]);

%% Suite script fabrication dataset periode restreinte

checkboxValues = find(cell2mat(get(h.c, 'Value')));
pathname = pathname(checkboxValues);
filename = filename(checkboxValues);

% GUI pour renseigner si enregistrement ou non du dataset cree
prompt = {'Enregistrement? = '}; dlg_title = 'Superstructure cree'; numlines = 1;
def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Si enregistrement
if saving==1
    % GUI pour recup date du dataset compose
    prompt = {'Nom dataset = '}; dlg_title = 'Semaine'; numlines = 1;
    def = {'17'}; Nomdataset = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 

    SessionDataWeek.SessionDate = Nomdataset;
    SessionDataWeek.DayvsWeek = 2;

    cd(pathname{1})
    save(['Datafilename_' Nomdataset],'filename')
    save(['Datapathname_' Nomdataset],'pathname')
end
close all
%% Construction structure datas

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}]);
           
    %% Concatenation des donnees
    if manip == 1
        SessionDatasets = SessionDataWeek;
        SessionDatasets.Custom.Subject = repmat(Nom(manip),1,SessionDataWeek.nTrials);
     else
         SessionDatasets.Custom.ChoiceLeft = [SessionDatasets.Custom.ChoiceLeft SessionDataWeek.Custom.ChoiceLeft];
         SessionDatasets.Custom.ChoiceCorrect = [SessionDatasets.Custom.ChoiceCorrect SessionDataWeek.Custom.ChoiceCorrect];
         SessionDatasets.Custom.Feedback = [SessionDatasets.Custom.Feedback SessionDataWeek.Custom.Feedback];
         SessionDatasets.Custom.FeedbackTime = [SessionDatasets.Custom.FeedbackTime SessionDataWeek.Custom.FeedbackTime];
         SessionDatasets.Custom.FixBroke = [SessionDatasets.Custom.FixBroke SessionDataWeek.Custom.FixBroke];
         SessionDatasets.Custom.EarlyWithdrawal = [SessionDatasets.Custom.EarlyWithdrawal SessionDataWeek.Custom.EarlyWithdrawal];
         SessionDatasets.Custom.FixDur = [SessionDatasets.Custom.FixDur SessionDataWeek.Custom.FixDur];
         SessionDatasets.Custom.MT = [SessionDatasets.Custom.MT SessionDataWeek.Custom.MT];
         SessionDatasets.Custom.CatchTrial = [SessionDatasets.Custom.CatchTrial SessionDataWeek.Custom.CatchTrial];
         SessionDatasets.Custom.OdorFracA = [SessionDatasets.Custom.OdorFracA SessionDataWeek.Custom.OdorFracA];
         SessionDatasets.Custom.OdorID = [SessionDatasets.Custom.OdorID SessionDataWeek.Custom.OdorID];
         SessionDatasets.Custom.OdorPair = [SessionDatasets.Custom.OdorPair SessionDataWeek.Custom.OdorPair];
         SessionDatasets.Custom.ST = [SessionDatasets.Custom.ST SessionDataWeek.Custom.ST];
         SessionDatasets.Custom.Rewarded = [SessionDatasets.Custom.Rewarded SessionDataWeek.Custom.Rewarded];
         SessionDatasets.Custom.RewardMagnitude = [SessionDatasets.Custom.RewardMagnitude SessionDataWeek.Custom.RewardMagnitude];
         SessionDatasets.Custom.TrialNumber = [SessionDatasets.Custom.TrialNumber SessionDataWeek.Custom.TrialNumber];
         SessionDatasets.Custom.AuditoryTrial = [SessionDatasets.Custom.AuditoryTrial SessionDataWeek.Custom.AuditoryTrial];
         if isfield(SessionDatasets.Custom,'AuditoryOmega')
            SessionDatasets.Custom.AuditoryOmega = [SessionDatasets.Custom.AuditoryOmega SessionDataWeek.Custom.AuditoryOmega];
            SessionDatasets.Custom.LeftClickRate = [SessionDatasets.Custom.LeftClickRate SessionDataWeek.Custom.LeftClickRate];
            SessionDatasets.Custom.RightClickRate = [SessionDatasets.Custom.RightClickRate SessionDataWeek.Custom.RightClickRate];
            SessionDatasets.Custom.LeftClickTrain = [SessionDatasets.Custom.LeftClickTrain SessionDataWeek.Custom.LeftClickTrain];
            SessionDatasets.Custom.RightClickTrain = [SessionDatasets.Custom.RightClickTrain SessionDataWeek.Custom.RightClickTrain];
         end
         SessionDatasets.Custom.DV = [SessionDatasets.Custom.DV SessionDataWeek.Custom.DV];
         SessionDatasets.Custom.StimDelay = [SessionDatasets.Custom.StimDelay SessionDataWeek.Custom.StimDelay];
         SessionDatasets.Custom.FeedbackDelay = [SessionDatasets.Custom.FeedbackDelay SessionDataWeek.Custom.FeedbackDelay];
         SessionDatasets.Custom.MinSampleAud = [SessionDatasets.Custom.MinSampleAud SessionDataWeek.Custom.MinSampleAud];
         SessionDatasets.Custom.MissedChoice = [SessionDatasets.Custom.MissedChoice SessionDataWeek.Custom.MissedChoice];
         SessionDatasets.Custom.StimulusDuration = [SessionDatasets.Custom.StimulusDuration SessionDataWeek.Custom.StimulusDuration];
         SessionDatasets.Custom.Modality = [SessionDatasets.Custom.Modality SessionDataWeek.Custom.Modality];
         SessionDatasets.Custom.TrialTypes = [SessionDatasets.Custom.TrialTypes SessionDataWeek.Custom.TrialTypes];
         SessionDatasets.Custom.SkippedFeedback = [SessionDatasets.Custom.SkippedFeedback SessionDataWeek.Custom.SkippedFeedback];
         if isfield(SessionDatasets.Custom, 'FeedbackTimeNorm') && isfield(SessionDataWeek.Custom, 'FeedbackTimeNorm')
            SessionDatasets.Custom.FeedbackTimeNorm = [SessionDatasets.Custom.FeedbackTimeNorm SessionDataWeek.Custom.FeedbackTimeNorm];
         end
         SessionDatasets.Custom.DVlog = [SessionDatasets.Custom.DVlog SessionDataWeek.Custom.DVlog];
         SessionDatasets.Custom.TrialStart = [SessionDatasets.Custom.TrialStart SessionDataWeek.Custom.TrialStart];
         %SessionDatasets.Custom.GracePeriod = [SessionDatasets.Custom.GracePeriod SessionDataWeek.Custom.GracePeriod];
         SessionDatasets.Custom.Session = [SessionDatasets.Custom.Session SessionDataWeek.Custom.Session+max(SessionDatasets.Custom.Session)];
         SessionDatasets.Custom.Subject = [SessionDatasets.Custom.Subject repmat(Nom(manip),1,SessionDataWeek.nTrials)];
    end
    
    clear SessionData
end

SessionDatasets.DayvsWeek = 2;
%% Enregistrement superstructure de donnees creee

% GUI pour renseigner si enregistrement ou non du dataset cree
prompt = {'Enregistrement? = '}; dlg_title = 'Superstructure cree'; numlines = 1;
def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Si enregistrement
if saving==1
    %% GUI pour recup nom (date) du dataset compose
    prompt = {'Nom dataset = '}; dlg_title = 'Semaine'; numlines = 1;
    def = {'17'}; Nomdataset = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 

    SessionDatasets.filename = Nomdataset;
    SessionDatasets.pathname = pathdataset;
    
    %% Enregistrement dataset
    cd(pathdataset)
    save(['SessionDatasets_' Nomdataset],'SessionDatasets')   
end
