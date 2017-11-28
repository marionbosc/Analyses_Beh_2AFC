%
%
%
% id_Total_code = 'SessionData.Custom.ChoiceCorrect==0 | SessionData.Custom.ChoiceCorrect==1';
% id_Interet_code = 'SessionData.Custom.ChoiceCorrect==1';

function fig = plot_Beh_param_acr_session (pathname, filename, id_Total_code, id_Interet_code,bin_size,type_variable,epoch,Titre_parametre_analyse)
%% Recup Pourcentage d'un type d'essai dans le temps 

% Figure pourcentage d'erreur et d'essais faux au fur et a mesure de la session
fig = figure('units','normalized','position',[0,0,1,1]); hold on;

% Bornes temporelles (de 0 à 4h de manip)
temps_min= datetime(0*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');
temps_max = datetime(4*3600,'ConvertFrom','epochtime','Epoch','2000-01-01');

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
    
    % Nombre de points dans l'analyse
    Xplot = 0:bin_size:size(SessionData.Custom.ChoiceLeft,2); % Bin de 'bin_size' essais
    Nbbin = size(Xplot,2);   

    % Pourcentage d'essais corrects au fur et a mesure de la session
    id_Total = eval(id_Total_code);
    id_Interet = eval(id_Interet_code);
    
    Pct_Interet = [];
     
    for i=1:Nbbin
        % Incrementation du premier essai du nouveau bin d'essai
        debut = Xplot(i)+1; 
        % Fabrication des bins d'essais a analyser:
        if debut + (bin_size-1) < size(SessionData.Custom.ChoiceLeft,2)
            fin = debut+(bin_size-1);
        else
            fin = size(SessionData.Custom.ChoiceLeft,2);
        end
        if strcmp(type_variable,'ratio')
            % Recup des ratio par bin d'essai 
            Pct_Interet = [Pct_Interet sum(id_Interet(debut:fin))/sum(id_Total(debut:fin))*100];
        elseif strcmp(type_variable,'duration') 
            Pct_Interet = [Pct_Interet nanmean(SessionData.Custom.(genvarname(epoch))(id_Interet(debut:fin)))];
        end
    end
    
    % Recup donnee temporelle (temps fin de bin)
    if size(SessionData.Custom.ChoiceLeft,2)~= Xplot(end)
        Xplot = [Xplot size(SessionData.Custom.ChoiceLeft,2)];
    end
    Xtime = SessionData.Custom.TrialStart(Xplot(2:end));
    
    % ligne moyenne essais faux (mauvais port de reponse)
    plot(Xtime,Pct_Interet, 'LineStyle','-','Color',rand(1,3),'Marker','+','Visible','on','LineWidth',1); 
    pause
    clear SessionData Pct* ndx* Nbbin t Trialstart*
end


%ylim([0 100]);
xlim ([temps_min temps_max]);
% Legendes et axes
%     legend('Wrong side ','Error ','Location','NorthEast');
title([Titre_parametre_analyse ' across session ' Nom] ,'fontsize',12);  %;['WS = ' Tot_False '% /Error = ' Tot_Error ' %']  
xlabel('Time from beginning session','fontsize',16);
ylabel([Titre_parametre_analyse ' per ' num2str(bin_size) ' trials bin'],'fontsize',16);hold off;    

clearvars -except pathname filename fig