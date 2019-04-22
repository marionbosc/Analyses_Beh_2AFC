%% Script to plot the conditioned psychometric curves: Short WT vs Long WT Psychometrics
%
%
% Input:
% - Dataset (SessionData or SessionDataWeek or SessionDatasets)
% - Sensory modality to analyse (1 = olfactory / 2 = auditory click task /
% 3 = auditory frequency task)
% - Analysis done on raw WT data  (0) or WT data normalized per session (1)
% - Coordinates subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - Extra text in the title of the plot
% - Percentile threshold  to use to determine Short vs Long WT
% - Option: Nb of bin to discretize data (needed for auditory click task with continuous DV only)
%
%

function ShvsLgWT_fig(SessionData, Modality, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Percentile,nbBin)
%% Plot settings:
% default number of DV bin 
if ~exist('nbBin','var')
    nbBin=8;
end

% Axis limits and label
if Modality == 1
    Sensory_Modality = 'Olfactory';
    xlimL = [0 1]; xlimR = [-1 0]; 
    xtick = 0:20:100;
    xmin = 0; xmax = 100;
    xlabel = '% Odor A';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xtick = -1:0.5:1;
    xlabel = 'Binaural contrast';
elseif Modality == 3
    Sensory_Modality = 'Auditory';
    xlimL = [0 1]; xlimR = [-1 0]; 
    xmin = -1; xmax = 1;
    xtick = -1:0.5:1;
    xlabel = 'DV';
elseif Modality ==4
    Sensory_Modality = 'Brightness';
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xtick = -1:0.5:1;
    xlabel = 'Brightness contrast';
end

% Plot localisation in the subplot
ShvsLg = subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on

%% Data retrieval

% Trials index  
ndxNan = isnan(SessionData.Custom.ChoiceLeft); % unanswered trials 
ndxCatch = SessionData.Custom.CatchTrial; % Catch trials
if Modality ==3 % case auditory frequency task
    ndxModality = SessionData.Custom.Modality==2;
else % case olfactory or auditory click task
    ndxModality = SessionData.Custom.Modality==Modality;
end

% WT data --> Short vs Long population of trials
if NormorNot == 1 % Normalized WT
    Percentile_WT = prctile(SessionData.Custom.FeedbackTimeNorm(ndxModality&ndxCatch),Percentile);
    ndxlongWT = SessionData.Custom.FeedbackTimeNorm>Percentile_WT;
    ndxshortWT = SessionData.Custom.FeedbackTimeNorm<Percentile_WT;
else % raw WT
    Percentile_WT = prctile(SessionData.Custom.FeedbackTime(ndxModality&ndxCatch),Percentile);
    ndxlongWT = SessionData.Custom.FeedbackTime>Percentile_WT;
    ndxshortWT = SessionData.Custom.FeedbackTime<Percentile_WT;
end

% Computatn probability of Left choice for each trial type (short vs long WT)
if Modality ==1 || Modality == 3 % for olfactory or tone cloud auditory discrimination (discrete DV)
    % DV data retrieval
    if Modality == 1
        DV = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
    elseif Modality == 3
        DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    end
    % Long WT
    PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
    PsycX = unique(DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT));
    PsycX_L = PsycX(~isnan(PsycX)); % Suppress NaN values
    
    % Short WT
    PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
    PsycX = unique(DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT));
    PsycX_S = PsycX(~isnan(PsycX)); % Suppress NaN values
elseif Modality == 2  || Modality == 4 % for click train auditory discrimination or brightness discrimination
    % DV data retrieval
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Case DV selection was discrete
    if  isfield(SessionData.Settings.GUI, 'AuditoryTrialSelection') && SessionData.Settings.GUI.AuditoryTrialSelection==2
        if  Modality == 2  
            % Long WT
            PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),SessionData.Custom.AuditoryOmega(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
            PsycX_L = grpstats(SessionData.Custom.DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),SessionData.Custom.AuditoryOmega(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
            % Short WT
            PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),SessionData.Custom.AuditoryOmega(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
            PsycX_S = grpstats(SessionData.Custom.DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),SessionData.Custom.AuditoryOmega(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
        elseif Modality ==4
            % Long WT
            PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),SessionData.Custom.StimulusOmega(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
            PsycX_L = grpstats(SessionData.Custom.DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),SessionData.Custom.StimulusOmega(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
            % Short WT
            PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),SessionData.Custom.StimulusOmega(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
            PsycX_S = grpstats(SessionData.Custom.DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),SessionData.Custom.StimulusOmega(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
        end
            
    else % Case DV selection was continuous
        % Binning of DV data
        BinIdx = discretize(DV,linspace(-1,1,nbBin+1));
        % Long WT
        PsycY_L = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT),BinIdx(ndxModality&~ndxNan&ndxCatch&ndxlongWT),'mean');
        PsycX = unique(BinIdx(ndxModality&~ndxNan&ndxCatch&ndxlongWT))/nbBin*2-1-1/nbBin;
        PsycX_L = PsycX(~isnan(PsycX)); % Suppress NaN values
        % Short WT
        PsycY_S = grpstats(SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT),BinIdx(ndxModality&~ndxNan&ndxCatch&ndxshortWT),'mean');
        PsycX = unique(BinIdx(ndxModality&~ndxNan&ndxCatch&ndxshortWT))/nbBin*2-1-1/nbBin;
        PsycX_S = PsycX(~isnan(PsycX)); % Suppress NaN values  
    end
end

% Plot data --> fitting curve
% Long WT
Psyc_L.YData = PsycY_L;
Psyc_L.XData = PsycX_L;
if sum(ndxModality&~ndxNan&ndxCatch&ndxlongWT) > 1
    PsycFit_L.XData = linspace(min(DV),max(DV),100);
    [Fit,~,Stat]=glmfit(DV(ndxModality&~ndxNan&ndxCatch&ndxlongWT),...
        SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxlongWT)','binomial');
    [PsycFit_L.YData,CILow_L,CIHigh_L] = glmval(Fit,linspace(min(DV),max(DV),100),'logit',Stat);
end

% Short WT
Psyc_S.YData = PsycY_S;
Psyc_S.XData = PsycX_S;
if sum(ndxModality&~ndxNan&ndxCatch&ndxshortWT) > 1
    PsycFit_S.XData = linspace(min(DV),max(DV),100);
    [Fit,~,Stat]=glmfit(DV(ndxModality&~ndxNan&ndxCatch&ndxshortWT),...
        SessionData.Custom.ChoiceLeft(ndxModality&~ndxNan&ndxCatch&ndxshortWT)','binomial');
    [PsycFit_S.YData,CILow_S,CIHigh_S] = glmval(Fit,linspace(min(DV),max(DV),100),'logit',Stat);
    clear Fit Stat
end

%% Figure:
% Plot data point
plot(Psyc_L.XData,Psyc_L.YData,'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b',...
    'MarkerSize',4,'Visible','on');
plot(Psyc_S.XData,Psyc_S.YData,'LineStyle','none','Marker','o','MarkerEdge','m','MarkerFace','m',...
    'MarkerSize',4,'Visible','on');
% Plot data fit and confidence interval for each curve 
plot(PsycFit_L.XData,PsycFit_L.YData,'color','b','Visible','on');
ciplot(PsycFit_L.YData-CILow_L,PsycFit_L.YData+CIHigh_L,PsycFit_L.XData,'b',0.3);
plot(PsycFit_S.XData,PsycFit_S.YData,'color','m','Visible','on');
ciplot(PsycFit_S.YData-CILow_S,PsycFit_S.YData+CIHigh_S,PsycFit_S.XData,'m',0.3);
% Legends and axis
plot([xmin, xmax],[0.5 0.5],'--','color',[.7,.7 .7]);
p = plot([xmin+(xmax-xmin)/2 xmin+(xmax-xmin)/2],[0 1],'--','color',[.7,.7 .7]);
p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
ylim([0 1]); xlim ([xmin, xmax]);
p.Parent.XTick = xtick; p.Parent.YTick = 0:0.2:1;
leg = legend(['Long WT n = ',num2str(sum(ndxModality&~ndxNan&ndxCatch&ndxlongWT))],['Short WT n = ',num2str(sum(ndxModality&~ndxNan&ndxCatch&ndxshortWT))],'Location','SouthEast');
title({['Psychometric ' Sensory_Modality  ' ' TitleExtra]; [num2str(Percentile) 'th percentile catch trials WT = ' num2str(round(Percentile_WT,2))]},'fontsize',12);
leg.FontSize = 10; legend('boxoff');
p.Parent.XLabel.String = xlabel; p.Parent.XLabel.FontSize =14;
p.Parent.YLabel.String = 'P(choose left)'; p.Parent.YLabel.FontSize =14;
hold off;

