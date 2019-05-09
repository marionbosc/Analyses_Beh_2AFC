%% Dataset to perform the analysis on:
% Filename_name = 'AllDatafilename_180912_1109_Data_Cfdce_task_MC8.mat';
% Pathname_name = 'Pathname_homeserver_MC8.mat';
% Filename_name = 'AllDatafilename_181003_1109_Data_Cfdce_task_MC7.mat';
% Pathname_name = 'Pathname_homeserver_MC7.mat';
cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Session Data')
Filename_name = 'Filename_Cfdce_0301_0423_Thy1.mat';
Pathname_name = 'Pathname_Local_Thy1.mat';
% cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Session Data')
% Filename_name = 'Filename_Cfdce_0306_0423_Thy2.mat';
% Pathname_name = 'Pathname_Local_Thy2.mat';

load(Filename_name)
load(Pathname_name)

statornot = 0;

% Mean_WT_Session_unlim(4, 'Thy2 CfdceCatch','/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Session Data/SessionDataWeek_CfdceCatch_0306_0423_Thy2.mat')
% Perf_Bias_per_Session_unlim(4, 'Thy1 Cfdce','/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Session Data/SessionDataWeek_Cfdce_0301_0423.mat')

%% Number of trials executed 

figure('units','normalized','position',[0,0,0.7,1]); hold on;

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

% temps_min= datetime(0*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
% temps_max = datetime(3*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

title(['Nb of trials executed throughout session - ' Nom],'fontsize',12);
% xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Time from session start','fontsize',16);
% leg = legend('Mon','Tues','Wed','Thur','Fri','Location','SouthEast');
% leg.FontSize = 10; legend('boxoff');
hold off;

% Scatterplot and correlation between session duration and amount of executed trials
[r, p] = corrcoef(LasttrialtimeSec,Tot_essais);
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
scatter(Lasttrialtime,Tot_essais,4,'k',...
         'Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
%xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Session duration','fontsize',16);
title({['Correlation: r = ' num2str(round(r(2),2)) ' / p = '  num2str(round(p(2),2))] Nom},'fontsize',14); hold off;

%% Skipped Correct FB
id_Interet_code = '~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
id_Total_code = '~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
type_variable = 'ratio';
bin_size = 100;
epoch = '';
Titre_parametre_analyse ='Skipped Correct Feedback (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);
%fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);

%% Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' Correct trials (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,1);

%% EWD trials
id_Interet_code = 'SessionData.Custom.EarlyWithdrawal==1;';
id_Total_code = 'SessionData.Custom.FixBroke==0 ';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' EWD trials (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);

%% WT Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);

%% WT Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);

%% WT Correct Catch trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1 & SessionData.Custom.CatchTrial;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time correct catched trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot); 

%% MT Correct trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'MT';
Titre_parametre_analyse =' Movement Time correct trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);

%% MT Error trials
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'MT';
Titre_parametre_analyse =' Movement Time error trials (s)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot);