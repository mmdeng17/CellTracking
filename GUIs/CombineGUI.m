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
tmpUploadImagesSetts  = struct('ImageType','RGB','UploadType','FileSelect',...
    'Names',[],'Frames',0,'Fields',0);
tmpCorrectImagesSetts = struct('Sigma',0,'Invert',0,'Resize',1);
tmpDetectObjectsSetts  = struct('Method','EdgeWater','DOSetts',{{0,250,1}},...
    'MetricLims',[]);
f.UserData = struct('UploadImagesSetts',tmpUploadImagesSetts,...
    'CorrectImagesSetts',tmpCorrectImagesSetts,...
    'DetectObjectsSetts',tmpDetectObjectsSetts);

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


function checkPanelSize(f,hPanel,maxX,maxY)
if f.Position(3)>maxX
    hPanel.Position(3) = maxX/f.Position(3);
else
    hPanel.Position(3) = 1;
end
if f.Position(4)>maxY
    hPanel.Position(2) = 1-maxY/f.Position(4);
    hPanel.Position(4) = maxY/f.Position(4);
else
    hPanel.Position(2) = 0;
    hPanel.Position(4) = 1;
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
    case handles.DetectObjectsTab
        postUpdateDetectObjects(hObject);
end

switch event.NewValue
    case handles.MainTab
    case handles.UploadImagesTab
        preUpdateUploadImages(hObject);
    case handles.CorrectImagesTab
        preUpdateCorrectImages(hObject);
    case handles.DetectObjectsTab
        preUpdateDetectObjects(hObject);
end

end


function preUpdateUploadImages(hObject)
handles = guihandles(getFig(hObject));
f = getFig(hObject);
handles.UploadImagesPanel.Visible = 'off';
maxX = 450; maxY = 300;
checkPanelSize(f,handles.UploadImagesPanel,maxX,maxY);
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
checkPanelSize(f,handles.CorrectImagesPanel,maxX,maxY);
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


function preUpdateDetectObjects(hObject)
handles = guihandles(getFig(hObject));
f = getFig(hObject);
handles.DetectObjectsPanel.Visible = 'off';
maxX = 800; maxY = 600;
checkPanelSize(f,handles.DetectObjectsPanel,maxX,maxY);
handles.DetectObjectsPanel.Visible = 'on';

switch f.UserData.UploadImagesSetts.ImageType
    case {'RGB','Split'}
        handles.DetectObjectsRChGroup.Title  = 'R Ch';
        handles.DetectObjectsGChGroup.Visible = 'on';
        handles.DetectObjectsBChGroup.Visible = 'on';
    case 'Gray'
        handles.DetectObjectsRChGroup.Title   = 'Gray Ch';
        handles.DetectObjectsGChGroup.Visible = 'off';
        handles.DetectObjectsBChGroup.Visible = 'off';
        
end
end


function postUpdateDetectObjects(hObject)
f = getFig(hObject);
handles = guihandles(getFig(hObject));
tmpDetectObjectsSetts  = struct('Method','EdgeWater','DOSetts',{{0,250,1}},...
    'MetricLims',[]);

switch handles.DetectObjectsMethodMenu.Value
    case 1
        tmpDetectObjectsSetts.Method = 'EdgeWater';
        tmpDetectObjectsSetts.DOSetts = {...
            str2double(handles.DetectObjectsEdgeWaterMinSizeEdit.String),...
            str2double(handles.DetectObjectsEdgeWaterMaxSizeEdit.String),...
            str2double(handles.DetectObjectsEdgeWaterThreshEdit.String) };
    case 2
        tmpDetectObjectsSetts.Method = 'ThreshWater';
        tmpDetectObjectsSetts.DOSetts = {...
            str2double(handles.DetectObjectsThreshWaterMinSizeEdit.String),...
            str2double(handles.DetectObjectsThreshWaterMaxSizeEdit.String),...
            handles.DetectObjectsThreshWaterMergeCheck.String,...
            handles.DetectObjectsThreshWaterPostProcCheck.String };
end

switch f.UserData.UploadImagesSetts.ImageType
    case {'RGB','Split'}
        tmpDetectObjectsSetts.MetricLims = [handles.DORMeanCheck.Value,...
            handles.DORStdCheck.Value,handles.DORMedCheck.Value,...
            handles.DORIQRCheck.Value,handles.DORMinCheck.Value,...
            handles.DORMaxCheck.Value,handles.DORTotCheck.Value,...
            handles.DOGrMeanCheck.Value,...
            handles.DOGrStdCheck.Value,handles.DOGrMedCheck.Value,...
            handles.DOGrIQRCheck.Value,handles.DOGrMinCheck.Value,...
            handles.DOGrMaxCheck.Value,handles.DOGrTotCheck.Value,...
            handles.DOBMeanCheck.Value,...
            handles.DOBStdCheck.Value,handles.DOBMedCheck.Value,...
            handles.DOBIQRCheck.Value,handles.DOBMinCheck.Value,...
            handles.DOBMaxCheck.Value,handles.DOBTotCheck.Value,...
            handles.DOGAreaCheck.Value,handles.DOGPerimCheck.Value,...
            handles.DOGCircCheck.Value,handles.DOGXCheck.Value,...
            handles.DOGYCheck.Value,handles.DOGAngleCheck.Value,...
            handles.DOGDensCheck.Value;...
            str2double(handles.DORMeanMin.String),str2double(handles.DORStdMin.String),...
            str2double(handles.DORMedMin.String),str2double(handles.DORIQRMin.String),...
            str2double(handles.DORMinMin.String),str2double(handles.DORMaxMin.String),...
            str2double(handles.DORTotMin.String),...
            str2double(handles.DOGrMeanMin.String),str2double(handles.DOGrStdMin.String),...
            str2double(handles.DOGrMedMin.String),str2double(handles.DOGrIQRMin.String),...
            str2double(handles.DOGrMinMin.String),str2double(handles.DOGrMaxMin.String),...
            str2double(handles.DOGrTotMin.String),...
            str2double(handles.DOBMeanMin.String),str2double(handles.DOBStdMin.String),...
            str2double(handles.DOBMedMin.String),str2double(handles.DOBIQRMin.String),...
            str2double(handles.DOBMinMin.String),str2double(handles.DOBMaxMin.String),...
            str2double(handles.DOBTotMin.String),...
            str2double(handles.DOGAreaMin.String),str2double(handles.DOGPerimMin.String),...
            str2double(handles.DOGCircMin.String),str2double(handles.DOGXMin.String),...
            str2double(handles.DOGYMin.String),str2double(handles.DOGAngleMin.String),...
            str2double(handles.DOGDensMin.String);...
            str2double(handles.DORMeanMax.String),str2double(handles.DORStdMax.String),...
            str2double(handles.DORMedMax.String),str2double(handles.DORIQRMax.String),...
            str2double(handles.DORMinMax.String),str2double(handles.DORMaxMax.String),...
            str2double(handles.DORTotMax.String),...
            str2double(handles.DOGrMeanMax.String),str2double(handles.DOGrStdMax.String),...
            str2double(handles.DOGrMedMax.String),str2double(handles.DOGrIQRMax.String),...
            str2double(handles.DOGrMinMax.String),str2double(handles.DOGrMaxMax.String),...
            str2double(handles.DOGrTotMax.String),...
            str2double(handles.DOBMeanMax.String),str2double(handles.DOBStdMax.String),...
            str2double(handles.DOBMedMax.String),str2double(handles.DOBIQRMax.String),...
            str2double(handles.DOBMinMax.String),str2double(handles.DOBMaxMax.String),...
            str2double(handles.DOBTotMax.String),...
            str2double(handles.DOGAreaMax.String),str2double(handles.DOGPerimMax.String),...
            str2double(handles.DOGCircMax.String),str2double(handles.DOGXMax.String),...
            str2double(handles.DOGYMax.String),str2double(handles.DOGAngleMax.String),...
            str2double(handles.DOGDensMax.String) ];
    case 'Gray'
        tmpDetectObjectsSetts.MetricLims = [handles.DORMeanCheck.Value,...
            handles.DORStdCheck.Value,handles.DORMedCheck.Value,...
            handles.DORIQRCheck.Value,handles.DORMinCheck.Value,...
            handles.DORMaxCheck.Value,handles.DORTotCheck.Value,...
            handles.DOGAreaCheck.Value,handles.DOGPerimCheck.Value,...
            handles.DOGCircCheck.Value,handles.DOGXCheck.Value,...
            handles.DOGYCheck.Value,handles.DOGAngleCheck.Value,...
            handles.DOGDensCheck.Value;...
            str2double(handles.DORMeanMin.String),str2double(handles.DORStdMin.String),...
            str2double(handles.DORMedMin.String),str2double(handles.DORIQRMin.String),...
            str2double(handles.DORMinMin.String),str2double(handles.DORMaxMin.String),...
            str2double(handles.DORTotMin.String),...
            str2double(handles.DOGAreaMin.String),str2double(handles.DOGPerimMin.String),...
            str2double(handles.DOGCircMin.String),str2double(handles.DOGXMin.String),...
            str2double(handles.DOGYMin.String),str2double(handles.DOGAngleMin.String),...
            str2double(handles.DOGDensMin.String);...
            str2double(handles.DORMeanMax.String),str2double(handles.DORStdMax.String),...
            str2double(handles.DORMedMax.String),str2double(handles.DORIQRMax.String),...
            str2double(handles.DORMinMax.String),str2double(handles.DORMaxMax.String),...
            str2double(handles.DORTotMax.String),...
            str2double(handles.DOGAreaMax.String),str2double(handles.DOGPerimMax.String),...
            str2double(handles.DOGCircMax.String),str2double(handles.DOGXMax.String),...
            str2double(handles.DOGYMax.String),str2double(handles.DOGAngleMax.String),...
            str2double(handles.DOGDensMax.String) ];
end

f.UserData.DetectObjectsSetts = tmpDetectObjectsSetts;
end