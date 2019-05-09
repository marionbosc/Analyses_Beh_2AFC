%% Comparison of normalization between different type of fitting:
%
%
%% Dataset

load('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Session Data/SessionDataWeek_Cfdce_0301_0423.mat');

%load('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Session Data/SessionDataWeek_Cfdce_0306_0423_Thy2')

%% WT normalization on SessionDataWeek:

FeedbackTimeNorm(:,1:SessionDataWeek.nTrials) = nan(10,SessionDataWeek.nTrials);
colorcode = {[0.4660, 0.6740, 0.1880];	[0.8500, 0.3250, 0.0980];[0, 0.75, 0.75]};
for manip = unique(SessionDataWeek.Custom.Session)
    
    % id of catched trials
    ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial & SessionDataWeek.Custom.Session==manip | SessionDataWeek.Custom.ChoiceCorrect==0 & SessionDataWeek.Custom.Session==manip;
    
    % Plot
    fig = figure('units','normalized','position',[0,0,0.5,0.5]); hold on
    % Plot raw WT data
    scatter(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,SessionDataWeek.Custom.FeedbackTime(ndxCatched),...
        6,'k','Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
    leg{1} = 'Raw WT data';    
    for degreeoffreedom = 1:2
        % Polynomial fit (linear regression as 1 degree of freedom in the equation):
        [p{manip,degreeoffreedom}, YCalc, ~, R2adjusted(manip,degreeoffreedom)] = polynomial_fit(SessionDataWeek.Custom.TrialStartSec(ndxCatched),SessionDataWeek.Custom.FeedbackTime(ndxCatched),degreeoffreedom); 
        FeedbackTimeNorm(degreeoffreedom,ndxCatched) = SessionDataWeek.Custom.FeedbackTime(ndxCatched) - polyval(p{manip,degreeoffreedom},SessionDataWeek.Custom.TrialStartSec(ndxCatched));
        clear p
        
        % Plot WT data fit
        plot(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,YCalc,'-','Color',colorcode{degreeoffreedom},'LineWidth',0.5);
        % Plot labels
        ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
        leg{degreeoffreedom+1} = ['d= ' num2str(degreeoffreedom) ' ;R2adj= ' num2str(round(R2adjusted(manip,degreeoffreedom),3))];
    end
    legend(leg,'Location','NorthEastoutside');
    title(['Manip number ' num2str(manip)],'fontsize',14); hold off;
end

% % Plot of the adjusted root square of the fit per degree of freedom
% figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
% for manip = unique(SessionDataWeek.Custom.Session)
%     plot(1:2,R2adjusted(manip,:)-R2adjusted(manip,1), '-', 'Color',rand(1,3))
% end
% ylabel('Rsquare adjusted','fontsize',16);xlabel('Degree of freedom','fontsize',16);
% title(['Comparison of polynomial fit ' SessionDataWeek.Custom.Subject],'fontsize',14); hold off;

% Plot R2adj for 1 or 2 degree of freedom for each session:
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
for manip = unique(SessionDataWeek.Custom.Session)
    delta(manip) = R2adjusted(manip,2)-R2adjusted(manip,1);
    if delta(manip) > 0
        plotcolor = 'g';
        impactofd(manip) = 1;
    elseif delta(manip) == 0
        plotcolor = 'k';
        impactofd(manip) = 0;
    elseif delta(manip) < 0
        plotcolor = 'r';
        impactofd(manip) = -1;
    end
    plot(1:2,R2adjusted(manip,1:2), '-', 'Color',plotcolor,'LineWidth',1)
    leg{manip} = num2str(round(R2adjusted(manip,2)-R2adjusted(manip,1),3));
end
ylabel('Rsquare adjusted','fontsize',16);xlabel('Degree of freedom','fontsize',16); xlim([0.5 2.5]);
title({['Mean improvement of R2adj for green session= ' num2str(round(mean(delta(delta>0)),3))];...
    ['Mean diminishment of R2adj for red session= ' num2str(round(mean(delta(delta<0)),3))]},'fontsize',14); hold off;

%% Same but over all data at once

FeedbackTimeNorm(:,1:SessionDataWeek.nTrials) = nan(10,SessionDataWeek.nTrials);
colorcode = {[0.4660, 0.6740, 0.1880];	[0.8500, 0.3250, 0.0980];[0, 0.75, 0.75]};

% id of catched trials
ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial | SessionDataWeek.Custom.ChoiceCorrect==0;
Xdata = SessionDataWeek.Custom.TrialStartSec(ndxCatched)./60;
Ydata = SessionDataWeek.Custom.FeedbackTime(ndxCatched);
% Data sorting
[Xdata, Xsort] = sort(Xdata);
Ydata = Ydata(Xsort);
    
% Plot
fig = figure('units','normalized','position',[0,0,0.5,0.5]); hold on
% Plot raw WT data
scatter(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,SessionDataWeek.Custom.FeedbackTime(ndxCatched),...
    6,'k','Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
leg{1} = 'Raw WT data';  

% Plot polynomial regression of several degree:
for degreeoffreedom = 1:2
    % Polynomial fit (linear regression as 1 degree of freedom in the equation):
    [p{degreeoffreedom}, YCalc, ~, R2adjusted(degreeoffreedom)] = polynomial_fit(Xdata,Ydata,degreeoffreedom); 
    %FeedbackTimeNorm(degreeoffreedom,ndxCatched) = SessionDataWeek.Custom.FeedbackTime(ndxCatched) - polyval(p{degreeoffreedom},SessionDataWeek.Custom.TrialStartSec(ndxCatched));
    % legend
    leg{degreeoffreedom+1} = ['d= ' num2str(degreeoffreedom) ' ;R2adj= ' num2str(round(R2adjusted(degreeoffreedom),3))];   
    clear p
end

% Plot WT data fit
plot(Xdata,YCalc,'-','Color',colorcode{degreeoffreedom},'LineWidth',2);
% Plot labels
ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
legend(leg,'Location','NorthEastoutside');ylim([0 20]);
title(['Data ' SessionDataWeek.Custom.Subject],'fontsize',14); hold off;
