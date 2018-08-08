%% Script to analyse and plot behavioral data from one session of training
%
% (1) Loading of the data file to analyse
% (2) Implement SessionData
% (3) Plot the plots missing from the Session Figures folder of the animal
%

%% (1) Loading of the data file to analyse
% GUI to get the Bpod protocol name to localise the data files:
prompt = {'Bpod protocol = '}; dlg_title = 'Protocol?'; numlines = 1;
def = {'Mouse2AFC'}; BpodProtocol = cell2mat(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt
    
pathdatalocal = ['/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/' BpodProtocol];
pathdataserver='/Volumes/home/BpodData/Mouse2AFC/';
cd(pathdataserver);
prompt = {'Name= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

[filename,pathname] = uigetfile([cd '/' Nom '/Session Data/*.mat']);
load([pathname '/' filename])

%% (2) Implementation of SessionData for further analysis

SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,0);

%% (3) Plot the plots missing from the Session Figures folder of the animal
    
% Path towards animal Session Figures folder:
pathfigures = [pathdatalocal '/' Nom '/Session Figures'];
cd(pathfigures);
takeabreak = false;

% Case the GnlBeh plot for this session does not appear in the Session Figure folder:
if exist([SessionData.filename(1:end-4) 'GnlBeh.png'],'file')~=2
    Session = fig_beh(SessionData); % Analyse globale session comportement
    FigurePathSession = fullfile(pathfigures,[SessionData.filename(1:end-4) 'GnlBeh.png']);
    saveas(Session,FigurePathSession,'png'); takeabreak = true;
end

% Case more than 10% of olfactory trials (Protocol = Dual2AFC)
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % Case more than 10% of auditory trials as well
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        % Case the plot/analysis on both modality does not exist
        if exist([SessionData.filename(1:end-4) 'Cfdce.png'],'file')~=2
            Cfdce = fig_beh_Cfdce_bimodality(SessionData);  % Analyse confidence both modality
            FigurePathCfdce = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Cfdce.png']);
            saveas(Cfdce,FigurePathCfdce,'png'); takeabreak = true;
        end
        % Case of a session with at least 10 CatchTrials
        if sum(SessionData.Custom.CatchTrial)>10
            % Case the plot/analysis on Confidence for Olfactory trials does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
                CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
                FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
                saveas(CfdceOlf,FigurePathCfdceOlf,'png'); takeabreak = true;
            end
            % Case the plot/analysis on Confidence for Auditory trials does not exist
            if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
                CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
                FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
                saveas(CfdceAud,FigurePathCfdceAud,'png'); takeabreak = true;
            end
        end
    % Case less than 10% of auditory trials (session with Olfactory trials only)
    else 
        % Case the plot/analysis on Confidence for Olfactory trials does not exist
        if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
            CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
            FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
            saveas(CfdceOlf,FigurePathCfdceOlf,'png'); takeabreak = true;
        end
    end
% Case less than 10% of olfactory trials (session with Auditory trials only)
elseif sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % Case the plot/analysis on Confidence for Auditory trials does not exist
    if exist([SessionData.filename(1:end-4) 'CfdceBeh.png'],'file')~=2
        CfdceBeh = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
        FigurePathCfdceBeh = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceBeh.png']);
        saveas(CfdceBeh,FigurePathCfdceBeh,'png'); takeabreak = true;
    end
end

if takeabreak
    pause; takeabreak = false;    
end

close all