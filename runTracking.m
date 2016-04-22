function app = runTracking
% runTracking Main Settings GUI for running CellTracker
%
% Written by: Michael M. Deng
% Last updated: 4/22/2016

% Constants
FULL_FILL = [.02 .02 .96 .96];
TOP_FILL = [.02 .51 .96 .47];
BOT_FILL = [.02 .02 .96 .47];
LEFT_FILL = [.02 .02 .47 .96];
RIGHT_FILL = [.51 .02 .47 .96];

app = CellTracker();

% Defaults
defFileSetts = struct('FileType','File','FilePath',pwd,'NFrames',0);
defFcnSetts = struct('ImType',1,'ObjCh',1,'Resize',1,'SegAlg',1,'SegAlgSett',{{{25,500,1.0},{5 25 1 0}}},...
    'BkgdCorr',0,'ObjMets',[1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 1 1;zeros(1,22);Inf(1,22)],...
    'MetCost',25,'GapClose',7,'Greedy',1,'TrackMets',[1 0 0 0 0 0 0 0 0 1 0 1 1 1 1;4.5 0 0 0 0 0 0 0 0 15 0 .1 3.5 3.5 12]);
defSaveSetts = struct('YN',0,'FileName','','FilePath',pwd);
app.FileSettings = defFileSetts;
app.FcnSettings = defFcnSetts;
app.SaveSettings = defSaveSetts;

% Create figure
X = 450;
Y = 500;
f = figure('name','Cell Tracking','Visible','off','Position',[150,200,X,Y]);
hStart = uicontrol('Parent',f,'Style','pushbutton','String','Start','Units','normalized',...
    'Position',[.05 .03 .30 .07],'Callback',@start);
set(f,'UserData',app)

hTypeTabs = uitabgroup('Parent',f);
hTypeTab(1) = uitab(hTypeTabs,'Title','Run New...');
hTypeTab(2) = uitab(hTypeTabs,'Title','Run Existing...');
hTypeTab(3) = uitab(hTypeTabs,'Title','Run Multiple...');
hTypeTab(4) = uitab(hTypeTabs,'Title','Start Analysis');

% Link to sub-GUIs
GUIRNT(hTypeTab(1));
GUIRET(hTypeTab(2));
GUIRMT(hTypeTab(3));

hRNT = struct('Handles',[]);
hRET = struct('Handles',[]);
hRMT = struct('Handles',[]);

% Progress sub-GUI
hProgs(1) = uibuttongroup('Parent',hTypeTab(4));
hProgs(2) = uicontrol('Parent',hProgs(1),'Style','edit','String',{''},...
    'HorizontalAlignment','left','Max',2,...
    'BackgroundColor',[1 1 1]);
hProgs(3) = axes('Parent',hProgs(1),'XTick',[],'YTick',[],'XColor',[1 1 1],...
    'YColor',[1 1 1],'XLim',[0 1],'YLim',[0 1]);
hProgs(4) = uicontrol('Parent',hTypeTab(4),'Style','text','String','Time elapsed: 0s',...
    'HorizontalAlignment','left');
hProgs(5) = rectangle('Parent',hProgs(3),'Position',[0 0 0 0],'FaceColor',[0 0 1]);

ProgPos = [0 0 1 1;.05 .48 .9 .5;.05 .38 .9 .05;.05 .25 .9 .08];
for i=1:numel(hProgs)-1
    set(hProgs(i),'Units','Normalized')
    set(hProgs(i),'Position',ProgPos(i,:))
end
hProg = struct('Handles',hProgs);

handles = struct('Tabs',[hTypeTabs hTypeTab],'Prog',hProg);
addprop(f,'Handles');
set(f,'Handles',handles)

uistack(hStart,'top');
pause(.1)
set(f,'Visible','on')






























end


%% Callback functions
function start(h,e)
% Function to start analysis
f = getFig(h);
app = get(f,'UserData');

handles = get(f,'Handles');
curr = get(handles.Tabs(1),'SelectedTab');
set(handles.Tabs(1),'SelectedTab',handles.Tabs(5))
drawnow;

if (isnumeric(curr)&&curr==1)||(curr==handles.Tabs(2))
    RNT(f,app);
elseif (isnumeric(curr)&&curr==2)||(curr==handles.Tabs(3))
    RET(f,app);
elseif (isnumeric(curr)&&curr==3)||(curr==handles.Tabs(4))
    RMT(f,app);
elseif (isnumeric(curr)&&curr==4)||(curr==handles.Tabs(5))
end

end

function RNT(h,app)
% Function to run new tracking.
writeAction(h,['--- ' datestr(datetime('now')) ' ---\n'])
app.init();
app.ready();
if ~app.isReady()
    writeAction(h,'Cell tracking not ready.\nPlease re-check the entered settings.\n')
    return
end

tic
nFrames = app.FileSettings.NFrames;
writeAction(h,'Loading images...');
updateTime(h,0,toc);
app.initLoad();
for i=1:nFrames
    app.loadNextImage();
    updateTime(h,i/nFrames,toc);
end
app.finLoad();
writeAction(h,' Done.\n');

writeAction(h,'Detecting cell objects...');
updateTime(h,0,toc);
for i=1:nFrames
    app.segment(i);
    updateTime(h,i/nFrames,toc);
end
writeAction(h,' Done.\n');

writeAction(h,'Making object measurements...');
updateTime(h,0,toc);
for i=1:nFrames
    app.characterize(i);
    updateTime(h,i/nFrames,toc);
end
writeAction(h,' Done.\n');

writeAction(h,'Linking object trajectories...');
app.initMotion();
updateTime(h,1/(2*nFrames),toc)
for i=1:nFrames-1
    app.linkNext();
    updateTime(h,(i+1)/(2*nFrames),toc);
end
app.restartMotion();
updateTime(h,0.5,toc)
for i=1:nFrames-1
    app.linkNextGap();
    updateTime(h,0.5+i/nFrames,toc);
end
app.finalMotion();
updateTime(h,1,toc)
writeAction(h,' Done.\n');

writeAction(h,'Finalizing algorithm data...');
app.finalize();
writeAction(h,' Done.\n');

writeAction(h,'Saving output data...');
if app.SaveSettings.YN
    save(fullfile(app.SaveSettings.FilePath,app.SaveSettings.FileName),'app');
end
writeAction(h,' Done.\n');

writeAction(h,'Opening tracking GUI...');
writeAction(h,' Done.\n');
updateTime(h,1,toc);
writeAction(h,'--- FINISHED ---')
writeAction(h,'\n')
viewTracking(app);
end

function RET(h,app)
% Function to run existing tracking.
writeAction(h,['--- ' datestr(datetime('now')) ' ---\n'])
tic
writeAction(h,'Loading .mat file...')
tmpStruct = load(fullfile(app.SaveSettings.FilePath,app.SaveSettings.FileName));
app = tmpStruct.app;
updateTime(h,1,toc)
writeAction(h,'Done.\n')
writeAction(h,'Opening tracking GUI...');
writeAction(h,' Done.\n');
writeAction(h,'--- FINISHED ---')
writeAction(h,'\n')
viewTracking(app);
end

function RMT(h,app)
% Function to run multiple trackings.
writeAction(h,['--- ' datestr(datetime('now')) ' ---\n'])
tic
FNs = app.FileNames;
for i=1:app.FileSettings.NFields
    writeAction(h,sprintf('Analysis %i of %i.\n',i,app.FileSettings.NFields))
    if strcmp(app.FcnSettings.ImType,'Split')
        app.FileNames = {sprintf(FNs{1},i),sprintf(FNs{2},i),sprintf(FNs{3},i)};
    else
        app.FileNames = sprintf(FNs,i);
    end
    app.init();
    app.ready();
    if ~app.isReady()
        writeAction(h,'Cell tracking not ready.\nPlease re-check the entered settings.\n')
        return
    end
    
    tic
    nFrames = app.FileSettings.NFrames;
    writeAction(h,'Loading images...');
    updateTime(h,0,toc);
    app.initLoad();
    for j=1:nFrames
        app.loadNextImage();
        updateTime(h,j/nFrames,toc);
    end
	app.finLoad();
    writeAction(h,' Done.\n');
    
    writeAction(h,'Detecting cell objects...');
    updateTime(h,0,toc);
    for j=1:nFrames
        app.segment(j);
        updateTime(h,j/nFrames,toc);
    end
    writeAction(h,' Done.\n');
    
    writeAction(h,'Making object measurements...');
    updateTime(h,0,toc);
    for j=1:nFrames
        app.characterize(j);
        updateTime(h,j/nFrames,toc);
    end
    writeAction(h,' Done.\n');
    
    writeAction(h,'Linking object trajectories...');
    app.initMotion();
    updateTime(h,1/(2*nFrames),toc)
    for j=1:nFrames-1
        app.linkNext();
        updateTime(h,(j+1)/(2*nFrames),toc);
    end
	app.restartMotion();
    updateTime(h,0.5,toc)
    for j=1:nFrames-1
        app.linkNextGap();
        updateTime(h,0.5+j/(2*nFrames),toc);
    end
    app.finalMotion();
    updateTime(h,1,toc)
    writeAction(h,' Done.\n');
    
    writeAction(h,'Finalizing algorithm data...');
    app.finalize();
    writeAction(h,' Done.\n');
    
    writeAction(h,'Saving output data...');
    if app.SaveSettings.YN
        %app.SaveSettings.FileName = sprintf(app.SaveSettings.FileName,i);
        save(fullfile(app.SaveSettings.FilePath,sprintf(app.SaveSettings.FileName,i)),'app');
    end
    writeAction(h,' Done.\n');
    
    writeAction(h,'Opening tracking GUI...');
    writeAction(h,' Done.\n');
    updateTime(h,1,toc);
    writeAction(h,'--- FINISHED ---')
    writeAction('\n')
    viewTracking(app);
end
end

function helpString = getHelp(s)
helpString = '';
end

function writeAction(h,s)
% Function to write to GUI history
f = getFig(h);
handles = get(f,'Handles');
hProgs = handles.Prog.Handles;

currString = get(hProgs(2),'String');
if ~iscell(currString)
    currString = {currString};
end
newStrings = strsplit(s,'\\n');

currString{end} = [currString{end} newStrings{1}];
for i=2:numel(newStrings)
    currString{end+1} = newStrings{i};
end

set(hProgs(2),'String',currString)
drawnow;
end

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

function updateTime(f,prog,t)
% Function to UI controls with time
handles = get(f,'Handles');

set(handles.Prog.Handles(4),'String',['Time elapsed: ' sprintf('%ds',round(t))]);
set(handles.Prog.Handles(5),'Position',[0 0 prog 1]);
drawnow;
end
