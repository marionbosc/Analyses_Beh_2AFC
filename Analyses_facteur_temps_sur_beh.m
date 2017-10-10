%% Nombre d'essais executes au cours de la session (dans le temps)

figure('units','normalized','position',[0,0,0.7,1]); hold on;

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}])
    
    if ~isfield(SessionData.Custom, 'TrialStart')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if ~isfield(SessionData, 'pathname') && ~isfield(SessionData, 'filename')
            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    plot(SessionData.Custom.TrialStart,SessionData.Custom.TrialNumber,'color',rand(1,3)) 
    
    Tot_essais(manip) = SessionData.Custom.TrialNumber(end);
    Lasttrialtime(manip) = SessionData.Custom.TrialStart(end);
    LasttrialtimeSec(manip) = SessionData.Custom.TrialStartSec(end);
    
    clear SessionData t
end

temps_min= datetime(0*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

title('Nb of trials executed throughout session','fontsize',12);
xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Time from session start','fontsize',16);hold off;

% Scatterplot et correlation entre duree session et nb d'essai
[r, p] = corrcoef(LasttrialtimeSec,Tot_essais);
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;
scatter(Lasttrialtime,Tot_essais,4,'k',...
         'Marker','o','MarkerFaceColor','k','Visible','on','MarkerEdgeColor','k');
xlim ([temps_min temps_max]);
ylabel('Number of executed trials','fontsize',16);xlabel('Session duration','fontsize',16);
title(['Correlation: r = ' num2str(round(r(2),2)) ' / p = '  num2str(round(p(2),2))],'fontsize',14); hold off;

%% Recup perf dans le temps 

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;

temps_min= datetime(0*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}])
    
    % Nombre de points dans l'analyse
    Xplot = 0:50:size(SessionData.Custom.ChoiceLeft,2);
    Nbbin = size(Xplot,2);

    % Pourcentage d'essais corrects au fur et a mesure de la session
    ndxAllDone = SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1;
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    ndxFalse = SessionData.Custom.ChoiceCorrect==0; % False = wrong response port
    ndxError = SessionData.Custom.MissedChoice==1 | SessionData.Custom.EarlyWithdrawal==1 | SessionData.Custom.FixBroke==1; % Error = other beh mistake 

    Pct_Correct = []; Pct_False = [];Pct_Error = [];

    for i=1:Nbbin
        debut = Xplot(i)+1; 
        if debut + 49 < size(SessionData.Custom.ChoiceLeft,2)
            fin = debut+49;
        else
            fin = size(SessionData.Custom.ChoiceLeft,2);
        end
        Pct_Correct = [Pct_Correct sum(ndxCorrect(debut:fin))/sum(ndxAllDone(debut:fin))*100];
        Pct_False = [Pct_False sum(ndxFalse(debut:fin))/sum(ndxAllDone(debut:fin))*100];
        Pct_Error = [Pct_Error sum(ndxError(debut:fin))/size(debut:fin,2)*100];
    end

%     % Donnees moyenne:
%     Tot_Correct = num2str(sum(ndxCorrect)/sum(ndxAllDone)*100);
%     Tot_False = num2str(sum(ndxFalse)/sum(ndxAllDone)*100);
%     Tot_Error = num2str(sum(ndxError)/sum(ndxAllDone)*100);
    
    % Fabrication vecteur temps debut de chaque essai
    if ~isfield(SessionData.Custom, 'TrialStart')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if ~isfield(SessionData, 'pathname') && ~isfield(SessionData, 'filename')
            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    % Recup donnee temporelle
    Xtime = [temps_min SessionData.Custom.TrialStart(Xplot(2:end))];
    
    % ligne moyenne essais faux (mauvais port de reponse)
    plot(Xtime,Pct_Correct, 'LineStyle','-','Color',rand(1,3),'Visible','on','LineWidth',2); 
%     % ligne moyenne essais correct catch 
%     plot(Xplot,Pct_Error,'LineStyle','-','Color','k','Visible','on','LineWidth',2);
    
    clear SessionData Pct* ndx* Nbbin t Trialstart*
end


ylim([0 100]);xlim ([temps_min temps_max]);
% Legendes et axes
%     legend('Wrong side ','Error ','Location','NorthEast');
title({'Performance  '},'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session','fontsize',16);ylabel('Performance','fontsize',16);hold off;    

clearvars -except pathname filename
%% Idem per time period

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
figure('units','normalized','position',[0,0,0.5,0.5]); hold on;

temps_min= datetime(0.25*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

% Vecteur vide pour recup perf par tranche de 30 minutes
Perf_per_demiH = nan(size(pathname,2),20);

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}])
    
    % Fabrication vecteur temps debut de chaque essai
    if ~isfield(SessionData.Custom, 'TrialStart')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if ~isfield(SessionData, 'pathname') && ~isfield(SessionData, 'filename')
            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    % Conversion dbt essais en minutes
    temps_minutes = SessionData.Custom.TrialStartSec./60;
    
    % Pourcentage d'essais corrects au fur et a mesure de la session
    ndxAllDone = SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1;
    ndxCorrect = SessionData.Custom.ChoiceCorrect==1;
    %ndxFalse = SessionData.Custom.ChoiceCorrect==0; % False = wrong response port
    %ndxError = SessionData.Custom.MissedChoice==1 | SessionData.Custom.EarlyWithdrawal==1 | SessionData.Custom.FixBroke==1; % Error = other beh mistake  
    
    % Nombre de bin 
    Nbbin = round(temps_minutes(end)/30)+1;
    
    for bin = 1:Nbbin
        if bin == 1
            debut = 1; fin = 30;
            id_debut = 1;
            id_fin = max(find(temps_minutes<fin));
        else
            debut = fin+1; fin =  debut + 29;
            id_debut = id_fin+1;
            id_fin = max(find(temps_minutes<fin));
        end
        
        Xplot(bin) = SessionData.Custom.TrialStart(id_fin);
        
        % Calcul perf pour le bin de temps considere
        nb_id_in_bin(bin) = id_fin-id_debut;
        if nb_id_in_bin(bin)>5 || (Xplot(bin)==Xplot(bin-1))==0
            Pct_Correct(bin) = sum(ndxCorrect(id_debut:id_fin))/sum(ndxAllDone(id_debut:id_fin))*100;
            %Pct_False(bin) = sum(ndxFalse(debut:fin))/sum(ndxAllDone(debut:fin))*100;
            %Pct_Error(bin) = sum(ndxError(debut:fin))/size(debut:fin,2)*100;
        else
            Pct_Correct(bin) = NaN;
            Xplot(bin) = NaT;
        end
    end
    
    % Recup des donnees dans vecteur global
    for i = 1: size(Pct_Correct,2)
        if ~isnan(Pct_Correct(i)) && ~isnat(Xplot(i))
            Perf_per_demiH(manip,i) = Pct_Correct(i);
        end
    end

    % Suppression des valeurs manquantes dans les vecteurs
    Pct_Correct_nonan = Pct_Correct(~isnan(Pct_Correct)&~isnat(Xplot));
    Xplot_nonan = Xplot(~isnan(Pct_Correct)&~isnat(Xplot));    
    
    % ligne moyenne performance (port de reponse correct) par manip
    plot(Xplot_nonan,Pct_Correct_nonan, 'LineStyle','-','Color',rand(1,3),'Visible','on','LineWidth',2); 
%     % ligne moyenne essais correct catch 
%     plot(Xplot,Pct_Error,'LineStyle','-','Color','k','Visible','on','LineWidth',2);
    
    clear SessionData Pct* ndx* Nbbin t Trialstart* temps_minutes Xplot* id_* bin debut fin nb_id*
end


ylim([0 100]);xlim ([temps_min temps_max]);
% Legendes et axes
%     legend('Wrong side ','Error ','Location','NorthEast');
title({'Performance  '},'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session','fontsize',16);ylabel('Performance','fontsize',16);hold off;    

% Representation des perf moyennes par tranche de 30 minutes:
Demies_heures = datetime((0.5:0.5:10)*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
Demies_heures.Format = 'hh:mm:ss';
Demies_heures_h = 0.5:0.5:10;

% Reorg des donnees 
Y_perf = []; X_Demies_heures = [];
for colonne = 1: size(Perf_per_demiH)
    % Vecteur data:
    idx_ligne = ~isnan(Perf_per_demiH(:,colonne));
    Y_perf = [Y_perf ; Perf_per_demiH(idx_ligne,colonne)];
    X_Demies_heures = [X_Demies_heures ; repmat(Demies_heures_h(colonne),sum(idx_ligne),1)];
    clear idx_ligne
end

% Troncage vecteurs donnees pour analyser les 3.5 premieres heures seulement
idx = find(X_Demies_heures<4);
X_Demies_heures = X_Demies_heures(idx);
Y_perf = Y_perf(idx);
clear idx

% Stat: one-way ANOVA time
[p,~,stat] =anova1(Y_perf,X_Demies_heures,'off');
% Post-hoc
if p<0.06
    c=multcompare(stat,'Alpha',0.01,'CType','bonferroni','Display','off');
    signif_idx = find(c(:,6)<0.06);
    if ~isempty(signif_idx)
        post_hoc_res = '*';
        X1 = c(signif_idx,1)/2;
        X2 = c(signif_idx,2)/2;
        for s=1:size(signif_idx)
            c{s} = nr2M_etoilesignif((c(signif_idx(s),6)))
        end
    else
        post_hoc_res = 'ns';
    end
else
   post_hoc_res = ''; 
   signif_idx = [];
end

[PsycY, semY] = grpstats(Y_perf,X_Demies_heures,{'mean','sem'});
PsyX = unique(X_Demies_heures);

% Plot moyenne+/-sem par tranches de 30 minutes avec resultats stat
errorbar(PsyX,PsycY,semY,'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','b',...
    'MarkerSize',6,'Visible','on');hold on
xlim ([0.25 4]); ylim([0 100]);
title({'Performance across time during session '; ['One-w ANOVA: p = ' num2str(round(p,3)) '/ Bonferroni post-hoc: ' post_hoc_res]},'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session(h)','fontsize',16);ylabel('Performance','fontsize',16);
if ~isempty(signif_idx)
    for i = 1:size(X1,1)
        plot([X1(i) X2(i)],[98-(i*3) 98-(i*3)],'k','LineStyle','-','Marker','+');
        text ((X1(i)+X2(i))/2,98-(i*3)+1,star(i),'fontsize',14);
    end
end
hold off;    






