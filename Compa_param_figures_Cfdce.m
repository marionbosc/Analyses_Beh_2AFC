%% Figures:

f1=figure('units','normalized','position',[0,0,1,1]);

PerfperWT_fig(SessionDataWeek, 1, 0,2,2,1,'WT brutes - WT min = 1',1);

PerfperWT_fig(SessionDataWeek, 1, 1,2,2,2,'WT normalisees  - WT min = 1',1);

PerfperWT_fig(SessionDataWeek, 2, 0,2,2,3,'WT brutes - WT min = 2',1);

PerfperWT_fig(SessionDataWeek, 2, 1,2,2,4,'WT normalisees  - WT min = 2',1);

ShvsLgWT_fig(SessionDataWeek, 2, 0,2,2,1, '70th Percentile - WT brutes',70,8);

ShvsLgWT_fig(SessionDataWeek, 2, 1,2,2,2, '70th Percentile - WT normalises',70,8);

ShvsLgWT_fig(SessionDataWeek, 2, 0,2,2,3, '50th Percentile - WT brutes',50,8);

ShvsLgWT_fig(SessionDataWeek, 2, 1,2,2,4, '50th Percentile - WT normalises',50,8);