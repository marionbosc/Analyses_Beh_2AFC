%% Script to build learning curve on Auditory discrimination:
%
% 
%% Data variables to retrieve 
Accu_Animals = []; Bias_Animals = [];

% Prompt windows to select the localisation of data files:
Pathtodata = choosePath('Mouse2AFC');
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Mouse2AFC';
cd(Pathtodata);

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
    
    % Prompt windows to select if dataset already exist or needs to be create
    answer = questdlg('Filenames need to be...','Dataset filenames', 'loaded','created','');

    % Handle response
    switch answer
        case 'loaded'
            cd([Pathtodata '/' Name '/Session Data/']);
            uiopen; pathname =cd;
            DatasetName = '19';
        case 'created'
        % Retrieve data files path
        [filename,pathname] = uigetfile([Pathtodata '/' Name '/Session Data/*.mat'], 'MultiSelect','on');
    end

    
    % Loop to retrieve data for each session for that animal:
    f=figure;
    for session= 1 : size(filename,2)
        % load data
        load([pathname '/' filename{session}])
        % Check and implement data (if necessary)
        SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,session);
        % Get the date of the session:
        datemanip{animal,session} = datestr(datetime(str2num(SessionData.SessionDate) , 'ConvertFrom','yyyymmdd'),'dd-mmm');
        if isfield(SessionData.Custom, 'AuditoryOmega')
            % Get the binaural contrast of the session:
            Bin_Contrast{animal,session}= unique(SessionData.Custom.AuditoryOmega)*100;
            Modality = 2;
        elseif isfield(SessionData.Custom, 'StimulusOmega')
            % Get the binaural contrast of the session:
            Bin_Contrast{animal,session}= unique(SessionData.Custom.StimulusOmega)*100;
            Modality = 4;
        end
        
        % Retrieve data on accuracy and bias for the session and plot the Psychometric
        [SessionData,Accu(session)] = Psychometric_fig(SessionData, Modality,1,1,1);
    end
    
    % Save psychometric:
    if Saving==1
        cd([pathdatalocal '/LearningCurve']);
        saveas(f,['Psychometric_' Name '.png']);
    end        
    
    % Plot learning curve per date of session
    f=figure; hold on; Accuracy = [Accu.globale];
    e=plot(datetime(datestr(datemanip(animal,find(~cellfun(@isempty,datemanip(animal,:)))))),...
        Accuracy,... %Accu.globale(1,~isnan(Accu.globale(1,:))),...
         'k','LineStyle','-','LineWidth',2);
     % Add a marker on the accuracy curve for each session with increased
     % difficulty
     new_difficulty = []; 
     for manip = 2:size([Accu.globale],2)
        if ~isequal(Bin_Contrast(animal,manip),Bin_Contrast(animal,manip-1))
            new_difficulty = [new_difficulty manip]; 
        end
     end
     if ~isempty(new_difficulty)
         plot(datetime(datestr(datemanip(animal,new_difficulty))),Accuracy(new_difficulty),...
             'k','LineStyle','none','Marker','h','MarkerSize',10,'MarkerFaceColor','k','Visible','on');
         last_difficulties = Bin_Contrast{animal,new_difficulty(end)};
     else
         last_difficulties = Bin_Contrast{animal,1};
     end   
    e.Parent.XLabel.String = 'Behavioral Sessions'; e.Parent.YLabel.String = 'Accuracy';
    e.Parent.XLabel.FontSize = 14; e.Parent.YLabel.FontSize = 14; 
    e.Parent.YLim=[0 1]; e.Parent.XTickLabelRotation = 45;
    e.Parent.YTick = round(min(e.Parent.YTick)):0.2:round(max(e.Parent.YTick));
    plot(e.Parent.XLim, [0.5 0.5], '--k'); 
    title(['Learning curve ' Name ' / Difficulty reached: ' num2str(last_difficulties(last_difficulties<50)/100)],'fontsize',12);
    leg = legend('Accuracy','Difficulty increased','Location','southeast');
    leg.FontSize = 12; legend('boxoff');

    % Save learning curve:
    if Saving==1
        cd([pathdatalocal '/LearningCurve']);
        saveas(f,['LearngCurve_' Name '.png']);
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

    clearvars -except Accu_* Bias_* Nb_of_sessions Animal_Names Saving pathdata* Pathtodata datemanip Bin_Contrast
end
%% Plot of leaning curves and bias across days:
if size(Accu_Animals,1)>1
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
    title({['Mean accuracy per training session (n =  ' num2str(size(Accu_Animals,1)) ' animals)']},'fontsize',12);
end
    
% Plot data per animal:
f2=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for animal = 1:size(Accu_Animals,1)
    % Plot accuracy curve per date of session
    e(animal)=plot(datetime(datestr(datemanip(animal,find(~cellfun(@isempty,datemanip(animal,:)))))),...
        Accu_Animals(animal,~isnan(Accu_Animals(animal,:))),...
         'LineStyle','-','LineWidth',1);
     % Add a marker on the accuracy curve for each session with increased
     % difficulty
     new_difficulty = []; 
     for manip = 2:size(Accu_Animals(animal,(~isnan(Accu_Animals(animal,:)))),2)
        if ~isequal(Bin_Contrast(animal,manip),Bin_Contrast(animal,manip-1))
            new_difficulty = [new_difficulty manip]; 
        end
     end
     if ~isempty(new_difficulty)
         plot(datetime(datestr(datemanip(animal,new_difficulty))),Accu_Animals(animal,new_difficulty),...
             'LineStyle','none','Marker','h','MarkerSize',6,'MarkerFaceColor','k','Visible','on');
     end    
end
e(1).Parent.XLabel.String = 'Behavioral Sessions';e(1).Parent.YLabel.String = 'Accuracy';
e(1).Parent.XLabel.FontSize = 14;e(1).Parent.YLabel.FontSize = 14; 
e(1).Parent.YLim=[0 1];%e.Parent.XLim=[1 size(Accu_Animals,2)];
e(1).Parent.XTickLabelRotation = 45;
e(1).Parent.YTick = round(min(e(1).Parent.YTick)):0.2:round(max(e(1).Parent.YTick));
plot(e(end).Parent.XLim, [0.5 0.5], '--k'); 
title('Accuracy per training session for each animal','fontsize',12);
leg = legend(e,Animal_Names,'Location','southeast');
leg.FontSize = 12; legend('boxoff');

% Save plots:
if Saving==1
    cd([pathdatalocal '/LearningCurve']);   
    Names = [];
    for animal = 1:size(Animal_Names,2)
        Names = [Names char(Animal_Names(animal))];
    end
    if exist('f1')==1; saveas(f1,['MeanAccuracy_' Names '.png']);end
    saveas(f2,['Accuracy_' Names '.png']);
end 
%% Bias
% Absolute value of bias
Bias_abs_Souris = abs(Bias_Animals - 0.5);

if size(Bias_Animals,1)>1
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
    title({['Mean of absolute side bias per training session (n =  ' num2str(size(Bias_Animals,1)) ' animals)']},'fontsize',12);
end

% Plot data per animal:
f4=figure('units','normalized','position',[0,0,0.7,1]); hold on
hold on
for animal = 1:size(Bias_abs_Souris,1)
    % Plot accuracy curve per date of session
    e(animal)=plot(datetime(datestr(datemanip(animal,find(~cellfun(@isempty,datemanip(animal,:)))))),...
        Bias_abs_Souris(animal,~isnan(Bias_abs_Souris(animal,:))),...
         'LineStyle','-');
     % Add a marker on the accuracy curve for each session with increased
     % difficulty
     new_difficulty = []; 
     for manip = 2:size(Bias_abs_Souris(animal,(~isnan(Bias_abs_Souris(animal,:)))),2)
        if ~isequal(Bin_Contrast(animal,manip),Bin_Contrast(animal,manip-1))
            new_difficulty = [new_difficulty manip]; 
        end
     end
     if ~isempty(new_difficulty)
         plot(datetime(datestr(datemanip(animal,new_difficulty))),Bias_abs_Souris(animal,new_difficulty),...
             'LineStyle','none','Marker','o','MarkerSize',6,'Visible','on');
     end
    
%     e=plot(1:size(Accu_Animals,2),Bias_abs_Souris(animal,:),...
%         'LineStyle','-','Marker','o','MarkerSize',6,'Visible','on');%'k',,'MarkerEdge','k','MarkerFace','k'
end
e(1).Parent.XLabel.String = 'Behavioral Sessions';e(1).Parent.YLabel.String = 'Side Bias';
e(1).Parent.XLabel.FontSize = 14;e(1).Parent.YLabel.FontSize = 14; 
e(1).Parent.YLim=[0 0.4];%e.Parent.XLim=[1 size(Accu_Animals,2)];
e(1).Parent.XTickLabelRotation = 45;
leg = legend(e,Animal_Names,'Location','northeast');
leg.FontSize = 12; legend('boxoff');
title('Absolute side bias per training session for each animal','fontsize',12);

% Save plots:
if Saving==1
    cd([pathdatalocal '/LearningCurve']);   
    if exist('f3')==1; saveas(f3,['MeanBias_' Names '.png']); end
    saveas(f4,['Bias_' Names '.png']);
end 
