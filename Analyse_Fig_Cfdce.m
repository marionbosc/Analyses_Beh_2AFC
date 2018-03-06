
function [f2,Perf]=Analyse_Fig_Cfdce(SessionData, Modality)
%% Figure:

f2=figure('units','normalized','position',[0,0,0.5,1]);

%% Psychometric performance (1)
try
    [SessionData,Perf] = Psychometric_fig(SessionData, Modality,2,2,1);
end
%% Vevaiometric (2)
try
    Vevaiometric_fig(SessionData, Modality,2,2,2);
end
%% PerfperWT (3)

if SessionData.DayvsWeek == 1
    try
        PerfperWT_fig(SessionData, 2, 0,2,2,3,SessionData.SessionDate,0,Modality);
    end
else
    try
        PerfperWT_fig(SessionData, 2, 1,2,2,3,SessionData.SessionDate,1,Modality);
    end
end

%% Psychometric Sh vs Lg WT (4)

if SessionData.DayvsWeek == 2
    try
        ShvsLgWT_fig(SessionData, Modality, 0,2,2,4,SessionData.Custom.Subject,70,8);
    end
end

%% A implementer: Confidence Report Index
