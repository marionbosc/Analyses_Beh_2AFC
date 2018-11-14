%% Function to compute the Confidence Report Index of several datasets and to compare them
%
% Input : 
%  - Modality: 1 = Olfactory; 2 = Auditory
%  - nbBin: number of DV bins to compute the analysis on
%  - Figornot = 0 ne genere pas de figure / = 1 genere les figures
%  - Nom_dataset: cellule contenant le nom des dataset � analyser
%  - varargin: dataset1, dataset2,...datasetn � comparer
%
% Output:
%  - DV_pctile (dataset,Difficulty_bin): Difficulty bin boundary for each
%  dataset
%  - AUC (dataset,Difficulty_bin): ROC Area Under the Curve results
%  - Accu_per_bin (dataset,Difficulty_bin): Success rate calculated on all
%  the trials from the difficulty bin per dataset
%


function [DV_pctile,AUC,Accu_per_bin,AUCnorm]=CRI_unlim(Modality, nbBin, Figornot, Nom_dataset, varargin)
%% Assess the number of dataset to include into the analysis:
nb_dataset = size(varargin,2);

if Figornot
    figure('units','normalized','position',[0,0,1,1]); hold on
end

% Empty variable to collect data in the main loop:
if Modality ==1 % Olfactory trials
    idx_DV = nan(nb_dataset,6);
    Accu_per_bin = nan(nb_dataset,6);
    DV_pctile = nan(nb_dataset,6);
    AUC = nan(nb_dataset,6);
else % Auditory trials
    idx_DV = []; 
    Accu_per_bin = [];
    DV_pctile = []; 
    AUC = []; 
end
histog_DV = {}; P_Catch = {}; P_Error = {};

for dataset = 1:nb_dataset
    %% Data loading and CRI computing for each dataset:
   
    load(varargin{dataset});
    SessionData = SessionDataWeek;

    % Discretization of trials according to DV bin
    % Getting DV 
    if Modality ==1 % Olfactory trials
        BinIdx = abs((SessionData.Custom.OdorFracA(1:numel(SessionData.Custom.ChoiceLeft)) -50)*2/100); % Formula to transform OdorFracA into a DV index (between -1 and 1)
        idx_DV_Before = unique(BinIdx(~isnan(BinIdx)));
        for bin = 1: size(idx_DV_Before,2)
            if sum(SessionData.Custom.CatchTrial==1 & BinIdx==idx_DV_Before(bin)) < 10
                idx_DV_Before(bin) =  NaN;
            end
        end
        idx_DV_Before = idx_DV_Before(~isnan(idx_DV_Before));
        idx_DV(dataset,1:size(idx_DV_Before,2)) = idx_DV_Before; clear idx_DV_Before     
        nbBin = sum(~isnan(idx_DV(dataset,:)));
    else % Auditory trials
        DV = abs(SessionData.Custom.DV(1:numel(SessionData.Custom.ChoiceLeft)));
        % Get DV bin bounds from all trials distrib percentile:
        DV_pctile(dataset,:) = min(DV);
        for j = 1:nbBin
            DV_pctile(dataset,j+1) = prctile(DV,(100/nbBin)*j);
        end
        % Binned DV value for all trials:
        BinIdx = discretize(DV,DV_pctile(dataset,:));
        idx_DV(dataset,:) = unique(BinIdx(~isnan(BinIdx)));
    end

    % Trial types:
    ndxModality = SessionData.Custom.Modality==Modality;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0;
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxCatch = SessionData.Custom.CatchTrial==1;

    % Compute CRI for each difficulty bin:
    for bin = 1: nbBin

        if Modality ==2 % Auditory trials
            % Fetch data plot distrib per DV bin:
            histog_DV.Catch{dataset,bin} = SessionData.Custom.DV(ndxCatch & ndxModality & BinIdx==idx_DV(dataset,bin));
            histog_DV.Error{dataset,bin} = SessionData.Custom.DV(ndxFalse & ndxModality & BinIdx==idx_DV(dataset,bin));
        end
        % Compute bin's success rate
        Accu_per_bin(dataset,bin) = sum(ndxCorrect& BinIdx==idx_DV(dataset,bin)& ndxModality)/...
            sum(ndxCorrect& BinIdx==idx_DV(dataset,bin)& ndxModality|ndxFalse & BinIdx==idx_DV(dataset,bin)& ndxModality);
        
        if Figornot
            % subplot of the WT distribution for Correct Catch and Error trials per bin
            subplot(nb_dataset,size(idx_DV,2),bin+(size(idx_DV,2)*(dataset-1))); hold on;
            % Error trials histogram: 
            D = histogram(SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV(dataset,bin) & ndxModality),...
                'FaceColor','m','EdgeColor','m','BinWidth',0.1,'Normalization','probability'); hold on; 
            D.FaceAlpha=0.3;
            % Fetch data:
            Data_Error_WT{bin} = D.BinEdges(2:end);
            Data_Error_P{bin} =  D.Values;
        else
            [Values, BinEdges] = histcounts(SessionData.Custom.FeedbackTime(ndxFalse & BinIdx==idx_DV(dataset,bin) & ndxModality),...
                'BinWidth',0.1,'Normalization','probability');
            % Fetch data:
            Data_Error_WT{bin} = BinEdges(2:end);
            Data_Error_P{bin} =  Values;
            clear Values BinEdges
        end
        

        if Figornot
            % Correct Catched trials histogram:
            F = histogram(SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV(dataset,bin) & ndxModality),...
                'FaceColor','y','EdgeColor','y','BinWidth',0.1,'Normalization','probability'); hold on; %
            F.FaceAlpha=0.3;
            % Fetch data:
            Data_Catch_WT{bin} = F.BinEdges(2:end);
            Data_Catch_P{bin} = F.Values;
            % Figures axes and legend
            xlabel('Waiting Time (s)','fontsize',12);ylabel('Probability','fontsize',12);
            if dataset == 1 && bin ==1
                legend('WS','Correct Catched','Location','NorthWest');
            end
        else
            [Values, BinEdges] = histcounts(SessionData.Custom.FeedbackTime(ndxCorrect & ndxCatch & BinIdx==idx_DV(dataset,bin) & ndxModality),...
                'BinWidth',0.1,'Normalization','probability');
            % Fetch data:
            Data_Catch_WT{bin} = BinEdges(2:end);
            Data_Catch_P{bin} = Values;
            clear Values BinEdges
        end
        
        
        % Compute WT criterion for the ROC analysis:
        bin_WT = linspace(max([Data_Error_WT{bin} Data_Catch_WT{bin}]), min([Data_Error_WT{bin} Data_Catch_WT{bin}]),20);
        i=1; 
        % Fetch probabilities of error/correct catch trials WT > criterion, for each criterion
        for Theta = bin_WT 
            P_Error{dataset,bin}(i) = sum(Data_Error_P{bin}(Data_Error_WT{bin}>Theta));
            P_Catch{dataset,bin}(i) = sum(Data_Catch_P{bin}(Data_Catch_WT{bin}>Theta)); 
            i=i+1;
        end
        clear Data_* Theta bin_WT 
        % Compute area under the curve under the ROC curve
        AUC(dataset,bin)= trapz(P_Error{dataset,bin},P_Catch{dataset,bin});  
        
        if Figornot
            % Plot subplot title with the DV bounds and the AUC of the bin:
            if Modality ==1 % Olfactory trials
                title([Nom_dataset{dataset} ' : DV = ' num2str(idx_DV(dataset,bin))  ' / AUC = ' num2str(round(AUC(dataset,bin),2))],...
                    'fontsize',12);
                hold off
            else % Auditory trials
                title([Nom_dataset{dataset} ' : DV = ' num2str(round(DV_pctile(dataset,bin),2)) ' : ' num2str(round(DV_pctile(dataset,bin+1),2)) ' / AUC = ' num2str(round(AUC(dataset,bin),2))],...
                    'fontsize',12); 
            end
        end        
    end
    
    % Computation of normalized (rescaled) AUC:
    AUCnorm(dataset,:) = (AUC(dataset,:) - min(AUC(dataset,:)))/(1-min(AUC(dataset,:)));       
    
    clear ndx* BinIdx D F
end

if Figornot
    % Main figure title
    figtitle(['P(WT) per DV percentile ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');

    %% Plot trial DV distribution for Correct_catch/Error trial among created DV bins
    if Modality == 2 && Figornot % Auditory trials
        figure('units','normalized','position',[0,0,1,1]); hold on

        % Main loop: each dataset is plot on a row
        for dataset = 1:nb_dataset
            % Correct catch trials distribution
            subplot(nb_dataset,2,1+(2*(dataset-1))); hold on
            for bin = 1:size(idx_DV,2)
                h=histogram(histog_DV.Catch{dataset,bin},'BinWidth',0.02); 
                hold on
    %             legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
            end
            xlabel('Binaural contrast','fontsize',12);ylabel('Number of trials','fontsize',12); xlim([-1 1]);

    %         legend(legend_name,'Location','North');
            title(['Correct Catch trials ' Nom_dataset{dataset}],...
                    'fontsize',12);

            % Error trials distribution
            subplot(nb_dataset,2,2+(2*(dataset-1)));
            for bin = 1: size(idx_DV,2)
                h = histogram(histog_DV.Error{dataset,bin},'BinWidth',0.02); 
                hold on
                legend_name{bin} = [num2str((100/nbBin)*bin) ' th DV pctl = ' num2str(round(min(abs(h.Data)),2)) ' : ' num2str(round(max(abs(h.Data)),2))];
            end
            xlabel('Binaural contrast','fontsize',12);ylabel('Number of trials','fontsize',12); xlim([-1 1]);
            legend(legend_name,'Location','NorthWest');
            title(['Error trials ' Nom_dataset{dataset}],...
                    'fontsize',12);
        end

        % Main figure title
        figtitle(['Distribution of trials per DV percentile ' SessionData.Custom.Subject '   '  SessionData.SessionDate],'fontsize',14,'fontweight','bold');
    end
    %% Plot AUC Before-After
    figure('units','normalized','position',[0,0,1,1]); hold on

    if Modality ==1 % Olfactory trials
        % Fetch all the DV used for the ROC curve analysis
        idx_DV_alldataset = { 0; 0.1; 0.12; [0.16 0.24]; 0.3; 0.8}; % idx_DV_alldataset = unique(idx_DV(~isnan(idx_DV)));
        datasetincl =[]; % Variable to fetch which dataset is on the bin being plotted

        % Plot per difficulty bin:
        for bin = 1: size(idx_DV_alldataset,1)
            subplot(2,size(idx_DV_alldataset,1),bin); hold on;
            for dataset = 1:nb_dataset
                if size(idx_DV_alldataset{bin},2)>1
                    idx = [];
                    for i = 1:size(idx_DV_alldataset{bin},2)
                        idx = [idx find(idx_DV(dataset,:) == idx_DV_alldataset{bin}(i))];
                    end
                else
                    idx = find(idx_DV(dataset,:) == idx_DV_alldataset{bin});
                end               
                if ~isempty(idx)
                    plot(P_Error{dataset,idx},P_Catch{dataset,idx},'Linewidth',1.2);
                    datasetincl =[datasetincl dataset];clear idx
                end
            end
            % Legends and settings ROC plot per difficulty bin:
            plot([0 1],[0 1],'--k');
            title(['ROC: DV = ' num2str(idx_DV_alldataset{bin})],...
                'fontsize',12);
            xlabel('P(WT > \theta | error)','fontsize',14);ylabel('P(WT > \theta | correct)','fontsize',14);
            legend(Nom_dataset{datasetincl},'Location','SouthEast'); xlim([0 1]); ylim([0 1]);
            datasetincl =[]; 
        end

    else % Auditory trials 
        for bin = 1: size(idx_DV,2)
            subplot(2,nbBin,bin); hold on;
            for dataset = 1:nb_dataset
                plot(P_Error{dataset,bin},P_Catch{dataset,bin},'Linewidth',1.4);
            end    
            plot([0 1],[0 1],'--k');
            title(['ROC: DV = ' num2str((100/nbBin)*bin) ' th DV percentile'],...
                'fontsize',12);
            xlabel('P(WT > \theta | error)','fontsize',14);ylabel('P(WT > \theta | correct)','fontsize',14);
            legend(Nom_dataset,'Location','SouthEast');xlim([0 1]); ylim([0 1]);
        end
    end

    % Plot Confidence Report Index for every condition per bin of difficulty
    subplot(2,3,4); hold on;
    for dataset = 1:nb_dataset
        if Modality ==1 % Olfactory trials
            plot(idx_DV(dataset,:),AUC(dataset,:),'-','Linewidth',1.4);
        else % Auditory trials
            plot(DV_pctile(dataset,1:end-1),AUC(dataset,:),'-','Linewidth',1.4);
        end
    end
    xlabel('Binaural contrast','fontsize',14);ylabel('CRI','fontsize',14);%ylim([0 1]);
    legend(Nom_dataset,'Location','Northwest');
    title('Lesion impact on Confidence Report Index',...
            'fontsize',12);
        
    % Plot Confidence Report Index for every condition per bin of difficulty
    subplot(2,3,5); hold on;
    for dataset = 1:nb_dataset
        if Modality ==1 % Olfactory trials
            plot(idx_DV(dataset,:),AUCnorm(dataset,:),'-','Linewidth',1.4);
        else % Auditory trials
            plot(DV_pctile(dataset,1:end-1),AUCnorm(dataset,:),'-','Linewidth',1.4);
        end
    end
    xlabel('Binaural contrast','fontsize',14);ylabel('CRI (rescaled)','fontsize',14);%ylim([0 1]);
    legend(Nom_dataset,'Location','Northwest');
    title('Lesion impact on Confidence Report Index',...
            'fontsize',12);

    % Plot Confidence Report Index for every condition per success rate (of each analysed bin)
    subplot(2,3,6); hold on;
    for dataset = 1:nb_dataset
        plot(Accu_per_bin(dataset,:),AUC(dataset,:),'-','Linewidth',1.4);
    end
    xlabel('Accuracy','fontsize',14);ylabel('CRI','fontsize',14);%ylim([0 1]);
    legend(Nom_dataset,'Location','Northwest');
    title('Lesion impact on Confidence Report Index',...
            'fontsize',12);

    % Main figure title    
    figtitle(['Confidence Report Index ' SessionData.Custom.Subject],'fontsize',14,'fontweight','bold');
end