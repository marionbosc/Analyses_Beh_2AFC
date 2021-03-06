%% Fct to set and use criterion to include session in data analysis
%

function [SessionData, Include] = get_SessionData_ConfidenceSettings(WhichStep,SessionData,ConfidenceSettings)
%% 1st Step: Set the threshold of the required settings to include the dataset in the analysis
switch WhichStep
    case 1
        ConfidenceSettings = ...
            {'Min amount of trials', 100, 'SessionData.nTrials', ' >= ConfidenceSettings{Line, 2}';...
            'Min difficulty Alpha', 0.5, 'SessionData.Settings.GUI.AuditoryAlpha', ' >= ConfidenceSettings{Line, 2}';...
            'Min accuracy', 0.7, 'sum(SessionData.Custom.ChoiceCorrect==1)/sum(~isnan(SessionData.Custom.ChoiceCorrect))', ' >= ConfidenceSettings{Line, 2}';...
            'Max |bias|', 0.1, 'abs(((sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.ChoiceLeft==1)/sum(SessionData.Custom.LeftRewarded==1&~isnan(SessionData.Custom.ChoiceLeft)))-(sum(SessionData.Custom.ChoiceCorrect==1&SessionData.Custom.ChoiceLeft==0)/sum(SessionData.Custom.LeftRewarded==0&~isnan(SessionData.Custom.ChoiceLeft))))/2)', ' <= ConfidenceSettings{Line, 2}';...
            'Error catched', 1, 'SessionData.Settings.GUI.CatchError', ' == ConfidenceSettings{Line, 2}';...
            'Incorrect Choice feedback', 1, 'SessionData.Settings.GUI.IncorrectChoiceSignalType', ' == ConfidenceSettings{Line, 2}';...
            'Incorrect Choice TimeOut', 0, 'SessionData.Settings.GUI.TimeOutIncorrectChoice', ' == ConfidenceSettings{Line, 2}';...
            'Skipped FB TimeOut', 0, 'SessionData.Settings.GUI.TimeOutSkippedFeedback', ' == ConfidenceSettings{Line, 2}';...
            'Min P(CatchTrials)', 0.1, 'SessionData.Settings.GUI.PercentCatch', ' >= ConfidenceSettings{Line, 2}';...
            'FB delay distribution', 3, 'SessionData.Settings.GUI.FeedbackDelaySelection', ' == ConfidenceSettings{Line, 2}';...
            'Min FB delay', 0.5, 'SessionData.Settings.GUI.FeedbackDelayMin', ' == ConfidenceSettings{Line, 2}';...
            'Max FB delay', 8, 'SessionData.Settings.GUI.FeedbackDelayMax', ' == ConfidenceSettings{Line, 2}';...
            'FB delay Tau', 1.5, 'SessionData.Settings.GUI.FeedbackDelayTau', ' == ConfidenceSettings{Line, 2}';...
            'Reward after Min sampling', 0, 'SessionData.Settings.GUI.RewardAfterMinSampling', ' == ConfidenceSettings{Line, 2}'};
        
        top = 20*size(ConfidenceSettings,1) + 20; % Y coordinate of each line. Needs to be 20 per line + 20 for bottom button
        figure('Position',[100 100 240 top+30]); % Position = [X,Y,width, height];
        
        for Line = 1:size(ConfidenceSettings,1)
            h.c(Line) = uicontrol('style','checkbox', 'string',ConfidenceSettings{Line,1},'Value', 1,...
                'Position',[10 top 160 15]);
            h.c2(Line) = uicontrol('style','edit', 'string', ConfidenceSettings{Line,2},...
                'Position',[180 top 50 15]);
                top=top-20;
        end
        h.p = uicontrol('Style', 'pushbutton', 'string', 'Update criteria',...
                    'Position', [60 top 100 15],'CallBack', {@PushButtonCfdceSett,ConfidenceSettings,h});

%%  2nd Step: Test each dataset to decide which one meets the criterion and can be included in the Confidence analysis:
    case 2
        Failed_criteria = 0; Include = 1; 
        display(['Session: ' SessionData.SessionDate])
        for Line = 1:size(ConfidenceSettings,1)
            test = eval([ConfidenceSettings{Line, 3} ConfidenceSettings{Line, 4}]);
            if ~test
                display([ConfidenceSettings{Line, 1} ' criterion not met: ' ConfidenceSettings{Line, 1} ' = ' num2str(eval(ConfidenceSettings{Line, 3}))]) 
                Failed_criteria = 1;
            end
        end

        if Failed_criteria
            % Prompt to decide to exlude the dataset or not:
            prompt = {'Include datatset=1 / Exclude dataset=0'}; dlg_title = 'Include dataset?'; numlines = 1;
            def = {'0'}; Include = str2num(cell2mat(inputdlg(prompt,dlg_title,numlines,def))); 
            clear def dlg_title numlines prompt
        end
end




   