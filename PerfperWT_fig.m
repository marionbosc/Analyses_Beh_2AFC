%% f(WT) = accuracy for catch trials only 
%
% Input:
% - Dataset (SessionData or SessionDataWeek or SessionDatasets)
% - Minimum WT taken into account for the analysis (in sec)
% - WT data raw (0) or normalized per session (1)
% - Coordinates subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - Extra text in the title of the plot
% - Statistic (1) or not (0)
% - Sensory modality to analyse (1 = olfactory / 2 = auditory click task /
% 3 = auditory frequency task)
%
%

function PerfperWT_fig(SessionData, BorneMin,BorneMaxWT, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Statornot,Modality)
%% Sensory modality
if Modality ==3
    Modality = 2;
end

%% Analysis 
% Trials index
ndxIncl = ~isnan(SessionData.Custom.ChoiceLeft) & SessionData.Custom.StartEasyTrial==0;
ndxModality = SessionData.Custom.Modality== Modality;
ndxCatch = SessionData.Custom.CatchTrial==1 & SessionData.Custom.FeedbackTime>BorneMin;

% Sensory modality analysed
if Modality == 1
    Sensory_Modality = 'Olfactory';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
elseif Modality ==4
    Sensory_Modality = 'Random Dots task';
end

% WT data retrieval
if NormorNot == 1  && isfield(SessionData.Custom, 'FeedbackTimeNorm')% Case WT normalized over session 
    BorneMin = min(SessionData.Custom.FeedbackTimeNorm(ndxCatch&ndxModality));
    BorneMax = max(SessionData.Custom.FeedbackTimeNorm(ndxCatch&ndxModality));  
    xlabel = 'Normalized WT (s)';  
else % Case raw WT
    BorneMax = BorneMaxWT;%round(max(SessionData.Custom.FeedbackTime(ndxCatch&ndxModality)));
    xlabel = 'WT (s)';
end

% WT Bins
Xdata = round(BorneMin):1:round(BorneMax);
nbBin = size(Xdata,2);
if NormorNot == 1 && isfield(SessionData.Custom, 'FeedbackTimeNorm')
    BinWT = round(BorneMin)-0.5+discretize(SessionData.Custom.FeedbackTimeNorm,linspace(BorneMin,BorneMax,nbBin+1));
else
    BinWT = round(BorneMin)-0.5+discretize(SessionData.Custom.FeedbackTime,linspace(BorneMin,BorneMax,nbBin+1));
end

% Accuracy per bin
Perf_id = SessionData.Custom.ChoiceCorrect(ndxCatch&ndxIncl&ndxModality);
BinWT_id = BinWT(ndxCatch&ndxIncl&ndxModality);
[PsycY, semY,PsycX] = grpstats(Perf_id,BinWT_id,{'mean','sem','gname'});
PsycX = str2double(PsycX)';

% Stat: 
if Statornot==1
    % Reorg data for statistic analysis
    X_binWT =  BinWT_id(~isnan(BinWT_id)&~isnan(Perf_id))';
    Y_perf = Perf_id(~isnan(BinWT_id)&~isnan(Perf_id))';
    
    % One-way ANOVA
    [p,~,stat] =anova1(Y_perf,X_binWT,'off');
    
    % Post-hoc
    if p<0.05
        c=multcompare(stat,'Alpha',0.05,'CType','bonferroni','Display','off');
        signif_idx = find(c(:,6)<0.05);
        if ~isempty(signif_idx)
            post_hoc_res = '*';
            X1 = PsycX(c(signif_idx,1));
            X2 = PsycX(c(signif_idx,2));
            % Significancy stars
            for s=1:size(signif_idx)
                star{s} = nr2M_etoilesignif((c(signif_idx(s),6)));
            end
        else
            post_hoc_res = 'ns';
        end
    else
        post_hoc_res = '';
        signif_idx = [];
    end
    % Texte titre recap stat
    Stat_title = ['One-w ANOVA: p = ' num2str(round(p,3)) '/ Bonferroni post-hoc: ' post_hoc_res];
elseif Statornot==0
    Stat_title = '';
end

% Subject name:
NameSubject = unique(SessionData.Custom.Subject,'stable');
if size(NameSubject,2)>1
    Names = [];
    for animal = 1:size(NameSubject,2)
        Names = [Names char(NameSubject(animal))];
    end
    NameSubject =  Names;
end
%% Plot 
subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on

% right axis: amount of trial per bin of WT
yyaxis right
h=histogram(BinWT_id,'BinWidth',1); %
h.FaceAlpha = 0.2; 
h.Parent.YLabel.String = 'Trials count';h.Parent.YLabel.FontSize = 14;
h.Parent.YLabel.Rotation=270; 
h.BinLimits = [min(h.BinEdges(h.Values>=5)) max(h.BinEdges(h.Values>=5))+1];
h.Parent.XAxis(1).Limits = [min(h.BinEdges(h.Values>=5)) max(h.BinEdges(h.Values>=5))+1];
h.Parent.YLabel.Position(1) = h.Parent.YLabel.Position(1)+0.5;

% Reselecting the data to plot:
Xtoplot = PsycX(PsycX>h.BinLimits(1) & PsycX<h.BinLimits(2));
Ytoplot = PsycY(PsycX>h.BinLimits(1) & PsycX<h.BinLimits(2));
semtoplot = semY(PsycX>h.BinLimits(1) & PsycX<h.BinLimits(2));

% left axis: Accuracy per bin of WT
yyaxis left
e = errorbar(Xtoplot,Ytoplot,semtoplot,'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','b',...
'MarkerSize',6,'Visible','on');
e.Parent.XLabel.String = xlabel;e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14;
ylim([0 1.2]);
% stat result displaying
if Statornot==1 && ~isempty(signif_idx)
    for i = 1:size(X1,2)
        plot([X1(i) X2(i)],[1.18-(i*0.03) 1.18-(i*0.03)],'k','LineStyle','-','Marker','+');
        text ((X1(i)+X2(i))/2,1.18-(i*0.03)+0.01,star(i),'fontsize',14);
    end
end

title({[NameSubject '  ' Sensory_Modality '  ' TitleExtra]; Stat_title},'fontsize',12);
