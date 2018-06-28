%% Script/fonction pour calcul et figure vevaiometric:
%
%
% Input:
% - Dataset --> SessionData
% - Sensory modality : 1 = Olfactory / 2 = Auditory --> Modality
% - Coordinates subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)
%
%

function [SessionData] = Vevaiometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig)
%% Paramètres de la figure:
VevaiometricMinWT = 2; % FB time minimum pris en compte dans analyse WT

if Modality == 1
    Sensory_Modality = 'Olfactory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0]; 
    xmin = -1.1; xmax = 1.1;
    xlabel = 'DV';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xlabel = 'Binaural contrast';
    Frequency = 0;
elseif Modality == 3
    Sensory_Modality = 'Auditory';
    % Limites plot figures
    xlimL = [0 1]; xlimR = [-1 0];
    xmin = -1; xmax = 1;
    xlabel = 'DV';
    Modality =2;
    Frequency = 1;
end

% Figure vevaiometric f(DV)=WT
veva = subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on
Affichage_figure = 0;
%% Recup essais a analyser
ndxModality = SessionData.Custom.Modality(1:end) == Modality ; % Essais stimulus auditif
ndxError = SessionData.Custom.ChoiceCorrect(1:end) == 0 ; %all (completed) error trials (including catch errors)
ndxCorrectCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.ChoiceCorrect(1:end) == 1; %only correct catch trials
ndxMinWT = SessionData.Custom.FeedbackTime > VevaiometricMinWT;
ndxLeft=SessionData.Custom.ChoiceLeft(1:end)==1;
ndxRight=SessionData.Custom.ChoiceLeft(1:end)==0 ;

%% Recup data erreur
if sum(ndxError&ndxMinWT&ndxModality&ndxLeft)>9 || sum(ndxError&ndxMinWT&ndxModality&ndxRight)>9
    % Datas WT brutes
    if Modality ==1
        DVerrLeft = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxRight); % Recup DV essais erreur pointage a gauche
        DVerrRight = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxLeft); % recup DV essais erreur pointage a droite
    elseif Modality ==2
        if Frequency ==0
            DVerrLeft = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxRight); % Recup DV essais erreur pointage a gauche
            DVerrRight = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxLeft); % recup DV essais erreur pointage a droite
        else
            DVerrLeft = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxRight); % Recup DV essais erreur pointage a gauche
            DVerrRight = SessionData.Custom.DV(ndxError&ndxMinWT&ndxModality&ndxLeft); % recup DV essais erreur pointage a droite
        end
    end
    
    if SessionData.DayvsWeek == 2 && isfield(SessionData.Custom,'FeedbackTimeNorm')
        WTerrLeft = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxRight); % Recup WT erreur pointees a droite (essais a gauche) 
        WTerrRight = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxModality&ndxLeft); % Recup WT erreur pointees a gauche (essais a droite) 
        ylabel = 'Normalized WT (s)';  
    else
        WTerrLeft = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxRight); % Recup WT erreur pointees a droite (essais a gauche) 
        WTerrRight = SessionData.Custom.FeedbackTime(ndxError&ndxMinWT&ndxModality&ndxLeft); % Recup WT erreur pointees a gauche (essais a droite) 
        ylabel = 'WT (s)';
    end
        
    % Data sorting: (reorg des WT selon classement DV croissant pour que DV soit continu):
    [DVerrLeft, eL_sort] = sort(DVerrLeft);
    WTerrLeft = WTerrLeft(eL_sort);
    [DVerrRight, eR_sort] = sort(DVerrRight);
    WTerrRight = WTerrRight(eR_sort);
    
    % Recup data a ploter:
    Scatter.err.YData = [WTerrLeft WTerrRight];
    Scatter.err.XData = [DVerrLeft DVerrRight];
    [CorrCoeff.errLeft.r, CorrCoeff.errLeft.p] = corrcoef(DVerrLeft,WTerrLeft);
    [CorrCoeff.errRight.r, CorrCoeff.errRight.p] = corrcoef(DVerrRight,WTerrRight);
    [Fit.errLeft.r, Fit.errLeft.p] = fit(DVerrLeft',WTerrLeft','poly1');
    [Fit.errRight.r, Fit.errRight.p] = fit(DVerrRight',WTerrRight','poly1');
    [pdint.errLeft.r, pdint.errLeft.p] = predint(Fit.errLeft.r,DVerrLeft',0.95,'functional','on');
    [pdint.errRight.r, pdint.errRight.p] = predint(Fit.errRight.r,DVerrRight',0.95,'functional','on');
    
    % Figure:
    s=scatter(Scatter.err.XData,Scatter.err.YData,2,[1 0.6 0],... % orange dot [1 0.6 0]
     'Marker','o','MarkerFaceColor',[1 0.6 0],'MarkerEdgeAlpha',0.5,...
     'Visible','on','MarkerEdgeColor',[1 0.6 0]);
    Ymax = [max(s.YData)*1.01 max(s.YData)*1.01];
    % Equation de la droite : ans(x) = p1*x + p2
    plot(xlimL,[Fit.errLeft.r.p1*xlimL(1) + Fit.errLeft.r.p2 Fit.errLeft.r.p1*xlimL(2) + Fit.errLeft.r.p2],'r-','LineWidth',1.5);
    plot(xlimR,[Fit.errRight.r.p1*xlimR(1) + Fit.errRight.r.p2 Fit.errRight.r.p1*xlimR(2) + Fit.errRight.r.p2],'r-','LineWidth',1.5);
    plot(DVerrLeft',pdint.errLeft.r,'r-','LineWidth',1);
    plot(DVerrRight',pdint.errRight.r,'r-','LineWidth',1);
    Leg_error = ['Error n = ',num2str(size(Scatter.err.YData,2))];
    Title_error = ['Error rL = ' num2str(round(CorrCoeff.errLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.errLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.errRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.errRight.p(1,2),3))];
    Affichage_figure = 1;
else
    Leg_error = ''; Title_error = '';s = [];
end

%% Recup data catch correct
if sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft)>10 || sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight)>10
    % Datas WT brutes
     if Modality ==1
        DVcatchLeft = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % recup DV essais catch pointage a gauche
        DVcatchRight = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % recup DV essais catch pointage a droite
    elseif Modality ==2
        if Frequency ==0
            DVcatchLeft = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % recup DV essais catch pointage a gauche
            DVcatchRight = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % recup DV essais catch pointage a droite
        else
            DVcatchLeft = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % recup DV essais catch pointage a gauche
            DVcatchRight = SessionData.Custom.DV(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % recup DV essais catch pointage a droite
        end
     end
     
     if SessionData.DayvsWeek == 2 && isfield(SessionData.Custom,'FeedbackTimeNorm')
        WTcatchLeft = SessionData.Custom.FeedbackTimeNorm(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % recup WT essais catch pointage a gauche
        WTcatchRight = SessionData.Custom.FeedbackTimeNorm(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % recup WT essais catch pointage a droite
        ylabel = 'Normalized WT (s)';
     else
        WTcatchLeft = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft); % recup WT essais catch pointage a gauche
        WTcatchRight = SessionData.Custom.FeedbackTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight); % recup WT essais catch pointage a droite
        ylabel = ' WT (s)'; 
    end

    % Data sorting: (reorg des WT selon classement DV croissant pour que DV soit continu):
    [DVcatchLeft, cL_sort] = sort(DVcatchLeft);
    WTcatchLeft = WTcatchLeft(cL_sort);
    [DVcatchRight, cR_sort] = sort(DVcatchRight);
    WTcatchRight = WTcatchRight(cR_sort);

    % Recup data a ploter:
    Scatter.catch.YData = [WTcatchLeft WTcatchRight];
    Scatter.catch.XData = [DVcatchLeft DVcatchRight];
    [CorrCoeff.catchLeft.r, CorrCoeff.catchLeft.p] = corrcoef(DVcatchLeft,WTcatchLeft);
    [CorrCoeff.catchRight.r, CorrCoeff.catchRight.p] = corrcoef(DVcatchRight,WTcatchRight);
    [Fit.catchLeft.r, Fit.catchLeft.p] = fit(DVcatchLeft',WTcatchLeft','poly1');
    [Fit.catchRight.r, Fit.catchRight.p] = fit(DVcatchRight',WTcatchRight','poly1');
    [pdint.catchLeft.r, pdint.catchLeft.p] = predint(Fit.catchLeft.r,DVcatchLeft',0.95,'functional','on');
    [pdint.catchRight.r, pdint.catchRight.p] = predint(Fit.catchRight.r,DVcatchRight',0.95,'functional','on');
    
    % Figure:
    s2=scatter(Scatter.catch.XData,Scatter.catch.YData,2,'g',...
     'Marker','o','MarkerFaceColor','g','MarkerEdgeAlpha',0.5,...
     'Visible','on','MarkerEdgeColor','g');
    Ymax = [max(s2.YData)*1.01 max(s2.YData)*1.01];
    % Equation de la droite : ans(x) = p1*x + p2
    plot(xlimL,[Fit.catchLeft.r.p1*xlimL(1) + Fit.catchLeft.r.p2 Fit.catchLeft.r.p1*xlimL(2) + Fit.catchLeft.r.p2],'-','Color', [0.23, 0.5, 0.17] ,'LineWidth',1.5); % [olive 0.23, 0.37, 0.17] 
    plot(xlimR,[Fit.catchRight.r.p1*xlimR(1) + Fit.catchRight.r.p2 Fit.catchRight.r.p1*xlimR(2) + Fit.catchRight.r.p2],'-','Color', [0.23, 0.5, 0.17],'LineWidth',1.5);
    plot(DVcatchLeft',pdint.catchLeft.r,'-','Color', [0.23, 0.5, 0.17],'LineWidth',1);
    plot(DVcatchRight',pdint.catchRight.r,'-','Color', [0.23, 0.5, 0.17],'LineWidth',1);
    Leg_catch = ['Catch n = ',num2str(size(Scatter.catch.YData,2))];
    Title_catch = ['Catch rL = ' num2str(round(CorrCoeff.catchLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.catchLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.catchRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.catchRight.p(1,2),3))];
    Affichage_figure = 1;
else
    Leg_catch = ''; Title_catch = ''; s2 =[];
end

%% Figure properties
if Affichage_figure == 1
    legend off
    s.Parent.XAxis.FontSize = 10; s.Parent.YAxis.FontSize = 10;
    leg = legend([s s2],Leg_error,Leg_catch,'Location','NorthWest');
    leg.FontSize = 10; legend('boxoff'); 

    % Legendes et axes
    %xlim ([-1.6, 1.6]); %ylim([0 10]);
    title({['Vevaiometric ' Sensory_Modality ' trials ' ];Title_error;Title_catch},'fontsize',11);
    s.Parent.XLabel.String = xlabel;s.Parent.YLabel.String = ylabel; 
    s.Parent.XLabel.FontSize = 14;s.Parent.YLabel.FontSize = 14; 
    xlim([xmin xmax]); 
    hold off; % ylim([-6 8]);
    % clear Scatter* WT* DV* ndx* CorrCoeff Fit pdint Veva* 
end
clearvars -except SessionData
