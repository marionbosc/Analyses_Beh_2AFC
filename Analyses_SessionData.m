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
    
% Prompt windows to select the localisation of the data file:
Pathtodata = choosePath(BpodProtocol);
cd(Pathtodata);
prompt = {'Name= '}; dlg_title = 'Animal'; numlines = 1;
def = {'M'}; Nom = char(inputdlg(prompt,dlg_title,numlines,def)); 
clear def dlg_title numlines prompt  

[filename,pathname] = uigetfile([cd '/' Nom '/Session Data/*.mat']);
load([pathname '/' filename])

%% (2) Implementation of SessionData for further analysis

SessionData = Implementatn_SessionData_Offline(SessionData, filename, pathname,0);

%% (3) Plot the plots missing from the Session Figures folder of the animal
    
% Path towards animal Session Figures folder:
pathfigures = [Pathtodata '/' Nom '/Session Figures'];
cd(pathfigures);
takeabreak = false;

% Case the GnlBeh plot for this session does not appear in the Session Figure folder:
if exist([SessionData.filename(1:end-4) 'GnlBeh.png'],'file')~=2
    [Session, Error] = fig_beh(SessionData); % Analyse globale session comportement
    FigurePathSession = fullfile(pathfigures,[SessionData.filename(1:end-4) 'GnlBeh.png']);
    saveas(Session,FigurePathSession,'png'); takeabreak = true;
end

% Plotting of the confidence signature if enough CatchTrials:
if sum(SessionData.Custom.CatchTrial)>10
    % Case more than 50 olfactory trials
    if sum(SessionData.Custom.Modality==1)>50
        % Case the plot/analysis on Confidence for Olfactory trials does not exist
        if exist([SessionData.filename(1:end-4) 'CfdceOlf.png'],'file')~=2
            CfdceOlf = Analyse_Fig_Cfdce(SessionData, 1); % Analysis confidence Olf only
            FigurePathCfdceOlf = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceOlf.png']);
            saveas(CfdceOlf,FigurePathCfdceOlf,'png'); takeabreak = true;
        end
    end

    % Case more than 50 auditory click trials
    if sum(SessionData.Custom.Modality==2)>50
        % Case the plot/analysis on Confidence for Auditory trials does not exist
        if exist([SessionData.filename(1:end-4) 'CfdceAud.png'],'file')~=2
            CfdceAud = Analyse_Fig_Cfdce(SessionData, 2); % Analysis confidence Aud only
            FigurePathCfdceAud = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAud.png']);
            saveas(CfdceAud,FigurePathCfdceAud,'png'); takeabreak = true;
        end
    end

    % Case more than 50 auditory Frequency trials
    if sum(SessionData.Custom.Modality==3)>50
        if exist([SessionData.filename(1:end-4) 'CfdceAudFqcy.png'],'file')~=2
            CfdceBeh = Analyse_Fig_Cfdce(SessionData, 3); % Analysis confidence Aud only
            FigurePathCfdceBeh = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceAudFqcy.png']);
            saveas(CfdceAud,FigurePathCfdceAud,'png'); takeabreak = true;
        end
    end

    % Case more than 50 brightness trials
    if sum(SessionData.Custom.Modality==4)>50
        % Case the plot/analysis on Confidence for Brightness trials does not exist
        if exist([SessionData.filename(1:end-4) 'CfdceBright.png'],'file')~=2
            CfdceBright = Analyse_Fig_Cfdce(SessionData, 4); % Analysis confidence Aud only
            FigurePathCfdceBright = fullfile(pathfigures,[SessionData.filename(1:end-4) 'CfdceBright.png']);
            saveas(CfdceBright,FigurePathCfdceBright,'png'); takeabreak = true;
        end
    end

    % Case more than 20 olfactory and 20 auditory trials
    if sum(SessionData.Custom.Modality==1)>20 && sum(SessionData.Custom.Modality==2)>20  
    % Case the plot/analysis on both modality does not exist
        if exist([SessionData.filename(1:end-4) 'Cfdce.png'],'file')~=2 && sum(SessionData.Custom.CatchTrial)>10
            Cfdce = fig_beh_Cfdce_bimodality(SessionData);  % Analysis confidence both modality
            FigurePathCfdce = fullfile(pathfigures,[SessionData.filename(1:end-4) 'Cfdce.png']);
            saveas(Cfdce,FigurePathCfdce,'png'); takeabreak = true;
        end
    end
    
    elseif strcmp(SessionData.Protocol,{'MouseNosePoke'})==0
        [CfdceBeh, Perf] = Analyse_Fig_Cfdce(SessionData, 2);
        close(CfdceBeh)
end

if takeabreak
    pause; takeabreak = false;    
end

close all

%% Computation of Evernote note if needed:
datemanip = datestr(datetime(str2num(SessionData.SessionDate) , 'ConvertFrom','yyyymmdd'),'dd-mmm');
nbTrials = num2str(SessionData.nTrials);

% Amount of reward obtained:
if isfield(SessionData.Custom,'Rewarded') % Case Protocol = Dual2AFC
    RewObt = num2str(round(sum([SessionData.Custom.RewardMagnitude(1,(SessionData.Custom.Rewarded&SessionData.Custom.ChoiceLeft==1))...
        SessionData.Custom.RewardMagnitude(2,(SessionData.Custom.Rewarded&SessionData.Custom.ChoiceLeft==0))])/1000,2));
elseif isfield(BpodSystem.Data.Custom,'CenterPortRewarded') % Case Protocol = Mouse2AFC
    RewObt = num2str(round(sum([SessionData.Custom.RewardMagnitude(1,(~SessionData.Custom.EarlyWithdrawal&SessionData.Custom.ChoiceLeft==1))...
        SessionData.Custom.RewardMagnitude(2,(~SessionData.Custom.EarlyWithdrawal&SessionData.Custom.ChoiceLeft==0))...
        SessionData.Custom.CenterPortRewardAmount(SessionData.Custom.CenterPortRewarded)])/1000,2));
else % Case Protocol = MouseNosePoke
    RewObt = num2str(round(sum([SessionData.Custom.RewardMagnitude(1,(~SessionData.Custom.EarlyWithdrawal&SessionData.Custom.ChoiceLeft==1))...
        SessionData.Custom.RewardMagnitude(2,(~SessionData.Custom.EarlyWithdrawal&SessionData.Custom.ChoiceLeft==0))])/1000,2));
end

% Building text structure with all the informations about the session:
% Case Protocol = Dual2AFC or Mouse2AFC and analysis executed
if sum(strcmp(BpodProtocol,{'Dual2AFC', 'Mouse2AFC'})) && exist('Error','var') && exist('Perf','var')
    note = strcat([datemanip ' (' nbTrials ' / ' RewObt ') : ' BpodProtocol  '. Perf: ' num2str(round(Perf.globale * 100)) '% Accuracy (L/R = ' num2str(round(Perf.Left * 100)) ' / ' num2str(round(Perf.Right * 100)) '% and Bias = ' num2str(round(Perf.Bias,2)) ') and lapse rate (L/R): ' num2str(Perf.left_lapserate) ' / ' num2str(Perf.right_lapserate) '%. ErrorTrials: ' Error.FixBroke '% BrokeFixation, ' Error.EWD '% EWD, ' Error.SkippedFB '% SkippedFB, ' Error.SkippedPosFB  '% Skipped Correct FB (L/R = ' Error.SkippedLeftFB ' / ' Error.SkippedRightFB '%).']);
else % Case Protocol = MouseNosePoke
    note = strcat([datemanip ' (' nbTrials ' / ' RewObt ') : ' BpodProtocol '. EWD: ' num2str(round(sum(SessionData.Custom.EarlyWithdrawal)/size(SessionData.Custom.EarlyWithdrawal,2) * 100)) '% and Bias = ' num2str(round(nansum(SessionData.Custom.ChoiceLeft)/sum(~isnan(SessionData.Custom.ChoiceLeft)),2)) '. SampleTimeEndSession: ' num2str(round(SessionData.Custom.ST(1,end-1),3)) ' sec. MedianSampleTime = ' num2str(round(nanmedian(SessionData.Custom.ST),3)) ' sec.']);
end

note