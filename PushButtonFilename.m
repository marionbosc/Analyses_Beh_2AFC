function filename = PushButtonFilename(source,event,filename,h)

checkboxValues = find(cell2mat(get(h.c, 'Value')));
filename = filename(checkboxValues);

assignin('base', 'filename', filename);

display('Filename list updated')

end