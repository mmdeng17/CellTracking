function viewTracking(app)

% Define constants
global COLORS metrics time last;
time = 0;
last = 0;
COLORS = {[.5 .5 1],'c','m','y',[1 .5 .5],[.5 1 .5]};
FULL_FILL = [0 0 1 1];
TOP_FILL = [.02 .51 .96 .47];
BOT_FILL = [.02 .02 .96 .47];
LEFT_FILL = [.02 .02 .47 .96];
RIGHT_FILL = [.51 .02 .47 .96];
metrics = {'Nuc Mean';'Nuc Median';'Nuc Std Dev';'Nuc Min';'Nuc Max';...
    'Track1 Mean';'Track1 Median';'Track1 Std Dev';'Track1 Min';'Track1 Max';
    'Track2 Mean';'Track2 Median';'Track2 Std Dev';'Track2 Min';'Track2 Max';
    'Area';'Perimeter';'Circularity';'X Position';'Y Position';'Local Density';'Orientation';'Tracks'};
pauseim = [zeros(12,2) 256*.85*ones(12,6) zeros(12,2)];
pauseim = uint8(cat(3,pauseim,pauseim,pauseim));
[tmp1,tmp2] = meshgrid(0:10,0:12);
playim = ~(tmp2>(7/12)*tmp1 & tmp2<(12-(7/12)*tmp1));
playim = uint8(cat(3,256*.85*playim,256*.85*playim,256*.85*playim));
fendim = [playim(:,:,1) 256*.85*ones(13,1) zeros(13,2)];
fendim = cat(3,fendim,fendim,fendim);
bendim = cat(3,fliplr(fendim(:,:,1)),fliplr(fendim(:,:,1)),fliplr(fendim(:,:,1)));
[tmp1,tmp2] = meshgrid(0:7,0:12);
bkdim = ~(tmp2<(8.5/12)*(tmp1+9) & tmp2>(12-(8.5/12)*(tmp1+9)));
bkdim = [bkdim ones(13,2) bkdim];
bkdim = uint8(cat(3,256*.85*bkdim,256*.85*bkdim,256*.85*bkdim));
fwdim = cat(3,fliplr(bkdim(:,:,1)),fliplr(bkdim(:,:,1)),fliplr(bkdim(:,:,1)));

% Define app properties
Props = struct('CurrFrame',1,'CurrTracks',[],'CurrMets',[],'CurrOuts',[],...
    'CurrResize',[],'ResizeLimit',[],'ResizePos',[0 0 0 0],'CurrPlots',[],...
    'NewBounds',{cell(app.FileSettings.NFrames,1)});
DispSetts = struct('Change',0,'HistData',{cell(app.FileSettings.NFrames,1)},...
    'Ch1',1,'Ch1Min',0,'Ch1Max',255,...
    'Ch2',1,'Ch2Min',0,'Ch2Max',255,...
    'Ch3',1,'Ch3Min',0,'Ch3Max',255);
ImContrSetts = struct('DispTraj',1,'DispOther',1,'DispTrail',0,'TrailLength',0);
DataContrSetts = struct('CurrTrack',[],'NextTrack',[],'CurrFrames',[],'Action',[],...
    'Enable',0,'Last',[]);
if numel(app.Images)>=8
    ImCache = struct('Enable',1,'NBlocks',max(1,ceil(log2(numel(app.Images)))-4),...
        'Blocks',[],'Images',[],'MRU',[]);
    ImCache.MRU = 1:(ImCache.NBlocks-1);
    ImCache.Blocks = zeros(ImCache.NBlocks,1);
    ImCache.Image = cell(ImCache.NBlocks,1);
else
    ImCache = struct('Enable',0);
end
ImCache.Enable = 0;


% Create GUI
x = 1330;
y = 685;
f = figure('name','Cell Tracking Viewer','Visible','off','Position',[0,0,x,y],...
    'Toolbar','figure','Menu','none',...
    'WindowButtonDownFcn',{@clickFcn},'WindowButtonMotionFcn',{@mouseMoveFcn},'WindowButtonUpFcn',{@unclickFcn});
set(f,'Units','normalized')

% View controls
hView(1) = uibuttongroup('Parent',f);
hView(2) = axes('Parent',hView(1),'XTick',[],'YTick',[]);
hView(3) = axes('Parent',hView(1));
hView(4) = uicontrol('Parent',hView(1),'Style','slider','Min',0,...
    'Max',1,'Value',0,'Callback',{@updateFields},...
    'SliderStep',[.1 .2]);
hView(5) = uitable('Parent',hView(1),'Visible','off','Data',[],...
    'ColumnWidth',{45},'CellSelectionCallback',{@updateFields},...
    'CellEditCallback',{@changeFields});
viewPos = [0 0 .59 1;.02 .49 .96 .50;.1 .05 .85 .385;.07 .46 .92 .02;.1 .05 .85 .385];
for i=1:numel(hView)
    hView(i).Units = 'normalized';
    hView(i).Position = viewPos(i,:);
end

% Select controls
hSelect(1) = uibuttongroup('Parent',f);
hSelect(2) = uitable('Parent',hSelect(1),'RowName',[],'ColumnName',{'Track'},...
    'ColumnFormat',{'char','logical'},'ColumnWidth',{75},'ColumnEditable',[false true],...
    'CellSelectionCallback',{@updateFields});
hSelect(3) = uitable('Parent',hSelect(1),'RowName',[],'ColumnName',[],...
    'ColumnFormat',{'char'},'ColumnWidth',{85},'CellSelectionCallback',{@updateFields});
hSelect(4) = uibuttongroup('Parent',hSelect(1),'Title','Navigation');
hSelect(5) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',bendim);
hSelect(6) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',bkdim);
hSelect(7) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',pauseim);
hSelect(8) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',playim);
hSelect(9) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',fwdim);
hSelect(10) = uicontrol('Parent',hSelect(4),'Style','pushbutton','CData',fendim);
hSelect(11) = uicontrol('Parent',hSelect(1),'Style','text','String','Frame: 1',...
    'HorizontalAlignment','left');
selectPos = [.59 0 .14 1;0 .56 1 .44;0 0 1 .44;0 .45 1 .06;.02 .02 .16 .96;...
    .18 .02 .16 .96;.34 .02 .16 .96;.5 .02 .16 .96;.66 .02 .16 .96;...
    .82 .02 .16 .96;0 .51 1 .04];
for i=1:numel(hSelect)
    hSelect(i).Units = 'normalized';
    hSelect(i).Position = selectPos(i,:);
    if ~isempty(find(hSelect([5:10])==hSelect(i),1))
        hSelect(i).Callback = {@updateFields};
    end
end

% Control Controls
hControl(1) = uibuttongroup('Parent',f,'Units','normalized','Position',[.73 0 .27 1]);
hControlTabs = uitabgroup('Parent',hControl(1));
hControlTab(1) = uitab('Parent',hControlTabs,'Title','Bright/Contr');
hControlTab(2) = uitab('Parent',hControlTabs,'Title','Im. Contr.');
hControlTab(3) = uitab('Parent',hControlTabs,'Title','Data Contr.');
hControlTab(4) = uitab('Parent',hControlTabs,'Title','Output Contr.');

% Image Display Controls
hImDisp(1) = uibuttongroup('Parent',hControlTab(1));
imDispPos = [FULL_FILL];
for i=1:numel(hImDisp)
    hImDisp(i).Units = 'normalized';
    hImDisp(i).Position = imDispPos(i,:);
end
tmp = .67;
tmpNames = {'Ch1','Ch2','Ch3'};
tmpFields = {'Ch1','Ch1Min','Ch1Max';'Ch2','Ch2Min','Ch2Max';'Ch3','Ch3Min','Ch3Max';};
for i=1:3
    hImDisp(end+1) = uibuttongroup('Parent',hImDisp(1),'Title',tmpNames{i});
    hImDisp(end+1) = uicontrol('Parent',hImDisp(2+5*(i-1)),'Style','checkbox',...
        'Value',DispSetts.(tmpFields{i,1}),'String','','Callback',@updateFields);
    hImDisp(end+1) = axes('Parent',hImDisp(2+5*(i-1)),'YTick',[],'XLim',[0 255]);
    hImDisp(end+1) = uicontrol('Parent',hImDisp(2+5*(i-1)),'Style','slider',...
        'Min',0,'Max',255,'Value',DispSetts.(tmpFields{i,2}),...
        'Callback',@updateFields);
    hImDisp(end+1) = uicontrol('Parent',hImDisp(2+5*(i-1)),'Style','slider',...
        'Min',0,'Max',255,'Value',DispSetts.(tmpFields{i,3}),...
        'Callback',@updateFields);
    for i=1:5
        hImDisp(end-5+i).Units = 'normalized';
    end
    hImDisp(end-4).Position = [0 tmp 1 .32];
    hImDisp(end-3).Position = [0 .9 .07 .07];
    hImDisp(end-2).Position = [.1 .34 .83 .64];
    hImDisp(end-1).Position = [.054 .11 .935 .1];
    hImDisp(end).Position = [.054 .01 .935 .1];
    tmp = tmp-.33;
end

% Trajectory display controls
hImContr(1) = uibuttongroup('Parent',hControlTab(2));
hImContr(2) = uibuttongroup('Parent',hImContr(1),'Title','Show Trajectories');
hImContr(3) = uicontrol('Parent',hImContr(2),'Style','checkbox',...
    'Value',ImContrSetts.DispTraj);
hImContr(4) = uibuttongroup('Parent',hImContr(1),'Title','Show Unlinked');
hImContr(5) = uicontrol('Parent',hImContr(4),'Style','checkbox',...
    'Value',ImContrSetts.DispOther);
hImContr(6) = uibuttongroup('Parent',hImContr(1),'Title','Show Trails');
hImContr(7) = uicontrol('Parent',hImContr(6),'Style','checkbox',...
    'Value',ImContrSetts.DispTrail);
hImContr(8) = uicontrol('Parent',hImContr(6),'Style','edit',...
    'String',num2str(ImContrSetts.TrailLength),'HorizontalAlignment','right');
% hImContr(9) = uibuttongroup('Parent',hImContr(1),'Title','Navigation');
% hImContr(10) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',bendim);
% hImContr(11) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',bkdim);
% hImContr(12) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',pauseim);
% hImContr(13) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',playim);
% hImContr(14) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',fwdim);
% hImContr(15) = uicontrol('Parent',hImContr(9),'Style','pushbutton','CData',fendim);
imContrPos = [0 0 1 1;.02 .91 .96 .08;FULL_FILL;.02 .82 .96 .08;FULL_FILL;...
    .02 .73 .96 .08;0 0 .15 1;.20 .05 .75 .93];%;.02 .62 .96 .06;.02 .02 .16 .96;...
    %.18 .02 .16 .96;.34 .02 .16 .96;.5 .02 .16 .96;.66 .02 .16 .96;.82 .02 .16 .96];
for i=1:numel(hImContr)
    hImContr(i).Units = 'normalized';
    hImContr(i).Position = imContrPos(i,:);
    
    if ~isempty(find(hImContr([3 5 7 8])==hImContr(i),1))
        hImContr(i).Callback = {@updateFields};
    end
end

% Data controls
hDataContr(1) = uibuttongroup('Parent',hControlTab(3));
hDataContr(2) = uibuttongroup('Parent',hDataContr(1),'Title','Data View');
hDataContr(3) = uicontrol('Parent',hDataContr(2),'Style','popupmenu',...
    'String','Graph|Table');
hDataContr(4) = uibuttongroup('Parent',hDataContr(1),'Title','Table Operations',...
    'Visible','off');
hDataContr(5) = uicontrol('Parent',hDataContr(4),'Style','pushbutton','String','Copy');
hDataContr(6) = uicontrol('Parent',hDataContr(4),'Style','pushbutton','String','Cut');
hDataContr(7) = uicontrol('Parent',hDataContr(4),'Style','pushbutton','String','Paste');
hDataContr(8) = uicontrol('Parent',hDataContr(4),'Style','pushbutton','String','Swap');
hDataContr(9) = uicontrol('Parent',hDataContr(4),'Style','pushbutton','String','Clear');
hDataContr(10) = uibuttongroup('Parent',hDataContr(1),'Title','Motion Detection');
hDataContr(11) = uicontrol('Parent',hDataContr(10),'Style','pushbutton','String','Create Object');
hDataContr(12) = uicontrol('Parent',hDataContr(10),'Style','pushbutton','String','Refactor Motion');
dataContrPos = [0 0 1 1;.02 .9 .96 .08;FULL_FILL;.02 .73 .96 .15;...
    .02 .68 .48 .30;.50 .68 .48 .30;.02 .35 .48 .30;.50 .35 .48 .30;...
    .02 .02 .48 .30;.02 .60 .96 .10;TOP_FILL;BOT_FILL];
for i=1:numel(hDataContr)
    hDataContr(i).Units = 'normalized';
    hDataContr(i).Position = dataContrPos(i,:);
    if (~isempty(find(i==[3 5:9 11 12],1)))
        hDataContr(i).Callback = {@updateFields};
    end
end

% Output controls
hOutputContr(1) = uibuttongroup('Parent',hControlTab(4));
hOutputContr(2) = uibuttongroup('Parent',hOutputContr(1),'Title','Save/Load...');
hOutputContr(3) = uicontrol('Parent',hOutputContr(2),'Style','pushbutton',...
    'String','Save Tracking');
hOutputContr(4) = uicontrol('Parent',hOutputContr(2),'Style','pushbutton',...
    'String','Load Tracking');
hOutputContr(5) = uibuttongroup('Parent',hOutputContr(1),'Title','Export as...');
hOutputContr(6) = uicontrol('Parent',hOutputContr(5),'Style','pushbutton',...
    'String','Export as CSV');
hOutputContr(7) = uicontrol('Parent',hOutputContr(5),'Style','pushbutton',...
    'String','Export as Excel');
outputContrPos = [0 0 1 1;.02 .9 .96 .06;LEFT_FILL;RIGHT_FILL;.02 .8 .96 .06;...
    LEFT_FILL;RIGHT_FILL];
for i=1:numel(hOutputContr)
    hOutputContr(i).Units = 'normalized';
    hOutputContr(i).Position = outputContrPos(i,:);
    if (~isempty(find(i==[3 4 6 7],1)))
        hOutputContr(i).Callback = {@updateFields};
    end
end

handles = struct('View',hView,'Select',hSelect,'Control',[hControlTabs hControlTab hControl],...
    'ImDisp',hImDisp,'ImContr',hImContr,'DataContr',hDataContr,'OutputContr',hOutputContr);

addprop(f,'Handles');
f.Handles = handles;

f.UserData = struct('App',app,'DispSetts',DispSetts,'ImContrSetts',ImContrSetts,...
    'DataContrSetts',DataContrSetts,'Props',Props,'ImCache',ImCache);

f.Visible = 'on';

init(f);
updateImage(f);
updateGraph(f);
updateOutlines(f);
updateHistogram(f);
drawnow;























end


%% Callback Functions

%%

function init(f)
% Function to restore GUI to initial state.
global metrics;
Props = struct('CurrFrame',1,'CurrTracks',[],'CurrMets',[],'CurrOuts',[],...
    'CurrResize',[],'ResizeLimit',[],'ResizePos',[0 0 0 0],'CurrPlots',[],...
    'NewBounds',{cell(f.UserData.App.FileSettings.NFrames,1)});
DispSetts = struct('Change',0,'HistData',{cell(f.UserData.App.FileSettings.NFrames,1)},...
    'Ch1',1,'Ch1Min',0,'Ch1Max',255,...
    'Ch2',1,'Ch2Min',0,'Ch2Max',255,...
    'Ch3',1,'Ch3Min',0,'Ch3Max',255);
ImContrSetts = struct('DispTraj',1,'DispOther',1,'DispTrail',0,'TrailLength',0);
DataContrSetts = struct('CurrTrack',[],'NextTrack',[],'CurrFrames',[],'Action',[],...
    'Enable',0,'Last',[]);
if numel(f.UserData.App.Images)>=8
    ImCache = struct('Enable',1,'NBlocks',max(1,ceil(log2(numel(f.UserData.App.Images)))-4),...
        'Blocks',[],'Images',[],'MRU',[]);
    ImCache.MRU = 1:(ImCache.NBlocks-1);
    ImCache.Blocks = zeros(ImCache.NBlocks,1);
    ImCache.Image = cell(ImCache.NBlocks,1);
else
    ImCache = struct('Enable',0);
end
ImCache.Enable = 0;

f.UserData = struct('App',f.UserData.App,'DispSetts',DispSetts,'ImContrSetts',ImContrSetts,...
    'DataContrSetts',DataContrSetts,'Props',Props,'ImCache',ImCache);

app = f.UserData.App;
handles = f.Handles;
hView = handles.View;
hSelect = handles.Select;
hImDisp = handles.ImDisp;
hImContr = handles.ImContr;
hDataContr = handles.DataContr;
hOutputContr = handles.OutputContr;
set(hView(4),'Min',1,'Max',app.FileSettings.NFrames,'Value',Props.CurrFrame,...
    'SliderStep',[1/(app.FileSettings.NFrames-1) 2/(app.FileSettings.NFrames-1)]);
set(hView(5),'Data',[],'RowName',{(1:size(app.DataArray,1))'},...
    'ColumnName',{(1:app.FileSettings.NFrames)'});
set(hSelect(2),'Data',[cellfun(@(x) num2str(x),num2cell((1:size(app.TrackData,1))'),'UniformOutput',0) repmat({false},size(app.TrackData,1),1)]);
set(hSelect(3),'Data',metrics(logical([app.FcnSettings.ObjMets(1,:) 1])))

end


%% Mouse callbacks
function clickFcn(h,e)
currPos = get(h,'CurrentPoint');

set(h,'Units','pixels')
fPos = get(h,'Position');
set(h,'Units','normalized');
imSize = size(h.UserData.App.Images{1});
boxPos = get(h.Handles.View(1),'Position');
axPos = get(h.Handles.View(2),'Position');
figPos = [boxPos(1)+boxPos(3)*axPos(1) boxPos(2)+boxPos(4)*axPos(2)...
    boxPos(3)*axPos(3) boxPos(4)*axPos(4)];
imPos = [figPos(1)*fPos(3) figPos(2)*fPos(4) figPos(3)*fPos(3) figPos(4)*fPos(4)];
if imPos(3)/imPos(4)>imSize(1)/imSize(2)
    newX = imPos(4)*imSize(1)/imSize(2);
    imPos(1) = imPos(1)+0.5*(imPos(3)-newX);
    imPos(3) = newX;
    limit = 'Y';
else
    newY = imPos(3)*imSize(2)/imSize(1);
    imPos(2) = imPos(2)+.5*(imPos(4)-newY);
    imPos(4) = newY;
    limit = 'X';
end
imPos = [imPos(1)/fPos(3) imPos(2)/fPos(4) imPos(3)/fPos(3) imPos(4)/fPos(4)];

xLim = [imPos(1)-.03*imPos(3) imPos(1)+.06*imPos(3) imPos(1)+.94*imPos(3) imPos(1)+1.03*imPos(3)];
yLim = [imPos(2)-.03*imPos(4) imPos(2)+.06*imPos(4) imPos(2)+.94*imPos(4) imPos(2)+1.03*imPos(4)];

xL = currPos(1)>xLim(1)&&currPos(1)<xLim(2);
xR = currPos(1)>xLim(3)&&currPos(1)<xLim(4);
yB = currPos(2)>yLim(1)&&currPos(2)<yLim(2);
yT = currPos(2)>yLim(3)&&currPos(2)<yLim(4);

if (xL||xR)&&(yB||yT)
    h.UserData.Props.CurrResize = 'XY';
elseif xL||xR
    h.UserData.Props.CurrResize = 'X';
elseif yB||yT
    h.UserData.Props.CurrResize = 'Y';
end
if (xL||xR||yB||yT)
    h.UserData.Props.ResizeLimit = limit;
    h.UserData.Props.ResizePos = imPos;
end

end

function mouseMoveFcn(h,e)
hView = h.Handles.View;
if ~isempty(h.UserData.Props.CurrResize)
    currPoint = get(h,'CurrentPoint');
    imSize = size(h.UserData.App.Images{1});
    switch h.UserData.Props.CurrResize
        case 'X'
        case 'Y'
            yLim = h.UserData.Props.ResizePos(2)-2*imSize(2)/imSize(1)*(h.UserData.Props.ResizePos(1)-0.0118);
            if currPoint(2)>max(yLim,.15)&& currPoint(2)<.75
                currPos = get(hView(2),'Position');
                set(hView(2),'Position',[currPos(1) currPoint(2) currPos(3) .99-currPoint(2)])
                currPos = get(hView(4),'Position');
                set(hView(4),'Position',[currPos(1) currPoint(2)-.03 currPos(3) .02])
                currPos = get(hView(3),'Position');
                set(hView(3),'Position',[currPos(1) .05 currPos(3) currPoint(2)-.105])
                set(hView(5),'Position',[currPos(1) .05 currPos(3) currPoint(2)-.105])
            end
        case 'XY'
    end
end
end

function unclickFcn(h,e)
h.UserData.Props.CurrResize = [];
end


%% GUI field callbacks
function updateFields(h,e)
% Function to update selected field in GUI.
f = getFig(h);
handles = f.Handles;
hView = handles.View;
hSelect = handles.Select;
hImDisp = handles.ImDisp;
hImContr = handles.ImContr;
hDataContr = handles.DataContr;
hOutputContr = handles.OutputContr;

if ~isempty(find(hView==h,1))
    updateViewFields(h,e,f)
elseif ~isempty(find(hSelect==h,1))
    updateSelectFields(h,e,f)
elseif ~isempty(find(hImDisp==h,1))
    updateImDispFields(h,e,f)
elseif ~isempty(find(hImContr==h,1))
    updateImContrFields(h,e,f)
elseif ~isempty(find(hDataContr==h,1))
    updateDataContrFields(h,e,f)
elseif ~isempty(find(hOutputContr==h,1))
    updateOutputContrFields(h,e,f)
end

end

function updateViewFields(h,e,f)
handles = f.Handles;
hView = handles.View;
hSelect = handles.Select;
DataContrSetts = f.UserData.DataContrSetts;

switch h
    case hView(4)
        if h.Value==f.UserData.Props.CurrFrame
            return
        end
        f.UserData.Props.CurrFrame = round(h.Value);
        set(hSelect(11),'String',sprintf('Frame: %i',f.UserData.Props.CurrFrame));
    case hView(5)
        if isempty(e.Indices)
            return
        end
        if ~DataContrSetts.Enable
            DataContrSetts.CurrTrack = e.Indices(1,1);
            DataContrSetts.CurrFrames = unique(e.Indices(:,2));
        else
            DataContrSetts.NextTrack = e.Indices(1,1);
        end
end

f.UserData.DataContrSetts = DataContrSetts;

tic
updateImage(f);
a = toc;
tic
updateGraph(f);
b = toc;
tic
updateOutlines(f);
c = toc;
tic
updateTable(f);
d = toc;
tic
updateHistogram(f);
e = toc;
tic
drawnow;
f = toc;
[a b c d e f];
end

function updateSelectFields(h,e,f)
% Function to update select controls
global time last;

handles = f.Handles;
hSelect = handles.Select;
hView = handles.View;

switch h
    case hSelect(2)
        t = now();
		tmp = unique(e.Indices(e.Indices(:,2)==1,1));
        f.UserData.Props.CurrTracks = tmp(1:min(6,numel(tmp)));
        if (t-time)*(3600*24)<=.5 && f.UserData.Props.CurrTracks(1)==last
            selTracks = get(hSelect(2),'Data');
            selTracks = selTracks(:,2);
            selTracks(last) = 1;
            [cellfun(@(x) num2str(x),num2cell((1:size(app.TrackData,1))'),'UniformOutput',0) selTracks]
        end
        time = now;
        last = f.UserData.Props.CurrTracks(1);
        updateImage(f);
        updateOutlines(f);
    case hSelect(3)
        f.UserData.Props.CurrMets = e.Indices(1,1);
    case hSelect(5)
        set(hView(4),'Value',1)
        f.UserData.Props.CurrFrame = 1;
        set(hSelect(11),'String',sprintf('Frame: %i',f.UserData.Props.CurrFrame));
        updateImage(f);
        updateOutlines(f);
        updateHistogram(f);
    case hSelect(6)
    case hSelect(7)
    case hSelect(8)
    case hSelect(9)
    case hSelect(10)
        set(hView(4),'Value',f.UserData.App.FileSettings.NFrames);
        f.UserData.Props.CurrFrame = f.UserData.App.FileSettings.NFrames;
        set(hSelect(11),'String',sprintf('Frame: %i',f.UserData.Props.CurrFrame));
        updateImage(f);
        updateOutlines(f);
        updateHistogram(f);
end

updateGraph(f);
updateTable(f);
end

function updateImDispFields(h,e,f)
% Function to update image display fields
handles = f.Handles;
hImDisp = handles.ImDisp;
DispSetts = f.UserData.DispSetts;
DispSetts.Change = find(sum(hImDisp([3 8 13;5 10 15;6 11 16])==h)~=0,1);

switch h
    case {hImDisp(3),hImDisp(8),hImDisp(13)}
        DispSetts.(['Ch' num2str(find(hImDisp([3 8 13])==h,1))]) = get(h,'Value');
    case {hImDisp(5),hImDisp(10),hImDisp(15)}
        if get(h,'Value')>253
            set(h,'Value',253);
        end
        hCurrMax = hImDisp(5*find(hImDisp([5 10 15])==h)+1);
        if get(hCurrMax,'Value')<(h.Value+2);
            set(hCurrMax,'Value',h.Value+2);
        end
        DispSetts.(['Ch' num2str(find(hImDisp([5 10 15])==h,1)) 'Min']) = get(h,'Value');
    case {hImDisp(6),hImDisp(11),hImDisp(16)}
        if get(h,'Value')<3
            set(h,'Value',3);
        end
        hCurrMin = hImDisp(5*find(hImDisp([6 11 16])==h));
        if get(hCurrMin,'Value')>(h.Value-2);
            set(hCurrMin,'Value',h.Value-2);
        end
        DispSetts.(['Ch' num2str(find(hImDisp([6 11 16])==h,1)) 'Max']) = get(h,'Value');
end

f.UserData.DispSetts = DispSetts;
updateImage(f);
updateOutlines(f);
end

function updateImContrFields(h,e,f)
% Function to update Image Control Settings
handles = f.Handles;
hView = handles.View;
hImContr = handles.ImContr;
ImContrSetts = f.UserData.ImContrSetts;

switch h
    case hImContr(3)
        ImContrSetts.DispTraj = get(h,'Value');
    case hImContr(5)
        ImContrSetts.DispOther = get(h,'Value');
    case hImContr(7)
        ImContrSetts.DispTrail = get(h,'Value');
    case hImContr(8)
        ImContrSetts.TrailLength = str2double(get(h,'String'));
    case hImContr(10)
        set(hView(4),'Value',1)
        f.UserData.Props.CurrFrame = 1;
    case hImContr(11)
    case hImContr(12)
    case hImContr(13)
    case hImContr(14)
    case hImContr(15)
        set(hView(4),'Value',f.UserData.App.FileSettings.NFrames)
        f.UserData.Props.CurrFrame = f.UserData.App.FileSettings.NFrames;
end

f.UserData.ImContrSetts = ImContrSetts;

switch h
    case {hImContr(3),hImContr(5),hImContr(7),hImContr(8)}
        updateOutlines(f);
    case {hImContr(10),hImContr(11),hImContr(12),hImContr(13),hImContr(14),hImContr(15)}
        updateImage(f);
        updateOutlines(f);
        updateGraph(f);
end
end

function updateDataContrFields(h,e,f)
% Function to update data control fields.
app = f.UserData.App;
handles = f.Handles;
hView = handles.View;
hDataContr = handles.DataContr;
DataContrSetts = f.UserData.DataContrSetts;

switch h
    case hDataContr(3)
        if get(h,'Value')==1
            set(hView(3),'Visible','on')
            set(hDataContr(4),'Visible','off')
            set(hView(5),'Visible','off')
        else
            set(hView(3),'Visible','off')
            set(hDataContr(4),'Visible','on')
            set(hView(5),'Visible','on')
        end
    case hDataContr(5)
        DataContrSetts.Action = 'C';
        DataContrSetts.Enable = 1;
    case hDataContr(6)
        DataContrSetts.Action = 'X';
        DataContrSetts.Enable = 1;
    case hDataContr(7)
        tmpData = app.DataArray;
        nMets = size(tmpData,3);
        for i=1:nMets
            tmpData(DataContrSetts.NextTrack,DataContrSetts.CurrFrames,i) = ...
                tmpData(DataContrSetts.CurrTrack,DataContrSetts.CurrFrames,i);
        end
        if strcmp(DataContrSetts.Action,'X')
            for i=1:nMets
                tmpData(DataContrSetts.CurrTrack,DataContrSetts.CurrFrames,i) = 0;
            end
        end
        app.updateData(tmpData);
        DataContrSetts = struct('CurrTrack',[],'NextTrack',[],'CurrFrames',[],'Action',[],...
            'Enable',0,'Last',[]);
    case hDataContr(8)
        tmpData = app.DataArray;
        nMets = size(tmpData,3);
        for i=1:nMets
            tmp = tmpData(DataContrSetts.CurrTrack,DataContrSetts.CurrFrames,i);
            tmpData(DataContrSetts.CurrTrack,DataContrSetts.CurrFrames,i) = ...
                tmpData(DataContrSetts.NextTrack,DataContrSetts.CurrFrames,i);
            tmpData(DataContrSetts.NextTrack,DataContrSetts.CurrFrames,i) = tmp;
        end
        app.updateData(tmpData);
        DataContrSetts = struct('CurrTrack',[],'NextTrack',[],'CurrFrames',[],'Action',[],...
            'Enable',0,'Last',[]);
    case hDataContr(9)
        tmpData = app.DataArray;
        nMets = size(tmpData,3);
        for i=1:nMets
            tmpData(DataContrSetts.CurrTrack,DataContrSetts.CurrFrames,i) = 0;
        end
        app.updateData(tmpData);
        DataContrSetts = struct('CurrTrack',[],'NextTrack',[],'CurrFrames',[],'Action',[],...
            'Enable',0,'Last',[]);
    case hDataContr(11)
        currFrame = f.UserData.Props.CurrFrame;
        Image = app.Images{currFrame};
        DispSetts = f.UserData.DispSetts;
        dispIm = getDispIm(Image,DispSetts);
        fTmp = figure('Name','Draw new boundary');
        imshow(uint8(dispIm));
        
        [tmpMask,x,y] = roipoly;
        if isempty(x)||isempty(y)
            try
                close(fTmp)
            end
            return
        end
        
        tmpBound = [round(y),round(x)];
        hold on
        plot(tmpBound(:,2),tmpBound(:,1),'m-')
        hold off
        
        keep = questdlg('Confirm new object creation.','','Yes','Cancel','Yes');
        close(fTmp)
        switch keep
            case 'Yes'
                singleCC = struct('Connectivity',8,'ImageSize',size(app.Images{1}(:,:,1)),...
                    'NumObjects',1,'PixelIdxList',[]);
                singleCC.PixelIdxList{end+1} = find(tmpMask==1);
                singleData = quickMeasBound(f,singleCC,app.Images{currFrame});
                app.addData(currFrame,singleData);
                app.addBound(currFrame,tmpBound);
%                 for i=1:numel(app.Data{currFrame})
%                     app.Data{currFrame}{i} = [app.Data{currFrame}{i};singleData{i}];
%                 end
                
                if (isempty(f.UserData.Props.NewBounds{currFrame}))
                    newCC = struct('Connectivity',8,'ImageSize',size(app.Images{1}(:,:,1)),...
                        'NumObjects',1,'PixelIdxList',[]);
                    newCC.PixelIdxList{end+1} = find(tmpMask==1);
                    f.UserData.Props.NewBounds{currFrame} = newCC;
                else
                    f.UserData.Props.NewBounds{currFrame}.NumObjects = ...
                        f.UserData.Props.NewBounds{currFrame}.NumObjects+1;
                    f.UserData.Props.NewBounds{currFrame}.PixelIdxList{end+1} = ...
                        find(tmpMask==1);
                end
            case 'Cancel'
        end
        updateImage(f);
        updateOutlines(f);
    case hDataContr(12)
        
end

f.UserData.App = app;
f.UserData.DataContrSetts = DataContrSetts;

updateGraph(f);
updateTable(f);
end

function updateOutputContrFields(h,e,f)
% Function to update output control fields

global metrics;

app = f.UserData.App;
handles = f.Handles;
hSelect = handles.Select;
hOutputContr = handles.OutputContr;

switch h
    case hOutputContr(3)
        measBounds(f);
        
        if isempty(app.SaveSettings.FileName)
            currPath = app.SaveSettings.FilePath;
        else
            currPath = fullfile(app.SaveSettings.FilePath,app.SaveSettings.FileName);
        end
        [names,path] = uiputfile({'*.mat','MAT Files';'*.*','All Files'},...
            'Choose tracking file to save:',currPath);
        if ~isequal(names,0)
            app.SaveSettings.FileName = names;
            app.SaveSettings.FilePath = path;
            save(fullfile(path,names),'app');
            f.UserData.App = app;
            msgbox(['Output data successfully written to ' names]);
        else
        end
    case hOutputContr(4)
        if isempty(app.SaveSettings.FileName)
            currPath = app.SaveSettings.FilePath;
        else
            currPath = fullfile(app.SaveSettings.FilePath,app.SaveSettings.FileName);
        end
        [names,path] = uigetfile({'*.mat','MAT Files';'*.*','All Files'},...
            'Choose tracking file to save:',currPath,'MultiSelect','off');
        if ~isequal(names,0)
            tmpStruct = load(fullfile(path,names));
            f.UserData.App = tmpStruct.app;
            init(f);
            updateImage(f);
            updateOutlines(f);
            updateGraph(f);
            updateTable(f);
            updateHistogram(f);
        else
        end
    case hOutputContr(6)
        measBounds(f);
        
        outData = app.DataArray;
        selTracks = get(hSelect(2),'Data');
        selTracks = cell2mat(selTracks(:,2));
        if sum(selTracks)==0
            return;
        end
        selData = outData(selTracks,:,:);

        [outfile,outpath] = uiputfile({'*.csv','CSV File'});
        if ~isequal(outfile,0)
            [path,file,ext] = fileparts(fullfile(outpath,outfile));
            objMets = f.UserData.App.FcnSettings.ObjMets(1,:);
            metInd = find(objMets);
            for i=1:sum(objMets==1)
                fN = fullfile(path,[file metrics{metInd(i)} ext]);
                csvwrite(fN,selData(:,:,i));
            end
            msgbox(['Output data successfully written to ' outfile]);
        end
    case hOutputContr(7)
end
end

function changeFields(h,e)
% Function to update selected field in GUI.
f = getFig(h);
handles = f.Handles;
hView = handles.View;
hSelect = handles.Select;
hImDisp = handles.ImDisp;
hImContr = handles.ImContr;
hDataContr = handles.DataContr;
hOutputContr = handles.OutputContr;

if ~isempty(find(hView==h,1))
    changeViewFields(h,e,f)
elseif ~isempty(find(hSelect==h,1))
    changeSelectFields(h,e,f)
elseif ~isempty(find(hImDisp==h,1))
    changeImDispFields(h,e,f)
elseif ~isempty(find(hImContr==h,1))
    changeImContrFields(h,e,f)
elseif ~isempty(find(hDataContr==h,1))
    changeDataContrFields(h,e,f)
elseif ~isempty(find(hOutputContr==h,1))
    changeOutputContrFields(h,e,f)
end

end

function changeViewFields(h,e,f)
app = f.UserData.App;
if e.NewData~=0
    mets = find(app.FcnSettings.ObjMets(1,:)==1);
    tmp1Data = app.DataArray;
    for i=1:size(tmp1Data,3)-1
        tmp1Data(e.Indices(1),e.Indices(2),i) = app.Data{e.Indices(2)}{mets(i)}(e.NewData);
    end
    tmp1Data(e.Indices(1),e.Indices(2),end) = e.NewData;
    app.updateData(tmp1Data);
    f.UserData.App = app;
end
end

%% GUI Display callbacks
function updateImage(f)
% Function to update displayed image
currFrame = f.UserData.Props.CurrFrame;

Image = f.UserData.App.Images{currFrame};
handles = f.Handles;
hView = handles.View;

DispSetts = f.UserData.DispSetts;
ImCache = f.UserData.ImCache;

% Cache in progress
index =  8*floor(currFrame/8)+1;
index2 = currFrame-index+1;
if ImCache.Enable
    if ~inCache(ImCache,index)
        disp('Not in cache.')
        ImBlock = cell(8,1);
        for i=index:index+7
            ImBlock{i-index+1} = getDispIm(f.UserData.App.Images{index},DispSetts);
        end
        ImCache = loadBlockCache(ImCache,index,ImBlock);
    end
    dispIm = getBlockCache(ImCache,index,index2);
else
    dispIm = getDispIm(Image,DispSetts);
end

f.UserData.ImCache = ImCache;

set(f,'CurrentAxes',hView(2));
imshow(uint8(dispIm));

end

function updateOutlines(f)
% Function to update image outlines
global COLORS;

app = f.UserData.App;
hView = f.Handles.View;
ImContrSetts = f.UserData.ImContrSetts;
currOuts = f.UserData.Props.CurrOuts;
currTracks = f.UserData.Props.CurrTracks;
currFrame = f.UserData.Props.CurrFrame;
Bounds = app.Bounds{currFrame};
nTracks = size(app.DataArray,1);
arrayTracks = app.DataArray(:,:,end);
hOuts = [];

for i=1:numel(currOuts)
    try
        delete(currOuts(i));
    end
end

showTracks = currTracks(1:min(6,numel(currTracks)));
othTracks = setdiff(1:nTracks,showTracks);
for i=1:numel(showTracks)
    ind = arrayTracks(showTracks(i),currFrame);
    if ind~=0
        set(f,'CurrentAxes',hView(2));
        hold (hView(2),'on')
        hOuts(end+1) = plot(Bounds{ind}(:,2),Bounds{ind}(:,1),'Color',COLORS{rem(i,6)+1});
        hOuts(end+1) = text(mean(Bounds{ind}(:,2)),mean(Bounds{ind}(:,1)),num2str(showTracks(i)),...
            'Color',COLORS{rem(i,6)+1},'HorizontalAlignment','center');
    end
end
for i=1:numel(othTracks)
    ind = arrayTracks(othTracks(i),currFrame);
    if ind~=0 && ImContrSetts.DispTraj
        set(f,'CurrentAxes',hView(2));
        hold (hView(2),'on')
        hOuts(end+1) = plot(Bounds{ind}(:,2),Bounds{ind}(:,1),'Color',[.8,.5,.2]);
        hOuts(end+1) = text(mean(Bounds{ind}(:,2)),mean(Bounds{ind}(:,1)),num2str(othTracks(i)),...
            'Color',[.8,.5,.2],'HorizontalAlignment','center');
    elseif ind~=0 && ImContrSetts.DispOther
        set(f,'CurrentAxes',hView(2));
        hold (hView(2),'on')
        hOuts(end+1) = plot(Bounds{ind}(:,2),Bounds{ind}(:,1),'Color',[1,.1,.3]);
        hOuts(end+1) = text(mean(Bounds{ind}(:,2)),mean(Bounds{ind}(:,1)),num2str(ind),...
            'Color',[1,.1,.3],'HorizontalAlignment','center');
    end
end

othBounds = arrayTracks(:,currFrame);
othBounds = othBounds(othBounds~=0);
othBounds = setdiff(1:numel(Bounds),othBounds);
for i=1:numel(othBounds)
    ind = othBounds(i);
    if ImContrSetts.DispOther
        set(f,'CurrentAxes',hView(2));
        hold (hView(2),'on')
        hOuts(end+1) = plot(Bounds{ind}(:,2),Bounds{ind}(:,1),'Color',[1,.1,.3]);
        hOuts(end+1) = text(mean(Bounds{ind}(:,2)),mean(Bounds{ind}(:,1)),num2str(ind),...
            'Color',[1,.1,.3],'HorizontalAlignment','center');
    end
end

f.UserData.Props.CurrOuts = hOuts;

end

function updateGraph(f)
% Function to update graph
global COLORS

app = f.UserData.App;
hView = f.Handles.View;
currTracks = f.UserData.Props.CurrTracks;
currFrame = f.UserData.Props.CurrFrame;
currMets = f.UserData.Props.CurrMets;
nFrames = app.FileSettings.NFrames;
currPlots = f.UserData.Props.CurrPlots;

hOuts = [];
for i=1:numel(currPlots)
    try
        delete(currPlots(i));
    end
end

if strcmp(get(hView(3),'Visible'),'off')
    return
end

if isempty(currTracks)||isempty(currMets)
    return
end

set(f,'CurrentAxes',hView(3))
hold on
for i=1:min(6,length(currTracks))
    metData = app.DataArray(currTracks(i),:,currMets);
    for j=1:nFrames-1
        if ~isnan(metData(j))&&metData(j)~=0
            hOuts(end+1) = plot(j-1,metData(j),'Color',COLORS{rem(i,6)+1},'Marker','.','MarkerSize',15);
            
            if ~isnan(metData(j+1))&&metData(j+1)~=0
                hOuts(end+1) = line([j-1 j],[metData(j) metData(j+1)],'Color',COLORS{rem(i,6)+1});
            end
        end
    end
    if ~isnan(metData(end))&&metData(end)~=0
        hOuts(end+1) = plot(nFrames-1,metData(end),'Color',COLORS{rem(i,6)+1},'Marker','.','MarkerSize',10);
    end
end

yLim = get(get(f,'CurrentAxes'),'YLim');
hOuts(end+1) = plot((currFrame-1)*ones(1,30),linspace(yLim(1),yLim(2),30),'k--');
set(hView(3),'XLim',[0 nFrames])
hold off
f.UserData.Props.CurrPlots = hOuts;
end

function updateTable(f)
app = f.UserData.App;
hView = f.Handles.View;
currMets = f.UserData.Props.CurrMets;

if strcmp(get(hView(5),'Visible'),'off')
    return
end

set(hView(5),'Data',app.DataArray(:,:,currMets))
if currMets==sum(app.FcnSettings.ObjMets(1,:))+1
    set(hView(5),'ColumnEditable',true);
else
    set(hView(5),'ColumnEditable',false);
end
end

function updateHistogram(f)

currFrame = f.UserData.Props.CurrFrame;
handles = f.Handles;
hImDisp = handles.ImDisp;
DispSetts = f.UserData.DispSetts;

Image = f.UserData.App.Images{currFrame};
if isempty(DispSetts.HistData{currFrame})
    tmpH = histogram(hImDisp(4),reshape(Image(:,:,1),numel(Image(:,:,1)),1),0:2:256,...
        'FaceColor',[1 0 0]);
    histData = [tmpH.Values;tmpH.BinEdges(1:end-1)+tmpH.BinWidth/2];
    tmpH = histogram(hImDisp(9),reshape(Image(:,:,2),numel(Image(:,:,1)),1),0:2:256,...
        'FaceColor',[0 1 0]);
    histData = [histData;tmpH.Values;tmpH.BinEdges(1:end-1)+tmpH.BinWidth/2];
    tmpH = histogram(hImDisp(14),reshape(Image(:,:,3),numel(Image(:,:,1)),1),0:2:256,...
        'FaceColor',[0 0 1]);
    histData = [histData;tmpH.Values;tmpH.BinEdges(1:end-1)+tmpH.BinWidth/2];
    DispSetts.HistData{currFrame} = histData;
else
    histData = DispSetts.HistData{currFrame};
end

area(hImDisp(4),histData(2,:),histData(1,:),'FaceColor','r');
area(hImDisp(9),histData(4,:),histData(3,:),'FaceColor','g');
area(hImDisp(14),histData(6,:),histData(5,:),'FaceColor','b');

set(hImDisp(4),'YTick',[]); set(hImDisp(9),'YTick',[]); set(hImDisp(14),'YTick',[]);
set(hImDisp(4),'XLim',[0 255]); set(hImDisp(9),'XLim',[0 255]); set(hImDisp(14),'XLim',[0 255]);

f.UserData.DispSetts = DispSetts;

end


%% Image cacheing controls
% Function to preload cache
function preloadCache(ImCache,app)
end

% Function to check if image in cache
function yn = inCache(ImCache,index)
disp('inCache')
ImCache.Blocks
index
yn = ~isempty(find(ImCache.Blocks==index,1));
end

% Function to load block into cache
function ImCache = loadBlockCache(ImCache,index,ImBlock)
disp('loadBlockCache')
index
ImCache.Blocks
LRU = setdiff(1:ImCache.NBlocks,ImCache.MRU);
ImCache.Images{LRU} = ImBlock;
ImCache.Blocks(LRU) = index;
end

% Function to get block/image from cache
function Im = getBlockCache(ImCache,index,index2)
disp('getBlockCache')
ImCache.Blocks
ImCache.Images
[index index2]
blockNum = find(ImCache.Blocks==index,1);
if nargin==2
    Im = ImCache.Images{blockNum};
elseif nargin==3
    Im = ImCache.Images{blockNum}{index2};
end

tmp = setdiff(ImCache.MRU,index);
tmp = [index tmp];
ImCache.MRU = tmp(1:ImCache.NBlocks-1);
end


%% Custom boundary controls
% Rough/quick measurement of user-defined boundaries
function data = quickMeasBound(f,singleCC,Image)
% estimate background from low level of Otsu thresholding
if strcmp(f.UserData.App.FcnSettings.BkgdCorr,'Gauss')||strcmp(f.UserData.App.FcnSettings.BkgdCorr,'SKIZ')
    tmp = otsu(Image(:,:,1),2);
    tmp = (tmp==1).*Image(:,:,1);
    backR = median(tmp(:));
    tmp = otsu(Image(:,:,2),2);
    tmp = (tmp==1).*Image(:,:,2);
    backG = median(tmp(:));
    tmp = otsu(Image(:,:,3),2);
    tmp = (tmp==1).*Image(:,:,3);
    backB = median(tmp(:));
else
    backR = 0;
    backG = 0;
    backB = 0;
end

data = cell(1,22);
CCStats = regionprops(singleCC,'PixelIdxList','Area','Perimeter','Centroid','Orientation');
tmp = Image(:,:,1);
data{1} = 255*(mean(tmp(singleCC.PixelIdxList{1}))-backR);
data{2} = 255*(median(tmp(singleCC.PixelIdxList{1}))-backR);
data{3} = 255*(std(tmp(singleCC.PixelIdxList{1})));
data{4} = 255*(min(tmp(singleCC.PixelIdxList{1}))-backR);
data{5} = 255*(max(tmp(singleCC.PixelIdxList{1}))-backR);
tmp = Image(:,:,2);
data{6} = 255*(mean(tmp(singleCC.PixelIdxList{1}))-backG);
data{7} = 255*(median(tmp(singleCC.PixelIdxList{1}))-backG);
data{8} = 255*(std(tmp(singleCC.PixelIdxList{1})));
data{9} = 255*(min(tmp(singleCC.PixelIdxList{1}))-backG);
data{10} = 255*(max(tmp(singleCC.PixelIdxList{1}))-backG);
tmp = Image(:,:,3);
data{11} = 255*(mean(tmp(singleCC.PixelIdxList{1}))-backB);
data{12} = 255*(median(tmp(singleCC.PixelIdxList{1}))-backB);
data{13} = 255*(std(tmp(singleCC.PixelIdxList{1})));
data{14} = 255*(min(tmp(singleCC.PixelIdxList{1}))-backB);
data{15} = 255*(max(tmp(singleCC.PixelIdxList{1}))-backB);
data{16} = CCStats.Area;
data{17} = CCStats.Perimeter;
data{18} = 4*pi*CCStats.Area/CCStats.Perimeter/CCStats.Perimeter;
data{19} = CCStats.Centroid(1);
data{20} = CCStats.Centroid(2);
data{21} = 0;
data{22} = CCStats.Orientation;
end

% Real measurement of user-defined boundaries
function measBounds(f)
app = f.UserData.App;
nFrames = app.FileSettings.NFrames;
for i=1:nFrames
    if isempty(f.UserData.Props.NewBounds{i})
        continue
    else
        newData = getCellData(f.UserData.Props.NewBounds{i},...
            round(255*app.Images{i}),...
            'BkgdCorr',app.FcnSettings.BkgdCorr); % get measurements
        % update all cell data
        for k=1:numel(app.Data{1})
            app.Data{i}{k}(end-f.UserData.Props.NewBounds{i}.NumObjects+1:end) = newData{k};
        end
        
        % update track data
        tmp = numel(app.Data{i}{1})-f.UserData.Props.NewBounds{i}.NumObjects+1;
        mets = find(app.FcnSettings.ObjMets(1,:)==1);
        arraydata = app.DataArray;
        replaceBounds = find((arraydata(:,i,end)-tmp)>=0);
        if ~isempty(replaceBounds)
            for j=1:numel(replaceBounds)
                for k=1:sum(app.FcnSettings.ObjMets(1,:))
                    arraydata(replaceBounds(j),i,k) = newData{mets(k)}(arraydata(replaceBounds(j),i,end)-tmp+1);
                end
            end
        end
        app.updateData(arraydata);
    end
end

f.UserData.App = app;
f.UserData.Props.NewBounds = cell(nFrames,1); % clear new boundaries
end

% Function to get display image from display settings
function dispIm = getDispIm(Image,DispSetts)
dispIm = Image;
for i=1:3
    if DispSetts.(['Ch' num2str(i)])==1
        min = DispSetts.(['Ch' num2str(i) 'Min']);
        max = DispSetts.(['Ch' num2str(i) 'Max']);
        dispIm(:,:,i) = (Image(:,:,i)>=max).*255+(Image(:,:,i)<=min).*0+...
            (Image(:,:,i)<max & Image(:,:,i)>min).*round((Image(:,:,i)-min)/max*255);
    else
        dispIm(:,:,i) = zeros(size(Image(:,:,1)));
    end
end
end


%%
% Function to get root figure of the GUI
function root = getFig(h)
if isprop(h,'Name')
    if strcmp(h.Name,'Cell Tracking Viewer')
        root = h;
        return
    end
end
root = getFig(get(h,'Parent'));
end
