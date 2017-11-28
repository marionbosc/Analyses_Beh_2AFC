%% Nombre d'essais executes au cours de la session (dans le temps)

figure('units','normalized','position',[0,0,0.7,1]); hold on;

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}])
    Nom = SessionData.filename(1:3);
    
    if ~isfield(SessionData.Custom, 'TrialStart')
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
    
    plot(SessionData.Custom.TrialStart,SessionData.Custom.TrialNumber,'color',rand(1,3)) 
    
    Tot_essais(manip) = SessionData.Custom.TrialNumber(end);
    Lasttrialtime(manip) = SessionData.Custom.TrialStart(end);
    LasttrialtimeSec(manip) = SessionData.Custom.TrialStartSec(end);
    
    clear SessionData t
end

temps_min= datetime(0*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

title(['Nb of trials executed throughout session - ' Nom],'fontsize',12);
xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Time from session start','fontsize',16);hold off;

% Scatterplot et correlation entre duree session et nb d'essai
[r, p] = corrcoef(LasttrialtimeSec,Tot_essais);
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
scatter(Lasttrialtime,Tot_essais,4,'k',...
         'Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Session duration','fontsize',16);
title({['Correlation: r = ' num2str(round(r(2),2)) ' / p = '  num2str(round(p(2),2))] Nom},'fontsize',14); hold off;


%% Skipped Correct FB
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = '~SessionData.Custom.Feedback&~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
id_Total_code = '~SessionData.Custom.CatchTrial&SessionData.Custom.ChoiceCorrect==1';
type_variable = 'ratio';
bin_size = 100;
epoch = '';
Titre_parametre_analyse ='Skipped Correct Feedback (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% Correct trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' Correct trials (%)';
fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
%fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% EWD trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.EarlyWithdrawal==1;';
id_Total_code = 'SessionData.Custom.FixBroke==0 ';
bin_size = 100;
type_variable = 'ratio';
epoch = '';
Titre_parametre_analyse =' EWD trials (%)';
%fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% WT Correct trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time correct trials (s)';
%fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% WT Error trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'FeedbackTime';
Titre_parametre_analyse =' FB Waiting Time error trials (s)';
%fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% RT Correct trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'ST';
Titre_parametre_analyse =' Sampling Time correct trials (s)';
%fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
%% RT Error trials
load('AllDatafilename_171003_1027.mat')
load('AllDatapathname_171003_1027.mat')
id_Interet_code = 'SessionData.Custom.ChoiceCorrect==0;';
id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
bin_size = 100;
type_variable = 'duration';
epoch = 'ST';
Titre_parametre_analyse =' Sampling Time error trials (s)';
%fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse);
fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse);
