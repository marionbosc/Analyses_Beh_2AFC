function ConfidenceSettings = PushButtonCfdceSett(source,event,ConfidenceSettings,h)

for Line = 1:size(ConfidenceSettings,1)
    ConfidenceSettings{Line,2} = str2double(h.c2(Line).String);
end

checkboxValues = find(cell2mat(get(h.c, 'Value')));
ConfidenceSettings = ConfidenceSettings(checkboxValues,:);

assignin('base', 'ConfidenceSettings', ConfidenceSettings);

display('Confidence settings updated')
close
end