

function fig = plot_mean_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,type_variable,epoch,Titre_parametre_analyse)
%% Idem per time period

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
fig = figure('units','normalized','position',[0,0,0.5,1]); 
subplot(2,1,1); hold on;

temps_min= datetime(0.25*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

% Vecteur vide pour recup perf par tranche de 30 minutes
Perf_per_demiH = nan(size(pathname,2),20);

for manip= 1 : size(pathname,2)
    % Chargement manip
    load([pathname{manip} '/' filename{manip}])
    Nom = SessionData.filename(1:3);
    
    % Fabrication vecteur temps debut de chaque essai
    if ~isfield(SessionData.Custom, 'TrialStart') ||  ~isfield(SessionData.Custom, 'TrialStartSec')
        % Get and format time of each trial begining in time value
        Trialstart_sessiondata=(SessionData.TrialStartTimestamp-SessionData.TrialStartTimestamp(1));
        t = datetime(Trialstart_sessiondata,'ConvertFrom','epochtime','Epoch','2000-01-01');
        t.Format = 'hh:mm:ss';
        SessionData.Custom.TrialStart(1:SessionData.nTrials) = t(1:SessionData.nTrials);
        SessionData.Custom.TrialStartSec(1:SessionData.nTrials) = Trialstart_sessiondata(1:SessionData.nTrials);
        if isfield(SessionData, 'pathname') && isfield(SessionData, 'filename')
            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
    
    % Conversion dbt essais en minutes
    temps_minutes = SessionData.Custom.TrialStartSec./60;
    
    % Pourcentage d'essais corrects au fur et a mesure de la session
    ndxAllDone = eval(id_Total_code);
    ndxInteret = eval(id_Interet_code);
    
    % Nombre de bin 
    Nbbin = round(temps_minutes(end)/30)+1; % Bins de 30 minutes
    %Nom_bin = 0:30:temps_minutes(end);
    
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
        
        % Calcul taux pour le bin de temps considere
        nb_id_in_bin(bin) = id_fin-id_debut;
        if nb_id_in_bin(bin)>5 || (Xplot(bin)==Xplot(bin-1))==0
            if strcmp(type_variable,'ratio')
                % Recup des ratio par bin d'essai 
                Pct_Interet(bin) = sum(ndxInteret(id_debut:id_fin))/sum(ndxAllDone(id_debut:id_fin))*100;
            elseif strcmp(type_variable,'duration') 
                Pct_Interet(bin) = nanmean(SessionData.Custom.(genvarname(epoch))(ndxInteret(debut:fin)));
            end
        else
            Pct_Interet(bin) = NaN;
            Xplot(bin) = NaT;
        end
    end
    
    % Recup des donnees dans vecteur global
    for i = 1: size(Pct_Interet,2)
        if ~isnan(Pct_Interet(i)) && ~isnat(Xplot(i))
            Perf_per_demiH(manip,i) = Pct_Interet(i);
        end
    end

    % Suppression des valeurs manquantes dans les vecteurs
    Pct_Correct_nonan = Pct_Interet(~isnan(Pct_Interet)&~isnat(Xplot));
    Xplot_nonan = Xplot(~isnan(Pct_Interet)&~isnat(Xplot));    
    
    % ligne moyenne/taux variable d'interet par manip
    plot(Xplot_nonan,Pct_Correct_nonan, 'LineStyle','-','Color',rand(1,3),'Marker','+','Visible','on','LineWidth',1.5); 
    
    clear SessionData Pct* ndx* Nbbin t Trialstart* temps_minutes Xplot* id_debut id_fin bin debut fin nb_id*
end

%ylim([0 100]);
xlim ([temps_min temps_max]);
title([Titre_parametre_analyse ' across session ' Nom],'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session','fontsize',16);ylabel(Titre_parametre_analyse,'fontsize',16);hold off;    

%% Representation des perf moyennes par tranche de 30 minutes:

% Figure moyenne pourcentage d'essais d'interet au fur et a mesure de la session
subplot(2,1,2); hold on;

% Vecteur temps
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
            star{s} = nr2M_etoilesignif(c(signif_idx(s),6));
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
max_fig = max(PsycY + semY);
xlim ([0.25 4]); %ylim([0 max_fig*1.2 ]);
title({[Titre_parametre_analyse ' across session ' Nom]; ['One-w ANOVA: p = ' num2str(round(p,3)) '/ Bonferroni post-hoc: ' post_hoc_res]},'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session(h)','fontsize',16);
ylabel(['Mean ' Titre_parametre_analyse ' (+/-SEM)'],'fontsize',16);
if ~isempty(signif_idx)
    for i = 1:size(X1,1)
        plot([X1(i) X2(i)],[max_fig+1+(i*0.15) max_fig+1+(i*0.15)],'k','LineStyle','-','Marker','+');
        text ((X1(i)+X2(i))/2,max_fig+1.05+(i*0.15),star(i),'fontsize',14);
    end
end
hold off;    