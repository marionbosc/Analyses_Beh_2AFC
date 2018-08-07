%% Script to plot Psychometric in one sensory modality:
%
%
% Input:
% - Dataset --> SessionData or SessionDataWeek or SessionDatasets
% - Sensory modality: 1 = Olfactory / 2 = Auditory click task / 3 = Auditory frequency task  
% - Subplot coordinates (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
%
% Output:
% - Dataset
% - Matrix containing behavioral informations about the data
%

function [SessionData,Perf] = Psychometric_fig(SessionData, Modality,nb_row_fig,nb_col_fig,positn_fig)
%% Subject name:
NameSubject = unique(SessionData.Custom.Subject,'stable');
if size(NameSubject,2)>1
    Names = [];
    for animal = 1:size(NameSubject,2)
        Names = [Names char(NameSubject(animal))];
    end
    NameSubject =  Names;
end
    
%% (1) Psychometric for Olfactory trials

if Modality==1
    % Retrieve fraction of odor A used for each trial:
    OdorFracA = SessionData.Custom.OdorFracA(1:end);
    % Index of olfactory trials
    ndxOlf = SessionData.Custom.Modality(1:end)==1; 
    % Index of trials not completed (ChoiceLeft = NaN)
    ndxNan = isnan(SessionData.Custom.ChoiceLeft);

    % Retrieve of the 6-8 odor fraction used during the training 
    setStim = reshape(unique(OdorFracA),1,[]);
    setStim = setStim(~isnan(setStim));

    % Empty vector to fill with accuracy per DV (or trial type)
    psyc = nan(size(setStim));

    % Loop to retrieve probability to go left for all DV point 
    for iStim = setStim
        ndxStim = reshape(OdorFracA == iStim,1,[]);
        psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndxStim&~ndxNan&ndxOlf))/...
                        sum(ndxStim&~ndxNan&ndxOlf);
    end

    % Data for the plot (point + fitting curve)
    PsycOlf.XData = setStim;
    PsycOlf.YData = psyc; 
    PsycOlfFit.XData = linspace(min(setStim),max(setStim),100);
    if sum(OdorFracA(ndxOlf))>0
        PsycOlfFit.YData = glmval(glmfit(OdorFracA(ndxOlf),...
                        SessionData.Custom.ChoiceLeft(ndxOlf)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
    end
    
    % Bias/Accuracy/Lapse rate calculation
    Perf.Bias = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality);
    Perf.Left = sum(SessionData.Custom.OdorID==1 & SessionData.Custom.Modality==1 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.OdorID==1 & SessionData.Custom.Modality==1 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.Right = sum(SessionData.Custom.OdorID==2 & SessionData.Custom.Modality==1 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.OdorID==2 & SessionData.Custom.Modality==1 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.globale = sum(SessionData.Custom.Modality==1 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.Modality==1 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.left_lapserate = 100 - round(psyc(end)*100,1);
    Perf.right_lapserate = round(psyc(1)*100,1);
    
    % plot: f(% Odor A) = % left
    subplot(nb_row_fig,nb_col_fig,positn_fig); hold on;
    % Points 
    p=plot(PsycOlf.XData,PsycOlf.YData, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','on');
    % Fitting curve 
    plot(PsycOlfFit.XData,PsycOlfFit.YData,'color','k','Visible','on');
    % Legends et axis
    plot([0, 100],[0.5 0.5],'--','color',[.7,.7 .7]);
    p=plot([50 50],[0 105],'--','color',[.7,.7 .7]);
    p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
    ylim([0 1]);xlim (100*[0 1]);
    title({['Psychometric Olf  ' NameSubject '  ' SessionData.SessionDate];...
        ['Side Bias toward left = ' num2str(round(Perf.Bias,2))];...
        ['% Success L = ' num2str(round(Perf.Left,2)) ...
        ' / R = ' num2str(round(Perf.Right,2)) ...
        ' / all = ' num2str(round(Perf.globale,2))]},'fontsize',12);
    xlabel('% odor A','fontsize',14);ylabel('% left','fontsize',14);hold off;

    clearvars -except SessionData Modality nb_raw_fig nb_col_fig positn_fig Perf
end

%% (2) Psychometric for Auditory trials --> Click task
if Modality==2
    % Retrieve DV 
    AudDV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Auditory trials index
    ndxAud = SessionData.Custom.Modality==Modality;
    % Index of trials not completed (ChoiceLeft = NaN)
    ndxNan = isnan(SessionData.Custom.ChoiceLeft);
    
    % Probability to go left for all DV bin/point
    if isfield(SessionData.Settings.GUI, 'AuditoryTrialSelection') && SessionData.Settings.GUI.AuditoryTrialSelection==2
        PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),SessionData.Custom.AuditoryOmega(ndxAud&~ndxNan),'mean');
        PsycX = grpstats(SessionData.Custom.DV(ndxAud&~ndxNan),SessionData.Custom.AuditoryOmega(ndxAud&~ndxNan),'mean');
    else
        AudBin = 8; % DV bins
        BinIdx = discretize(AudDV,linspace(min(AudDV),max(AudDV),AudBin+1));
        PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
        PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*2-1-1/AudBin;
        PsycX = PsycX(~isnan(PsycX));
    end

    % Data for the plot (point + fitting curve)
    PsycAud.YData = PsycY;
    PsycAud.XData = PsycX;
    if sum(ndxAud&~ndxNan) > 1
        PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
        PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
            SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
    end
    
    % Bias/Accuracy/Lapse rate calculation
    ndxModality = SessionData.Custom.AuditoryTrial;
    ndxLeftRewd = SessionData.Custom.ChoiceCorrect == 1  & SessionData.Custom.ChoiceLeft == 1;
    ndxLeftRewDone = SessionData.Custom.LeftRewarded==1 & ~isnan(SessionData.Custom.ChoiceLeft);
    ndxRightRewd = SessionData.Custom.ChoiceCorrect == 1  & SessionData.Custom.ChoiceLeft == 0;
    ndxRightRewDone = SessionData.Custom.LeftRewarded==0 & ~isnan(SessionData.Custom.ChoiceLeft);
    Perf.Left = sum(ndxModality & ndxLeftRewd)/sum(ndxModality & ndxLeftRewDone);
    Perf.Right = sum(ndxModality & ndxRightRewd)/sum(ndxModality & ndxRightRewDone);
    Perf.Bias = (Perf.Left-Perf.Right)/2 + 0.5;
    %Perf.Bias = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality);
    Perf.globale = sum(SessionData.Custom.Modality==2 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.Modality==2 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.left_lapserate = 100 - round(PsycY(end)*100,1);
    Perf.right_lapserate = round(PsycY(1)*100,1);
    
    % plot: f(beta)= % left
    subplot(nb_row_fig,nb_col_fig,positn_fig); hold on;
    % points Perf/DV
    p=plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k',...
        'MarkerSize',3,'Visible','on');  
    % Fitting curve
    plot(PsycAudFit.XData,PsycAudFit.YData,'color','k','Visible','on');
    % Legends et axis
    plot([min(p.XData)-0.05, max(p.XData)+0.05],[0.5 0.5],'--','color',[.7,.7 .7]);
    plot([0 0],[-.05 1.05],'--','color',[.7,.7 .7]);
    p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
    ylim([0 1]);xlim ([min(p.XData)-0.05, max(p.XData)+0.05]);
    title({['Psychometric Aud  ' NameSubject '  ' SessionData.SessionDate];...
        ['Side Bias toward left = ' num2str(round(Perf.Bias,2))];...
        ['% Success L = ' num2str(round(Perf.Left,2)) ...
        ' / R = ' num2str(round(Perf.Right,2)) ...
        ' / all = ' num2str(round(Perf.globale,2))]},'fontsize',12);
    xlabel('Binaural contrast','fontsize',14);ylabel('% left','fontsize',14);hold off;

    clearvars -except SessionData Modality Perf
end

%% (3) Psychometric for Auditory trials --> Frequency task
if Modality==3
    % Retrieve DV 
    BinIdx = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Auditory trials index
    ndxAud = SessionData.Custom.Modality==2;
    % Index of trials not completed (ChoiceLeft = NaN)
    ndxNan = isnan(SessionData.Custom.ChoiceLeft);
    
    % Probability to go left for all DV point
    PsycX = unique(BinIdx(~isnan(BinIdx)));
    PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
    
    % Data for the plot (point + fitting curve)
    PsycAud.YData = PsycY;
    PsycAud.XData = PsycX;
    if sum(ndxAud&~ndxNan) > 1
        PsycAudFit.XData = linspace(min(BinIdx),max(BinIdx),100);
        PsycAudFit.YData = glmval(glmfit(BinIdx(ndxAud&~ndxNan),...
            SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(BinIdx),max(BinIdx),100),'logit');
    end
    
    % Bias/ Accuracy/Lapse rate calculation
    Perf.Bias = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==2)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==2);
    Perf.Left = sum(SessionData.Custom.DV>0 & SessionData.Custom.Modality==2 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.DV>0 & SessionData.Custom.Modality==2 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.Right = sum(SessionData.Custom.DV<0 & SessionData.Custom.Modality==2 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.DV<0 & SessionData.Custom.Modality==2 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.globale = sum(SessionData.Custom.Modality==2 & SessionData.Custom.ChoiceCorrect==1)/sum(SessionData.Custom.Modality==2 & ~isnan(SessionData.Custom.ChoiceCorrect)); 
    Perf.left_lapserate = 100 - round(PsycY(end)*100,1);
    Perf.right_lapserate = round(PsycY(1)*100,1);
    
    % plot: f(beta)= % left
    subplot(nb_row_fig,nb_col_fig,positn_fig); hold on;
    % Data points
    plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k',...
        'MarkerSize',3,'Visible','on');    
    % Fitting curve
    plot(PsycAudFit.XData,PsycAudFit.YData,'color','k','Visible','on');
    % Legends et axis
    plot([-1, 1],[0.5 0.5],'--','color',[.7,.7 .7]);
    p=plot([0 0],[0 1],'--','color',[.7,.7 .7]);
    p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
    ylim([0 1]);xlim ([-1, 1]);
    title({['Psychometric Aud  ' NameSubject '  ' SessionData.SessionDate];...
        ['Side Bias toward left = ' num2str(round(Perf.Bias,2))];...
        ['% Success L = ' num2str(round(Perf.Left,2)) ...
        ' / R = ' num2str(round(Perf.Right,2)) ...
        ' / all = ' num2str(round(Perf.globale,2))]},'fontsize',12);
    xlabel('DV ','fontsize',14);ylabel('% left','fontsize',14);hold off;

    clearvars -except SessionData Perf
end