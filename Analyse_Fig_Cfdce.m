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

function [f2,Perf]=Analyse_Fig_Cfdce(SessionData, Modality,BorneMaxWT)
%% Check varargin:
if ~exist('BorneMaxWT','var'); BorneMaxWT=19; end

%% Figure:

f2=figure('units','normalized','position',[0,0,0.5,1]);

%% (1) Psychometric  
try % Psychometric_fig(SessionData, Modality,nb_row_fig,nb_col_fig,positn_fig,colorplot)
    [SessionData,Perf] = Psychometric_fig(SessionData, Modality,2,2,1);
end
%% (2) Vevaiometric 
try % Vevaiometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig, SensoORMvt,plotpointormean,normornot,BorneMaxWT)
    Vevaiometric_fig(SessionData, Modality,2,2,2,1,2,0,BorneMaxWT);
end
%% (3) Calibration curve (Accuracy per WT) 

if SessionData.DayvsWeek == 1
    try % PerfperWT_fig(SessionData, BorneMin,BorneMaxWT, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Statornot,Modality)
        PerfperWT_fig(SessionData, 2, BorneMaxWT, 0 ,2,2,3,SessionData.SessionDate,0,Modality);
    end
else
    try
        PerfperWT_fig(SessionData, 2, BorneMaxWT, 0,2,2,3,SessionData.SessionDate,1,Modality);
    end
end

%% (4) Conditioned psychometric (short vs long WT)

if SessionData.DayvsWeek == 2
    try % ShvsLgWT_fig(SessionData, Modality, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Percentile,nbBin,BorneMaxWT)
        ShvsLgWT_fig(SessionData, Modality, 0,2,2,4,'',70,8,BorneMaxWT);
    end
end

