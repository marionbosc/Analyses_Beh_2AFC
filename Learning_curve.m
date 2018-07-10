%% Fabrication learning curve on Auditory discrimination:
%
% 
%% Recup donnee animal a analyser
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC';
cd(pathdatalocal);
prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

%% Suite
prompt = {'N = '}; dlg_title = 'Nombre de manips'; numlines = 1;
def = {'12'}; N = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
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
% Perf_Taconic = [Perf_Taconic; Perf(:).globale];
% Bias_Taconic = [Bias_Taconic; Perf(:).Bias];

if manip<12
    Perf_CharlesRiver = [Perf_CharlesRiver; Perf.globale NaN(1,12-manip)];
    Bias_CharlesRiver = [Bias_CharlesRiver; Perf.Bias NaN(1,12-manip)];
else
    Perf_CharlesRiver = [Perf_CharlesRiver; Perf(:).globale];
    Bias_CharlesRiver = [Bias_CharlesRiver; Perf(:).Bias];
end

% if manip<8    
%     Perf_Souris = [Perf_Souris; Perf.globale NaN(1,8-manip)];
% else
%     Perf_Souris = [Perf_Souris; Perf(:).globale];
% end
%% Menage:
clearvars -except Perf_* Bias_*

%% Representation de la learning curve et du biais au fur et à mesure des sessions:

Mean_Perf_CharlesRiver = nanmean(Perf_CharlesRiver,1);
SEM_Perf_CharlesRiver = nanstd(Perf_CharlesRiver,1)./sqrt(size(Perf_CharlesRiver,1));
Mean_Perf_Taconic = nanmean(Perf_Taconic,1);
SEM_Perf_Taconic = nanstd(Perf_Taconic,1)./sqrt(size(Perf_Taconic,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
errorbar(1:12,Mean_Perf_Taconic,SEM_Perf_Taconic ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','k','MarkerSize',6,'Visible','on');
e=errorbar(1:12,Mean_Perf_Harlan,SEM_Perf_Harlan ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
% plot(idx_total,Perf.globale,'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','k',...
% 'MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 12];
plot([1 12], [0.5 0.5], '--k'); 
leg = legend('Taconic (n=5)','Harlan (n=10)','Location','southeast');
leg.FontSize = 10; legend('boxoff');

%% Bias
% Absolute value of bias
Bias_abs_Harlan = abs(Bias_Harlan - 0.5);
Bias_abs_Taconic = abs(Bias_Taconic - 0.5);

Mean_Bias_Harlan = nanmean(Bias_abs_Harlan,1);
SEM_Bias_Harlan = nanstd(Bias_abs_Harlan,1)./sqrt(size(Bias_abs_Harlan,1));
Mean_Bias_Taconic = nanmean(Bias_abs_Taconic,1);
SEM_Bias_Taconic = nanstd(Bias_abs_Taconic,1)./sqrt(size(Bias_abs_Taconic,1));

figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
errorbar(1:12,Mean_Bias_Taconic,SEM_Bias_Taconic ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','k','MarkerSize',6,'Visible','on');
e=errorbar(1:12,Mean_Bias_Harlan,SEM_Bias_Harlan ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 12];
leg = legend('Taconic (n=5)','Harlan (n=10)','Location','northeast');
leg.FontSize = 10; legend('boxoff');
