%% Script to combine several sessions of training in a superdata structure
%
% 1) Identify the Session to combine together:
%    a) Prompt windows to provide the name of the Bpod protocol used for
%    data collection
%       --> Allow to identify the path towards the data files to concatenate
%    b) Prompt windows to provide the animal's name
%       --> Allow to identify the path towards the data files to concatenate
%    c) Prompt windows to decide whether the list of file to compile already
%    exist or need to be created
%       --> finder to select and load the existing filename file
%        or
%    	--> Finder windows open to select the data fileS of the session to include
%        - Select them all at once (use CTR or cmd to select all the files at the same time)
%        - Create a variable containing all the filename and a variable
%       containing the pathname
%        - Prompt windows to inquire whether you want to save the filename and
%       pathname in the Session Data folder of the animal (0 = no / 1 = save)
%    d) GUI with the list of critical criteria and their respective value to select the "good
%    sessions' to analyse Confidence behavior. Uncheck the unnecessary criteria and adjust the 
%    value according to the type of session you want to select, and then click on "Update".  
%
% 2) Implement and do missing analysis on every session SessionData, select the one that fits the 
%   Confidence criterion set earlier and concatenate the sessions that passed the selection
%   - Load  and implement SessionData
%   - Plot/Analysis for the session (if it has not been done already)
%   - Check if comply to the Confidence criteria and if not, ask if we
%   still want to include the session based on the session value for the
%   criteria it didn't fill
%   - Concatenate the SessionData into the superdata structure (SessionDataWeek)
%
% 3) Save superdataset created (SessionDataWeek) in animal's data folder
%    - Prompt windows to inquire whether you want to save the dataset in the Session Data folder of the animal (0 = no / 1 = save)
%       --> Case = 1: Prompt windows to provide the name of the Dataset and Filename
%
% 4) Redefine the sessions to include into the dataset (in case Confidence
%    criteria where not reached for some session that where then excluded)
%    - Prompt windows to inquire whether you want to exclude session(s) from
%    the predefine population
%       --> Case = 1: GUI with the list of the session contained in
%       SessionDataWeek to unselect the session to exclude (blank if
%       excluded)
%       - Prompt windows to inquire whether you want to save the new filename
%       of the new population of session in the Session Data folder of the animal (0 = no / 1 = save)
%       --> Case = 1: Prompt windows to provide the name of the Dataset filenames
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
def = {'WT'}; AnimalName = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt   

% Localisation of data files:
Pathtodata = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC';
cd(Pathtodata);

% Prompt windows to select if dataset already exist or needs to be create
answer = questdlg('Filenames need to be...','Dataset filenames', 'loaded','created','');

% Handle response
switch answer
    case 'loaded'
        cd([Pathtodata '/' AnimalName '/Session Data/']);
        uiopen; pathname =cd;
        DatasetName = '19';
    case 'created'
        % Finder windows open to select the data files of the session to include
        [filename,pathname] = uigetfile([Pathtodata '/' AnimalName '/Session Data/*.mat'], 'MultiSelect','on');

        % Prompt windows to inquire whether you want to save the filename and pathname 
        prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
        def = {'0'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
        clear def dlg_title numlines prompt

        DatasetName = '19';

        % Case "Yes"
        if saving==1
            % Prompt windows to provide the name of the Dataset
            prompt = {'Date of Sessions = '}; dlg_title = 'Name dataset'; numlines = 1;
            def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
            clear def dlg_title numlines prompt 

            % Save pathname and filename from the population of session selected
            cd([Pathtodata '/' AnimalName '/Session Data']);
            save(['Filenames_' DatasetName],'filename')
            save(['Pathname_Local_' AnimalName],'pathname')
        end
end

% Set criteria to include in the Confidence analysis:
get_SessionData_ConfidenceSettings(1);

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
        
        % Case more than 50 visual trials
        if sum(SessionData.Custom.Modality==4)>50
            % Case the plot/analysis on Confidence behavior does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceVis.png'],'file')~=2
                CfdceVis = Analyse_Fig_Cfdce(SessionData, 4); % Analysis confidence beh
                FigurePathCfdceVis = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceVis.png']);
                saveas(CfdceVis,FigurePathCfdceVis,'png'); takeabreak = true;
            end
        end
        
    end    

    if takeabreak
        pause; takeabreak = false;    
    end
    
    close all
    
    %% Test if the dataset can be include in the Confidence analysis:
    clc
    [SessionData, Include] = get_SessionData_ConfidenceSettings(2,SessionData,ConfidenceSettings);
    
    if Include
    %% Concatenation of the SessionData into the superdata structure
        % Case 1st session of the dataset
        if Day == 1 || ~exist('SessionDataWeek', 'var')
            DayIncl = 1;
            SessionDataWeek = SessionData;
            SessionDataWeek.SessionDate = []; SessionDataWeek.filename = [];
            SessionDataWeek.Custom.Session = repmat(DayIncl,1,SessionData.nTrials);
            MainFields = fieldnames(SessionData.Custom);
        % Case following sessions of the dataset
        else
            DayIncl = DayIncl + 1;
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

             % Add the rank of the session in the dataset for all the trials of the session
             SessionDataWeek.Custom.Session = [SessionDataWeek.Custom.Session repmat(DayIncl,1,SessionData.nTrials)];
        end
        
    else
        filename{Day} = [];
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
    def = {['Cfdce_' AnimalName]}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 
    
    % Prompt windows to provide the name of the Filename name
    prompt = {'Name filename = '}; dlg_title = 'Name filename'; numlines = 1;
    def = {['Filename_' DatasetName]}; FilenameName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 
    
    % Save the name of the dataset file and the filename in SessionDataWeek
    SessionDataWeek.SessionDate = FilenameName;
    SessionDataWeek.filename = ['SessionDataWeek_' DatasetName];
    
    % Save SessionDataWeek
    cd([Pathtodata '/' AnimalName '/Session Data']);
    save(['SessionDataWeek_' DatasetName],'SessionDataWeek')   
end

%% 4) Redefine the sessions to include into the dataset

% Prompt windows to inquire whether you want to exclude session(s) from the predefine population 
prompt = {'Modify previous session selection? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'1'}; Modify = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

if Modify == 1
    % Create GUI with checkbox for each previously selected session
    nb_column = max(1,round(size(filename,2)/30));
    top = (20*30)+50;
    h.f = figure('Position',[100 100 350*nb_column top]);
    Day = 1; Xcoord = 10;keepgoing = 1;
    for column = 1:nb_column
        while Day <= 30 * column && keepgoing==1
            h.c(Day) = uicontrol('style','checkbox', 'string',filename{Day},...
                      'Value', 1,...
                      'Position',[Xcoord top-(20*(Day-30*(column-1))) 300 15]);
            Day = Day+1; keepgoing=0;
            if Day< size(filename,2)
                keepgoing = 1;
            end
        end
        Xcoord = 10 + column*350;
    end
    h.p = uicontrol('Style', 'pushbutton', 'string', 'Update dataset list',...
            'Position', [20 20 100 20],'CallBack',{@PushButtonFilename,filename,h});
    h.p2 = uicontrol('Style', 'pushbutton', 'string', 'Close',...
        'Position', [200 20 60 20],'CallBack',{@PushButtonClose,h});
    
    waitfor(h.f)
    
    % Prompt windows to inquire whether you want to save the new filename
    prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
    def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
    clear def dlg_title numlines prompt
    
    % Case "Yes"
    if saving==1
        % Prompt windows to provide the name of the Dataset
        prompt = {'Name file = '}; dlg_title = 'New dataset filename'; numlines = 1;
        def = {FilenameName}; FilenameName = char(inputdlg(prompt,dlg_title,numlines,def)); 
        clear def dlg_title numlines prompt 
        % Save pathname and filename from the new population of session selected
        cd([Pathtodata '/' AnimalName '/Session Data'])
        save(FilenameName,'filename')
        save(['Pathname_Local_' AnimalName],'pathname')
    end
    
end


%% 5) Plot figures on general and confidence behavior on the combined dataset
% Path to Analyses folder of the animal
cd([Pathtodata '/' AnimalName '/Analyses']); 

% Plot of general behavior analysis : [f1,Error] = fig_beh(SessionData,normornot)
fig_beh(SessionDataWeek);

% Plot on Confidence behavior : [f2,Perf]=Analyse_Fig_Cfdce(SessionData, Modality,BorneMaxWT)
Analyse_Fig_Cfdce(SessionDataWeek, 4,19);
        

