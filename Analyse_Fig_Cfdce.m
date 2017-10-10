
function f2=Analyse_Fig_Cfdce(SessionData, Modality)
%% Figure:

f2=figure('units','normalized','position',[0,0,0.5,1]);

%% Psychometric performance (1)

[SessionData] = Psychometric_fig(SessionData, Modality,2,2,1);

%% Vevaiometric (2)

Vevaiometric_fig(SessionData, Modality,2,2,2);

%% PerfperWT (3)

if SessionData.DayvsWeek == 1
    PerfperWT_fig(SessionData, Modality, 0,2,2,3,SessionData.SessionDate,0);
else
    PerfperWT_fig(SessionData, Modality, 0,2,2,3,SessionData.SessionDate,1);
end

%% Psychometric Sh vs Lg WT (4)

if SessionData.DayvsWeek == 2
    ShvsLgWT_fig(SessionData, Modality, 0,2,2,4,SessionData.Custom.Subject,70,8);   
end

%% A implementer: Confidence Report Index
