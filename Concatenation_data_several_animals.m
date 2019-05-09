%% Script to retrieve and combine datasets of several animals together
%
%
% Input:
% 1) Get path towards the datasets to combine (one per animal)
% 2) Build structure SessionDatasets containing all the data
%   * Load the dataset of the animal
%   * Add it to SessionDatasets  
% 3) Save superstructure of data created: SessionDatasets
% 4) Redefine the animals to include into the final superdataset:
% 
%

%% 1) Get path towards the datasets to combine (one per animal)

% Number of animals to put in the superdataset:
prompt = {'N = '}; dlg_title = 'Number of animals'; numlines = 1;
def = {'3'}; N = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt  

% Locate the dataset for each animal from the animal's name
% Prompt windows to select the localisation of data files:
Pathtodata = choosePath('Mouse2AFC');
cd(Pathtodata);
for animal = 1 : N
    cd(Pathtodata);
    prompt = {'Name= '}; dlg_title = 'Animal'; numlines = 1;
    def = {'M'}; Names{animal} = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  
    [filename{animal},pathname{animal}] = uigetfile([Pathtodata '/' Names{animal} '/Session Data/*.mat']);
end

% Prompt windows to inquire whether you want to save the filename and pathname
pathdataset = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Mouse2AFC/dataset_animaux';

prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'0'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

DatasetName = '18';

% Case "Yes"
if saving==1
    % Prompt windows to provide the name of the Dataset
    prompt = {'Name superdataset = '}; dlg_title = 'TimePeriod_Animals'; numlines = 1;
    def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 

    % Save pathname and filename of each animal to include in the superdataset
    cd(pathdataset)
    save(['AllDatafilename_' DatasetName],'filename')
    save(['AllDatapathname_' DatasetName],'pathname')
end

%% 2) Superdataset building (SessionDatasets)

% Loop on each animal
for animal = 1 : size(pathname,2)
    % load animal dataset
    load([pathname{animal} '/' filename{animal}]);
    SessionDataWeek = SessionData;       
    %% Concatenation of the animal dataset in SessionDatasets
    % Case 1st animal of the dataset
    if animal == 1
        SessionDatasets = SessionDataWeek;
        SessionDatasets.Custom.Subject = repmat(Names(animal),1,SessionDataWeek.nTrials);
        MainFields = fieldnames(SessionDataWeek.Custom);
        
     % Case following animals of the dataset
    else
         % Retrieve the name of the fields of SessionData.Custom
         CustomFields = fieldnames(SessionDataWeek.Custom);
         
         % Name of the fields that require a specific treatment
         WeirdFields = {'OdorID';'Rig';'Session';'Subject';'PsychtoolboxStartup';'OlfactometerStartup';...
            'FreqStimulus';'PulsePalParamStimulus';'PulsePalParamFeedback';'FeedbackTimeNorm';...
            'AuditoryOmega';'LeftClickRate';'RightClickRate';'LeftClickTrain';'RightClickTrain'};
         
         % Concatenation of the data for the regular fields
         for field = 1: size (CustomFields,1)
            if ~any(strcmp(CustomFields{field},WeirdFields)) && any(strcmp(CustomFields{field},MainFields))
                SessionDatasets.Custom.(CustomFields{field}) = [SessionDatasets.Custom.(CustomFields{field}) SessionDataWeek.Custom.(CustomFields{field})];
            end
         end
         
         % Concatenation of the data for the other "weird" fields
         if isfield(SessionDatasets.Custom,'AuditoryOmega') % case of auditory session
            SessionDatasets.Custom.AuditoryOmega = [SessionDatasets.Custom.AuditoryOmega SessionDataWeek.Custom.AuditoryOmega];
            SessionDatasets.Custom.LeftClickRate = [SessionDatasets.Custom.LeftClickRate SessionDataWeek.Custom.LeftClickRate];
            SessionDatasets.Custom.RightClickRate = [SessionDatasets.Custom.RightClickRate SessionDataWeek.Custom.RightClickRate];
            SessionDatasets.Custom.LeftClickTrain = [SessionDatasets.Custom.LeftClickTrain SessionDataWeek.Custom.LeftClickTrain];
            SessionDatasets.Custom.RightClickTrain = [SessionDatasets.Custom.RightClickTrain SessionDataWeek.Custom.RightClickTrain];
         end
         
         if isfield(SessionDatasets.Custom,'OdorID') % case of olfactory session
             SessionDatasets.Custom.OdorID = [SessionDatasets.Custom.OdorID SessionDataWeek.Custom.OdorID];
         end
         
         if isfield(SessionDatasets.Custom, 'FeedbackTimeNorm') && isfield(SessionDataWeek.Custom, 'FeedbackTimeNorm') % Normalized WT
            SessionDatasets.Custom.FeedbackTimeNorm = [SessionDatasets.Custom.FeedbackTimeNorm SessionDataWeek.Custom.FeedbackTimeNorm];
         end
         
         % Reattribute a rank to the session in the dataset to be continuous between animal datasets
         %SessionDatasets.Custom.Session = [SessionDatasets.Custom.Session SessionDataWeek.Custom.Session+max(SessionDatasets.Custom.Session)];
         % Name of the animal add for each trial of its dataset
         SessionDatasets.Custom.Subject = [SessionDatasets.Custom.Subject repmat(Names(animal),1,SessionDataWeek.nTrials)];
    end
    
    clear SessionDataWeek
end

SessionDatasets.DayvsWeek = 2;
SessionDatasets.nTrials = size(SessionDatasets.Custom.ChoiceLeft,2);
%% 3) Save superdataset created (SessionDatasets)

% Prompt windows to inquire whether you want to save the superdataset created
prompt = {'Save superdataset? = '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Case "Yes"
if saving==1
    % Prompt windows to provide the name of the SuperDataset
    prompt = {'Name superdataset = '}; dlg_title = 'TimePeriod_Animals'; numlines = 1;
    def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 
    
    % Save the name and the path of the superdataset in SessionDatasets
    SessionDatasets.filename = DatasetName;
    SessionDatasets.pathname = pathdataset;
    
    % Save SessionDatasets
    cd(pathdataset)
    save(['SessionDatasets_' DatasetName],'SessionDatasets')   
end

%% 4) Redefine the animals to include into the final superdataset:

% GUI with checkbox for each previously selected animal (uncheck the ones
% you do not want to include anymore)
top = (20*size(filename,2))+30;
h.f = figure('Position',[100 100 top 500]);

for animal = 1:size(filename,2)
    h.c(animal) = uicontrol('style','checkbox', 'string',Names{animal},...
          'Value', 1,...
          'Position',[10 top 300 15]);
    top=top-20;
end

h.p = uicontrol('Style', 'pushbutton', 'string', 'Update dataset list',...
        'Position', [20 20 100 20]);

%% Processing of the new list of session to combine
checkboxValues = find(cell2mat(get(h.c, 'Value')));
pathname = pathname(checkboxValues);
filename = filename(checkboxValues);

 % Prompt windows to inquire whether you want to save the new filename and pathname
prompt = {'Save filename and pathname? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'1'}; saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Si enregistrement
if saving==1
    % GUI pour recup date du dataset compose
    prompt = {'Name superdataset = '}; dlg_title = 'TimePeriod_Animals'; numlines = 1;
    def = {DatasetName}; DatasetName = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt 

    SessionDataWeek.SessionDate = DatasetName;
    SessionDataWeek.DayvsWeek = 2;

    cd(pathname{1})
    save(['Datafilename_' DatasetName],'filename')
    save(['Datapathname_' DatasetName],'pathname')
end
close all

% Prompt to remind to go back to the step 2 of the script to reconcatenate the data
msgbox('Go back to step 2 to create a new superdataset with the newly selected animals');

