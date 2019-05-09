function Pathtodata = choosePath(BpodProtocol)

answer = questdlg('Where do you want to get/save the dataset?', ...
	'Data pathway', ...
	'Locally','Home server','new location','');
% Handle response
switch answer
    case 'Locally'
        disp(['Data will be saved  ' answer ])
        Pathtodata = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh';
    case 'Home server'
        disp(['Data will be saved on ' answer ])
        Pathtodata = '/Volumes/marion/BpodData';
    case 'new location'
        Pathtodata = uigetdir;
        disp(['Data will be saved on ' Pathtodata ])
end

Pathtodata = [Pathtodata '/' BpodProtocol];

%% Other Path
%pathdatalocal = '/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Cfdce_brightness_data/'; % Larkum's data
%pathdatalocal = ['/Users/marionbosc/Documents/Kepecs_Lab_sc/Confidence_ACx/Datas/Datas_Beh/Larkum_data/Data/' BpodProtocol '/']; % Larkum's data
% case 'Confidence server'
%         disp(['Data will be saved on ' answer ])
%         Pathtodata = '/Volumes/MiceConfidence/BpodData/';
