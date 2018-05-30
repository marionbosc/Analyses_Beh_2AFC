%% Fabrication learning curve on Auditory discrimination:
%
% 
%% Variable de data à recuperer
Perf_Souris = []; Bias_Souris = [];

% Nombre d'animaux? 
prompt = {'N = '}; dlg_title = 'Nb de souris'; numlines = 1;
def = {'4'}; Nb_souris = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

% Nombre de manip a analyser? 
prompt = {'N = '}; dlg_title = 'Nb de manip'; numlines = 1;
def = {'17'}; Nb_de_manip = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt
    
%% Boucle à faire tourner sur chaque animal pour collecter les datas
for souris = 1 : Nb_souris
    %% Recup donnee animal a analyser
    pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Mouse2AFC';
    cd(pathdatalocal);
    prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
    def = {'MC'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  

    %% Suite
    Animal_Names{souris} = Nom;
    prompt = {'N = '}; dlg_title = 'Nombre de manips'; numlines = 1;
    def = {num2str(Nb_de_manip)}; N = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
    clear def dlg_title numlines prompt  

    for jour = 1:N
        [filename{jour},pathname{jour}] = uigetfile([pathdatalocal '/' Nom '/Session Data/*.mat']);
    end

    %% Boucle recup data par bestiaux

    for manip= 1 : size(pathname,2)
        % Chargement manip
        load([pathname{manip} '/' filename{manip}])

        %% Implementation des donnees manquantes pour l'analyse
        SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,manip);

        %% Recup donnees perf et biais par jour
        [SessionData,Perf(manip)] = Psychometric_fig(SessionData, 2,1,1,1);

    end

    %% Remplissage variable data commune:

    if manip<Nb_de_manip
        Perf_Souris = [Perf_Souris; Perf.globale NaN(1,Nb_de_manip-manip)];
        Bias_Souris = [Bias_Souris; Perf.Bias NaN(1,Nb_de_manip-manip)];
    else
        Perf_Souris = [Perf_Souris; Perf(:).globale];
        Bias_Souris = [Bias_Souris; Perf(:).Bias];
    end

    %% Menage:
    clearvars -except Perf_* Bias_* Nb_de_manip Animal_Names
end
%% Representation de la learning curve et du biais au fur et à mesure des sessions:

Mean_Perf_Souris = nanmean(Perf_Souris,1);
SEM_Perf_Souris = nanstd(Perf_Souris,1)./sqrt(size(Perf_Souris,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
e=errorbar(1:Nb_de_manip,Mean_Perf_Souris,SEM_Perf_Souris ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 Nb_de_manip];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
e.Parent.YTick = round(min(e.Parent.YTick)):0.2:round(max(e.Parent.YTick));
plot([1 Nb_de_manip], [0.5 0.5], '--k'); 
title({['Mean accuracy per training session (n =  ' num2str(size(Perf_Souris,1)) ' mice)']},'fontsize',12);
    
% Plot perf per animal
figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for souris = 1:size(Perf_Souris,1)
    e=plot(1:Nb_de_manip,Perf_Souris(souris,:),...
        'LineStyle','-','Marker','o','MarkerSize',6,'Visible','on');% 'k',,'MarkerEdge','k','MarkerFace','k'
end
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 Nb_de_manip];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
e.Parent.YTick = round(min(e.Parent.YTick)):0.2:round(max(e.Parent.YTick));
plot([1 Nb_de_manip], [0.5 0.5], '--k'); 
title('Accuracy per training session for each mice','fontsize',12);
leg = legend(Animal_Names,'Location','southeast');
leg.FontSize = 12; legend('boxoff');

%% Bias
% Absolute value of bias
Bias_abs_Souris = abs(Bias_Souris - 0.5);

Mean_Bias_Souris = nanmean(Bias_abs_Souris,1);
SEM_Bias_Souris = nanstd(Bias_abs_Souris,1)./sqrt(size(Bias_abs_Souris,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
e=errorbar(1:Nb_de_manip,Mean_Bias_Souris,SEM_Bias_Souris ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 Nb_de_manip];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
title({['Mean of absolute side bias per training session (n =  ' num2str(size(Bias_Souris,1)) ' mice)']},'fontsize',12);
 
% Plot bias per animal
figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for souris = 1:size(Bias_abs_Souris,1)
    e=plot(1:Nb_de_manip,Bias_abs_Souris(souris,:),...
        'LineStyle','-','Marker','o','MarkerSize',6,'Visible','on');%'k',,'MarkerEdge','k','MarkerFace','k'
end
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 Nb_de_manip];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
leg = legend(Animal_Names,'Location','northwest');
leg.FontSize = 12; legend('boxoff');
title('Absolute side bias per training session for each mice','fontsize',12);

