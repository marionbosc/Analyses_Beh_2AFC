%% Calcul et implementation DV logarithmique:
function SessionData = DVlog(SessionData)

if isfield(SessionData.Custom, 'DVlog')==0

    
    
    for essai = 1:size(SessionData.Custom.ChoiceLeft,2)
        if SessionData.Custom.Modality(essai)==2
            % Implementation DVlog
            SessionData.Custom.DVlog(essai) = -log10(length(SessionData.Custom.RightClickTrain{essai})/length(SessionData.Custom.LeftClickTrain{essai}));
        else
            SessionData.Custom.DVlog(essai) = NaN;
        end
    end
    
    % Enregistrement des datas implementees
    cd(SessionData.pathname)
    save(SessionData.filename,'SessionData');
end
