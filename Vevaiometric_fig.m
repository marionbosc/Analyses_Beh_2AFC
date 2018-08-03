%% Script to plot vevaiometric curve (WT = f(DV) for Correct catch and Error (catched) trials:
%
%
% Input:
% - Data structure (SessionData or SessionDataWeek or SessionDatasets)
% - Sensory modality to analyse (1 = olfactory / 2 = auditory click task /
% 3 = auditory frequency task)
% - Subplot coordinates (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - option to change the x data disposition: 0 --> right/left of the DV points /
%  1 --> right/left port entered (right/left (0) sensory evidence by default)
%
%

function [SessionData] = Vevaiometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig, SensoORMvt)
%% Plot settings:
% default for the axis disposition of DV points 
if ~exist('SensoORMvt','var')
    SensoORMvt=0;
end

VevaiometricMinWT = 2; % FB time minimum included in the analysis 

% Axis limits and label
Ymax = []; Ymin = [];
if Modality == 1
    Sensory_Modality = 'Olfactory';
    xlimL = [0 1]; xlimR = [-1 0]; 
    xmin = -1; xmax = 1;
    xlabel = 'DV';
elseif Modality == 2
    Sensory_Modality = 'Auditory';
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    if SensoORMvt==0
        xlabel = 'Binaural contrast - sensory ev';
    elseif SensoORMvt==1
        xlabel = 'Binaural contrast - per side entry';
    end
elseif Modality == 3
    Sensory_Modality = 'Auditory';
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xlabel = 'DV';
    Modality = 2;
end

% Plot localisation in the subplot
subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on
Plot_displayed = 0;

%% Retrieve trial index to analyse
ndxModality = SessionData.Custom.Modality(1:end) == Modality ; % Trials from the sensory modality
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; % all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; % correct catch trials
ndxMinWT = SessionData.Custom.FeedbackTime > VevaiometricMinWT; % Trials with WT> than the minimum to analyse
ndxLeft=SessionData.Custom.ChoiceLeft(1:end)==1; % Left trials
ndxRight=SessionData.Custom.ChoiceLeft(1:end)==0 ; % Right trials

%% Error data point and fitted line
if sum(ndxError&ndxMinWT&ndxModality&ndxLeft)>9 || sum(ndxError&ndxMinWT&ndxModality&ndxRight)>9
    % DV data
    if SensoORMvt==0
        DVerrLeft = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxRight); % DV data for LEFT Error trials --> RIGHT PORT entered by the animal
        DVerrRight = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxLeft); % DV data for RIGHT Error trials --> LEFT PORT entered by the animal
    elseif SensoORMvt==1
        DVerrLeft = -SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxLeft); % DV data for Error trials with LEFT PORT entry
        DVerrRight = -SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxRight); % DV data for Error trials with RIGHT PORT entry
    end
    
    % WT data
    if SessionData.DayvsWeek == 2 && isfield(SessionData.Custom,'FeedbackTimeNorm') && SensoORMvt==0 % Normalized WT data
        if SensoORMvt==0
            WTerrLeft = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxRight); % WT data for LEFT Error trials (entered in the RIGHT port)
            WTerrRight = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxLeft); % WT data for RIGHT Error trials (entered in the LEFT port)
        elseif SensoORMvt==1
            WTerrLeft = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxLeft); % WT data for LEFT Error trials (entered in the LEFT port)
            WTerrRight = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxRight); % WT data for RIGHT Error trials (entered in the RIGHT port)
        end
        ylabel = 'Normalized WT (s)';  
    else % Raw WT data
        if SensoORMvt==0
            WTerrLeft = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxRight); % WT data for LEFT Error trials (entered in the RIGHT port)
            WTerrRight = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxLeft); % WT data for RIGHT Error trials 
        elseif SensoORMvt==1
            WTerrLeft = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxLeft); % WT data for LEFT Error trials (entered in the LEFT port)
            WTerrRight = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxRight); % WT data for RIGHT Error trials 
        end
        ylabel = 'WT (s)';
    end
        
    % Data sorting: (reorg of WT according to DV order (increasg) for DV to be continuously plotted:
    [DVerrLeft, eL_sort] = sort(DVerrLeft);
    WTerrLeft = WTerrLeft(eL_sort);
    [DVerrRight, eR_sort] = sort(DVerrRight);
    WTerrRight = WTerrRight(eR_sort);
    
    % Data to plot (scatter points + fitted line + confidence interval of the fit) per side:
    Scatter.err.YData = [WTerrLeft WTerrRight];
    Scatter.err.XData = [DVerrLeft DVerrRight];
    [CorrCoeff.errLeft.r, CorrCoeff.errLeft.p] = corrcoef(DVerrLeft,WTerrLeft);
    [CorrCoeff.errRight.r, CorrCoeff.errRight.p] = corrcoef(DVerrRight,WTerrRight);
    [Fit.errLeft.r, Fit.errLeft.p] = fit(DVerrLeft',WTerrLeft','poly1');
    [Fit.errRight.r, Fit.errRight.p] = fit(DVerrRight',WTerrRight','poly1');
    [pdint.errLeft.r, pdint.errLeft.p] = predint(Fit.errLeft.r,DVerrLeft',0.95,'functional','on');
    [pdint.errRight.r, pdint.errRight.p] = predint(Fit.errRight.r,DVerrRight',0.95,'functional','on');
    
    % Plot:
    s=scatter(Scatter.err.XData,Scatter.err.YData,2,[1 0.6 0],... 
     'Marker','o','MarkerFaceColor',[1 0.6 0],'MarkerEdgeAlpha',0.5,...
     'Visible','on','MarkerEdgeColor',[1 0.6 0]);
    Ymax = [Ymax max(s.YData)*1.01];
    Ymin = [Ymin min(s.YData)*0.99];
    % Fitting line equation : f(x) = p1*x + p2
    plot(xlimL,[Fit.errLeft.r.p1*xlimL(1) + Fit.errLeft.r.p2 Fit.errLeft.r.p1*xlimL(2) + Fit.errLeft.r.p2],'r-','LineWidth',1.5);
    plot(xlimR,[Fit.errRight.r.p1*xlimR(1) + Fit.errRight.r.p2 Fit.errRight.r.p1*xlimR(2) + Fit.errRight.r.p2],'r-','LineWidth',1.5);
    plot(DVerrLeft',pdint.errLeft.r,'r-','LineWidth',1);
    plot(DVerrRight',pdint.errRight.r,'r-','LineWidth',1);
    Leg_error = ['Error n = ',num2str(size(Scatter.err.YData,2))];
    Title_error = ['Error rL = ' num2str(round(CorrCoeff.errLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.errLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.errRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.errRight.p(1,2),3))];
    Plot_displayed = 1;
else
    Leg_error = ''; Title_error = '';s = [];
end

%% Correct catch data point and fitted line
if sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft)>10 || sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight)>10
    % DV data
    DVcatchLeft = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % DV data for LEFT Error trials --> LEFT PORT entered by the animal
    DVcatchRight = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % DV data for RIGHT Error trials --> RIGHT PORT entered by the animal

     % WT data
     if SessionData.DayvsWeek == 2 && isfield(SessionData.Custom,'FeedbackTimeNorm')  && SensoORMvt==0 % Normalized WT data
        WTcatchLeft = SessionData.Custom.FeedbackTimeNorm(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % WT data for LEFT Error trials 
        WTcatchRight = SessionData.Custom.FeedbackTimeNorm(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % WT data for RIGHT Error trials
        ylabel = 'Normalized WT (s)';
     else % Raw WT data
        WTcatchLeft = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % WT data for LEFT Error trials 
        WTcatchRight = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % WT data for RIGHT Error trials
        ylabel = ' WT (s)'; 
    end

    % Data sorting: (reorg of WT according to DV order (increasg) for DV to be continuously plotted:
    [DVcatchLeft, cL_sort] = sort(DVcatchLeft);
    WTcatchLeft = WTcatchLeft(cL_sort);
    [DVcatchRight, cR_sort] = sort(DVcatchRight);
    WTcatchRight = WTcatchRight(cR_sort);

    % Data to plot (scatter points + fitted line + confidence interval of the fit) per side:
    Scatter.catch.YData = [WTcatchLeft WTcatchRight];
    Scatter.catch.XData = [DVcatchLeft DVcatchRight];
    [CorrCoeff.catchLeft.r, CorrCoeff.catchLeft.p] = corrcoef(DVcatchLeft,WTcatchLeft);
    [CorrCoeff.catchRight.r, CorrCoeff.catchRight.p] = corrcoef(DVcatchRight,WTcatchRight);
    [Fit.catchLeft.r, Fit.catchLeft.p] = fit(DVcatchLeft',WTcatchLeft','poly1');
    [Fit.catchRight.r, Fit.catchRight.p] = fit(DVcatchRight',WTcatchRight','poly1');
    [pdint.catchLeft.r, pdint.catchLeft.p] = predint(Fit.catchLeft.r,DVcatchLeft',0.95,'functional','on');
    [pdint.catchRight.r, pdint.catchRight.p] = predint(Fit.catchRight.r,DVcatchRight',0.95,'functional','on');
    
    % Plot:
    s2=scatter(Scatter.catch.XData,Scatter.catch.YData,2,'g',...
     'Marker','o','MarkerFaceColor','g','MarkerEdgeAlpha',0.5,...
     'Visible','on','MarkerEdgeColor','g');
    Ymax = [Ymax max(s2.YData)*1.01];
    Ymin = [Ymin min(s2.YData)*0.99];
    % Fitting line equation : f(x) = p1*x + p2
    plot(xlimL,[Fit.catchLeft.r.p1*xlimL(1) + Fit.catchLeft.r.p2 Fit.catchLeft.r.p1*xlimL(2) + Fit.catchLeft.r.p2],'-','Color', [0.23, 0.5, 0.17] ,'LineWidth',1.5); 
    plot(xlimR,[Fit.catchRight.r.p1*xlimR(1) + Fit.catchRight.r.p2 Fit.catchRight.r.p1*xlimR(2) + Fit.catchRight.r.p2],'-','Color', [0.23, 0.5, 0.17],'LineWidth',1.5);
    plot(DVcatchLeft',pdint.catchLeft.r,'-','Color', [0.23, 0.5, 0.17],'LineWidth',1);
    plot(DVcatchRight',pdint.catchRight.r,'-','Color', [0.23, 0.5, 0.17],'LineWidth',1);
    Leg_catch = ['Catch n = ',num2str(size(Scatter.catch.YData,2))];
    Title_catch = ['Catch rL = ' num2str(round(CorrCoeff.catchLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.catchLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.catchRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.catchRight.p(1,2),3))];
    Plot_displayed = 1;
else
    Leg_catch = ''; Title_catch = ''; s2 =[];
end

%% Figure properties
if Plot_displayed == 1
    legend off
    s.Parent.XAxis.FontSize = 10; s.Parent.YAxis.FontSize = 10;
    leg = legend([s s2],Leg_error,Leg_catch,'Location','NorthWest');
    leg.FontSize = 10; legend('boxoff'); 

    % Legends et axis
    title({['Vevaiometric ' Sensory_Modality ' trials ' ];Title_error;Title_catch},'fontsize',11);
    s.Parent.XLabel.String = xlabel;s.Parent.YLabel.String = ylabel; 
    s.Parent.XLabel.FontSize = 14;s.Parent.YLabel.FontSize = 14; 
    xlim([xmin xmax]); ylim([max([2 min(Ymin)]) min([max(Ymax) 12])]);
    hold off;
end
clearvars -except SessionData
