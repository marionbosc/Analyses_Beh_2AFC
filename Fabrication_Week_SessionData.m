%% Script recup datas pour plusieurs jours, implementatn data/analyses par jour puis analyses globales par pop
%
% - Recup donnee animal a analyser
% - GUI selection manip a conserver pour redef une nouvelle pop plus
% restreinte
% - Script fabrication dataset periode restreinte (suite et fin)
% - Construction structure datas population
%   * Chargement manip
%   * Implementation des donnees manquantes pour l'analyse
%   * Figures analyses donnees par session
%   * Concatenation des donnees de toutes les sessions
% - Enregistrement superstructure de donnees creee
% - Figures analyses donnees dataset
% 
%

%% Recup donnee animal a analyser
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC';
cd(pathdatalocal);
prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

%% Suite
prompt = {'N = '}; dlg_title = 'Nombre de manips'; numlines = 1;
def = {'4'}; N = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt  

for jour = 1:N
    [filename{jour},pathname{jour}] = uigetfile([pathdatalocal '/' Nom '/Session Data/*.mat']);
end

% GUI pour renseigner si enregistrement ou non du dataset cree
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

    cd(pathname{1})
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
    load([pathname{manip} '/' filename{manip}])
    
    %% Implementation des donnees manquantes pour l'analyse
    Implementatn_SessionData_Offline
        
    %% Figure analyse donnee journee de manip
    
    % Redirection vers dossier figures animal:
    pathfigures = [pathdatalocal '/' Nom '/Session Figures'];
    cd(pathfigures);
    faireunepause = false;
    
    if exist([SessionData.filename(1:end-4) 'Analysis1.png'],'file')~=2
        Session = fig_beh(SessionData); % Analyse globale session comportement
        FigurePathSession = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Analysis1.png']);
        saveas(Session,FigurePathSession,'png'); faireunepause = true;
    end
    
% Manip Dual2AFC Click version
    if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
            % Plus de 10% d'essais olf et Plus de 10% d'essais audit
            if exist([SessionData.filename(1:end-4) 'Cfdce.png'],'file')~=2
                Cfdce = fig_beh_Cfdce_bimodality(SessionData);  % Analyse confidence both modality
                FigurePathCfdce = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Cfdce.png']);
                saveas(Cfdce,FigurePathCfdce,'png'); faireunepause = true;
            end
            if sum(SessionData.Custom.CatchTrial)>10
                if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
                    CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
                    FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
                    saveas(CfdceOlf,FigurePathCfdceOlf,'png'); faireunepause = true;
                end
                if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
                    CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
                    FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
                    saveas(CfdceAud,FigurePathCfdceAud,'png'); faireunepause = true;
                end
            end
        else % Plus de 10% d'essais olf et moins de 10% d'essais audit 
            if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
                CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
                FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
                saveas(CfdceOlf,FigurePathCfdceOlf,'png'); faireunepause = true;
            end
        end
    elseif sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        % Moins de 10% d'essais olf mais Plus de 10% d'essais audit
        if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
            CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
            FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
            saveas(CfdceAud,FigurePathCfdceAud,'png'); faireunepause = true;
        end
    end
    
% % Manip Dual2AFC Frequency version
%     if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
%         CfdceAud = Analyse_Fig_Cfdce(SessionData, 3); % Analyse confidence Aud only
%         FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
%         saveas(CfdceAud,FigurePathCfdceAud,'png'); faireunepause = true;
%     end

    if faireunepause
        pause; faireunepause = false;    
    end
    
    close all
    
    %% Concatenation des donnees
    if manip == 1
        SessionDataWeek = SessionData;
        SessionDataWeek.Custom.Session = repmat(manip,1,SessionData.nTrials);
     else
         SessionDataWeek.Custom.ChoiceLeft = [SessionDataWeek.Custom.ChoiceLeft SessionData.Custom.ChoiceLeft];
         SessionDataWeek.Custom.ChoiceCorrect = [SessionDataWeek.Custom.ChoiceCorrect SessionData.Custom.ChoiceCorrect];
         SessionDataWeek.Custom.Feedback = [SessionDataWeek.Custom.Feedback SessionData.Custom.Feedback];
         SessionDataWeek.Custom.FeedbackTime = [SessionDataWeek.Custom.FeedbackTime SessionData.Custom.FeedbackTime];
         SessionDataWeek.Custom.FixBroke = [SessionDataWeek.Custom.FixBroke SessionData.Custom.FixBroke];
         SessionDataWeek.Custom.EarlyWithdrawal = [SessionDataWeek.Custom.EarlyWithdrawal SessionData.Custom.EarlyWithdrawal];
         SessionDataWeek.Custom.FixDur = [SessionDataWeek.Custom.FixDur SessionData.Custom.FixDur];
         SessionDataWeek.Custom.MT = [SessionDataWeek.Custom.MT SessionData.Custom.MT];
         SessionDataWeek.Custom.CatchTrial = [SessionDataWeek.Custom.CatchTrial SessionData.Custom.CatchTrial];
         SessionDataWeek.Custom.OdorFracA = [SessionDataWeek.Custom.OdorFracA SessionData.Custom.OdorFracA];
         SessionDataWeek.Custom.OdorID = [SessionDataWeek.Custom.OdorID SessionData.Custom.OdorID];
         SessionDataWeek.Custom.OdorPair = [SessionDataWeek.Custom.OdorPair SessionData.Custom.OdorPair];
         SessionDataWeek.Custom.ST = [SessionDataWeek.Custom.ST SessionData.Custom.ST];
         SessionDataWeek.Custom.Rewarded = [SessionDataWeek.Custom.Rewarded SessionData.Custom.Rewarded];
         SessionDataWeek.Custom.RewardMagnitude = [SessionDataWeek.Custom.RewardMagnitude SessionData.Custom.RewardMagnitude];
         SessionDataWeek.Custom.TrialNumber = [SessionDataWeek.Custom.TrialNumber SessionData.Custom.TrialNumber];
         SessionDataWeek.Custom.AuditoryTrial = [SessionDataWeek.Custom.AuditoryTrial SessionData.Custom.AuditoryTrial];
         if isfield(SessionDataWeek.Custom,'AuditoryOmega')
            SessionDataWeek.Custom.AuditoryOmega = [SessionDataWeek.Custom.AuditoryOmega SessionData.Custom.AuditoryOmega];
            SessionDataWeek.Custom.LeftClickRate = [SessionDataWeek.Custom.LeftClickRate SessionData.Custom.LeftClickRate];
            SessionDataWeek.Custom.RightClickRate = [SessionDataWeek.Custom.RightClickRate SessionData.Custom.RightClickRate];
            SessionDataWeek.Custom.LeftClickTrain = [SessionDataWeek.Custom.LeftClickTrain SessionData.Custom.LeftClickTrain];
            SessionDataWeek.Custom.RightClickTrain = [SessionDataWeek.Custom.RightClickTrain SessionData.Custom.RightClickTrain];
            SessionDataWeek.Custom.MoreLeftClicks = [SessionDataWeek.Custom.MoreLeftClicks SessionData.Custom.MoreLeftClicks];
         end
         SessionDataWeek.Custom.DV = [SessionDataWeek.Custom.DV SessionData.Custom.DV];
         SessionDataWeek.Custom.StimDelay = [SessionDataWeek.Custom.StimDelay SessionData.Custom.StimDelay];
         SessionDataWeek.Custom.FeedbackDelay = [SessionDataWeek.Custom.FeedbackDelay SessionData.Custom.FeedbackDelay];
         SessionDataWeek.Custom.MinSampleAud = [SessionDataWeek.Custom.MinSampleAud SessionData.Custom.MinSampleAud];
         SessionDataWeek.Custom.MissedChoice = [SessionDataWeek.Custom.MissedChoice SessionData.Custom.MissedChoice];
         SessionDataWeek.Custom.StimulusDuration = [SessionDataWeek.Custom.StimulusDuration SessionData.Custom.StimulusDuration];
         SessionDataWeek.Custom.Modality = [SessionDataWeek.Custom.Modality SessionData.Custom.Modality];
         SessionDataWeek.Custom.TrialTypes = [SessionDataWeek.Custom.TrialTypes SessionData.Custom.TrialTypes];
         SessionDataWeek.Custom.SkippedFeedback = [SessionDataWeek.Custom.SkippedFeedback SessionData.Custom.SkippedFeedback];
         if isfield(SessionDataWeek.Custom, 'FeedbackTimeNorm') && isfield(SessionData.Custom, 'FeedbackTimeNorm')
            SessionDataWeek.Custom.FeedbackTimeNorm = [SessionDataWeek.Custom.FeedbackTimeNorm SessionData.Custom.FeedbackTimeNorm];
         end
         SessionDataWeek.Custom.DVlog = [SessionDataWeek.Custom.DVlog SessionData.Custom.DVlog];
         SessionDataWeek.Custom.TrialStart = [SessionDataWeek.Custom.TrialStart SessionData.Custom.TrialStart];
         SessionDataWeek.Custom.GracePeriod = [SessionDataWeek.Custom.GracePeriod SessionData.Custom.GracePeriod];
         SessionDataWeek.Custom.Session = [SessionDataWeek.Custom.Session repmat(manip,1,SessionData.nTrials)];
    end
    
    clear SessionData
end

SessionDataWeek.DayvsWeek = 2;
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

    SessionDataWeek.SessionDate = Nomdataset;
    
    %% Enregistrement dataset
    cd(SessionDataWeek.pathname)
    save(['SessionDataWeek_' Nomdataset],'SessionDataWeek')   
end

%% Figures analyses donnees dataset
cd(pathfigures); 

fig_beh(SessionDataWeek);

if sum(SessionDataWeek.Custom.Modality==2)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
    Analyse_Fig_Cfdce(SessionDataWeek, 2);
    if sum(SessionDataWeek.Custom.Modality==1)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
        fig_beh_Cfdce_bimodality(SessionDataWeek);
        Analyse_Fig_Cfdce(SessionDataWeek, 1);
    end
elseif sum(SessionDataWeek.Custom.Modality==1)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
    Analyse_Fig_Cfdce(SessionDataWeek, 1);
end        

