%% Script to check if the lag realted to the data processing increase with time during the session

for trial = 1 : SessionData.nTrials
    
    % Real duration of each trial   
    if trial>1
        Real_trial_duration(trial-1) = SessionData.TrialStartTimestamp(trial)-SessionData.TrialStartTimestamp(trial-1);
    end
    
    % Last Bpod event
    Sum_Evt_duration (trial) = SessionData.RawEvents.Trial{1, trial}.States.ITI_Signal(2);
    
end

for trial = 1 : SessionData.nTrials-1
    % Duration of the lag after ITI (data processing):
    Lag_post_ITI(trial) = Real_trial_duration(trial) - Sum_Evt_duration (trial);
end


%% Analysis on Mouse2AFC TicToc
for trial = 1 : SessionData.nTrials-1
    % Duration of the sum of the sma events
    Sum_Evt_duration (trial) = SessionData.RawEvents.Trial{1, trial}.States.ITI_Signal(2);
    
    % Duration of each post-processing step
    AfterRawEvts(trial) = SessionData.Timer.AfterRawEvts (trial) - SessionData.Timer.AfterSendStateMatrix(trial);
    AfterSaveBpodData(trial) = SessionData.Timer.AfterSaveBpodData (trial) - SessionData.Timer.AfterRawEvts(trial);
    AfterupdateCDF(trial) = SessionData.Timer.AfterupdateCDF (trial) - SessionData.Timer.AfterSaveBpodData(trial);
    AfterMainPlot(trial) = SessionData.Timer.AfterMainPlot (trial) - SessionData.Timer.AfterupdateCDF(trial);
    AfterSMS(trial) = SessionData.Timer.AfterSMS (trial) - SessionData.Timer.AfterMainPlot(trial);    

   % Delta duration of the sma processing and sum of the event
   Delta(trial) = AfterRawEvts(trial) - Sum_Evt_duration (trial);
end

% figure;plot(AfterRawEvts); hold on; plot(Delta); plot(AfterSaveBpodData);plot(AfterupdateCDF);plot(AfterMainPlot);plot(AfterSMS);
% legend('RawEvts','Delta smaprocessing-sumoftheevt','SaveBpodData','updateCDF','MainPlot','SMS')

figure;plot(Delta); hold on; plot(AfterSaveBpodData);plot(AfterupdateCDF);plot(AfterMainPlot);plot(AfterSMS);
legend('Delta smaprocessing-sumoftheevt','SaveBpodData','updateCDF','MainPlot','SMS','location', 'NorthWest');
title([SessionData.Custom.Subject ' post-processing duration after each trial during a training session'],'fontsize',12);
    xlabel('Trials','fontsize',14);ylabel('Time (sec)','fontsize',14);
    xlim([1 SessionData.nTrials]);hold off;



    