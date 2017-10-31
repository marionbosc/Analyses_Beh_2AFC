%% Script quantif du nombre d'essais durant lequel l'animal a recu une REC apres un FBdelay <0.5 
SessionData = SessionDataWeek;

Idx_Session = unique(SessionData.Custom.Session);

for session = Idx_Session
    idxRew = find(SessionData.Custom.Rewarded&SessionData.Custom.Session==session);
    small_Rew_delay = idxRew(find(SessionData.Custom.FeedbackTime(idxRew)<0.5));
    Nb_Bug_Rew(session) = size(small_Rew_delay,2);
    Nb_essais_rew(session) = size(find(SessionData.Custom.Rewarded&SessionData.Custom.Session==session),2);
    clear idxRew small_Rew_delay 
end
    
Pct_bug = Nb_Bug_Rew ./Nb_essais_rew *100
Mean_Bug = mean(Pct_bug)