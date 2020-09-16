%% CRI
%
% Input : 
%  - DataBefore: before lesion dataset pathway
%  - DataAfter: after lesion dataset pathway
%  - Modality: 1 = Olfaction; 2 = Audition
%  - nbBin
%  - perside: 1 = both side together; 2 = both side separetely
%


function CRI_Olf(DataBefore, DataAfter,perside,AnimalName)
%% Chargement data Before:
% Chargement datas avant lesion:
load(DataBefore);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Recup DV 
if perside ==2
    BinIdx = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
else 
    BinIdx = abs((SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft)) -50)*2/100); % Formule pour reorg les OdorFrac entre -1 et 1. 
end
idx_DV_qty = unique(BinIdx(~isnan(BinIdx)));
for bin = 1: size(idx_DV_qty,2)
    idx_DV_qty(2,bin) =  sum(SessionData.Custom.CatchTrial==1 & BinIdx==idx_DV_qty(1,bin));
end
%%
nbBin = 3;
idx_DV_Before = cell(1,nbBin);
if strcmp(AnimalName,'M7')
    idx_DV_Before{1} = [0 0.1];
    idx_DV_Before{2} = [0.2 0.24 0.3];
    idx_DV_Before{3} = 0.8;
elseif strcmp(AnimalName,'P28')
    idx_DV_Before{1} = [0 0.1 0.12]; 
    idx_DV_Before{2} = [0.16 0.24 0.3]; 
    idx_DV_Before{3} = 0.8; 
end

% index d'essais:
ndxModality = SessionData.Custom.Modality==1;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Calcul CRI pour chaque bin de difficulte:
figure('units','normalized','position',[0,0,1,1]); hold on
AUC_before = []; 
for bin = 1: nbBin
    % Compute mean DV for each bin:
    Mean_DV_Before(bin) = mean(idx_DV_Before{bin});
    
    % Get id for all DV values of the bin
    for idx = 1:size(idx_DV_Before{bin},2)
        SumCorrect(idx) = sum(ndxCorrect& BinIdx==idx_DV_Before{bin}(idx)& ndxModality);
        SumAll(idx) = sum(ndxCorrect& BinIdx==idx_DV_Before{bin}(idx)& ndxModality|ndxFalse & BinIdx==idx_DV_Before{bin}(idx)& ndxModality);
    end
    Perf_per_bin.Before(bin) = sum(SumCorrect)/...
        sum(SumAll);

    subplot(2,nbBin/perside,bin); hold on;
    % Essais Error WS 
    data =[];
    for idx = 1:size(idx_DV_Before{bin},2)
        data = [data SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV_Before{bin}(idx) & ndxModality)];
    end
    D = histogram(data,'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; %
    D.FaceAlpha=0.3;
    % Recup data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;
    clear data

    % Essais Correct Catched
    data =[];
    for idx = 1:size(idx_DV_Before{bin},2)
        data = [data SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV_Before{bin}(idx) & ndxModality)];
    end
    F = histogram(data,'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; %
    F.FaceAlpha=0.3;
    % Recup data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    clear data
    
    % Compute ROC curve:
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_before{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_before{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    % Compute AUROC:
    AUC_before(bin)= trapz(P_Error_before{bin},P_Catch_before{bin});  
    

    title(['BEFORE: DV = ' num2str(idx_DV_Before{bin})  ' / AUC = ' num2str(AUC_before(bin))],...
        'fontsize',10);

    hold off
end
clear idx_DV_qty ndx* SessionData* bin* BinIdx i idx Sum* Theta
%% Chargement data After:
% Chargement datas apres lesion:
load(DataAfter);
SessionData = SessionDataWeek;

% Discretization of trials according to DV bin
% Recup DV 
if perside ==2
    BinIdx = SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft));
else 
    BinIdx = abs((SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft)) -50)*2/100); % Formule pour reorg les OdorFrac entre -1 et 1. 
end
idx_DV_qty = unique(BinIdx(~isnan(BinIdx)));
for bin = 1: size(idx_DV_qty,2)
    idx_DV_qty(2,bin) =  sum(SessionData.Custom.CatchTrial==1 & BinIdx==idx_DV_qty(1,bin));
end
%%
idx_DV_After = cell(1,nbBin);
if strcmp(AnimalName,'M7')
    idx_DV_After{1} = 0.1;
    idx_DV_After{2} = [0.2 0.3];
    idx_DV_After{3} = 0.8;
elseif strcmp(AnimalName,'P28')
    idx_DV_After{1} = 0.12; 
    idx_DV_After{2} = [0.16 0.3]; 
    idx_DV_After{3} = 0.8; 
end

% index d'essais:
ndxModality = SessionData.Custom.Modality==1;
ndxFalse = SessionData.Custom.ChoiceCorrect==0;
ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
ndxCatch = SessionData.Custom.CatchTrial==1;

% Calcul CRI pour chaque bin de difficulte:
%figure('units','normalized','position',[0,0,1,1]); hold on
AUC_After = []; 
for bin = 1 : size(idx_DV_After,2)
    % Compute mean DV for the bin
    Mean_DV_After(bin) = mean(idx_DV_After{bin});
    
    % Get id for all DV values of the bin
    for idx = 1:size(idx_DV_After{bin},2)
        SumCorrect(idx) = sum(ndxCorrect& BinIdx==idx_DV_After{bin}(idx)& ndxModality);
        SumAll(idx) = sum(ndxCorrect& BinIdx==idx_DV_After{bin}(idx)& ndxModality|ndxFalse & BinIdx==idx_DV_After{bin}(idx)& ndxModality);
    end
    Perf_per_bin.After(bin) = sum(SumCorrect)/...
        sum(SumAll);
    
    subplot(2,nbBin/perside,bin+nbBin); hold on;
    % Essais Error WS 
    data =[];
    for idx = 1:size(idx_DV_After{bin},2)
        data = [data SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV_After{bin}(idx) & ndxModality)];
    end
    D = histogram(data,'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; %
    D.FaceAlpha=0.3;
    % Recup data
    Data_Error_WT{bin} = D.BinEdges(2:end);
    Data_Error_P{bin} =  D.Values;
    clear data

    % Essais Correct Catched
    data =[];
    for idx = 1:size(idx_DV_After{bin},2)
        data = [data SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV_After{bin}(idx) & ndxModality)];
    end
    F = histogram(data,'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; %
    F.FaceAlpha=0.3;
    % Recup data
    Data_Catch_WT{bin} = F.BinEdges(2:end);
    Data_Catch_P{bin} = F.Values;
    xlabel('Waiting Time (s)','fontsize',14);ylabel('Probability','fontsize',14);
    legend('WS','Correct Catched','Location','NorthWest');
    clear data
    
    % Compute ROC
    bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
    i=1; 
    for Theta = bin_WT
        P_Error_After{bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
        P_Catch_After{bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
        i=i+1;
    end
    % Compute AUROC
    AUC_After(bin)= trapz(P_Error_After{bin},P_Catch_After{bin});  
    
    title(['AFTER: DV = ' num2str(idx_DV_After{bin})  ' / AUC = ' num2str(AUC_After(bin))],...
        'fontsize',10);
        
    hold off
end

figtitle(['P(WT) per DV percentile BEFORE / AFTER lesion ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');

clear idx_DV_qty ndx* bin* BinIdx i idx Sum* Theta
%% Plot AUC Before-After
figure('units','normalized','position',[0,0,1,1]); hold on

%idx_DV = unique([idx_DV_Before idx_DV_After]);
for bin = 1: nbBin
    subplot(2,nbBin/perside,bin); hold on;
    plot(P_Error_before{bin},P_Catch_before{bin},'k','Linewidth',1);
    plot(P_Error_After{bin},P_Catch_After{bin},'r','Linewidth',1);        
    plot([0 1],[0 1],'--k');
    title(['ROC: DV = ' num2str(unique([idx_DV_Before{bin} idx_DV_After{bin}]))],...
        'fontsize',12);
    xlabel('P(WT > \theta | error)','fontsize',14);ylabel('P(WT > \theta | correct)','fontsize',14);
    legend('Before','After','Location','SouthEast');ylim([0 1]);
end

% Plot Confidence Report Index Before - After
subplot(2,3,4); hold on;
plot(Mean_DV_Before,AUC_before,'-+k','Linewidth',1);
plot(Mean_DV_After,AUC_After,'-+r','Linewidth',1);

xlabel('Mixture contrast','fontsize',14);ylabel('CRI','fontsize',14);%ylim([0 1]);
legend('BEFORE','AFTER','Location','Northwest');
title('Lesion impact on Confidence Report Index',...
        'fontsize',12);

figtitle(['Confidence Report Index BEFORE / AFTER lesion ' SessionData.Custom.Subject],'fontsize',14,'fontweight','bold');

subplot(2,3,5); hold on;
AUCnorm_before = (AUC_before - min(AUC_before))/(1-min(AUC_before));
AUCnorm_After = (AUC_After - min(AUC_After))/(1 -min(AUC_After)) ;
plot(Mean_DV_Before,AUCnorm_before,'-+k','Linewidth',1);
plot(Mean_DV_After,AUCnorm_After,'-+r','Linewidth',1);

xlabel('Mixture contrast','fontsize',14);ylabel('CRI (rescaled)','fontsize',14);%ylim([0 1]);
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