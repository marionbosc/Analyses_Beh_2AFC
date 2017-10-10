%% f(WT) = accuracy for catch trials only 
% Chargement datas avant lesion:
load('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC/TO05/Session Data/SessionDataWeek_170803_25.mat');
SessionData = SessionDataWeek;

figure('units','normalized','position',[0,0,1,1]); hold on

PerfperWT_fig(SessionData, 2, 0,1,2,1,'Before lesion',0)

% Chargement datas avant lesion:
load('/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC/TO05/Session Data/SessionDataWeek_170907_14.mat');
SessionData = SessionDataWeek;

PerfperWT_fig(SessionData, 2, 0,1,2,2,'After lesion',0)

