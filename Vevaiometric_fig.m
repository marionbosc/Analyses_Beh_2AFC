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
% - plotpointormean = 1 --> plot all datas point / = 2 --> plot binned data 
% - normornot = 1 --> Analysis on normalized data / 0 --> Analyse on raw data (default)
%
%

function [SessionData] = Vevaiometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig, SensoORMvt,plotpointormean,normornot)
%% Plot settings:
% default for the axis disposition of DV points 
if ~exist('SensoORMvt','var')
    SensoORMvt=0;
end

if ~exist('plotpointormean','var')
    plotpointormean=1;
end

% Default: use of raw FeedbackTime data
WTdata = 'FeedbackTime';
ylabel = 'WT (s)';
Ylimit = 'ylim([max([2 floor(min(Ymin))]) min([ceil(max(Ymax)) 12])])';
% if use of normalized FeedbackTime data
if exist('normornot','var') && normornot==1 && isfield(SessionData.Custom,'FeedbackTimeNorm')
    WTdata = 'FeedbackTimeNorm';
    ylabel = 'Normalized WT (s)';
    Ylimit = 'ylim([floor(min(Ymin)) ceil(max(Ymax))])';
end

VevaiometricMinWT = 2;% FB time minimum included in the analysis
VevaiometricMaxWT = 20; % FB time max included in the analysis

% Axis limits and label
% Default values:
Ymax = []; Ymin = [];
xlimR = [-1 0]; xlimL = [0 1]; 
xmin = -1; xmax = 1;
xlabel = 'DV';
if Modality == 1
    Sensory_Modality = 'Olfactory';
elseif Modality == 2
    Sensory_Modality = 'Auditory';
    if SensoORMvt==0
        xlabel = 'Binaural contrast - sensory ev';
    elseif SensoORMvt==1
        xlabel = 'Binaural contrast - per side entry';
    end
elseif Modality == 3
    Modality = 2;
elseif Modality == 4
    Sensory_Modality = 'Random Dot task';
    if SensoORMvt==0
        xlabel = 'Decision Variable - sensory ev';
    elseif SensoORMvt==1
        xlabel = 'Decision Variable - per side entry';
    end
end

% Plot localisation in the subplot
subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on
Plot_displayed = 0;

%% Retrieve trial index to analyse
ndxIncl = SessionData.Custom.Modality(1:end) == Modality & SessionData.Custom.FeedbackTime > VevaiometricMinWT...
    & SessionData.Custom.FeedbackTime < VevaiometricMaxWT; % Trials from the sensory modality and WT > minWT
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; % all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; % correct catch trials
ndxLeft=SessionData.Custom.ChoiceLeft(1:end)==1; % Left trials
ndxRight=SessionData.Custom.ChoiceLeft(1:end)==0 ; % Right trials

%% Error data point and fitted line
if sum(ndxError&ndxIncl&ndxLeft)>9 || sum(ndxError&ndxIncl&ndxRight)>9
    % DV data
    if SensoORMvt==0
        DVerrLeft = SessionData.Custom.DV(ndxError&ndxIncl&ndxRight); % DV data for LEFT Error trials --> RIGHT PORT entered by the animal
        DVerrRight = SessionData.Custom.DV(ndxError&ndxIncl&ndxLeft); % DV data for RIGHT Error trials --> LEFT PORT entered by the animal
    elseif SensoORMvt==1
        DVerrLeft = -SessionData.Custom.DV(ndxError&ndxIncl&ndxLeft); % DV data for Error trials with LEFT PORT entry
        DVerrRight = -SessionData.Custom.DV(ndxError&ndxIncl&ndxRight); % DV data for Error trials with RIGHT PORT entry
    end
    
    % WT data
    if SensoORMvt==0
        WTerrLeft = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxError&ndxIncl&ndxRight); % WT data for LEFT Error trials (entered in the RIGHT port)
        WTerrRight = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxError&ndxIncl&ndxLeft); % WT data for RIGHT Error trials (entered in the LEFT port)
    elseif SensoORMvt==1
        WTerrLeft = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxError&ndxIncl&ndxLeft); % WT data for LEFT Error trials (entered in the LEFT port)
        WTerrRight = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxError&ndxIncl&ndxRight); % WT data for RIGHT Error trials (entered in the RIGHT port)
    end

    % Data sorting: (reorg of WT according to DV order (increasg) for DV to be continuously plotted:
    [DVerrLeft, eL_sort] = sort(DVerrLeft);
    WTerrLeft = WTerrLeft(eL_sort);
    [DVerrRight, eR_sort] = sort(DVerrRight);
    WTerrRight = WTerrRight(eR_sort);
    
    % If plot of the mean WT per DV bin/DV discrete value:
    if plotpointormean ==2 
        % if DV distrib is discrete and less than 20 DV points:
        if size(unique([DVerrLeft DVerrRight]),2)<=20 
            % Mean WT and sem for each bin
            [MeanWTLeft.Error, semWTLeft.Error, MeanDVLeft.Error] = grpstats(WTerrLeft,DVerrLeft,{'mean','sem','gname'});
            [MeanWTRight.Error, semWTRight.Error, MeanDVRight.Error] = grpstats(WTerrRight,DVerrRight,{'mean','sem','gname'});
            MeanDVLeft.Error =str2double(MeanDVLeft.Error)'; MeanDVRight.Error =str2double(MeanDVRight.Error)';
        else
            % Get DV bin bounds from all trials distrib percentile:
            DV_pctileLeft = min(DVerrLeft); DV_pctileRight = min(DVerrRight);
            for j = 1:4
                DV_pctileLeft(j+1) = prctile(DVerrLeft,25*j);
                DV_pctileRight(j+1) = prctile(DVerrRight,25*j);
            end
            % Binned DV value for all trials:
            BinIdxerrLeft = discretize(DVerrLeft,DV_pctileLeft);
            BinIdxerrRight = discretize(DVerrRight,DV_pctileRight);
            clear DV_pctile*
            % Mean DV of each bin
            for  j = 1:4
                MeanDVLeft.Error(j) = nanmean(DVerrLeft(BinIdxerrLeft==j));
                MeanDVRight.Error(j) = nanmean(DVerrRight(BinIdxerrRight==j));
            end
            % Mean WT and sem for each bin
            [MeanWTLeft.Error, semWTLeft.Error] = grpstats(WTerrLeft,BinIdxerrLeft,{'mean','sem'});
            [MeanWTRight.Error, semWTRight.Error] = grpstats(WTerrRight,BinIdxerrRight,{'mean','sem'});

        end
    end
   
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
    if plotpointormean == 1
        s=scatter(Scatter.err.XData,Scatter.err.YData,2,[1 0.6 0],... 
         'Marker','o','MarkerFaceColor',[1 0.6 0],'MarkerEdgeAlpha',0.5,...
         'Visible','on','MarkerEdgeColor',[1 0.6 0]);
        Ymax = [Ymax max(s.YData)*1.01];
        Ymin = [Ymin min(s.YData)*0.99];
    else
        s= errorbar([MeanDVLeft.Error MeanDVRight.Error], [MeanWTLeft.Error ; MeanWTRight.Error]',...
            [semWTLeft.Error ; semWTRight.Error]','r','LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r',...
            'MarkerSize',6,'Visible','on','Capsize',0); 
    end
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
clear Mean* BinIdx*
%% Correct catch data point and fitted line
if sum(ndxCorrectCatch&ndxIncl&ndxLeft)>10 || sum(ndxCorrectCatch&ndxIncl&ndxRight)>10
    % DV data
    DVcatchLeft = SessionData.Custom.DV(ndxCorrectCatch&ndxIncl&ndxLeft); % DV data for LEFT Error trials --> LEFT PORT entered by the animal
    DVcatchRight = SessionData.Custom.DV(ndxCorrectCatch&ndxIncl&ndxRight); % DV data for RIGHT Error trials --> RIGHT PORT entered by the animal

     % WT data
    WTcatchLeft = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxCorrectCatch&ndxIncl&ndxLeft); % WT data for LEFT Catch trials 
    WTcatchRight = SessionData.Custom.(matlab.lang.makeValidName(WTdata))(ndxCorrectCatch&ndxIncl&ndxRight); % WT data for RIGHT Catch trials     

    % Data sorting: (reorg of WT according to DV order (increasg) for DV to be continuously plotted:
    [DVcatchLeft, cL_sort] = sort(DVcatchLeft);
    WTcatchLeft = WTcatchLeft(cL_sort);
    [DVcatchRight, cR_sort] = sort(DVcatchRight);
    WTcatchRight = WTcatchRight(cR_sort);
    
    % If plot of the mean WT per DV bin/DV discrete value:
    if plotpointormean ==2 
        % if DV distrib is discrete and less than 20 DV points:
        if size(unique([DVcatchLeft DVcatchRight]),2)<=20 
            % Mean WT and sem for each bin
            [MeanWTLeft.Catch, semWTLeft.Catch, MeanDVLeft.Catch] = grpstats(WTcatchLeft,DVcatchLeft,{'mean','sem','gname'});
            [MeanWTRight.Catch, semWTRight.Catch, MeanDVRight.Catch] = grpstats(WTcatchRight,DVcatchRight,{'mean','sem','gname'});
            MeanDVLeft.Catch =str2double(MeanDVLeft.Catch)'; MeanDVRight.Catch =str2double(MeanDVRight.Catch)';
        else
            % Get DV bin bounds from all trials distrib percentile:
            DV_pctileLeft = min(DVcatchLeft); DV_pctileRight = min(DVcatchRight);
            for j = 1:4
                DV_pctileLeft(j+1) = prctile(DVcatchLeft,25*j);
                DV_pctileRight(j+1) = prctile(DVcatchRight,25*j);
            end
            % Binned DV value for all trials:
            BinIdxcatchLeft = discretize(DVcatchLeft,DV_pctileLeft);
            BinIdxcatchRight = discretize(DVcatchRight,DV_pctileRight);
            % Mean DV of each bin
            for  j = 1:4
                MeanDVLeft.Catch(j) = nanmean(DVcatchLeft(BinIdxcatchLeft==j));
                MeanDVRight.Catch(j) = nanmean(DVcatchRight(BinIdxcatchRight==j));
            end
            % Mean WT and sem for each bin
            [MeanWTLeft.Catch, semWTLeft.Catch] = grpstats(WTcatchLeft,BinIdxcatchLeft,{'mean','sem'});
            [MeanWTRight.Catch, semWTRight.Catch] = grpstats(WTcatchRight,BinIdxcatchRight,{'mean','sem'});

        end
    end
    
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
    if plotpointormean == 1
        s2=scatter(Scatter.catch.XData,Scatter.catch.YData,2,'g',...
         'Marker','o','MarkerFaceColor','g','MarkerEdgeAlpha',0.5,...
         'Visible','on','MarkerEdgeColor','g');
        Ymax = [Ymax max(s2.YData)*1.01];
        Ymin = [Ymin min(s2.YData)*0.99];
    else
        s2= errorbar([MeanDVLeft.Catch MeanDVRight.Catch], [MeanWTLeft.Catch ; MeanWTRight.Catch]',...
            [semWTLeft.Catch ; semWTRight.Catch]','g','LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g',...
            'MarkerSize',6,'Visible','on','Capsize',0); 
    end
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
    % Legend
    legend off
    s.Parent.XAxis.FontSize = 10; s.Parent.YAxis.FontSize = 10;
    leg = legend([s s2],Leg_error,Leg_catch,'Location','NorthWest');
    leg.FontSize = 10; legend('boxoff'); 
    % Axis Label
    title({['Vevaiometric ' Sensory_Modality ' trials ' ];Title_error;Title_catch},'fontsize',11);
    s.Parent.XLabel.String = xlabel;s.Parent.YLabel.String = ylabel; 
    s.Parent.XLabel.FontSize = 14;s.Parent.YLabel.FontSize = 14; 
    % Axis limits
    xlim([xmin xmax]); 
    if ~exist('Ymin','var')
        Ymin = min([s.Parent.YLim(1) s2.Parent.YLim(1)]);
        Ymax = max([s.Parent.YLim(2) s2.Parent.YLim(2)]);
    end
    eval(Ylimit)
    % Axis tick
    s.Parent.XTick = -1:0.5:1; s.Parent.YTick = s.Parent.YLim(1):2:ceil(s.Parent.YLim(2));
    hold off;
end
clearvars -except SessionData
