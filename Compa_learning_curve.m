%% Script to build and compare learning curve on Auditory discrimination between 2 cohorts:
%
% 
%% Data variables to retrieve 
Accu_coh1 = []; Bias_coh1 = [];
Accu_coh2 = []; Bias_coh2 = [];

% Path data server and local
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Mouse2AFC';
pathdataserver='/Volumes/home/BpodData/Mouse2AFC/';
cd(pathdataserver);  

%% Retrieve data 1st cohort
% Name of the 1st cohort
prompt = {'Name of the cohort ?'}; dlg_title = 'First cohort:'; numlines = 1;
def = {''}; Name_coh1 = cell2mat(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt

% Number of animal to include in the analysis for the 1st cohort
prompt = {'N(1st cohort)= '}; dlg_title = 'How many animals?'; numlines = 1;
def = {'4'}; Nb_animal = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Loop on each animal to retrieve the data:
for animal = 1 : Nb_animal
    % Get name to find path towards animal's data:
    prompt = {'Name= '}; dlg_title = 'Which animal ?'; numlines = 1;
    def = {'MC'}; Name = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt   

    % Retrieve data files path
    [filename,pathname] = uigetfile([pathdataserver '/' Name '/Session Data/*.mat'], 'MultiSelect','on');

    % Loop to retrieve data for each session for that animal:
    f=figure;
    for session= 1 : size(filename,2)
        % load data
        load([pathname '/' filename{session}])
        % Check and implement data (if necessary)
        SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,session);
        % Retrieve data on accuracy and bias for the session and plot the Psychometric
        [SessionData,Accu(session)] = Psychometric_fig(SessionData, 2,1,1,1);
    end
    % Fill data variable to compute the final analysis/plot
    % case nb of sessions for this animal < max nb of sessions per animal
    if session < size(Accu_coh1,2) 
        Accu_coh1 = [Accu_coh1; Accu.globale NaN(1,size(Accu_coh1,2)-session)];
        Bias_coh1 = [Bias_coh1; Accu.Bias NaN(1,size(Accu_coh1,2)-session)];
        
    % case nb of sessions for this animal < max nb of sessions per animal
    elseif session > size(Accu_coh1,2)
        Accu_coh1 = [Accu_coh1 NaN(size(Accu_coh1,1),session-size(Accu_coh1,2)) ; Accu(:).globale];
        Bias_coh1 = [Bias_coh1 NaN(size(Bias_coh1,1),session-size(Bias_coh1,2)) ; Accu(:).Bias];
        
    % case nb of sessions for this animal = max nb of sessions per animal
    elseif session == size(Accu_coh1,2)
        Accu_coh1 = [Accu_coh1; Accu(:).globale];
        Bias_coh1 = [Bias_coh1; Accu(:).Bias];
    end

    clearvars -except Accu_* Bias_* Nb_of_sessions Animal_Names Saving pathdata* Name_coh*
end

%% Retrieve data 2nd cohort
% Name of the 2nd cohort
prompt = {'Name of the cohort ?'}; dlg_title = 'Second cohort:'; numlines = 1;
def = {''}; Name_coh2 = cell2mat(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt

% Number of animal to include in the analysis for the 1st cohort
prompt = {'N(2nd cohort)= '}; dlg_title = 'How many animals?'; numlines = 1;
def = {'4'}; Nb_animal = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Loop on each animal to retrieve the data:
for animal = 1 : Nb_animal
    % Get name to find path towards animal's data:
    prompt = {'Name= '}; dlg_title = 'Which animal ?'; numlines = 1;
    def = {'MC'}; Name = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt   

    % Retrieve data files path
    [filename,pathname] = uigetfile([pathdataserver '/' Name '/Session Data/*.mat'], 'MultiSelect','on');

    % Loop to retrieve data for each session for that animal:
    f=figure;
    for session= 1 : size(filename,2)
        % load data
        load([pathname '/' filename{session}])
        % Check and implement data (if necessary)
        SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,session);
        % Retrieve data on accuracy and bias for the session and plot the Psychometric
        [SessionData,Accu(session)] = Psychometric_fig(SessionData, 2,1,1,1);
    end
    % Fill data variable to compute the final analysis/plot
    % case nb of sessions for this animal < max nb of sessions per animal
    if session < size(Accu_coh2,2) 
        Accu_coh2 = [Accu_coh2; Accu.globale NaN(1,size(Accu_coh2,2)-session)];
        Bias_coh2 = [Bias_coh2; Accu.Bias NaN(1,size(Bias_coh2,2)-session)];
        
    % case nb of sessions for this animal < max nb of sessions per animal
    elseif session > size(Accu_coh2,2)
        Accu_coh2 = [Accu_coh2 NaN(size(Accu_coh2,1),session-size(Accu_coh2,2)) ; Accu(:).globale];
        Bias_coh2 = [Bias_coh2 NaN(size(Bias_coh2,1),session-size(Bias_coh2,2)) ; Accu(:).Bias];
        
    % case nb of sessions for this animal = max nb of sessions per animal
    elseif session == size(Accu_coh2,2)
        Accu_coh2 = [Accu_coh2; Accu(:).globale];
        Bias_coh2 = [Bias_coh2; Accu(:).Bias];
    end

    clearvars -except Accu_* Bias_* Nb_of_sessions Animal_Names Saving pathdata* Name_coh*
end

%% Readjustment of the size of the data matrices in case the differ
% case nb of sessions for cohort 2 < nb of sessions for cohort 1
if size(Accu_coh2,1) < size(Accu_coh2,2) 
    Accu_coh2 = [Accu_coh2 NaN(size(Accu_coh2,1),size(Accu_coh1,2)-size(Accu_coh2,2))];
    Bias_coh2 = [Bias_coh2 NaN(size(Bias_coh2,1),size(Bias_coh1,2)-size(Bias_coh2,2))];
% case nb of sessions for cohort 2 > nb of sessions for cohort 1
elseif session > size(Accu_coh2,2)
    Accu_coh1 = [Accu_coh1 NaN(size(Accu_coh1,1),size(Accu_coh2,2)-size(Accu_coh1,2))];
    Bias_coh1 = [Bias_coh1 NaN(size(Bias_coh1,1),size(Bias_coh2,2)-size(Bias_coh1,2))];
end

clearvars -except Accu_* Bias_* Name_coh*
%% Representation de la learning curve et du biais au fur et à mesure des sessions:

Mean_Accu_coh1 = nanmean(Accu_coh1,1);
SEM_Accu_coh1 = nanstd(Accu_coh1,1)./sqrt(size(Accu_coh1,1));
Mean_Accu_coh2 = nanmean(Accu_coh2,1);
SEM_Accu_coh2 = nanstd(Accu_coh2,1)./sqrt(size(Accu_coh2,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
errorbar(1:size(Mean_Accu_coh1,2),Mean_Accu_coh1,SEM_Accu_coh1 ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','k','MarkerSize',6,'Visible','on');
e=errorbar(1:size(Mean_Accu_coh2,2),Mean_Accu_coh2,SEM_Accu_coh2 ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 size(Mean_Accu_coh1,2)];
plot([1 size(Mean_Accu_coh1,2)], [0.5 0.5], '--k'); 
leg = legend([Name_coh1 ' (n=' num2str(size(Accu_coh1,1)) ')'],[Name_coh2 ' (n=' num2str(size(Accu_coh2,1)) ')'],'Location','southeast');
leg.FontSize = 10; legend('boxoff');

%% Bias
% Absolute value of bias
Bias_abs_coh1 = abs(Bias_coh1 - 0.5);
Bias_abs_coh2 = abs(Bias_coh2 - 0.5);

Mean_Bias_coh1 = nanmean(Bias_abs_coh1,1);
SEM_Bias_coh1 = nanstd(Bias_abs_coh1,1)./sqrt(size(Bias_abs_coh1,1));
Mean_Bias_coh2 = nanmean(Bias_abs_coh2,1);
SEM_Bias_coh2 = nanstd(Bias_abs_coh2,1)./sqrt(size(Bias_abs_coh2,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
errorbar(1:size(Mean_Bias_coh1,2),Mean_Bias_coh1,SEM_Bias_coh1 ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','k','MarkerSize',6,'Visible','on');
e=errorbar(1:size(Mean_Bias_coh2,2),Mean_Bias_coh2,SEM_Bias_coh2 ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 size(Mean_Bias_coh1,2)];
leg = legend([Name_coh1 ' (n=' num2str(size(Bias_coh1,1)) ')'],[Name_coh2 ' (n=' num2str(size(Bias_coh2,1)) ')'],'Location','northeast');
leg.FontSize = 10; legend('boxoff');
