%% Find a way to normalize WT during the session:
%
%% Dataset to perform the analysis on:
% Filename_name = 'AllDatafilename_180912_1109_Data_Cfdce_task_MC8.mat';
% Pathname_name = 'Pathname_homeserver_MC8.mat';
% Filename_name = 'AllDatafilename_181003_1109_Data_Cfdce_task_MC7.mat';
% Pathname_name = 'Pathname_homeserver_MC7.mat';
cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Session Data')
Filename_name = 'Filename_CfdceCatch_0301_0423_Thy1.mat';
Pathname_name = 'Pathname_Local_Thy1.mat';
% cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Session Data')
% Filename_name = 'Filename_Cfdce_0306_0423_Thy2.mat';
% Pathname_name = 'Pathname_Local_Thy2.mat';

load(Filename_name)
load(Pathname_name)

%% Get mean WT data
% Figure 
fig = figure('units','normalized','position',[0,0,0.5,1]); 
subplot(2,1,1); hold on;

% Empty array to collect data per time slot
WTErr_per_Session = nan(size(filename,2),500);
WTCorr_per_Session = nan(size(filename,2),500);
TimeErr_per_Session = nan(size(filename,2),500);
TimeCorr_per_Session = nan(size(filename,2),500);
WTErr_vec = []; WTCorr_vec = []; TimeErr_vec = []; TimeCorr_vec = [];

for manip= 1 : size(filename,2)
    
    % Load SessionData
    load([pathname '/' filename{manip}])
    Nom = SessionData.Custom.Subject;
    
    % Conversion TrialStartSec in minutes
    temps_minutes = SessionData.Custom.TrialStartSec./60;
    
    % id of interest to quantify
    ndxErr = SessionData.Custom.ChoiceCorrect==0;
    ndxCorr = SessionData.Custom.ChoiceCorrect==1 & SessionData.Custom.CatchTrial;
    
    % WT per trials and corresponding time
    WTErr_per_Session(manip,1:sum(ndxErr)) = SessionData.Custom.FeedbackTime(ndxErr);
    WTCorr_per_Session(manip,1:sum(ndxCorr)) = SessionData.Custom.FeedbackTime(ndxCorr);
    TimeErr_per_Session(manip,1:sum(ndxErr)) = temps_minutes(ndxErr);
    TimeCorr_per_Session(manip,1:sum(ndxCorr)) = temps_minutes(ndxCorr);
    
    % Delete NaN value before plotting the data for the session
    WTErr_nonan = WTErr_per_Session(manip,~isnan(WTErr_per_Session(manip,:)));
    TimeErr_nonan = TimeErr_per_Session(manip,~isnan(WTErr_per_Session(manip,:)));
    WTCorr_nonan = WTCorr_per_Session(manip,~isnan(WTCorr_per_Session(manip,:)));
    TimeCorr_nonan = TimeCorr_per_Session(manip,~isnan(WTCorr_per_Session(manip,:)));
    WTErr_vec = [WTErr_vec WTErr_nonan]; 
    WTCorr_vec = [WTCorr_vec WTCorr_nonan]; 
    TimeErr_vec = [TimeErr_vec TimeErr_nonan]; 
    TimeCorr_vec = [TimeCorr_vec TimeCorr_nonan];
    
    % Getting corr coeff for each session
    [rErr, pErr] = corrcoef(TimeErr_vec,WTErr_vec);
    
    
    % Plot of the variable of interest for the session
    p = plot(TimeErr_nonan,WTErr_nonan, '-r','Visible','on','LineWidth',0.5); % Error WT plotted in red 'Marker','o','MarkerFaceColor','r',
    plot(TimeCorr_nonan,WTCorr_nonan,'-g','Visible','on','LineWidth',0.5); % Correct WT plotted in green 'Marker','o','MarkerFaceColor','g',
    
    clear Pct* ndx* t Trialstart* temps_minutes id_debut id_fin bin debut fin nb_id*
end

% Title/Label/Axis of the plot
%xlim ([SessionData.Custom.TrialStart(1) max(Xplot(:,end))]);
title(['WT across session ' Nom],'fontsize',12);  
xlabel('Time from session beginning (min)','fontsize',14);ylabel('Waiting Time','fontsize',14);hold off;    

%% All data correlation and fit

[rErr, pErr] = corrcoef(TimeErr_vec,WTErr_vec);[rCorr, pCorr] = corrcoef(TimeCorr_vec,WTCorr_vec);

[PFErr, YCalcErr] = polynomial_fit(TimeErr_vec,WTErr_vec,1);
[PFCorr, YCalcCorr] = polynomial_fit(TimeCorr_vec,WTCorr_vec,1);
[PFAll, YCalcAll] = polynomial_fit([TimeErr_vec TimeCorr_vec],[WTErr_vec WTCorr_vec],1);

subplot(2,1,2); hold on;
scatter(TimeErr_vec,WTErr_vec,4,'r',...
         'Marker','o','MarkerFaceColor','r','Visible','on','MarkerEdgeColor','r');
scatter(TimeCorr_vec,WTCorr_vec,4,'g',...
        'Marker','o','MarkerFaceColor','g','Visible','on','MarkerEdgeColor','g');
plot(TimeErr_vec,YCalcErr,'--r');plot(TimeCorr_vec,YCalcCorr,'--g'); plot([TimeErr_vec TimeCorr_vec],YCalcAll,'--k'); 

%xlim ([temps_min temps_max]);
ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
title({['Correlation: Error r = ' num2str(round(rErr(2),2)) ' / p = '  num2str(round(pErr(2),2))];...
    ['Correct r = ' num2str(round(rCorr(2),2)) ' / p = '  num2str(round(pCorr(2),2))]},'fontsize',14); hold off;

%% Linear regression:
plotfit = 'on';

for manip = unique(SessionDataWeek.Custom.Session)
    
    % id of catched trials
    ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial & SessionDataWeek.Custom.Session==manip | SessionDataWeek.Custom.ChoiceCorrect==0 & SessionDataWeek.Custom.Session==manip;
    
    % Polynomial fit (linear regression as n degree of freedom in the equation):
    degreeoffreedom = 2;
    [p, YCalc] = polynomial_fit(SessionDataWeek.Custom.TrialStartSec(ndxCatched),SessionDataWeek.Custom.FeedbackTime(ndxCatched),degreeoffreedom); 
    
   
    if strcmp(plotfit,'on')
        % Plot
        fig = figure('units','normalized','position',[0,0,0.5,0.5]); hold on
        % Plot raw WT data
        scatter(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,SessionDataWeek.Custom.FeedbackTime(ndxCatched),...
            6,'r','Marker','o','MarkerFaceColor','b','Visible','on','MarkerEdgeColor','b');
        % Plot WT data fit
        plot(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,YCalc,'--k');
        % Plot labels
        ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
        title(['Manip number ' num2str(manip)],'fontsize',14); hold off;
    end
end    
%% WT normalization on each session of SessionDataWeek:

% Plot of Confidence behavior raw data
figure('units','normalized','position',[0,0,0.5,1]);
Modality = 4; normornot = 0; SensoORMvt = 0; plotpointormean = 2; Statornot = 0;
Psychometric_fig(SessionDataWeek, Modality,2,2,1);
Vevaiometric_fig(SessionDataWeek, Modality,2,2,2,SensoORMvt,plotpointormean,normornot);
PerfperWT_fig(SessionDataWeek, 2, normornot,2,2,3,SessionDataWeek.SessionDate,Statornot,Modality);
ShvsLgWT_fig(SessionDataWeek, Modality, normornot,2,2,4,'',70,8);

SessionDataWeek.Custom.FeedbackTimeNorm(1:SessionDataWeek.nTrials) = nan(1,SessionDataWeek.nTrials);

for manip = unique(SessionDataWeek.Custom.Session)
    
    % id of catched trials
    ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial & SessionDataWeek.Custom.Session==manip | SessionDataWeek.Custom.ChoiceCorrect==0 & SessionDataWeek.Custom.Session==manip;
    
    % Polynomial fit (linear regression as 1 degree of freedom in the equation):
    degreeoffreedom = 2;
    [p,~,~,R2adjusted,Formula]  = polynomial_fit(SessionDataWeek.Custom.TrialStartSec(ndxCatched),SessionDataWeek.Custom.FeedbackTime(ndxCatched),degreeoffreedom); 
    SessionDataWeek.Custom.FeedbackTimeNorm(ndxCatched) = SessionDataWeek.Custom.FeedbackTime(ndxCatched) - polyval(p,SessionDataWeek.Custom.TrialStartSec(ndxCatched));
    SessionDataWeek.NormalizationFormula{manip} = Formula;
    SessionDataWeek.NormalizationR2adjusted(manip) = R2adjusted;
    
    clear p
end
cd(SessionDataWeek.pathname)
save(SessionDataWeek.filename,'SessionDataWeek') % save(['SessionDataWeek_' SessionDataWeek.filename],'SessionDataWeek');   

% Plot of Confidence behavior normalized data
figure('units','normalized','position',[0,0,0.5,1]);
normornot = 1;
Psychometric_fig(SessionDataWeek, Modality,2,2,1);
Vevaiometric_fig(SessionDataWeek, Modality,2,2,2,SensoORMvt,plotpointormean,normornot);
PerfperWT_fig(SessionDataWeek, 2, normornot,2,2,3,SessionDataWeek.SessionDate,Statornot,Modality);
ShvsLgWT_fig(SessionDataWeek, Modality, normornot,2,2,4,'',70,8);

%%
XErr = SessionDataWeek.Custom.TrialStartSec(SessionDataWeek.Custom.ChoiceCorrect==0)./60;
YErr = SessionDataWeek.Custom.FeedbackTime(SessionDataWeek.Custom.ChoiceCorrect==0);
YnormErr = SessionDataWeek.Custom.FeedbackTimeNorm(SessionDataWeek.Custom.ChoiceCorrect==0);

XCorr = SessionDataWeek.Custom.TrialStartSec(SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial)./60;
YCorr = SessionDataWeek.Custom.FeedbackTime(SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial);
YnormCorr = SessionDataWeek.Custom.FeedbackTimeNorm(SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial);

figure('units','normalized','position',[0,0,0.5,1]);
subplot(2,1,1); hold on;
scatter(XErr,YErr,4,'r',...
         'Marker','o','MarkerFaceColor','r','Visible','on','MarkerEdgeColor','r');
scatter(XCorr,YCorr,4,'g',...
        'Marker','o','MarkerFaceColor','g','Visible','on','MarkerEdgeColor','g');
ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
ylim([0 20]);
title(['Raw data ' SessionDataWeek.Custom.Subject],'fontsize',14); hold off;
    
subplot(2,1,2); hold on;
scatter(XErr,YnormErr,4,'r',...
         'Marker','o','MarkerFaceColor','r','Visible','on','MarkerEdgeColor','r');
scatter(XCorr,YnormCorr,4,'g',...
        'Marker','o','MarkerFaceColor','g','Visible','on','MarkerEdgeColor','g');
ylabel('Norm Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
title('Normalized data','fontsize',14); hold off;

    