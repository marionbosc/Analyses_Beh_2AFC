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
cd('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC');
prompt = {'Nom= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

[filename,pathname] = uigetfile([cd '/' Nom '/Session Data/*.mat']);
load([pathname '/' filename])

%% Implementation donnees pour analyses

Implementatn_SessionData

%% Figures resultats analyse

if sum(SessionData.Custom.Modality==1)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    fig_beh(SessionData)
end

if sum(SessionData.Custom.Modality==2)/sum(SessionData.Custom.Modality==1 | SessionData.Custom.Modality==2)>0.1
    fig_beh_auditory(SessionData)
end

if sum(SessionData.Custom.CatchTrial)>2
    fig_vevaiometric(SessionData)
end

