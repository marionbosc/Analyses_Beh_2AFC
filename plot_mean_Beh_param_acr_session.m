%% Plot the mean of a parameter through time for multiple session 
%
%

function fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse,statornot,colorornot,Uppertimelimit)
% Figure 
fig = figure('units','normalized','position',[0,0,0.5,1]); 
subplot(2,1,1); hold on;

% Slot duration and sliding window
Slot_duration_in_min = 10;
Duration_btw_sliding_slot = Slot_duration_in_min/2;

% Empty array to collect data per time slot
Perf_per_Time_slot = nan(size(filename,2),30);

for manip= 1 : size(filename,2)
    % Load SessionData
    load([pathname '/' filename{manip}])
    Nom = SessionData.Custom.Subject;
    
    % Built time vector from beginning of the session
    if ~isfield(SessionData.Custom, 'TrialStart') ||  ~isfield(SessionData.Custom, 'TrialStartSec')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if isfield(SessionData, 'pathname') && isfield(SessionData, 'filename')
            % Implemented data saving
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    % Conversion TrialStartSec in minutes
    temps_minutes = SessionData.Custom.TrialStartSec./60;
    
    % id of interest to quantify
    ndxAllDone = eval(id_Total_code);
    ndxInteret = eval(id_Interet_code);
    
    % Main loop to gather data per time point with a sliding window
    bin = 1;
    while bin > 0 % bin = 0 when all the trials have been elapsed (and the session is done)
        if bin == 1 % First bin
            debut = 0; fin = Slot_duration_in_min;
            id_debut = 1;
            id_fin = max(find(temps_minutes<fin));
            Xplot(manip,bin) = datetime((SessionData.Custom.TrialStart(1) + minutes(Duration_btw_sliding_slot)),'ConvertFrom','epochtime','Epoch','2000-01-01');
        else
            debut = debut+Duration_btw_sliding_slot; fin =  fin + Duration_btw_sliding_slot;
            id_debut = min(find(temps_minutes>debut));
            id_fin = max(find(temps_minutes<fin));
            Xplot(manip,bin) = datetime((Xplot(manip,bin-1) + minutes(Duration_btw_sliding_slot)),'ConvertFrom','epochtime','Epoch','2000-01-01');        
        end
           
        % Quantification of the parameter of interest on the set of trials
        % executed during the time slot
        nb_id_in_bin(bin) = id_fin-id_debut;
        if nb_id_in_bin(bin)>5 || bin>1 && (Xplot(manip,bin)==Xplot(manip,bin-1))==0
            if strcmp(type_variable,'ratio') % to estimate an amount of trial
                Perf_per_Time_slot(manip,bin) = sum(ndxInteret(id_debut:id_fin))/sum(ndxAllDone(id_debut:id_fin))*100;
            elseif strcmp(type_variable,'duration') % to get the mean duration of an event
                idxInteret = intersect(find(ndxInteret),id_debut:id_fin);
                Perf_per_Time_slot(manip,bin) = nanmean(SessionData.Custom.(genvarname(epoch))(idxInteret));
            end
        else
            Perf_per_Time_slot(manip,bin) = NaN; % if not enough trials --> no datapoint
        end
        
         if nb_id_in_bin(bin)>1 && id_fin ~= size(ndxAllDone,2) %  if the bin is not the last one, the window keep sliding
             bin = bin+1;
         else
             bin = 0;
         end 
    end

    % Delete NaN value before plotting the data for the session
    Pct_Correct_nonan = Perf_per_Time_slot(manip,~isnan(Perf_per_Time_slot(manip,:)));
    Xplot_nonan = Xplot(manip,~isnan(Perf_per_Time_slot(manip,:))); 
    
    % Plot of the variable of interest for the session
    if colorornot
        p = plot(Xplot_nonan,Pct_Correct_nonan, 'Color',rand(1,3),'Marker','none','Visible','on','LineWidth',1); % version with one colored line per session
    else
        p = plot(Xplot_nonan,Pct_Correct_nonan, 'LineStyle','none','Color','k','Marker','+','Visible','on'); % version with black dots without line
    end
    
    
    clear Pct* ndx* t Trialstart* temps_minutes id_debut id_fin bin debut fin nb_id*
end

% Title/Label/Axis of the plot
% xlim ([SessionData.Custom.TrialStart(1) max(Xplot(:,end))]);
title([Titre_parametre_analyse ' across session ' Nom],'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session','fontsize',14);ylabel(Titre_parametre_analyse,'fontsize',14);hold off;    

%% Mean of the data per time slot:

% subPlot
subplot(2,1,2); hold on;

% Data reconfiguration
Y_perf = []; X_Time_slot = [];
Time_vector = datestr(max(Xplot),'HH:MM');
Perf_per_Time_slot = Perf_per_Time_slot(:,1:size(Time_vector,1));
if  exist('Uppertimelimit','var')
    imaxTime = find(contains(cellstr(Time_vector),Uppertimelimit));
else
    imaxTime = size(Time_vector,1);
end
    
for colonne = 1 : imaxTime  
    % Data array:
    idx_ligne = ~isnan(Perf_per_Time_slot(:,colonne));
    Y_perf = [Y_perf ; Perf_per_Time_slot(idx_ligne,colonne)];
    X_Time_slot = [X_Time_slot ; repmat(Time_vector(colonne,:),sum(idx_ligne),1)];
    clear idx_ligne
end

% Mean and std of the data:
[PlotY, semY,PlotX] = grpstats(Y_perf,X_Time_slot,{'mean','sem','gname'});

if statornot==1
    % Stat: one-way ANOVA time
    [p,~,stat] =anova1(Y_perf,X_Time_slot,'off');
    % Post-hoc
    if p<0.06
        c=multcompare(stat,'Alpha',0.01,'CType','bonferroni','Display','off');
        signif_idx = find(c(:,6)<0.06);
        if ~isempty(signif_idx)
            post_hoc_res = '*';
            X1 = PlotX(c(signif_idx,1));
            X2 = PlotX(c(signif_idx,2));
            for s=1:size(signif_idx)
                star{s} = nr2M_etoilesignif(c(signif_idx(s),6));
            end
        else
            post_hoc_res = 'ns';
        end
        if exist('X1','var')
            X1 = datenum(X1,'HH:MM');
            X2 = datenum(X2,'HH:MM');
        end
    else
       post_hoc_res = '-'; 
       signif_idx = [];
    end
    TitleStat = [' One-w ANOVA: p = ' num2str(round(p,3)) '/ Bonferroni post-hoc: ' post_hoc_res];
else
    TitleStat = [];
end

% Plot mean+/-sem per time slot
% e=errorbar(datenum(PlotX,'HH:MM'),PlotY,semY,'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','b',...
%     'MarkerSize',6,'Visible','on');hold on
e=errorbar(datenum(PlotX,'HH:MM'),PlotY,semY,'k','LineStyle','-','Marker','none');hold on
e.Parent.XGrid = 'on'; e.Parent.YGrid = 'on';
datetick('x','HH:MM');
max_fig = max(PlotY + semY);
% ylim([0 max_fig*1.2 ]); % xlim ([0 2]);
title({[Titre_parametre_analyse ' across session ' Nom],TitleStat},'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session (h)','fontsize',14);
ylabel(['Mean ' Titre_parametre_analyse ' (+/-SEM)'],'fontsize',14);
if statornot==1 && ~isempty(signif_idx) % adding statistical result if wanted
    for i = 1:size(X1,1)
        plot([X1(i) X2(i)],[max_fig+1+(i*2) max_fig+1+(i*2)],'k','LineStyle','-','Marker','+');
        text ((X1(i)+X2(i))/2,max_fig+1.5+(i*2),star(i),'fontsize',14);
    end
    ylim([0  max_fig+5+(i*2)]);
end
hold off;    
  