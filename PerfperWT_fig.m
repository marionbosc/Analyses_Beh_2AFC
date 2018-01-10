%% f(WT) = accuracy for catch trials only 
%
% Input:
% - Dataset --> SessionData
% - Minimum WT (in sec)
% - WT data raw (0) or normalized per session (1)
% - Coordonnees subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
% - Extra text in the title
% - Statistic (1) or not (0)
% - Modality (1) Olfactory (2) Auditory
%
%

function PerfperWT_fig(SessionData, BorneMin, NormorNot,nb_raw_fig,nb_col_fig,positn_fig,TitleExtra,Statornot,Modality)
%% Modalite
if Modality ==3
    Modality = 2;
end

%% Analyse et figure
ndxNan = isnan(SessionData.Custom.ChoiceCorrect);
ndxModality = SessionData.Custom.Modality== Modality;
ndxCatch = SessionData.Custom.CatchTrial==1 & SessionData.Custom.FeedbackTime>BorneMin;

% Modalite sensorielle analysee
if Modality == 1
    Sensory_Modality = 'Olfactory';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
end

% Recup WT
if NormorNot == 1
    BorneMin = min(SessionData.Custom.FeedbackTimeNorm(ndxCatch&ndxModality));
    BorneMax = max(SessionData.Custom.FeedbackTimeNorm(ndxCatch&ndxModality));  
    xlabel = 'Normalized WT (s)';  
else
    BorneMax = round(max(SessionData.Custom.FeedbackTime(ndxCatch&ndxModality)));
    xlabel = 'WT (s)';
end

% Fabrication de bin
Xdata = round(BorneMin):1:round(BorneMax);
nbBin = size(Xdata,2);
if NormorNot == 1
    BinWT = round(BorneMin)-0.5+discretize(SessionData.Custom.FeedbackTimeNorm,linspace(BorneMin,BorneMax,nbBin+1));
else
    BinWT = round(BorneMin)-0.5+discretize(SessionData.Custom.FeedbackTime,linspace(BorneMin,BorneMax,nbBin+1));
end

% Calcul pourcent choix correct par type d'essai
Perf_id = SessionData.Custom.ChoiceCorrect(ndxCatch&~ndxNan&ndxModality);
BinWT_id = BinWT(ndxCatch&~ndxNan&ndxModality);
[PsycY, semY,PsycX] = grpstats(Perf_id,BinWT_id,{'mean','sem','gname'});
PsycX = str2double(PsycX)';% PsycX = unique(BinWT(ndxCatch&~ndxNan&ndxModality));
% PsycX = PsycX(~isnan(PsycX));

% Reorg des donnees pour stat
X_binWT =  BinWT_id(~isnan(BinWT_id)&~isnan(Perf_id))';
Y_perf = Perf_id(~isnan(BinWT_id)&~isnan(Perf_id))';

% Stat: one-way ANOVA time
if Statornot==1
    [p,~,stat] =anova1(Y_perf,X_binWT,'off');
    % Post-hoc
    if p<0.05
        c=multcompare(stat,'Alpha',0.05,'CType','bonferroni','Display','off');
        signif_idx = find(c(:,6)<0.05);
        if ~isempty(signif_idx)
            post_hoc_res = '*';
            X1 = PsycX(c(signif_idx,1));
            X2 = PsycX(c(signif_idx,2));
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

subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on
yyaxis left
e = errorbar(PsycX,PsycY,semY,'k','LineStyle','-','Marker','o','MarkerEdge','k','MarkerFace','b',...
'MarkerSize',6,'Visible','on');
%e.Parent.XAxis.FontSize = 10; e.Parent.YAxis.FontSize = 10;
e.Parent.XLabel.String = xlabel;e.Parent.YLabel.String = 'Accuracy';
e.Parent.XLabel.FontSize = 14;e.Parent.YLabel.FontSize = 14;
ylim([0 1.2]); %xlim([round(BorneMin)-0.5 round(BorneMax)+0.5]);
if Statornot==1 && ~isempty(signif_idx)
    for i = 1:size(X1,2)
        plot([X1(i) X2(i)],[1.18-(i*0.03) 1.18-(i*0.03)],'k','LineStyle','-','Marker','+');
        text ((X1(i)+X2(i))/2,1.18-(i*0.03)+0.01,star(i),'fontsize',14);
    end
end
yyaxis right
h=histogram(BinWT_id,'BinWidth',1); %
h.FaceAlpha = 0.2; %h.BinEdges=PsycX-0.5;
h.Parent.YLabel.String = 'Trials count';h.Parent.YLabel.FontSize = 14;
h.Parent.YLabel.Rotation=270; 
h.Parent.XAxis(1).Limits(1) = min(h.BinEdges)-0.5;
h.Parent.XAxis(1).Limits(2) = max(h.BinEdges)+0.5;
h.Parent.YLabel.Position(1) = h.Parent.YLabel.Position(1)+0.5;
title({[SessionData.Custom.Subject '  ' Sensory_Modality '  ' TitleExtra]; Stat_title},'fontsize',12);