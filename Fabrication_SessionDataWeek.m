%% Script to combine several sessions of training in a superdata structure
%
% 1) Identify the Session to combine together:
%    - Prompt windows to provide the animal's name
%       --> Allow to identify the path towards the data files to concatenate
%    - Finder windows open to select the data fileS of the session to include
%       --> Select them all at once (use CTR or cmd to select all the files at the same time)
%    - Create a variable containing all the filename and a variable
%    containing all tle pathname
%    - Prompt windows to inquire whether you want to save the filename and
%    pathname in the Session Data folder of the animal (0 = no / 1 = save)
%       --> Case = 1: Prompt windows to provide the name of the Dataset filenames and pathnames
%
% 2) Implement and do missing analysis on every session SessionData and concatenate all sessions 
%   - Load  and implement SessionData
%   - Plot/Analysis for the session (if it has not been done already)
%   - Concatenate the SessionData into the superdata structure (SessionDataWeek)
%
% 3) Save superdataset created (SessionDataWeek) in animal's data folder
%    - Prompt windows to inquire whether you want to save the dataset in the Session Data folder of the animal (0 = no / 1 = save)
%       --> Case = 1: Prompt windows to provide the name of the Dataset filenames and pathnames
%
% 4) Redefine the sessions to include into the dataset (in case daily
% analysis revealed sessions to exclude)
%    - Prompt windows to inquire whether you want to exclude session(s) from
%    the predefine population
%       --> Case = 1: GUI with the list of the session contained in
%       SessionDataWeek to unselect the session to exclude
%       - After selection, Run and Advance the script without closing the GUI to continue
%       - Prompt windows to inquire whether you want to save the new filename and
%    pathname of the new population of session in the Session Data folder of the animal (0 = no / 1 = save)
%       --> Case = 1: Prompt windows to provide the name of the Dataset filenames and pathnames
% 
% 5) Plot figures on general and confidence behavior on the combined dataset
% 
%

%% 1) Retrieve the path towards all the SessionData to combine together:
% GUI to get the Bpod protocol name to localise the data files:
prompt = {'Bpod protocol = '}; dlg_title = 'Protocol?'; numlines = 1;
def = {'Mouse2AFC'}; BpodProtocol = cell2mat(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt

% Prompt windows to provide the animal's name
prompt = {'Name = '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; AnimalName = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt   

% Prompt windows to select the localisation of data files:
Pathtodata = choosePath(BpodProtocol);
cd(Pathtodata);

% Prompt windows to select if dataset already exist or needs to be create
answer = questdlg('Filenames need to be...','Dataset filenames', 'loaded','created','');

% Handle response
switch answer
    case 'loaded'
        cd([Pathtodata '/' AnimalName '/Session Data/']);
        uiopen; pathname =cd;
        DatasetName = '18';
    case 'created'
        % Finder windows open to select the data files of the session to include
        [filename,pathname] = uigetfile([Pathtodata '/' AnimalName '/Session Data/*.mat'], 'MultiSelect','on');

        % Prompt windows to inquire whether you want to save the filename and pathname 
        prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
        def = {'0'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
        clear def dlg_title numlines prompt

        DatasetName = '18';

        % Case "Yes"
        if saving==1
            % Prompt windows to provide the name of the Dataset
            prompt = {'Date of Sessions = '}; dlg_title = 'Name dataset'; numlines = 1;
            def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
            clear def dlg_title numlines prompt 

            % Save pathname and filename from the population of session selected
            cd([Pathtodata '/' AnimalName '/Session Data']);
            save(['AllDatafilename_' DatasetName],'filename')
            save(['AllDatapathname_' DatasetName],'pathname')
        end
end

%% 2) Session by session implementation and complementary analysis + Super-dataset creation

% Loop on every session to combine into the super-dataset
for Day = 1 : size(filename,2)
    % load SessionData 
    load([pathname '/' filename{Day}])
    
    % Implementation of SessionData
    SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,Day);
        
    %% Plot/Analysis for the session (if it has not been done already)
    
    % Path towards Session Figure folder of the animal:
    pathfigures = [Pathtodata '/' AnimalName '/Session Figures'];
    cd(pathfigures);
    takeabreak = false;
    
    % Case the GnlBeh plot for this session does not appear in the Session Figure folder:
    if exist([SessionData.filename(1:end-4) 'GnlBeh.png'],'file')~=2
        Session = fig_beh(SessionData); % General behavior analysis and plot
        FigurePathSession = fullfile(pathfigures,[SessionData.filename(1:end-4) 'GnlBeh.png']);
        saveas(Session,FigurePathSession,'png'); takeabreak = true;
    end
    
    % Plotting of the confidence signature if enough CatchTrials:
    if sum(SessionData.Custom.CatchTrial)>10
        % Case more than 50 olfactory trials
        if sum(SessionData.Custom.Modality==1)>50
            % Case the plot/analysis on Confidence for Olfactory trials does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
                CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analysis confidence Olf only
                FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
                saveas(CfdceOlf,FigurePathCfdceOlf,'png'); takeabreak = true;
            end
        end
        
        % Case more than 50 auditory click trials
        if sum(SessionData.Custom.Modality==2)>50
            % Case the plot/analysis on Confidence for Auditory trials does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
                CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analysis confidence Aud only
                FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
                saveas(CfdceAud,FigurePathCfdceAud,'png'); takeabreak = true;
            end
        end
        
        % Case more than 50 auditory Frequency trials
        if sum(SessionData.Custom.Modality==3)>50
            if exist([SessionData.filename(1:end-4) 'CfdceAudFqcy.png'],'file')~=2
                CfdceBeh = Analyse_Fig_Cfdce(SessionData, 3); % Analysis confidence Aud only
                FigurePathCfdceBeh = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAudFqcy.png']);
                saveas(CfdceAud,FigurePathCfdceAud,'png'); takeabreak = true;
            end
        end
        
        % Case more than 50 brightness trials
        if sum(SessionData.Custom.Modality==4)>50
            % Case the plot/analysis on Confidence for Brightness trials does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceBright.png'],'file')~=2
                CfdceBright = Analyse_Fig_Cfdce(SessionData, 4); % Analysis confidence Aud only
                FigurePathCfdceBright = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceBright.png']);
                saveas(CfdceBright,FigurePathCfdceBright,'png'); takeabreak = true;
            end
        end
        
        % Case more than 20 olfactory and 20 auditory trials
        if sum(SessionData.Custom.Modality==1)>20 && sum(SessionData.Custom.Modality==2)>20  
        % Case the plot/analysis on both modality does not exist
            if exist([SessionData.filename(1:end-4) 'Cfdce.png'],'file')~=2 && sum(SessionData.Custom.CatchTrial)>10
                Cfdce = fig_beh_Cfdce_bimodality(SessionData);  % Analysis confidence both modality
                FigurePathCfdce = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Cfdce.png']);
                saveas(Cfdce,FigurePathCfdce,'png'); takeabreak = true;
            end
        end
    end    

    if takeabreak
        pause; takeabreak = false;    
    end
    
    close all
    
    %% Concatenation of the SessionData into the superdata structure
    % Case 1st session of the dataset
    if Day == 1
        SessionDataWeek = SessionData;
        SessionDataWeek.Custom.Session = repmat(Day,1,SessionData.nTrials);
        MainFields = fieldnames(SessionData.Custom);
        
    % Case following sessions of the dataset
    else
         % Retrieve the name of the fields of SessionData.Custom
         CustomFields = fieldnames(SessionData.Custom);
         
         % Name of the fields that require a specific treatment
         WeirdFields = {'OdorID';'Rig';'Subject';'PsychtoolboxStartup';'OlfactometerStartup';...
            'FreqStimulus';'PulsePalParamStimulus';'PulsePalParamFeedback';...
            'AuditoryOmega';'LeftClickRate';'RightClickRate';'LeftClickTrain';'RightClickTrain'};
        
        % Concatenation of the data for the regular fields
         for field = 1: size (CustomFields,1)
            if ~any(strcmp(CustomFields{field},WeirdFields)) && any(strcmp(CustomFields{field},MainFields))
                SessionDataWeek.Custom.(CustomFields{field}) = [SessionDataWeek.Custom.(CustomFields{field}) SessionData.Custom.(CustomFields{field})];
            end
         end
        
         % Concatenation of the data for the other "weird" fields
         if isfield(SessionDataWeek.Custom,'AuditoryOmega') % case of auditory session
            SessionDataWeek.Custom.AuditoryOmega = [SessionDataWeek.Custom.AuditoryOmega SessionData.Custom.AuditoryOmega(1:SessionData.nTrials)];
            SessionDataWeek.Custom.LeftClickRate = [SessionDataWeek.Custom.LeftClickRate SessionData.Custom.LeftClickRate(1:SessionData.nTrials)];
            SessionDataWeek.Custom.RightClickRate = [SessionDataWeek.Custom.RightClickRate SessionData.Custom.RightClickRate(1:SessionData.nTrials)];
            SessionDataWeek.Custom.LeftClickTrain = [SessionDataWeek.Custom.LeftClickTrain SessionData.Custom.LeftClickTrain(1:SessionData.nTrials)];
            SessionDataWeek.Custom.RightClickTrain = [SessionDataWeek.Custom.RightClickTrain SessionData.Custom.RightClickTrain(1:SessionData.nTrials)];
         end
         
         if isfield(SessionDataWeek.Custom,'OdorID') % case of olfactory session
             SessionDataWeek.Custom.OdorID = [SessionDataWeek.Custom.OdorID SessionData.Custom.OdorID];
         end
         
         % Add the rank of the session in the dataset for all the trials of the session
         SessionDataWeek.Custom.Session = [SessionDataWeek.Custom.Session repmat(Day,1,SessionData.nTrials)];
    end
    
    clear SessionData CustomFields
end

% Check if the filed FeedbackTimeNorm is fully filled --> if not: remove it
if isfield(SessionDataWeek.Custom, 'FeedbackTimeNorm')
    if size(SessionDataWeek.Custom.FeedbackTimeNorm,2) < size(SessionDataWeek.Custom.ChoiceLeft,2)
        SessionDataWeek.Custom = rmfield(SessionDataWeek.Custom,'FeedbackTimeNorm');
    end
end

% Add specific field to identify the superdata structure and total number of trial
SessionDataWeek.DayvsWeek = 2;
SessionDataWeek.nTrials = size(SessionDataWeek.Custom.ChoiceLeft,2);

%% 3) Save superdataset created (SessionDataWeek)

% Prompt windows to inquire whether you want to save the superdataset created
prompt = {'Save superdataset? = '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Case "Yes"
if saving==1
    % Prompt windows to provide the name of the Dataset
    prompt = {'Name superdataset = '}; dlg_title = 'Date Sessions'; numlines = 1;
    def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 
    
    % Save the name of the dataset in SessionDataWeek
    SessionDataWeek.SessionDate = DatasetName;
    
    % Save SessionDataWeek
    cd([Pathtodata '/' AnimalName '/Session Data']);
    save(['SessionDataWeek_' DatasetName],'SessionDataWeek')   
end

%% 4) Redefine the sessions to include into the dataset

% Prompt windows to inquire whether you want to exclude session(s) from the predefine population 
prompt = {'Modify previous session selection? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'0'}; Modify = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

if Modify == 1
    % Create GUI with checkbox for each previously selected session
    top = (20*size(filename,2))+30;
    h.f = figure('Position',[100 100 top 500]);

    for Day = 1:size(filename,2)
        h.c(Day) = uicontrol('style','checkbox', 'string',filename{Day},...
              'Value', 1,...
              'Position',[10 top 300 15]);
        top=top-20;
    end

    h.p = uicontrol('Style', 'pushbutton', 'string', 'Update dataset list',...
            'Position', [20 20 100 20]);
end

%% Processing of the new list of session to combine
if Modify == 1
    checkboxValues = find(cell2mat(get(h.c, 'Value')));
    filename = filename(checkboxValues);

    % Prompt windows to inquire whether you want to save the new filename and pathname
    prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
    def = {'0'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
    clear def dlg_title numlines prompt
    
    % Case "Yes"
    if saving==1
        % Prompt windows to provide the name of the Dataset
        prompt = {'Date of Sessions = '}; dlg_title = 'Name dataset'; numlines = 1;
        def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
        clear def dlg_title numlines prompt  
        
        % Save pathname and filename from the new population of session selected
        cd([Pathtodata '/' AnimalName '/Session Data'])
        save(['Datafilename_' DatasetName],'filename')
        save(['Datapathname_' DatasetName],'pathname')
    end
    close all
    
    % Prompt to remind to go back to the step 2 of the script to reconcatenate the data
    msgbox('Go back to step 2 to create a new dataset with the newly selected sessions');
end


%% 5) Plot figures on general and confidence behavior on the combined dataset
% Path to Session Figure of the animal
cd([Pathtodata '/' AnimalName '/Session Figures']); 

% Plot of general behavior analysis
fig_beh(SessionDataWeek);

% Plot on Confidence behavior (if applies) per sensory modality
if sum(SessionDataWeek.Custom.Modality==2)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
    Analyse_Fig_Cfdce(SessionDataWeek, 2);
    if sum(SessionDataWeek.Custom.Modality==1)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
        fig_beh_Cfdce_bimodality(SessionDataWeek);
        Analyse_Fig_Cfdce(SessionDataWeek, 1);
    end
elseif sum(SessionDataWeek.Custom.Modality==1)/sum(SessionDataWeek.Custom.Modality==1 | SessionDataWeek.Custom.Modality==2)>0.1
    Analyse_Fig_Cfdce(SessionDataWeek, 1);
elseif sum(SessionDataWeek.Custom.Modality==4)>30
    Analyse_Fig_Cfdce(SessionDataWeek, 4);
end        

