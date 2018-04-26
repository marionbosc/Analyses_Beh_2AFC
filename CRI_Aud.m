%% CRI
%
% Input : 
%  - DataBefore: before lesion dataset pathway
%  - DataAfter: after lesion dataset pathway
%  - Modality: 1 = Olfaction; 2 = Audition
%  - nbBin
%  - perside: 1 = both side together; 2 = both side separetely
%


function CRI_Aud(DataBefore, DataAfter, nbBin,perside)
%% Chargement data Before:
% Chargement datas avant lesion:
load(DataBefore);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Recup DV 
if perside ==2
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Calculs Bins de difficulte
    % Recup des bornes des bins par percentile de la distrib reelle des essais
    DV_pctile_Before = min(DV);
    for j = 1:nbBin
        DV_pctile_Before = [DV_pctile_Before prctile(DV,(100/nbBin)*j)];
    end
    %BinIdx = discretize(DV,linspace(-1.6,1.6,nbBin+1));
    BinIdx = discretize(DV,DV_pctile_Before);
else
    DV = abs(SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft)));
    % Recup des bornes des bins par percentile de la distrib reelle des essais
    DV_pctile_Before = min(DV);
    for j = 1:nbBin
        DV_pctile_Before = [DV_pctile_Before prctile(DV,(100/nbBin)*j)];
    end
    %BinIdx = discretize(DV,linspace(0,1.6,nbBin+1));
    BinIdx = discretize(DV,DV_pctile_Before);
end
idx_DV_Before = unique(BinIdx(~isnan(BinIdx)));

% index d'essais:
ndxModality = SessionData.Custom.Modality==2;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Calcul CRI pour chaque bin de difficulte:
figure('units','normalized','position',[0,0,1,1]); hold on
AUC_before = []; 
for bin = 1: size(idx_DV_Before,2)
    
    % Recup data plot distrib donnee par bin de DV:
    histog_DV.Before.Catch{bin} = SessionData.Custom.DV(ndxCatch & ndxModality & BinIdx==idx_DV_Before(bin));
    histog_DV.Before.Error{bin} = SessionData.Custom.DV(ndxFalse & ndxModality & BinIdx==idx_DV_Before(bin));
    
    % Recup perf par bin
    Perf_per_bin.Before(bin) = sum(ndxCorrect& BinIdx==idx_DV_Before(bin)& ndxModality)/...
        sum(ndxCorrect& BinIdx==idx_DV_Before(bin)& ndxModality|ndxFalse & BinIdx==idx_DV_Before(bin)& ndxModality);

    subplot(2,nbBin/perside,bin); hold on;
    % Essais Error WS 
    D = histogram(SessionData.Custom.FeedbackTimeNorm(ndxFalse & BinIdx==idx_DV_Before(bin) & ndxModality),...
        'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; %
    D.FaceAlpha=0.3;
    % Recup data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;

    % Essais Correct Catched
    F = histogram(SessionData.Custom.FeedbackTimeNorm(ndxCorrect & ndxCatch & BinIdx==idx_DV_Before(bin) & ndxModality),...
        'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; %
    F.FaceAlpha=0.3;
    % Recup data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_before{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_before{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    
    AUC_before(bin)= trapz(P_Error_before{bin},P_Catch_before{bin});  
    
    title(['BEFORE: DV = ' num2str(round(DV_pctile_Before(bin),2)) ' : ' num2str(round(DV_pctile_Before(bin+1),2)) ' / AUC = ' num2str(AUC_before(bin))],...
        'fontsize',10); 

    hold off
end

%% Chargement data After:
% Chargement datas apres lesion:
load(DataAfter);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Recup DV 
if perside ==2
    DV = SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft));
    % Calculs Bins de difficulte
    % Recup des bornes des bins par percentile de la distrib reelle des essais
    DV_pctile_After = min(DV);
    for j = 1:nbBin
        DV_pctile_After = [DV_pctile_After prctile(DV,(100/nbBin)*j)];
    end
    %BinIdx = discretize(DV,linspace(-1.6,1.6,nbBin+1));
    BinIdx = discretize(DV,DV_pctile_After);
else
    DV = abs(SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft)));
    % Calculs Bins de difficulte
    % Recup des bornes des bins par percentile de la distrib reelle des essais
    DV_pctile_After = min(DV);
    for j = 1:nbBin
        DV_pctile_After = [DV_pctile_After prctile(DV,(100/nbBin)*j)];
    end
    BinIdx = discretize(DV,DV_pctile_After);
    %BinIdx = discretize(DV,linspace(0,1.6,nbBin+1));
end
idx_DV_After = unique(BinIdx(~isnan(BinIdx)));


% index d'essais:
ndxModality = SessionData.Custom.Modality==2;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Calcul CRI pour chaque bin de difficulte:
%figure('units','normalized','position',[0,0,1,1]); hold on
AUC_After = []; 
for bin = 1 : size(idx_DV_After,2)
    
    % Recup data plot distrib donnee par bin de DV:
    histog_DV.After.Catch{bin} = SessionData.Custom.DV(ndxCatch & ndxModality & BinIdx==idx_DV_After(bin));
    histog_DV.After.Error{bin} = SessionData.Custom.DV(ndxFalse & ndxModality & BinIdx==idx_DV_After(bin));
    
    % Calcul Perf par bin
    Perf_per_bin.After(bin) = sum(ndxCorrect& BinIdx==idx_DV_After(bin)& ndxModality)/...
        sum(ndxCorrect& BinIdx==idx_DV_After(bin)& ndxModality|ndxFalse & BinIdx==idx_DV_After(bin)& ndxModality);
    
    subplot(2,nbBin/perside,bin+nbBin); hold on;
    % Essais Error WS 
    D = histogram(SessionData.Custom.FeedbackTimeNorm(ndxFalse & BinIdx==idx_DV_After(bin) & ndxModality),...
        'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; %
    D.FaceAlpha=0.3;
    % Recup data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;

    % Essais Correct Catched
    F = histogram(SessionData.Custom.FeedbackTimeNorm(ndxCorrect & ndxCatch & BinIdx==idx_DV_After(bin) & ndxModality),...
        'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; %
    F.FaceAlpha=0.3;
    % Recup data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_After{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_After{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    
    AUC_After(bin)= trapz(P_Error_After{bin},P_Catch_After{bin});  
    
    title(['AFTER: DV = ' num2str(round(DV_pctile_After(bin),2)) ' : ' num2str(round(DV_pctile_After(bin+1),2)) ' / AUC = ' num2str(AUC_After(bin))],...
         'fontsize',10);
        
    hold off
end

figtitle(['P(WT) per DV percentile BEFORE / AFTER lesion ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');

%% Figure histo rpsttn des nb essais Correct_catch/Error par WT par bin
figure('units','normalized','position',[0,0,0.7,0.8]); hold on
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

%% Plot AUC Before-After
figure('units','normalized','position',[0,0,1,1]); hold on

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

% Plot Confidence Report Index Before - After
subplot(2,3,4); hold on;
plot(DV_pctile_Before(1:end-1),AUC_before,'-+k','Linewidth',1);
plot(DV_pctile_After(1:end-1),AUC_After,'-+r','Linewidth',1);
xlabel('-log(DV)','fontsize',14);ylabel('CRI','fontsize',14);%ylim([0 1]);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

figtitle(['Confidence Report Index BEFORE / AFTER lesion ' SessionData.Custom.Subject],'fontsize',14,'fontweight','bold');

subplot(2,3,5); hold on;
AUCnorm_before = (AUC_before - min(AUC_before))/(1-min(AUC_before));
AUCnorm_After = (AUC_After - min(AUC_After))/(1 -min(AUC_After)) ;
plot(DV_pctile_Before(1:end-1),AUCnorm_before,'-+k','Linewidth',1);
plot(DV_pctile_After(1:end-1),AUCnorm_After,'-+r','Linewidth',1);
xlabel('-log(DV)','fontsize',14);ylabel('CRI (rescaled)','fontsize',14);%ylim([0 1]);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

figtitle(['Confidence Report Index BEFORE / AFTER lesion ' SessionData.Custom.Subject],'fontsize',14,'fontweight','bold');

% Plot Confidence Report Index Before - After
subplot(2,3,6); hold on;
plot(Perf_per_bin.Before,AUC_before,'-+k','Linewidth',1);
plot(Perf_per_bin.After,AUC_After,'-+r','Linewidth',1);
xlabel('Success Rate','fontsize',14);ylabel('CRI','fontsize',14);%ylim([0 1]);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

figtitle(['Confidence Report Index BEFORE / AFTER lesion ' SessionData.Custom.Subject '  ' SessionData.SessionDate],'fontsize',14,'fontweight','bold');