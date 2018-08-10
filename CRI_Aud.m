%% Function to compute the Confidence Report Index on the dataset before and after the lesion
%
% Input : 
%  - DataBefore: before lesion dataset pathway
%  - DataAfter: after lesion dataset pathway
%  - Modality: 1 = Olfactory; 2 = Auditory
%  - nbBin: number of DV bins to compute the analysis on
%  - perside: 1 = both side together; 2 = both side separetely
%  - NormWTornot: 1 = use normalized WT; 0 = use raw WT.
%
%


function CRI_Aud(DataBefore, DataAfter, nbBin,perside, NormWTornot)
%% Computation of AUC Before lesion

% Load data Before:
load(DataBefore);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Retrieve DV data
if perside ==2 % case analysis is conducted on left and right side separately
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Computation of DV bins based on percentile distribution of trials
    DV_pctile_Before = min(DV);
    for j = 1:nbBin
        DV_pctile_Before = [DV_pctile_Before prctile(DV,(100/nbBin)*j)];
    end
    BinIdx = discretize(DV,DV_pctile_Before);
else % case analysis is conducted on absolute DV (left and right side pooled together)
    DV = abs(SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft)));
    % Computation of DV bins based on percentile distribution of trials
    DV_pctile_Before = min(DV);
    for j = 1:nbBin
        DV_pctile_Before = [DV_pctile_Before prctile(DV,(100/nbBin)*j)];
    end
    BinIdx = discretize(DV,DV_pctile_Before);
end
idx_DV_Before = unique(BinIdx(~isnan(BinIdx)));

% Trials indices:
ndxModality = SessionData.Custom.Modality==2;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Computation CRI for each DV bin: 
figure('units','normalized','position',[0,0,1,1]); hold on
AUC_before = []; 
for bin = 1: size(idx_DV_Before,2)
    
    % Get data to plot the distrib of trials per DV bin:
    histog_DV.Before.Catch{bin} = SessionData.Custom.DV(ndxCatch & ndxModality & BinIdx==idx_DV_Before(bin));
    histog_DV.Before.Error{bin} = SessionData.Custom.DV(ndxFalse & ndxModality & BinIdx==idx_DV_Before(bin));
    
    % Accuracy per bin
    Accu_per_bin.Before(bin) = sum(ndxCorrect& BinIdx==idx_DV_Before(bin)& ndxModality)/...
        sum(ndxCorrect& BinIdx==idx_DV_Before(bin)& ndxModality|ndxFalse & BinIdx==idx_DV_Before(bin)& ndxModality);

    subplot(2,nbBin/perside,bin); hold on;
    % Wrong side error trials WT distribution
    if NormWTornot==1 && isfield(SessionData.Custom, 'FeedbackTimeNorm')
        D = histogram(SessionData.Custom.FeedbackTimeNorm(ndxFalse & BinIdx==idx_DV_Before(bin) & ndxModality),...
            'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; 
    else
        D = histogram(SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV_Before(bin) & ndxModality),...
            'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; 
    end
    D.FaceAlpha=0.3;
    % Fetch data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;

    % Correct Catched trials WT distribution
    if NormWTornot==1 && isfield(SessionData.Custom, 'FeedbackTimeNorm')
        F = histogram(SessionData.Custom.FeedbackTimeNorm(ndxCorrect & ndxCatch & BinIdx==idx_DV_Before(bin) & ndxModality),...
            'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; 
    else
        F = histogram(SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV_Before(bin) & ndxModality),...
            'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; 
    end
    F.FaceAlpha=0.3;
    % Fetch data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    
    % ROC computation
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_before{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_before{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    
    % AUROC
    AUC_before(bin)= trapz(P_Error_before{bin},P_Catch_before{bin});  
    
    % Histogram plot title
    title(['BEFORE: DV = ' num2str(round(DV_pctile_Before(bin),2)) ' : ' num2str(round(DV_pctile_Before(bin+1),2)) ' / AUC = ' num2str(AUC_before(bin))],...
        'fontsize',10); 

    hold off
end

%% Computation of AUC After lesion

% Load data After:
load(DataAfter);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Retrieve DV data 
if perside ==2 % case analysis is conducted on left and right side separately
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Computation of DV bins based on percentile distribution of trials
    DV_pctile_After = min(DV);
    for j = 1:nbBin
        DV_pctile_After = [DV_pctile_After prctile(DV,(100/nbBin)*j)];
    end
    BinIdx = discretize(DV,DV_pctile_After);
else % case analysis is conducted on absolute DV (left and right side pooled together)
    DV = abs(SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft)));
    % Computation of DV bins based on percentile distribution of trials
    DV_pctile_After = min(DV);
    for j = 1:nbBin
        DV_pctile_After = [DV_pctile_After prctile(DV,(100/nbBin)*j)];
    end
    BinIdx = discretize(DV,DV_pctile_After);
end
idx_DV_After = unique(BinIdx(~isnan(BinIdx)));

% Trials indices:
ndxModality = SessionData.Custom.Modality==2;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Computation CRI for each DV bin:
AUC_After = []; 
for bin = 1 : size(idx_DV_After,2)
    
    % Get data to plot the distrib of trials per DV bin:
    histog_DV.After.Catch{bin} = SessionData.Custom.DV(ndxCatch & ndxModality & BinIdx==idx_DV_After(bin));
    histog_DV.After.Error{bin} = SessionData.Custom.DV(ndxFalse & ndxModality & BinIdx==idx_DV_After(bin));
    
    % Accuracy per bin
    Accu_per_bin.After(bin) = sum(ndxCorrect& BinIdx==idx_DV_After(bin)& ndxModality)/...
        sum(ndxCorrect& BinIdx==idx_DV_After(bin)& ndxModality|ndxFalse & BinIdx==idx_DV_After(bin)& ndxModality);
    
    subplot(2,nbBin/perside,bin+nbBin); hold on;
    % Wrong side error trials WT distribution
    if NormWTornot==1 && isfield(SessionData.Custom, 'FeedbackTimeNorm')
        D = histogram(SessionData.Custom.FeedbackTimeNorm(ndxFalse & BinIdx==idx_DV_After(bin) & ndxModality),...
            'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; 
    else
        D = histogram(SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV_After(bin) & ndxModality),...
            'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on;
    end
    D.FaceAlpha=0.3;
    % Fetch data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;

    % Correct Catched trials WT distribution
    if NormWTornot==1 && isfield(SessionData.Custom, 'FeedbackTimeNorm')
        F = histogram(SessionData.Custom.FeedbackTimeNorm(ndxCorrect & ndxCatch & BinIdx==idx_DV_After(bin) & ndxModality),...
            'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; 
    else
        F = histogram(SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV_After(bin) & ndxModality),...
            'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; 
    end
    F.FaceAlpha=0.3;
    % Fetch data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    
    % ROC computation
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_After{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_After{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    
    % AUROC
    AUC_After(bin)= trapz(P_Error_After{bin},P_Catch_After{bin});  
    
    % Histogram plot title
    title(['AFTER: DV = ' num2str(round(DV_pctile_After(bin),2)) ' : ' num2str(round(DV_pctile_After(bin+1),2)) ' / AUC = ' num2str(AUC_After(bin))],...
         'fontsize',10);
        
    hold off
end

figtitle(['P(WT) per DV percentile BEFORE / AFTER lesion ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');

%% Histo plot of correct/error trials distribution per DV bin 
figure('units','normalized','position',[0,0,0.7,0.8]); hold on
% Correct trials Before
subplot(2,2,1); hold on
for bin = 1:size(idx_DV_Before,2)
    h=histogram(histog_DV.Before.Catch{bin},'BinWidth',0.02); 
    hold on
    if perside ==2
        legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(h.Data),2)) ' : ' num2str(round(max(h.Data),2))];
    else
        legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
    end
end
xlabel('-log(DV)','fontsize',14);ylabel('Number of trials','fontsize',14); xlim([-1.7 1.7]);
%legend(legend_name,'Location','North');
title('Correct Catch trials BEFORE',...
        'fontsize',12);

% Error trials Before
subplot(2,2,2);
for bin = 1: size(idx_DV_Before,2)
    h = histogram(histog_DV.Before.Error{bin},'BinWidth',0.02); 
    hold on
%     if perside ==2
%         legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(h.Data),2)) ' : ' num2str(round(max(h.Data),2))];
%     else
%         legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
%     end
end
xlabel('-log(DV)','fontsize',14);ylabel('Number of trials','fontsize',14); xlim([-1.7 1.7]);
legend(legend_name,'Location','NorthWest');
title('Error trials BEFORE',...
        'fontsize',12);

% Correct trials After
subplot(2,2,3); hold on
for bin = 1 : size(idx_DV_After,2)
    h=histogram(histog_DV.After.Catch{bin},'BinWidth',0.02); 
    hold on
    if perside ==2
        legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(h.Data),2)) ' : ' num2str(round(max(h.Data),2))];
    else
        legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
    end
end
xlabel('-log(DV)','fontsize',14);ylabel('Number of trials','fontsize',14); xlim([-1.7 1.7]);
%legend(legend_name,'Location','North');
title('Correct Catch trials AFTER',...
        'fontsize',12);

% Error trials After
subplot(2,2,4);
for bin = 1 : size(idx_DV_After,2)
    h = histogram(histog_DV.After.Error{bin},'BinWidth',0.02); 
    hold on
%     if perside ==2
%         legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(h.Data),2)) ' : ' num2str(round(max(h.Data),2))];
%     else
%         legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
%     end
end
xlabel('-log(DV)','fontsize',14);ylabel('Number of trials','fontsize',14); xlim([-1.7 1.7]);
legend(legend_name,'Location','NorthWest');
title('Error trials AFTER',...
        'fontsize',12);

figtitle(['Distribution of trials per DV percentile BEFORE / AFTER lesion ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');
%% Plot ROC and AUROC Before-After per DV bin
figure('units','normalized','position',[0,0,1,1]); hold on

% Plot ROC Before and After per bin
for bin = 1: size(idx_DV_After,2)
    subplot(2,nbBin/perside,bin); hold on;
    plot(P_Error_before{bin},P_Catch_before{bin},'k','Linewidth',1);
    plot(P_Error_After{bin},P_Catch_After{bin},'r','Linewidth',1);
    plot([0 1],[0 1],'--k');
    title(['ROC: DV = ' num2str((100/nbBin)*bin) ' th DV percentile'],...
        'fontsize',12);
    xlabel('P(WT > \theta | error)','fontsize',14);ylabel('P(WT > \theta | correct)','fontsize',14);
    legend('Before','After','Location','SouthEast');ylim([0 1]);
end

% Plot of the CRI = f(DVbin)
subplot(2,3,4); hold on;
plot(DV_pctile_Before(1:end-1),AUC_before,'-+k','Linewidth',1);
plot(DV_pctile_After(1:end-1),AUC_After,'-+r','Linewidth',1);
xlabel('-log(DV)','fontsize',14);ylabel('CRI','fontsize',14);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

% Plot of the rescaled CRI = f(DVbin)
subplot(2,3,5); hold on;
AUCnorm_before = (AUC_before - min(AUC_before))/(1-min(AUC_before));
AUCnorm_After = (AUC_After - min(AUC_After))/(1 -min(AUC_After)) ;
plot(DV_pctile_Before(1:end-1),AUCnorm_before,'-+k','Linewidth',1);
plot(DV_pctile_After(1:end-1),AUCnorm_After,'-+r','Linewidth',1);
xlabel('-log(DV)','fontsize',14);ylabel('CRI (rescaled)','fontsize',14);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

% Plot of the CRI = f(Accuracybin)
subplot(2,3,6); hold on;
plot(Accu_per_bin.Before,AUC_before,'-+k','Linewidth',1);
plot(Accu_per_bin.After,AUC_After,'-+r','Linewidth',1);
xlabel('Success Rate','fontsize',14);ylabel('CRI','fontsize',14);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);
figtitle(['Confidence Report Index BEFORE / AFTER lesion ' SessionData.Custom.Subject '  ' SessionData.SessionDate],'fontsize',14,'fontweight','bold');