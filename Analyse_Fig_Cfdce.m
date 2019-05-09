%% Script to plot the Psychometric and the Confidence Signatures for one sensory modality
%
% Input:
% - Data structure (SessionData or SessionDataWeek or SessionDatasets)
% - Sensory modality to analyse (1 = olfactory / 2 = auditory click task /
% 3 = auditory frequency task)
%
% Output:
% - Plot: 
%   (1) Psychometric
%   (2) Vevaiometric
%   (3) Calibration curve (Accuracy per WT)
%   (4) Conditioned psychometric (short vs long WT)
% - Perf: Structure containing session accuracy and other informations (see Psychometric_fig.m for more details)
%
%

function [f2,Perf]=Analyse_Fig_Cfdce(SessionData, Modality)
%% Figure:

f2=figure('units','normalized','position',[0,0,0.5,1]);

%% (1) Psychometric  
try
    [SessionData,Perf] = Psychometric_fig(SessionData, Modality,2,2,1);
end
%% (2) Vevaiometric 
try
    Vevaiometric_fig(SessionData, Modality,2,2,2,1,2);
end
%% (3) Calibration curve (Accuracy per WT) 

if SessionData.DayvsWeek == 1
    try
        PerfperWT_fig(SessionData, 2, 0,2,2,3,SessionData.SessionDate,0,Modality);
    end
else
    try
        PerfperWT_fig(SessionData, 2, 0,2,2,3,SessionData.SessionDate,1,Modality);
    end
end

%% (4) Conditioned psychometric (short vs long WT)

if SessionData.DayvsWeek == 2
    try
        ShvsLgWT_fig(SessionData, Modality, 0,2,2,4,'',70,8);
    end
end

