function CombineGUI()

drawnow limitrate nocallbacks

f = figure('name','Cell Tracking','Position',[10 10 650 550],...
    'MenuBar','none','ToolBar','none','Visible','off');

hTypeTabs = uitabgroup('Parent',f,'SelectionChangedFcn',{@changeTab},'Tag','TabGroup');
hTypeTab(1) = uitab(hTypeTabs,'Title','Main','Tag','MainTab');
hTypeTab(2) = uitab(hTypeTabs,'Title','Upload Images','Tag','UploadImagesTab');
hTypeTab(3) = uitab(hTypeTabs,'Title','Correct Images','Tag','CorrectImagesTab');
hTypeTab(4) = uitab(hTypeTabs,'Title','Detect Objects','Tag','DetectObjectsTab');

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

H = DetectObjects();
while ~isempty(H.Children)
    H.Children(1).Parent = hTypeTab(4);
end
close(H);

f.Visible = 'on';
tmpUploadImagesSetts = struct('ImageType','RGB','UploadType','FileSelect',...
    'Names',[],'Frames',0,'Fields',0);
tmpCorrectImagesSetts = struct('Sigma',0,'Invert',0,'Resize',1);
f.UserData = struct('UploadImagesSetts',tmpUploadImagesSetts,...
    'CorrectImagesSetts',tmpCorrectImagesSetts,...
    'DetectObjectsSetts',[]);

drawnow
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

function children = getChildren(h)
children = [];
listNodes = h;

while ~isempty(listNodes)
    currNode = listNodes(1);
    
    if ~isempty(currNode.Children)
        children = [children;currNode.Children];
        listNodes = [listNodes;currNode.Children];
    end
    
    listNodes(1) = [];
end
end


function changeTab(hObject,event,handles)
handles = guihandles(getFig(hObject));
switch event.OldValue
    case handles.MainTab
    case handles.UploadImagesTab
        postUpdateUploadImages(hObject);
    case handles.CorrectImagesTab
        postUpdateCorrectImages(hObject);
end

switch event.NewValue
    case handles.MainTab
    case handles.UploadImagesTab
        preUpdateUploadImages(hObject);
    case handles.CorrectImagesTab
        preUpdateCorrectImages(hObject);
end

end


function preUpdateUploadImages(hObject)
handles = guihandles(getFig(hObject));
f = getFig(hObject);
handles.UploadImagesPanel.Visible = 'off';
maxX = 450; maxY = 300;
if f.Position(3)>maxX && f.Position(4)>maxY
    handles.UploadImagesPanel.Position = [0 1-maxY/f.Position(4) maxX/f.Position(3) maxY/f.Position(4)];
else
    handles.UploadImagesPanel.Position = [0 0 1 1];
end
handles.UploadImagesPanel.Visible = 'on';
end


function postUpdateUploadImages(hObject)
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

f = getFig(hObject);
f.UserData.UploadImagesSetts = tmpUploadImagesSetts;
end


function preUpdateCorrectImages(hObject)
handles = guihandles(getFig(hObject));
f = getFig(hObject);
handles.CorrectImagesPanel.Visible = 'off';
maxX = 300; maxY = 200;
if f.Position(3)>maxX && f.Position(4)>maxY
    handles.CorrectImagesPanel.Position = [0 1-maxY/f.Position(4) maxX/f.Position(3) maxY/f.Position(4)];
else
    handles.CorrectImagesPanel.Position = [0 0 1 1];
end
handles.CorrectImagesPanel.Visible = 'on';
end


function postUpdateCorrectImages(hObject)
handles = guihandles(getFig(hObject));
tmpCorrectImagesSetts = struct('Sigma',0,'Invert',0,'Resize',1);

tmpCorrectImagesSetts.Sigma  = str2double(handles.CorrectImagesSigmaEdit.String);
tmpCorrectImagesSetts.Invert = handles.CorrectImagesInvertCheck.String;
tmpCorrectImagesSetts.Resize = str2double(handles.CorrectImagesResizeEdit.String);

f = getFig(hObject);
f.UserData.CorrectImagesSetts = tmpCorrectImagesSetts;
end