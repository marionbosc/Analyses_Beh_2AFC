%% Script/fonction pour calcul et figure Psychometric:
%
%
% Input:
% - Dataset --> SessionData
% - Modalite sensorielle: 1 = Olfaction / 2 = Audition --> Modality
% - Coordonnees subplot (zB subplot(2,3,2))--> subplot(nb_raw_fig,nb_col_fig,positn_fig)

function [SessionData] = Psychometric_fig(SessionData, Modality,nb_raw_fig,nb_col_fig,positn_fig)
%% Psyc Olfactory (1)

if Modality==1
    % Recup fraction odeur A utilises dans chaque essai:
    OdorFracA = SessionData.Custom.OdorFracA(1:end);
    % Index des essais Olfaction
    ndxOlf = SessionData.Custom.Modality(1:end)==1; 
    % Index des essais pour lesquel ChoiceLeft = Nan
    ndxNan = isnan(SessionData.Custom.ChoiceLeft);

    % Recup des 6-8 fractions d'odeur A utilises durnt la session
    setStim = reshape(unique(OdorFracA),1,[]);
    setStim = setStim(~isnan(setStim));

    %Vecteur vide a remplir avec perf par type d'essai
    psyc = nan(size(setStim));

    % Remplissage du vecteur avec nb de reponse a gauche par type d'essai
    for iStim = setStim
        ndxStim = reshape(OdorFracA == iStim,1,[]);
        psyc(setStim==iStim) = sum(SessionData.Custom.ChoiceLeft(ndxStim&~ndxNan&ndxOlf))/...
                        sum(ndxStim&~ndxNan&ndxOlf);
    end

    % Donnees figures (calcul courbe fit points)
    PsycOlf.XData = setStim;
    PsycOlf.YData = psyc; %psyc(~isnan(psyc));
    PsycOlfFit.XData = linspace(min(setStim),max(setStim),100);
    if sum(OdorFracA(ndxOlf))>0
        PsycOlfFit.YData = glmval(glmfit(OdorFracA(ndxOlf),...
                        SessionData.Custom.ChoiceLeft(ndxOlf)','binomial'),linspace(min(setStim),max(setStim),100),'logit');
    end
    
    % Calcul biais dans la modalite
    Biais = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality);

    % Figure perf olfaction: f(% Odor A)= % left
    subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on;% f1=figure('units','normalized','position',[0,0,0.5,0.7]); hold on;
    % Points perf/DV
    plot(PsycOlf.XData,PsycOlf.YData, 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k', 'MarkerSize',6,'Visible','on');
    % Courbe fittee donnees perf  
    plot(PsycOlfFit.XData,PsycOlfFit.YData,'color','k','Visible','on');
    plot([0, 100],[0.5 0.5],'--','color',[.7,.7 .7]);
    p=plot([50 50],[0 105],'--','color',[.7,.7 .7]);
    % Legendes et axes
    p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
    ylim([-.05 1.05]);xlim (100*[-.05 1.05]);
    title({['Psychometric Olf  ' SessionData.Custom.Subject '  ' SessionData.SessionDate];...
        ['Side Bias toward left = ' num2str(round(Biais,2))]},'fontsize',12);
    xlabel('% odor A','fontsize',14);ylabel('% left','fontsize',14);hold off;

    clearvars -except SessionData
end

%% Psyc Auditory Auditory modality
if Modality==2
    % Recup DV essais audit
    AudDV = SessionData.Custom.DVlog(1:numel(SessionData.Custom.ChoiceLeft));
    % Index essais audit
    ndxAud = SessionData.Custom.Modality==Modality;
    % Index essais sans reponse (ChoiceLeft = NaN)
    ndxNan = isnan(SessionData.Custom.ChoiceLeft);
    % Calculs Bins de difficulte
    AudBin = 12;
    BinIdx = discretize(AudDV,linspace(-1.6,1.6,AudBin+1));

    % Calcul pourcent choix gauche par type d'essai
    PsycY = grpstats(SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan),BinIdx(ndxAud&~ndxNan),'mean');
    PsycX = unique(BinIdx(ndxAud&~ndxNan))/AudBin*3.2-1.6-1/AudBin;
    PsycX = PsycX(~isnan(PsycX));

    % Donnees plot (courbe fit points)
    PsycAud.YData = PsycY;
    PsycAud.XData = PsycX;
    if sum(ndxAud&~ndxNan) > 1
        PsycAudFit.XData = linspace(min(AudDV),max(AudDV),100);
        PsycAudFit.YData = glmval(glmfit(AudDV(ndxAud&~ndxNan),...
            SessionData.Custom.ChoiceLeft(ndxAud&~ndxNan)','binomial'),linspace(min(AudDV),max(AudDV),100),'logit');
    end
    
    % Calcul biais dans la modalite
    Biais = sum(SessionData.Custom.ChoiceLeft==1&SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality)/sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.Modality==Modality);

    % Figure perf audition: f(beta)= % left
    subplot(nb_raw_fig,nb_col_fig,positn_fig); hold on;
    % points Perf/DV
    plot(PsycAud.XData,PsycAud.YData,'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace','k',...
        'MarkerSize',3,'Visible','on');
    
    % Courbe fittee donnees perf 
    plot(PsycAudFit.XData,PsycAudFit.YData,'color','k','Visible','on');
    plot([-1.6, 1.6],[0.5 0.5],'--','color',[.7,.7 .7]);
    p=plot([0 0],[-.05 1.05],'--','color',[.7,.7 .7]);
    % Legendes et axes
    p.Parent.XAxis.FontSize = 10; p.Parent.YAxis.FontSize = 10;
    ylim([-.05 1.05]);xlim ([-1.6, 1.6]);
    title({['Psychometric Aud  ' SessionData.Custom.Subject '  ' SessionData.SessionDate];...
        ['Side Bias toward left = ' num2str(round(Biais,2))]},'fontsize',12);
    xlabel('DV ','fontsize',14);ylabel('% left','fontsize',14);hold off;

%     clear ndx* Psyc* Aud* BinIdx
    clearvars -except SessionData
end