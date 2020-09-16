
SessionDataWeek.filename = 'SessionDataWeek_180201_0215_AfterRetraing.mat';

SessionDataWeek.pathname = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Dual2AFC/M1/Session Data/';

SessionDataWeek.nTrials = size(SessionDataWeek.Custom.ChoiceLeft,2);

if ~isfield(SessionDataWeek.Custom, 'StartEasyTrial')
    SessionDataWeek = set_StartEasyTrial_field(SessionDataWeek);
end

if ~isfield(SessionDataWeek.Custom, 'LeftRewarded')
    for iTrial = 1 : SessionDataWeek.nTrials
        SessionDataWeek.Custom.LeftRewarded(iTrial) = NaN;
        if length(SessionDataWeek.Custom.LeftClickTrain{iTrial}) > length(SessionDataWeek.Custom.RightClickTrain{iTrial})
            SessionDataWeek.Custom.LeftRewarded(iTrial) = 1;
        elseif length(SessionDataWeek.Custom.LeftClickTrain{iTrial}) < length(SessionDataWeek.Custom.RightClickTrain{iTrial})
            SessionDataWeek.Custom.LeftRewarded(iTrial) = 0;
        else
            SessionDataWeek.Custom.LeftRewarded(iTrial) = rand<0.5;
        end
    end
end

cd(SessionDataWeek.pathname)
save(SessionDataWeek.filename,'SessionDataWeek');

max(unique(SessionDataWeek.Custom.Session))