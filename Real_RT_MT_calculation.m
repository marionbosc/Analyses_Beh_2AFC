%% Compute real Reaction and Movement Time of the animal based on SessionData.RawEvents data
%
%

% Test to check if the field RT already exist:
if ~isfield(SessionData.Custom,'RT') || ~isfield(SessionData.Custom,'PostStimRT')
    % Create a NaN vector for Custom.RT and Custom.PostStimRT:
    SessionData.Custom.RT = nan(1,size(SessionData.Custom.ChoiceLeft,2));
    SessionData.Custom.PostStimRT = nan(1,size(SessionData.Custom.ChoiceLeft,2));
    SessionData.Custom.MT = nan(1,size(SessionData.Custom.ChoiceLeft,2));
    
    % Determine the name of each port
    if isfield(SessionData.Settings.GUI,'Ports_LMRAir')
        LeftPort = floor(mod(SessionData.Settings.GUI.Ports_LMRAir/1000,10));
        CenterPort = floor(mod(SessionData.Settings.GUI.Ports_LMRAir/100,10));
        RightPort = floor(mod(SessionData.Settings.GUI.Ports_LMRAir/10,10));
    elseif isfield(SessionData.Settings.GUI,'Ports_LMR')
        LeftPort = floor(mod(SessionData.Settings.GUI.Ports_LMR/100,10));
        CenterPort = floor(mod(SessionData.Settings.GUI.Ports_LMR/10,10));
        RightPort = mod(SessionData.Settings.GUI.Ports_LMR,10);
    end

    LeftPortIn = ['Port' num2str(LeftPort) 'In']; LeftPortOut = ['Port' num2str(LeftPort) 'Out'];
    CenterPortIn = ['Port' num2str(CenterPort) 'In']; CenterPortOut = ['Port' num2str(CenterPort) 'Out'];
    RightPortIn = ['Port' num2str(RightPort) 'In']; RightPortOut = ['Port' num2str(RightPort) 'Out'];

    % Determine which trial should be included:
    ndxincl = ~SessionData.Custom.EarlyWithdrawal & ~isnan(SessionData.Custom.ChoiceLeft);


    for trial = SessionData.Custom.TrialNumber(ndxincl)
        % Timepoint the stimulus starts 
        RT= SessionData.RawEvents.Trial{1, trial}.States.stimulus_delivery(1);
        % Timepoint the stimulus stops
        endST = SessionData.RawEvents.Trial{1, trial}.States.stimulus_delivery(2);
        
        %
        if SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(CenterPortOut))...
            > SessionData.RawEvents.Trial{1, trial}.States.stimulus_delivery(2)
            % Timepoint the animal left the center port
            MT(1) = min(SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(CenterPortOut))...
                (SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(CenterPortOut))...
                > SessionData.RawEvents.Trial{1, trial}.States.stimulus_delivery(2))); 
            % Check that the timepoint detected as the beginning of the MT is
            % correct:
            if MT(1) > SessionData.RawEvents.Trial{1, trial}.States.WaitForRewardStart(1)
                MT(1) = SessionData.RawEvents.Trial{1, trial}.States.CenterPortRewardDelivery(1);
            end

            if isfield(SessionData.RawEvents.Trial{1, trial}.Events, LeftPortIn) && SessionData.Custom.ChoiceLeft(trial)==1
                % Timepoint the animal entered the left response port
                MT(2) = min(SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(LeftPortIn))...
                    (SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(LeftPortIn)) > MT(1)));               
            elseif isfield(SessionData.RawEvents.Trial{1, trial}.Events, RightPortIn) && SessionData.Custom.ChoiceLeft(trial)==0
                % Timepoint the animal entered the right response port
                MT(2) = min(SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(RightPortIn))...
                    (SessionData.RawEvents.Trial{1, trial}.Events.(matlab.lang.makeValidName(RightPortIn)) > MT(1)));       
            else
                assert(false, 'No existing event describing a response');
            end
            % Reaction time of the trial overwrite in Custom.RT
            SessionData.Custom.RT(trial) = MT(1)-RT;
            % Reaction time after the end of the stimulus overwrite in Custom.PostStimRT
            SessionData.Custom.PostStimRT(trial) = MT(1)-endST;
            % Movement time of the trial overwrite in Custom.MT
            SessionData.Custom.MT(trial) = diff(MT);
        end
        clear MT RT endST
    end
end
    
    