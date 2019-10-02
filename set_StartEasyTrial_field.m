%% Create a field for the easy trials at the beginning of the session
%
%

function SessionData = set_StartEasyTrial_field(SessionData)

if ~isfield(SessionData.Custom , 'StartEasyTrial') || size(SessionData.Custom.StartEasyTrial,2) < size(SessionData.Custom.ChoiceLeft,2)
    if SessionData.DayvsWeek == 1
        for trial = 1 : SessionData.nTrials
            if trial < SessionData.Settings.GUI.StartEasyTrials
                SessionData.Custom.StartEasyTrial(trial)= 1;
            else
                SessionData.Custom.StartEasyTrial(trial)= 0; 
            end
        end
    elseif SessionData.DayvsWeek == 2
        SessionData.Custom.StartEasyTrial(1:size(SessionData.Custom.ChoiceLeft,2))= 0;
        for session = unique(SessionData.Custom.Session)
            SessionData.Custom.StartEasyTrial(find(SessionData.Custom.Session==session & SessionData.Custom.TrialNumber==1)...
                :find(SessionData.Custom.Session==session & SessionData.Custom.TrialNumber==SessionData.Settings.GUI.StartEasyTrials)) = 1;
        end 
    end
end