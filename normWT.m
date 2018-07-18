%% Calculation et implementation of WT normalized on median Catch trial WT of the session
%
% Input:
% - Data structure (SessionData or SessionDataWeek or SessionDatasets)
% Optional --> Forced variable (0 = compute only if 'FeedbackTimeNorm'
% field does not already exist / 1 = compute it anyway (overwrite in case
% field already exist))
%
% Output:
% - Data structure implemented
%

function SessionData = normWT(SessionData,Forced)

if ~exist('Forced', 'var')
    Forced= 0;
end
    
if SessionData.DayvsWeek==1   
    if Forced==1 
    % Computation of median WT of the session for Catch trials
    ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
    if sum(ndxCatch)>10
        ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
        ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
        % meanWTSession_left = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        % meanWTSession_right = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
        medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
        medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));

        % WT normalized per median session WT
        SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
        SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
        SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;

        % Saving of implemented SessionData
        cd(SessionData.pathname)
        save(SessionData.filename,'SessionData');
    end
    
    elseif Forced==0 && isfield(SessionData.Custom, 'FeedbackTimeNorm')==0 
        % Computation of median WT of the session for Catch trials
        ndxCatch = SessionData.Custom.CatchTrial(1:end) & SessionData.Custom.FeedbackTime(1:end)>=0.5;
        if sum(ndxCatch)>10
            ndx_left = SessionData.Custom.ChoiceLeft(1:end)==1;
            ndx_right = SessionData.Custom.ChoiceLeft(1:end)==0;
            % meanWTSession_left = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
            % meanWTSession_right = nanmean(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));
            medianWTSession_left = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_left));
            medianWTSession_right = nanmedian(SessionData.Custom.FeedbackTime(ndxCatch&ndx_right));

            % WT normalized per median session WT
            SessionData.Custom.FeedbackTimeNorm(ndx_left) = SessionData.Custom.FeedbackTime(ndx_left)-medianWTSession_left;
            SessionData.Custom.FeedbackTimeNorm(ndx_right) = SessionData.Custom.FeedbackTime(ndx_right)-medianWTSession_right;
            SessionData.Custom.FeedbackTimeNorm(~ndx_left&~ndx_right) = NaN;

            % Saving of implemented SessionData
            cd(SessionData.pathname)
            save(SessionData.filename,'SessionData');
        end
    end
end