%% Create a field for the easy trials at the beginning of the session
%
%

function SessionData = set_StartEasyTrial_field(SessionData)

if ~isfield(SessionData.Custom , 'StartEasyTrial') || size(SessionData.Custom.StartEasyTrial,2) < size(SessionData.Custom.ChoiceLeft,2)
    if SessionData.DayvsWeek == 1
        SessionData.Custom.StartEasyTrial(1:SessionData.Settings.GUI.StartEasyTrials)= 1;
        SessionData.Custom.StartEasyTrial(SessionData.Settings.GUI.StartEasyTrials+1:max(SessionData.Custom.TrialNumber))= 0;    
    elseif SessionData.DayvsWeek == 2
        SessionData.Custom.StartEasyTrial(1:size(SessionData.Custom.ChoiceLeft,2))= 0;
        for session = unique(SessionData.Custom.Session)
            SessionData.Custom.StartEasyTrial(find(SessionData.Custom.Session==session & SessionData.Custom.TrialNumber==1)...
                :find(SessionData.Custom.Session==session & SessionData.Custom.TrialNumber==SessionData.Settings.GUI.StartEasyTrials)) = 1;
        end 
    end
end