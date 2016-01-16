function CombineGUI()

f = figure('name','Cell Tracking','Visible','off');

hTypeTabs = uitabgroup('Parent',f,'SelectionChangedFcn',{@changeTab});
hTypeTab(1) = uitab(hTypeTabs,'Title','Main','Tag','MainTab');
hTypeTab(2) = uitab(hTypeTabs,'Title','Upload Images','Tag','UploadImagesTab');
hTypeTab(3) = uitab(hTypeTabs,'Title','Correct Images','Tag','CorrectImagesTab');
hTypeTab(4) = uitab(hTypeTabs,'Title','Start Analysis');

H = Main();
while ~isempty(H.Children)
    H.Children(1).Parent = hTypeTab(1);
end
close(H);

H = UploadImages();
while ~isempty(H.Children)
    H.Children(1).Parent = hTypeTab(2);
end
close(H);

H = CorrectImages();
while ~isempty(H.Children)
    H.Children(1).Parent = hTypeTab(3);
end
close(H);


f.Visible = 'on';
tmpUploadImagesSetts = struct('ImageType','RGB','UploadType','FileSelect',...
    'Names',[],'Frames',0,'Fields',0);
f.UserData = struct('UploadImagesSetts',tmpUploadImagesSetts,'CorrectImagesSetts',[],...
    'DetectObjectsSetts',[]);

end

%
function root = getFig(h)
% Function to get root figure of the GUI
if isprop(h,'Name')
    if strcmp(get(h,'Name'),'Cell Tracking')
        root = h;
        return
    end
end
root = getFig(get(h,'Parent'));
end


function changeTab(hObject,event,handles)
handles = guihandles(getFig(hObject));
switch event.OldValue
    case handles.MainTab
    case handles.UploadImagesTab
        updateUploadImages(hObject);
end

end


function updateUploadImages(hObject)
handles = guihandles(getFig(hObject));
tmpUploadImagesSetts = struct('ImageType','RGB','UploadType','FileSelect',...
    'Names',{{}},'Path',{{}},'Frames',0,'Fields',0);

switch handles.ImageTypeMenu.Value
    case 1
        tmpUploadImagesSetts.ImageType = 'RGB';
    case 2
        tmpUploadImagesSetts.ImageType = 'Split';
    case 3
        tmpUploadImagesSetts.ImageType = 'Gray';
end

switch handles.UploadTypeMenu.Value
    case 1
        tmpUploadImagesSetts.UploadType = 'Select';
    case 2
        tmpUploadImagesSetts.UploadType = 'Name';
    case 3
        tmpUploadImagesSetts.UploadType = 'Multi';
end

switch tmpUploadImagesSetts.UploadType
    case 'Select'
        tmpUploadImagesSetts.Names = handles.ImageListbox.UserData;
        tmpUploadImagesSetts.Path = handles.FileSelectPanel.UserData;
    case {'Name','Multi'}
        switch tmpUploadImagesSetts.ImageType
            case 'Split'
                tmpUploadImagesSetts.Names = {handles.FileNameEdit1.String,...
                    handles.FileNameEdit2.String,handles.FileNameEdit3.String};
            case {'RGB','Gray'}
                tmpUploadImagesSetts.Names = {handles.FileNameEdit1.String};
        end
end

switch tmpUploadImagesSetts.UploadType
    case 'Multi'
        tmpUploadImagesSetts.Fields = str2double(handles.MultiFileFieldEdit.String);
        tmpUploadImagesSetts.Frames = str2double(handles.MultiFileFrameEdit.String);
    case 'Name'
        tmpUploadImagesSetts.Frames = str2double(handles.FileNameFrameEdit.String);
end

tmpUploadImagesSetts
f = getFig(hObject);
f.UserData.UploadImagesSetts = tmpUploadImagesSetts;
end