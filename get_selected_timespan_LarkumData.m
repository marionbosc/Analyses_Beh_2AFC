
% Prompt windows to provide the animal's name
prompt = {'Name = '}; dlg_title = 'Animal'; numlines = 1;
def = {'Thy'}; AnimalName = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt   

% Localisation of data files:
Pathtodata = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC';

% Loading of filename list already created:
cd([Pathtodata '/' AnimalName '/Session Data/']);
        uiopen; pathname =cd;
        DatasetName = 'Partial_Session_';
        
%% 2) Session by session implementation and complementary analysis + Super-dataset creation

% Loop on every session to combine into the super-dataset
for Day = 1 : size(filename,2)
    % load SessionData 
    load([pathname '/' filename{Day}])
    
    % Implementation of SessionData
    SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,Day);
    
    %% Plot WT drift of Catched trials (error and correct) over time for the session
    % id of catched trials
    ndxCatched = SessionData.Custom.ChoiceCorrect==1 & SessionData.Custom.CatchTrial | SessionData.Custom.ChoiceCorrect==0;
    [p, YCalc,~,R2adjusted] = polynomial_fit(SessionData.Custom.TrialStartSec(ndxCatched),SessionData.Custom.FeedbackTime(ndxCatched),4); 
    % Plot
    fig = figure('units','normalized','position',[0,0,0.5,0.5]); hold on
    % Plot raw WT data
    scatter(SessionData.Custom.TrialStartSec(ndxCatched)/60,SessionData.Custom.FeedbackTime(ndxCatched),...
        6,'k','Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');  
    % Plot WT data fit
    plot(SessionData.Custom.TrialStartSec(ndxCatched)/60,YCalc,'-','Color',[0.4660, 0.6740, 0.1880],'LineWidth',0.5);
    % Plot labels
    ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
    legend({'Raw WT data', ['R2adj= ' num2str(round(R2adjusted,3))]},'Location','NorthEastoutside');
    title(['Manip ' SessionData.SessionDate ' ' SessionData.Custom.Subject],'fontsize',14); hold off;
    
    pause;
    
    % Prompt windows to inquire whether you want to exclude session(s) from the predefine population 
    prompt = {'Lower time limit';'Upper time limit'}; dlg_title = 'Data to analyse'; numlines = 1;
    def = {'0';'120'}; Answers = inputdlg(prompt,dlg_title,numlines,def); 
    mintimeboundary = str2num(cell2mat(Answers(1))); maxtimeboundary = str2num(cell2mat(Answers(2))); 
    clear def dlg_title numlines prompt Answers
    
    %% Determine the list of trial to include in the Superdataset: trials executed between 15 and 45 minutes after the beginning of the session
    ndxIncl = SessionData.Custom.TrialStartSec./60 > mintimeboundary & SessionData.Custom.TrialStartSec./60 < maxtimeboundary;
    nbTrialtoincl = sum(ndxIncl);
    FirstTrialtoincl = find(ndxIncl, 1);
    LastTrialtoincl = find(ndxIncl, 1,'last');
    close all
    %% Concatenation of the SessionData into the superdata structure
    % Case 1st session of the dataset
    if Day == 1 || ~exist('SessionDataWeek', 'var')
        
         % Name of the fields that require a specific treatment
         WeirdFields = {'Rig';'Subject';'PsychtoolboxStartup';'LightIntensityLeft';'LightIntensityRight';...
             'GratingOrientation';'rDots';'PulsePalParamStimulus';'PulsePalParamFeedback';...
             'LastSuccessCatchTial'; 'CatchCount'};

         % Retrieve the name of the fields of SessionData.Custom
         MainFields = fieldnames(SessionData.Custom);

         % Resampling of the data for the regular fields
         for field = 1: size (MainFields,1)
            if ~any(strcmp(MainFields{field},WeirdFields))
                SessionData.Custom.(MainFields{field}) = SessionData.Custom.(MainFields{field})(:,FirstTrialtoincl:LastTrialtoincl);
            end
         end
          
         SessionDataWeek = SessionData; SessionDataWeek.DaysvsWeek = 2;
         SessionDataWeek.nTrials = nbTrialtoincl;
         SessionDataWeek.TimeBoundaries = [mintimeboundary;maxtimeboundary];
         SessionDataWeek.Custom.Session = repmat(Day,1,SessionDataWeek.nTrials);
        
    % Case following sessions of the dataset
    else
        % Retrieve the name of the fields of SessionData.Custom
        CustomFields = fieldnames(SessionData.Custom);

        % Concatenation of the data for the regular fields
        for field = 1: size (CustomFields,1)
            if ~any(strcmp(CustomFields{field},WeirdFields)) && any(strcmp(CustomFields{field},MainFields))
                SessionDataWeek.Custom.(CustomFields{field}) = [SessionDataWeek.Custom.(CustomFields{field}) SessionData.Custom.(CustomFields{field})(:,FirstTrialtoincl:LastTrialtoincl)];
            end
        end
        
        % WeirdField special case:
        SessionDataWeek.Custom.rDots = [SessionDataWeek.Custom.rDots SessionData.Custom.rDots];
        SessionDataWeek.TimeBoundaries = [SessionDataWeek.TimeBoundaries [mintimeboundary;maxtimeboundary]];
        
        % Add the rank of the session in the dataset for all the trials of the session
        SessionDataWeek.nTrials = SessionDataWeek.nTrials + nbTrialtoincl;
        SessionDataWeek.Custom.Session = [SessionDataWeek.Custom.Session repmat(Day,1,nbTrialtoincl)];
    end
    
    clear SessionData CustomFields
end
%% Plot on Confidence behavior
Modality = 4;
f2=figure('units','normalized','position',[0,0,0.5,1]);
% [SessionData,Perf] = Psychometric_fig(SessionData, Modality,nb_row_fig,nb_col_fig,positn_fig,colorplot)
Psychometric_fig(SessionDataWeek, Modality,2,2,1); 
% [SessionData] = Vevaiometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig, SensoORMvt,plotpointormean,normornot,BorneMaxWT)
Vevaiometric_fig(SessionDataWeek, Modality,2,2,2,1,2,0,15);
% PerfperWT_fig(SessionData, BorneMin,BorneMaxWT, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Statornot,Modality)
PerfperWT_fig(SessionDataWeek, 0.5,15, 0,2,2,3,SessionDataWeek.SessionDate,1,Modality);
% ShvsLgWT_fig(SessionData, Modality, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Percentile,nbBin,BorneMaxWT)
ShvsLgWT_fig(SessionDataWeek, Modality, 0,2,2,4,'',50,8,15);

