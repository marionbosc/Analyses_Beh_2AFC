%% Calcul et implementation WT normalise sur catch trial moyen de la session:
function SessionData = normWT(SessionData,Forced)

if ~exist('Forced', 'var')
    Forced= 0;
end
    
if SessionData.DayvsWeek==1   
    if Forced==1 
    % Calcul WT moyen session pour catch trials
    ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
    if sum(ndxCatch)>10
        ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
        ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
        % meanWTSession_left = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        % meanWTSession_right = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
        medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));

        % Normalisation WT par WT moyen session
        SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
        SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
        SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;

        % Enregistrement des datas implementees
        cd(SessionData.pathname)
        save(SessionData.filename,'SessionData');
    end
    
    elseif Forced==0 && isfield(SessionData.Custom, 'FeedbackTimeNorm')==0 
        % Calcul WT moyen session pour catch trials
        ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
        if sum(ndxCatch)>10
            ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
            ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
            % meanWTSession_left = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
            % meanWTSession_right = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
            medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
            medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));

            % Normalisation WT par WT moyen session
            SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
            SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
            SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;

            % Enregistrement des datas implementees
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
end