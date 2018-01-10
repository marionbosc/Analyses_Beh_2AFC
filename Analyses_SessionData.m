%% Script analyses datas comportement rig de Paul (Dual2AFCv3)
%
% Analyses des donnees de cptmt produites avec la tache Dual2AFC 
%
%
% - Courbe psychometrique olfactif
% - Courbe psychometrique auditif
% - Courbe vevaiometrique olfactif
% - Courbe vevaiometrique auditif
% - Distribution des RT selon le niveau de difficulte essai olfactif
% - Distribution des WT selon le performance et modalite senso
% - Evolution des performances au cours de la session
% - Distribution des DV de la session selon la modalite
%
%
%% Recup donnee animal a analyser
pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC';
cd(pathdatalocal);
prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

[filename,pathname] = uigetfile([cd '/' Nom '/Session Data/*.mat']);
load([pathname '/' filename])

%% Implementation donnees pour analyses

Implementatn_SessionData_Offline

%% Figure analyse donnee journee de manip
    
% Redirection vers dossier figures animal:
pathfigures = [pathdatalocal '/' Nom '/Session Figures'];
cd(pathfigures);
faireunepause = false;

if exist([SessionData.filename(1:end-4) 'Analysis1.png'],'file')~=2
    Session = fig_beh(SessionData); % Analyse globale session comportement
    FigurePathSession = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Analysis1.png']);
    saveas(Session,FigurePathSession,'png'); faireunepause = true;
end
if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
        % Plus de 10% d'essais olf et Plus de 10% d'essais audit
        if exist([SessionData.filename(1:end-4) 'Cfdce.png'],'file')~=2
            Cfdce = fig_beh_Cfdce_bimodality(SessionData);  % Analyse confidence both modality
            FigurePathCfdce = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Cfdce.png']);
            saveas(Cfdce,FigurePathCfdce,'png'); faireunepause = true;
        end
        if sum(SessionData.Custom.CatchTrial)>10
            if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
                CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
                FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
                saveas(CfdceOlf,FigurePathCfdceOlf,'png'); faireunepause = true;
            end
            if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
                CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
                FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
                saveas(CfdceAud,FigurePathCfdceAud,'png'); faireunepause = true;
            end
        end
    else % Plus de 10% d'essais olf et moins de 10% d'essais audit 
        if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
            CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analyse confidence Olf only
            FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
            saveas(CfdceOlf,FigurePathCfdceOlf,'png'); faireunepause = true;
        end
    end
elseif sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    % Moins de 10% d'essais olf mais Plus de 10% d'essais audit
    if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
        CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analyse confidence Aud only
        FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
        saveas(CfdceAud,FigurePathCfdceAud,'png'); faireunepause = true;
    end
end

if faireunepause
    pause; faireunepause = false;    
end

close all