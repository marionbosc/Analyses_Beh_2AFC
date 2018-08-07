%% Script to build learning curve on Auditory discrimination:
%
% 
%% Data variables to retrieve 
Accu_Animals = []; Bias_Animals = [];

% Path data server and local
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Mouse2AFC';
pathdataserver='/Volumes/home/BpodData/Mouse2AFC/';

% Number of animal to include in the analysis 
prompt = {'N = '}; dlg_title = 'How many animals?'; numlines = 1;
def = {'4'}; Nb_animal = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt
   
% Save plot?
prompt = {'Save plot ? '}; dlg_title = '0=No / 1=Yes'; numlines = 1;
def = {'1'}; Saving = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
clear def dlg_title numlines prompt

if Saving==1
    cd(pathdatalocal);
    if ~isdir('LearningCurve')
        mkdir('LearningCurve');
    end
end
%% Loop on each animal to retrieve the data:
for animal = 1 : Nb_animal
    % Get name to find path towards animal's data:
    cd(pathdatalocal);
    prompt = {'Name= '}; dlg_title = 'Which animal ?'; numlines = 1;
    def = {'MC'}; Name = char(inputdlg(prompt,dlg_title,numlines,def)); 
    clear def dlg_title numlines prompt  
    Animal_Names{animal} = Name; 
    
    % Retrieve data files path
    [filename,pathname] = uigetfile([pathdataserver '/' Name '/Session Data/*.mat'], 'MultiSelect','on');
    
    
    % Loop to retrieve data for each session for that animal:
    f=figure;
    for session= 1 : size(filename,2)
        % load data
        load([pathname '/' filename{session}])
        % Check and implement data (if necessary)
        SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,session);
        % Retrieve data on accuracy and bias for the session and plot the Psychometric
        [SessionData,Accu(session)] = Psychometric_fig(SessionData, 2,1,1,1);
    end
    
    % Save psychometric:
    if Saving==1
        cd([pathdatalocal '/LearningCurve']);
        saveas(f,['Psychometric_' Name '.png']);
    end        
    
    % Fill data variable to compute the final analysis/plot
    % case nb of sessions for this animal < max nb of sessions per animal
    if session < size(Accu_Animals,2) 
        Accu_Animals = [Accu_Animals; Accu.globale NaN(1,size(Accu_Animals,2)-session)];
        Bias_Animals = [Bias_Animals; Accu.Bias NaN(1,size(Accu_Animals,2)-session)];
        
    % case nb of sessions for this animal < max nb of sessions per animal
    elseif session > size(Accu_Animals,2)
        Accu_Animals = [Accu_Animals NaN(size(Accu_Animals,1),session-size(Accu_Animals,2)) ; Accu(:).globale];
        Bias_Animals = [Bias_Animals NaN(size(Bias_Animals,1),session-size(Bias_Animals,2)) ; Accu(:).Bias];
        
    % case nb of sessions for this animal = max nb of sessions per animal
    elseif session == size(Accu_Animals,2)
        Accu_Animals = [Accu_Animals; Accu(:).globale];
        Bias_Animals = [Bias_Animals; Accu(:).Bias];
    end

    clearvars -except Accu_* Bias_* Nb_of_sessions Animal_Names Saving pathdata*
end
%% Plot of leaning curves and bias across days:
% Compute mean and sem:
Mean_Perf_Souris = nanmean(Accu_Animals,1);
SEM_Perf_Souris = nanstd(Accu_Animals,1)./sqrt(size(Accu_Animals,1));

% Plot mean (+/-sem):
f1=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
e=errorbar(1:size(Accu_Animals,2),Mean_Perf_Souris,SEM_Perf_Souris ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 size(Accu_Animals,2)];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
e.Parent.YTick = round(min(e.Parent.YTick)):0.2:round(max(e.Parent.YTick));
plot([1 size(Accu_Animals,2)], [0.5 0.5], '--k'); 
title({['Mean accuracy per training session (n =  ' num2str(size(Accu_Animals,1)) ' mice)']},'fontsize',12);
    
% Plot data per animal:
f2=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for animal = 1:size(Accu_Animals,1)
    e=plot(1:size(Accu_Animals,2),Accu_Animals(animal,:),...
        'LineStyle','-','Marker','o','MarkerSize',6,'Visible','on');% 'k',,'MarkerEdge','k','MarkerFace','k'
end
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 1];e.Parent.XLim=[1 size(Accu_Animals,2)];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
e.Parent.YTick = round(min(e.Parent.YTick)):0.2:round(max(e.Parent.YTick));
plot([1 size(Accu_Animals,2)], [0.5 0.5], '--k'); 
title('Accuracy per training session for each mice','fontsize',12);
leg = legend(Animal_Names,'Location','southeast');
leg.FontSize = 12; legend('boxoff');

% Save plots:
if Saving==1
    cd([pathdatalocal '/LearningCurve']);   
    Names = [];
    for animal = 1:size(Animal_Names,2)
        Names = [Names char(Animal_Names(animal))];
    end
    saveas(f1,['MeanAccuracy_' Names '.png']);
    saveas(f2,['Accuracy_' Names '.png']);
end 
%% Bias
% Absolute value of bias
Bias_abs_Souris = abs(Bias_Animals - 0.5);

% Compute mean and sem:
Mean_Bias_Souris = nanmean(Bias_abs_Souris,1);
SEM_Bias_Souris = nanstd(Bias_abs_Souris,1)./sqrt(size(Bias_abs_Souris,1));

% Plot mean (+/-sem):
f3=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
e=errorbar(1:size(Accu_Animals,2),Mean_Bias_Souris,SEM_Bias_Souris ,...
    'k','LineStyle','-','Marker','o','MarkerEdge','r','MarkerFace','r','MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 size(Accu_Animals,2)];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
title({['Mean of absolute side bias per training session (n =  ' num2str(size(Bias_Animals,1)) ' mice)']},'fontsize',12);
 
% Plot data per animal:
f4=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for animal = 1:size(Bias_abs_Souris,1)
    e=plot(1:size(Accu_Animals,2),Bias_abs_Souris(animal,:),...
        'LineStyle','-','Marker','o','MarkerSize',6,'Visible','on');%'k',,'MarkerEdge','k','MarkerFace','k'
end
e.Parent.XLabel.String = 'Behavioral Sessions';e.Parent.YLabel.String = 'Side Bias';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14; 
e.Parent.YLim=[0 0.4];e.Parent.XLim=[1 size(Accu_Animals,2)];
e.Parent.XTick = round(min(e.Parent.XTick)):1:round(max(e.Parent.XTick));
leg = legend(Animal_Names,'Location','northwest');
leg.FontSize = 12; legend('boxoff');
title('Absolute side bias per training session for each mice','fontsize',12);

% Save plots:
if Saving==1
    cd([pathdatalocal '/LearningCurve']);   
    saveas(f3,['MeanBias_' Names '.png']);
    saveas(f4,['Bias_' Names '.png']);
end 
