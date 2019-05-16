%% Comparison of normalization with different degree of freedom:
%
% 
%% Dataset and path leading to the figure folder
% cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Session Data/');
% load SessionDataWeek_Cfdce_Thy1.mat; load Filename_Cfdce_Thy1.mat
% pathtosaveFigure = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy1/Analyses/CompaNorm_Thy1';

% cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Session Data/');
% load SessionDataWeek_Cfdce_Thy2.mat; load Filename_Cfdce_Thy2.mat
% pathtosaveFigure = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/Mouse2AFC/Thy2/Analyses/CompaNorm_Thy2';

%% 1) Comparison of WT normalization with different degree of freedom on each session of SessionDataWeek:
% Plot colors:
colorcode = {[0.4660, 0.6740, 0.1880];	[0.8500, 0.3250, 0.0980];[0, 0.75, 0.75]; [0.75, 0, 0.75]};

for manip = unique(SessionDataWeek.Custom.Session)
    
    % id of catched trials
    ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial ...
        & SessionDataWeek.Custom.FeedbackTime<19 & SessionDataWeek.Custom.Session==manip  ...
        | SessionDataWeek.Custom.ChoiceCorrect==0 & SessionDataWeek.Custom.FeedbackTime<19 ...
        & SessionDataWeek.Custom.Session==manip;
    
    % Plot
    fig = figure('units','normalized','position',[0,0,0.6,0.5]); subplot(1,2,1);hold on
    % Plot raw WT data
    scatter(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,SessionDataWeek.Custom.FeedbackTime(ndxCatched),...
        6,'k','Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
    leg{1} = 'Raw WT data';    
    for degreeoffreedom = 1:4
        % Polynomial fit:
        [p{manip,degreeoffreedom}, YCalc, ~, R2adjusted(manip,degreeoffreedom)] = polynomial_fit(SessionDataWeek.Custom.TrialStartSec(ndxCatched),SessionDataWeek.Custom.FeedbackTime(ndxCatched),degreeoffreedom); 
        clear p
        
        % Plot WT data fit
        plot(SessionDataWeek.Custom.TrialStartSec(ndxCatched)/60,YCalc,'-','Color',colorcode{degreeoffreedom},'LineWidth',0.5);
        % Plot labels
        ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
        leg{degreeoffreedom+1} = ['d= ' num2str(degreeoffreedom) ' ;R2adj= ' num2str(round(R2adjusted(manip,degreeoffreedom),3))];
    end
    legend(leg,'Location','NorthEastoutside');
    title(filename(manip),'fontsize',14); 
    ax = gca; ax.Position = [0.1 0.1 0.4 0.8];hold off;
    subplot(1,2,2);
    histogram(SessionDataWeek.Custom.FeedbackTime(ndxCatched),'BinWidth',1);
    ylabel('Trials count','fontsize',16); xlabel('WT (s)','fontsize',16);
    title('Waiting Time distribution','fontsize',14);
    ax = gca; ax.Position = [0.65 0.1 0.2 0.4];
    saveas(fig,[pathtosaveFigure '/Session' num2str(manip)],'png'); close
end
clearvars -except SessionDataWeek R2adjusted
%% 2) Plot of the delta of the adjusted root square of the fit for two over one degree of freedom

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
clearvars -except SessionDataWeek
%% 3) Same as 1) but over all data at once

colorcode = {[0.4660, 0.6740, 0.1880];	[0.8500, 0.3250, 0.0980];[0, 0.75, 0.75]; [0.75, 0, 0.75]};

% id/data of all catched trials
ndxCatched = SessionDataWeek.Custom.ChoiceCorrect==1 & SessionDataWeek.Custom.CatchTrial ...
        & SessionDataWeek.Custom.FeedbackTime<19 ...
        | SessionDataWeek.Custom.ChoiceCorrect==0 & SessionDataWeek.Custom.FeedbackTime<19;
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

% Plot polynomial regression with up to four degree of freedom:
for degreeoffreedom = 1:4
    % Polynomial fit:
    [p{degreeoffreedom}, YCalc, ~, R2adjusted(degreeoffreedom)] = polynomial_fit(Xdata,Ydata,degreeoffreedom); 
    % Plot WT data fit
    plot(Xdata,YCalc,'-','Color',colorcode{degreeoffreedom},'LineWidth',2);
    % legend
    leg{degreeoffreedom+1} = ['d= ' num2str(degreeoffreedom) ' ;R2adj= ' num2str(round(R2adjusted(degreeoffreedom),3))];   
    clear YCalc
end


% Plot labels
ylabel('Waiting Time','fontsize',16);xlabel('Time from session beginning (min)','fontsize',16);
legend(leg,'Location','NorthEastoutside');ylim([0 20]);xlim([0 60]);
title(['Data ' SessionDataWeek.Custom.Subject],'fontsize',14); hold off;
