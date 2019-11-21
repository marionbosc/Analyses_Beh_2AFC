%% Load filename list of the animal to perform the analysis on:

% Prompt windows to provide the animal's name
prompt = {'Name = '}; dlg_title = 'Animal'; numlines = 1;
def = {'F0'}; AnimalName = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt   

% Prompt windows to select the localisation of data files:
Pathtodata = choosePath('Mouse2AFC');
pathname = [Pathtodata '/' AnimalName '/Session Data/'];
cd(pathname)
Filename_name = uigetfile; % Select Filename file:
load(Filename_name)
% Folder to save figures:
cd([Pathtodata '/' AnimalName '/Session Figures/']);
mkdir(['Time_effect_' Filename_name(10:end-4)]);
FigurePath = [Pathtodata '/' AnimalName '/Session Figures/Time_effect_' Filename_name(10:end-4)];

statornot = 0;

%% Number of trials executed 
f1 = figure('units','normalized','position',[0,0,0.7,1]); hold on;

for manip= 1 : size(filename,2)
    % Load dataset
    load([pathname '/' filename{manip}])
    Nom = SessionData.Custom.Subject;
    
    if ~isfield(SessionData.Custom, 'TrialStart') || ~isfield(SessionData.Custom, 'TrialStartSec')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if ~isfield(SessionData, 'pathname') && ~isfield(SessionData, 'filename')
            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    %plot(SessionData.Custom.TrialStart,SessionData.Custom.TrialNumber,'color',rand(1,3))
    p=plot(SessionData.Custom.TrialStart,SessionData.Custom.TrialNumber);
    
    Tot_essais(manip) = SessionData.Custom.TrialNumber(end);
    Lasttrialtime(manip) = SessionData.Custom.TrialStart(end);
    LasttrialtimeSec(manip) = SessionData.Custom.TrialStartSec(end);
    
    clear SessionData t
end

title(['Nb of trials executed throughout session - ' Nom],'fontsize',12);
ylabel('Number of executed trials','fontsize',16);xlabel('Time from session start','fontsize',16);
hold off;

% Scatterplot and correlation between session duration and amount of executed trials
[r, p] = corrcoef(LasttrialtimeSec,Tot_essais);
f2 = figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
scatter(Lasttrialtime,Tot_essais,4,'k',...
         'Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
ylabel('Number of executed trials','fontsize',16);xlabel('Session duration','fontsize',16);
title({['Correlation: r = ' num2str(round(r(2),2)) ' / p = '  num2str(round(p(2),2))] Nom},'fontsize',14); hold off;
saveas(f1,[FigurePath '/N_Trials.png']); saveas(f2,[FigurePath '/Correlation_Time_N_Trials.png']); close all
%% Skipped Correct FB
id_Interet_code = '~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
id_Total_code = '~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
type_variable = 'ratio';
bin_size = 100;
epoch = '';
Titre_parametre_analyse ='Skipped Correct Feedback (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
%fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
saveas(fig,[FigurePath '/SkippedCorrectFB.png']); close
%% Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' Correct trials (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/Accuracy.png']); close
%% EWD trials
id_Interet_code = 'SessionData.Custom.EarlyWithdrawal==1;';
id_Total_code = 'SessionData.Custom.FixBroke==0 ';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' EWD trials (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/EarlyWithDrawal.png']); close
%% WT Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/WT_Correcttrials.png']); close
%% WT Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/WT_Errortrials.png']); close
%% WT Correct Catch trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1 & SessionData.Custom.CatchTrial;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time correct catched trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1); 
saveas(fig,[FigurePath '/WT_CorrectCatchtrials.png']); close
%% MT Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'MT';
Titre_parametre_analyse =' Movement Time correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/MT_Correcttrials.png']); close
%% MT Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'MT';
Titre_parametre_analyse =' Movement Time error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/MT_Errortrials.png']); close
%% RT Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'PostStimRT';
Titre_parametre_analyse =' Reaction Time post stimulus correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/RT_Correcttrials.png']); close
%% RT Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'PostStimRT';
Titre_parametre_analyse =' Reaction Time post stimulus error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/RT_Errortrials.png']); close
%% ST Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'ST';
Titre_parametre_analyse =' Sampling Time correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/ST_Correcttrials.png']); close
%% ST Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'ST';
Titre_parametre_analyse =' Sampling Time error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);
saveas(fig,[FigurePath '/ST_Errortrials.png']); close