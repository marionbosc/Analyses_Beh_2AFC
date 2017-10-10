%% Script/fonction pour calcul et figure vevaiometric:
%
%
% Input:
% - Dataset --> SessionData
% - Modalite sensorielle --> 1 = Olfaction / 2 = Audition (Modality)
% - Manip unique vs sessions poolees: --> SessionData.DayvsWeek
% - Figure style output (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)

function Vevaiometric_fig_Paulsdata(CompiledData, Modality,nb_raw_fig,nb_col_fig,positn_fig)
%% Paramètres de la figure:
VevaiometricMinWT = 2; % FB time minimum pris en compte dans analyse WT

if Modality == 1
    Sensory_Modality = 'Olfactory';
    % Limites plot figures
     xlimL = [0 1]; xlimR = [-1 0];
     xmin= 0; xmax = 100;
     Xlabel = 'Fraction Odor A (%)';
elseif Modality ==2
    Sensory_Modality = 'Auditory';
    % Limites plot figures
    xlimL = [-1 0]; xlimR = [0 1];
    xmin= -1; xmax = 1;
    Xlabel = 'DV';
end

% Figure vevaiometric f(DV)=WT
veva = subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on

%% Recup essais a analyser
if isfield(CompiledData,'Modality')
    ndxModality = CompiledData.Modality(1:end) == Modality ; % Essais stimulus auditif
else
    ndxModality = ones(1,size(CompiledData.TrialIndex,2));
end

% Implementation:
ndxCorrect = CompiledData.CorrectChoice(1:end) == 1; 
ndxError = CompiledData.CorrectChoice(1:end) == 0 ;
ndxLefttrial = CompiledData.TrialTypes(1:end)==1 | CompiledData.TrialTypes(1:end)==3 | CompiledData.TrialTypes(1:end)==5;
ndxRighttrial = CompiledData.TrialTypes(1:end)==2 | CompiledData.TrialTypes(1:end)==4 | CompiledData.TrialTypes(1:end)==6;
ndxLeft = ndxError&ndxRighttrial | ndxCorrect&ndxLefttrial;
ndxRight = ndxError&ndxLefttrial | ndxCorrect&ndxRighttrial;
ndxnonan = ~isnan(CompiledData.WaitingTime);
CompiledData.ChoosenPort(ndxLeft & ~CompiledData.UnansweredTrial) = 1;
CompiledData.ChoosenPort(ndxRight & ~CompiledData.UnansweredTrial) = 2;

ndxCorrectCatch = CompiledData.CatchTrial(1:end) & CompiledData.CorrectChoice(1:end) == 1; %only correct catch trials
ndxMinWT = CompiledData.RewardDelay > VevaiometricMinWT;

%% Recup data erreur
if sum(ndxError&ndxMinWT&ndxModality&ndxLeft)>10 && sum(ndxError&ndxMinWT&ndxModality&ndxRight)>10
    % Datas WT brutes
%     SessionData = normWT(SessionData);
%     if SessionData.DayvsWeek==1
        WTerrLeft = CompiledData.WaitingTime(ndxError&ndxMinWT&ndxModality&ndxRight&ndxnonan); % recup WT essais erreur pointage a gauche
        WTerrRight = CompiledData.WaitingTime(ndxError&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % recup WT essais erreur pointage a droite
%     else
%         WTerrLeft = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxAud&ndxRight); % recup WT essais erreur pointage a gauche
%         WTerrRight = SessionData.Custom.FeedbackTimeNorm(ndxError&ndxMinWT&ndxAud&ndxLeft); % recup WT essais erreur pointage a droite
%     end
    if Modality ==1 % Essais Olf
        DVerrLeft = CompiledData.OdorLevel(ndxError&ndxMinWT&ndxModality&ndxRight&ndxnonan); % Recup DV essais erreur pointage a gauche
        DVerrRight = CompiledData.OdorLevel(ndxError&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % recup DV essais erreur pointage a droite
    elseif Modality ==2 % Essais Aud
        DVerrLeft = -CompiledData.Omega(ndxError&ndxMinWT&ndxModality&ndxRight&ndxnonan); % Recup DV essais erreur pointage a gauche
        DVerrRight = CompiledData.Omega(ndxError&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % recup DV essais erreur pointage a droite
    end
    
    % Data sorting: (reorg des WT selon classement DV croissant pour que DV soit continu):
    [DVerrLeft_sorted, eL_sort] = sort(DVerrLeft);
    WTerrLeft_sorted = WTerrLeft(eL_sort);
    [DVerrRight_sorted, eR_sort] = sort(DVerrRight);
    WTerrRight_sorted = WTerrRight(eR_sort);

    % Remplacement des variables par les variables reorganisees:
    DVerrLeft = DVerrLeft_sorted;
    WTerrLeft = WTerrLeft_sorted;
    DVerrRight = DVerrRight_sorted;
    WTerrRight = WTerrRight_sorted;

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
    s=scatter(Scatter.err.XData,Scatter.err.YData,3,'r',...
     'Marker','o','MarkerFaceColor','r','Visible','on','MarkerEdgeColor','r');
    Ymax = [max(s.YData)*1.01 max(s.YData)*1.01];
    plot(Fit.errLeft.r,'r-',xlimL,Ymax,'w-');
    plot(DVerrLeft',pdint.errLeft.r,'r--');
    plot(Fit.errRight.r,'r-',xlimR,Ymax,'w-');
    plot(DVerrRight',pdint.errRight.r,'r--');
    Leg_error = ['Error n = ',num2str(size(Scatter.err.YData,2))];
    Title_error = ['Error rL = ' num2str(round(CorrCoeff.errLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.errLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.errRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.errRight.p(1,2),3))];
else
    Leg_error = ''; Title_error = '';
end

%% Recup data catch correct
if sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft)>10 && sum(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight)>10
    % Datas WT brutes
    WTcatchLeft = CompiledData.WaitingTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % recup WT essais catch pointage a gauche
    WTcatchRight = CompiledData.WaitingTime(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight&ndxnonan); % recup WT essais catch pointage a droite
    
    if Modality ==1 % Essais Olf
        DVcatchLeft = CompiledData.OdorLevel(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % Recup DV essais catch pointage a gauche
        DVcatchRight = CompiledData.OdorLevel(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight&ndxnonan); % recup DV essais catch pointage a droite
    elseif Modality ==2 % Essais Aud
        DVcatchLeft = -CompiledData.Omega(ndxCorrectCatch&ndxMinWT&ndxModality&ndxLeft&ndxnonan); % Recup DV essais catch pointage a gauche
        DVcatchRight = CompiledData.Omega(ndxCorrectCatch&ndxMinWT&ndxModality&ndxRight&ndxnonan); % recup DV essais catch pointage a droite
    end
    
    % Data sorting: (reorg des WT selon classement DV croissant pour que DV soit continu):
    [DVcatchLeft_sorted, cL_sort] = sort(DVcatchLeft);
    WTcatchLeft_sorted = WTcatchLeft(cL_sort);
    [DVcatchRight_sorted, cR_sort] = sort(DVcatchRight);
    WTcatchRight_sorted = WTcatchRight(cR_sort);

    % Remplacement des variables par les variables reorganisees:
    DVcatchLeft = DVcatchLeft_sorted;
    WTcatchLeft = WTcatchLeft_sorted;
    DVcatchRight = DVcatchRight_sorted;
    WTcatchRight = WTcatchRight_sorted;

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
    s=scatter(Scatter.catch.XData,Scatter.catch.YData,3,'g',...
     'Marker','o','MarkerFaceColor','g','Visible','on','MarkerEdgeColor','g');
    Ymax = [max(s.YData)*1.01 max(s.YData)*1.01];
    plot(Fit.catchLeft.r,'g-',xlimL,Ymax,'w-');
    plot(DVcatchLeft',pdint.catchLeft.r,'g--');
    plot(Fit.catchRight.r,'g-',xlimR,Ymax,'w-');
    plot(DVcatchRight',pdint.catchRight.r,'g--');
    Leg_catch = ['Catch n = ',num2str(size(Scatter.catch.YData,2))];
    Title_catch = ['Catch rL = ' num2str(round(CorrCoeff.catchLeft.r(1,2),2))...
    ' / pL = ' num2str(round(CorrCoeff.catchLeft.p(1,2),3)) ...
    ' ; rR = ' num2str(round(CorrCoeff.catchRight.r(1,2),2)) ...
    ' / pR = ' num2str(round(CorrCoeff.catchRight.p(1,2),3))];
else
    Leg_catch = ''; Title_catch = '';
end

%% Figure properties
legend off
s.Parent.XAxis.FontSize = 10; s.Parent.YAxis.FontSize = 10;
leg = legend(Leg_error,Leg_catch,'Location','SouthWest');
leg.FontSize = 10; legend('boxoff'); 
xlim([xmin xmax]);
% Legendes et axes
%xlim ([-1.6, 1.6]); %ylim([0 10]);
title({['Vevaiometric ' Sensory_Modality ' trials ' ];Title_error;Title_catch},'fontsize',12);
s.Parent.XLabel.String = Xlabel;s.Parent.YLabel.String = 'WT (s)'; hold off;

% clear Scatter* WT* DV* ndx* CorrCoeff Fit pdint Veva* 
clearvars -except SessionData
