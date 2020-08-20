%% Script to produce Psychometric function:
%
%
% Input:
% - Dataset --> SessionData
% - Subplot coordinates (zB subplot(2,3,2))--> subplot(nb_row_fig,nb_col_fig,positn_fig)

function [SessionData,Perf] = Psychometric_fig_Larkum(SessionData,nb_row_fig,nb_col_fig,positn_fig)
%% Psyc light intensities

% Removal of data for future trial to obtain matrix of equal size:
CustomFields = fieldnames(SessionData.Custom);
WeirdFields = {'RewardMagnitude';'Rig';'Subject';'PulsePalParamStimulus';'PulsePalParamFeedback'};

SessionData.nTrials = size(SessionData.Custom.ChoiceLeft,2);
for field = 1: size (CustomFields,1)
    if ~any(strcmp(CustomFields{field},WeirdFields)) && size(SessionData.Custom.(CustomFields{field}),2)>=SessionData.nTrials
        SessionData.Custom.(CustomFields{field}) = SessionData.Custom.(CustomFields{field})(1:SessionData.nTrials);
    elseif strcmp(CustomFields{field},'RewardMagnitude')
            if find(size(SessionData.Custom.RewardMagnitude)==2)==1
                SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(:,1:SessionData.nTrials);
            else
                SessionData.Custom.RewardMagnitude = SessionData.Custom.RewardMagnitude(1:SessionData.nTrials,:)';
            end
    end
end

% Computation of the Decision Variable associated with every trials -->
% gradation of difficulty between easy right (0) and easy left (+1)
ndxLeft = SessionData.Custom.LeftRewarded(1:end)==1;
ndxRight = SessionData.Custom.LeftRewarded(1:end)==0;

SessionData.Custom.DV(ndxLeft) = SessionData.Custom.Intensties(ndxLeft)/100;
SessionData.Custom.DV(ndxRight) = 1-SessionData.Custom.Intensties(ndxRight)/100;

% Get intensities uses at every trial:
DV = SessionData.Custom.DV(1:end);

% Non responded trials (ChoiceLeft = Nan)
ndxNan = isnan(SessionData.Custom.ChoiceLeft);

% Recup des 6-8 fractions d'odeur A utilises durnt la session
setStim = reshape(unique(DV),1,[]);
setStim = setStim(~isnan(setStim));

% Rate of Choice Left for each DV
PsycY  = grpstats(SessionData.Custom.ChoiceLeft(~ndxNan),DV(~ndxNan),'mean');

% Data to plot: mean values and fitting curve 
PsycOlf.XData = setStim;
PsycOlf.YData = PsycY; 
PsycOlfFit.XData = linspace(min(setStim),max(setStim),100);
if sum(~ndxNan)>10
    PsycOlfFit.YData = glmval(glmfit(DV(~ndxNan),...
                    SessionData.Custom.ChoiceLeft(~ndxNan)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
end

% Calcul Bias and Accuracy
Perf.Bias = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.ChoiceCorrect==1);

% Calcul Accuracy per response port (left/Right):
Perf.Left = sum(SessionData.Custom.LeftRewarded==1  & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.LeftRewarded==1 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
Perf.Right = sum(SessionData.Custom.LeftRewarded==0  & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.LeftRewarded==0 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
Perf.globale = sum(SessionData.Custom.ChoiceCorrect==1)/sum(~isnan(SessionData.Custom.ChoiceCorrect)); 

% Figure f(DV)= % left
subplot(nb_row_fig,nb_col_fig,positn_fig); hold on;% f1=figure('units','normalized','position',[0,0,0.5,0.7]); hold on;
% Data points Accuracy/DV
p=plot(PsycOlf.XData,PsycOlf.YData, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','on');
% Fitting curve   
plot(PsycOlfFit.XData,PsycOlfFit.YData,'color','k','Visible','on');
plot([0, 1],[0.5 0.5],'--','color',[.7,.7 .7]);
p=plot([0.50 0.50],[0 1.05],'--','color',[.7,.7 .7]);
% Legends et axis
p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
ylim([-.05 1.05]);xlim (1*[-.05 1.05]);
title({['Psychometric Light intensity  ' SessionData.Custom.Subject];...
    ['Side Bias toward left = ' num2str(round(Perf.Bias,2))];...
    ['% Success L = ' num2str(round(Perf.Left,2)) ...
    ' / R = ' num2str(round(Perf.Right,2)) ...
    ' / all = ' num2str(round(Perf.globale,2))]},'fontsize',12);
xlabel('DV','fontsize',14);ylabel('% left','fontsize',14);hold off;

clearvars -except SessionData Modality nb_raw_fig nb_col_fig positn_fig Perf
