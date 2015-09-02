function GUIRMT(Parent)

% Constants
FULL_FILL = [.02 .02 .96 .96];
TOP_FILL = [.02 .51 .96 .47];
BOT_FILL = [.02 .02 .96 .47];
LEFT_FILL = [.02 .02 .47 .96];
RIGHT_FILL = [.51 .02 .47 .96];

% Defaults
defFileSetts = struct('FileNames','','Path',pwd,'NFields',0,'NFrames',0);
defFcnSetts = struct('ImType',1,'ObjCh',1,'Resize',1,'SegAlg',1,'SegAlgSett',{{{25,500,1.0},{5 25 1 0}}},...
    'BkgdCorr',0,'ObjMets',[1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 1 0 1 1 1 1 1;zeros(1,22);Inf(1,22)],...
    'MetCost',25,'GapClose',7,'Greedy',1,'TrackMets',[1 0 0 0 0 0 0 0 0 1 0 1 1 1 1;4.5 0 0 0 0 0 0 0 0 15 0 .1 3.5 3.5 12]);
defSaveSetts = struct('YN',0,'FileName','','Path',pwd);
Setts = struct('File',defFileSetts,'Fcn',defFcnSetts,'Save',defSaveSetts);

%% Run New Tracking section
hRNTTabs = uitabgroup('Parent',Parent,'SelectionChangedFcn',{@changeTab});
hRNTTab(1) = uitab(hRNTTabs,'Title','Images');
hRNTTab(2) = uitab(hRNTTabs,'Title','Object Analysis');
hRNTTab(3) = uitab(hRNTTabs,'Title','Motion Tracking');
hRNTTab(4) = uitab(hRNTTabs,'Title','Data Output');

hImGroup = uibuttongroup('Parent',hRNTTab(1),'Position',[0 .15 1 .85]);
hOAGroup = uibuttongroup('Parent',hRNTTab(2),'Position',[0 .15 1 .85]);
hMTGroup = uibuttongroup('Parent',hRNTTab(3),'Position',[0 .15 1 .85]);
hDOGroup = uibuttongroup('Parent',hRNTTab(4),'Position',[0 .15 1 .85]);

% Images subsection
hIms(1) = uibuttongroup('Parent',hImGroup,'Title','Upload Type');
hIms(2) = uicontrol('Parent',hIms(1),'Style','popupmenu',...
    'String','RGB Images|Split Channel Images|Grayscale Images',...
    'Callback',{@switchUI});
hIms(3) = uibuttongroup('Parent',hImGroup,'Title','Base Name');
hIms(4) = uicontrol('Parent',hIms(3),'Style','edit','HorizontalAlignment','left');
hIms(5) = uibuttongroup('Parent',hImGroup,'Title','Ch2 Base Name','Visible','off');
hIms(6) = uicontrol('Parent',hIms(5),'Style','edit','HorizontalAlignment','left');
hIms(7) = uibuttongroup('Parent',hImGroup,'Title','Ch3 Base Name','Visible','off');
hIms(8) = uicontrol('Parent',hIms(7),'Style','edit','HorizontalAlignment','left');
hIms(9) = uibuttongroup('Parent',hImGroup,'Title','Number of Fields');
hIms(10) = uicontrol('Parent',hIms(9),'Style','edit','HorizontalAlignment','right');
hIms(11) = uibuttongroup('Parent',hImGroup,'Title','Number of Frames');
hIms(12) = uicontrol('Parent',hIms(11),'Style','edit','HorizontalAlignment','right');
hIms(13) = uibuttongroup('Parent',hImGroup,'Title','Object Channel');
hIms(14) = uicontrol('Parent',hIms(13),'Style','popupmenu','String','Red (1)|Green (2)|Blue (3)');
hIms(15) = uibuttongroup('Parent',hImGroup,'Title','Image Resize');
hIms(16) = uicontrol('Parent',hIms(15),'Style','edit','String',num2str(Setts.Fcn.Resize),'HorizontalAlignment','right');
ImsPos = [.02 .86 .35 .12;FULL_FILL;.02 .72 .96 .12;FULL_FILL;...
    .02 .59 .96 .12;FULL_FILL;.02 .46 .96 .12;FULL_FILL;...
    .03 .33 .45 .12;FULL_FILL;.52 .33 .45 .12;FULL_FILL;...
    .02 .16 .3 .12;FULL_FILL;.02 .02 .3 .12;FULL_FILL];
for i=1:numel(hIms)
    set(hIms(i),'Units','Normalized')
    set(hIms(i),'Position',ImsPos(i,:))
end

% Object Analysis section
hOAs(1) = uibuttongroup('Parent',hOAGroup,'Title','Segmentation Algorithm');
hOAs(2) = uicontrol('Parent',hOAs(1),'Style','popupmenu','String','Edge-Watershed|Threshold-Watershed');
hOAs(3) = uibuttongroup('Parent',hOAGroup,'Title','Segmentation Settings');
hOAs(4) = uibuttongroup('Parent',hOAs(3),'Title','Sizes');
hOAs(5) = uicontrol('Parent',hOAs(4),'Style','edit','String',num2str(defFcnSetts.SegAlgSett{1}{1}),'HorizontalAlignment','right');
hOAs(6) = uicontrol('Parent',hOAs(4),'Style','edit','String',num2str(defFcnSetts.SegAlgSett{1}{2}),'HorizontalAlignment','right');
hOAs(7) = uibuttongroup('Parent',hOAs(3),'Title','Edge Threshold');
hOAs(8) = uicontrol('Parent',hOAs(7),'Style','edit','String',defFcnSetts.SegAlgSett{1}{3},'HorizontalAlignment','right');
hOAs(9) = uicontrol('Parent',hOAs(3),'Style','checkbox','Value',defFcnSetts.SegAlgSett{2}{3},'String','Merge Obj',...
    'HorizontalAlignment','left','Visible','off');
hOAs(10) = uicontrol('Parent',hOAs(3),'Style','checkbox','Value',defFcnSetts.SegAlgSett{2}{4},'String','Post Proc',...
    'HorizontalAlignment','left','Visible','off');
hOAs(11) = uibuttongroup('Parent',hOAGroup,'Title','Metric Selection');
hOAs(12) = uibuttongroup('Parent',hOAs(11),'Title','Ch1');
hOAs(13) = uibuttongroup('Parent',hOAs(11),'Title','Ch2');
hOAs(14) = uibuttongroup('Parent',hOAs(11),'Title','Ch3');
hOAs(15) = uibuttongroup('Parent',hOAs(11),'Title','General');
hOAs(16) = uibuttongroup('Parent',hOAGroup,'Title','Background Correction');
hOAs(17) = uicontrol('Parent',hOAs(16),'Style','popupmenu','String','None|Gauss|SKIZ');
OAsPos = [.02 .85 .47 .13;FULL_FILL;.02 .66 .96 .17;.02 .02 .34 .96;...
    LEFT_FILL;RIGHT_FILL;.38 .02 .34 .96;FULL_FILL;...
    .38 .02 .29 .8;.69 .02 .29 .8;.02 .03 .96 .6;.02 .43 .3 .55;...
    .35 .43 .3 .55;.68 .43 .3 .55; .02 .02 .96 .36;.51 .85 .47 .13;FULL_FILL];
for i=1:numel(hOAs)
    set(hOAs(i),'Units','Normalized')
    set(hOAs(i),'Position',OAsPos(i,:));
end

tmpString = {'Max','Min','Std Dev','Median','Mean'};
tmpEnable = {'off','on'};
for j=1:3
    tmp = .02;
    for i=1:5
        hOAs(end+1) = uicontrol('Parent',hOAs(11+j),'Style','checkbox','Value',defFcnSetts.ObjMets(1,5*(j-1)-i+6),...
            'String',tmpString{i},'HorizontalAlignment','left','Units','normalized');
        hOAs(end+1) = uicontrol('Parent',hOAs(11+j),'Style','edit','String',num2str(defFcnSetts.ObjMets(2,5*(j-1)-i+6)),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.ObjMets(1,5*(j-1)-i+6)+1});
        hOAs(end+1) = uicontrol('Parent',hOAs(11+j),'Style','edit','String',num2str(defFcnSetts.ObjMets(3,5*(j-1)-i+6)),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.ObjMets(1,5*(j-1)-i+6)+1});
        set(hOAs(end-2),'Position',[.02 tmp .47 .18])
        set(hOAs(end-1),'Position',[.51 tmp .23 .18])
        set(hOAs(end),'Position',[.75 tmp .23 .18])
        tmp = tmp+.2;
    end
end
tmpString = {'Circ','Perim','Area','Angle','YPos','XPos','Loc Dens'};
tmp1 = .02;
for j=1:3
    tmp2 = .02;
    for i=1:3
        hOAs(end+1) = uicontrol('Parent',hOAs(15),'Style','checkbox','Value',defFcnSetts.ObjMets(1,min(22,15+3*(j-1)+4-i)),...
            'String',tmpString{3*(j-1)+i},'HorizontalAlignment','left','Units','normalized');
        hOAs(end+1) = uicontrol('Parent',hOAs(15),'Style','edit','String',num2str(defFcnSetts.ObjMets(2,min(22,15+3*(j-1)+4-i))),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.ObjMets(1,min(22,15+3*(j-1)+4-i))+1});
        hOAs(end+1) = uicontrol('Parent',hOAs(15),'Style','edit','String',num2str(defFcnSetts.ObjMets(3,min(22,15+3*(j-1)+4-i))),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.ObjMets(1,min(22,15+3*(j-1)+4-i))+1});
        set(hOAs(end-2),'Units','normalized')
        set(hOAs(end-1),'Units','normalized')
        set(hOAs(end),'Units','normalized')
        set(hOAs(end-2),'Position',[tmp1 tmp2 .14 .3])
        set(hOAs(end-1),'Position',[tmp1+.15 tmp2 .07 .3])
        set(hOAs(end),'Position',[tmp1+.23 tmp2 .07 .3])
        tmp2 = tmp2+.33;
        if j==3
            set(hOAs(end-2),'Position',[tmp1 .68 .14 .3])
            set(hOAs(end-1),'Position',[tmp1+.15 .68 .07 .3])
            set(hOAs(end),'Position',[tmp1+.23 .68 .07 .3])
            break
        end
    end
    tmp1 = tmp1+.33;
end
for i=18:3:numel(hOAs)
    set(hOAs(i),'Callback',@metEnable)
end

% Motion Tracking subsection
hMTs(1) = uibuttongroup('Parent',hMTGroup,'Title','Metric Cost');
hMTs(2) = uicontrol('Parent',hMTs(1),'Style','edit','String',num2str(defFcnSetts.MetCost),...
    'HorizontalAlignment','right');
hMTs(3) = uibuttongroup('Parent',hMTGroup,'Title','Gap Close');
hMTs(4) = uicontrol('Parent',hMTs(3),'Style','edit','String',num2str(defFcnSetts.GapClose),...
    'HorizontalAlignment','right');
hMTs(5) = uicontrol('Parent',hMTGroup,'Style','checkbox','Value',defFcnSetts.Greedy,...
    'String','Greedy','HorizontalAlignment','left');
hMTs(6) = uibuttongroup('Parent',hMTGroup,'Title','Metric Selection');
hMTs(7) = uibuttongroup('Parent',hMTs(6),'Title','Ch1');
hMTs(8) = uibuttongroup('Parent',hMTs(6),'Title','Ch2');
hMTs(9) = uibuttongroup('Parent',hMTs(6),'Title','Ch3');
hMTs(10) = uibuttongroup('Parent',hMTs(6),'Title','General');
MTsPos = [.02 .85 .47 .13;FULL_FILL;.02 .7 .47 .13;FULL_FILL;.02 .58 .47 .1;...
    .02 .02 .96 .54;.02 .51 .3 .47;.35 .51 .3 .47;.68 .51 .3 .47;...
    BOT_FILL];
for i=1:numel(hMTs)
    set(hMTs(i),'Units','Normalized')
    set(hMTs(i),'Position',MTsPos(i,:))
end

tmpString = {'Std Dev','Median','Mean'};
tmpEnable = {'off','on'};
for j=1:3
    tmp = .02;
    for i=1:3
        hMTs(end+1) = uicontrol('Parent',hMTs(6+j),'Style','checkbox','Value',defFcnSetts.TrackMets(1,3*(j-1)-i+4),...
            'String',tmpString{i},'HorizontalAlignment','left','Units','normalized');
        hMTs(end+1) = uicontrol('Parent',hMTs(6+j),'Style','edit','String',num2str(defFcnSetts.TrackMets(2,3*(j-1)-i+4)),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.TrackMets(1,3*(j-1)-i+4)+1});
        set(hMTs(end-1),'Position',[.02 tmp .57 .3])
        set(hMTs(end),'Position',[.61 tmp .37 .3])
        tmp = tmp+.33;
    end
end
tmpString = {'Circ','Perim','Area','Angle','YPos','XPos'};
tmp1 = .02;
for j=1:2
    tmp2 = .02;
    for i=1:3
        hMTs(end+1) = uicontrol('Parent',hMTs(10),'Style','checkbox','Value',defFcnSetts.TrackMets(1,9+3*(j-1)-i+4),...
            'String',tmpString{3*(j-1)+i},'HorizontalAlignment','left','Units','normalized');
        hMTs(end+1) = uicontrol('Parent',hMTs(10),'Style','edit','String',num2str(defFcnSetts.TrackMets(2,9+3*(j-1)-i+4)),...
            'HorizontalAlignment','right','Units','normalized',...
            'Enable',tmpEnable{defFcnSetts.TrackMets(1,9+3*(j-1)-i+4)+1});
        hMTs(end-1).Units = 'normalized';
        hMTs(end).Units = 'normalized';
        set(hMTs(end-1),'Position',[tmp1 tmp2 .17 .3])
        set(hMTs(end),'Position',[tmp1+.18 tmp2 .11 .3])
        tmp2 = tmp2+.33;
    end
    tmp1 = tmp1+.33;
end
for i=11:2:numel(hMTs)
    set(hMTs(i),'Callback',@metEnable)
end

% Data Output subsection
hDOs(1) = uibuttongroup('Parent',hDOGroup,'Title','Data File');
hDOs(2) = uibuttongroup('Parent',hDOGroup,'Title','Properties');
hDOs(3) = uicontrol('Parent',hDOs(1),'Style','checkbox','Value',0);
hDOs(4) = uicontrol('Parent',hDOs(1),'Style','edit','String','','HorizontalAlignment','left');
hDOs(5) = uicontrol('Parent',hDOs(1),'Style','pushbutton','String','Choose File...',...
    'Callback',{@chooseFile});
DOsPos = [.02 .85 .66 .13;.02 .7 .66 .13;.02 .02 .08 .96;.11 .02 .51 .96;...
    .63 .02 .35 .96];
for i=1:numel(hDOs)
    set(hDOs(i),'Units','Normalized')
    set(hDOs(i),'Position',DOsPos(i,:))
end


%% Callback functions
    function changeTab(h,e)
        update(h,e);
    end

    function update(h,e)
        % Function to update settings from GUI fields.
        SAS = {{{str2double(get(hOAs(5),'String')),str2double(get(hOAs(6),'String')),str2double(get(hOAs(8),'String'))},...
            {str2double(get(hOAs(5),'String')),str2double(get(hOAs(6),'String')) get(hOAs(9),'Value') get(hOAs(10),'Value')}}};
        tmpInd = 15+3*[5:-1:1 10:-1:6 15:-1:11 18:-1:16 21:-1:19 22];
        OMs = arrayfun(@(x) get(x,'Value'),hOAs(tmpInd));
        OMMins = arrayfun(@(x) str2double(get(x,'String')),hOAs(tmpInd+1));
        OMMaxs = arrayfun(@(x) str2double(get(x,'String')),hOAs(tmpInd+2));
        tmpInd = 9+2*[3:-1:1 6:-1:4 9:-1:7 12:-1:10 15:-1:13];
        TMs = arrayfun(@(x) get(x,'Value'),hMTs(tmpInd));
        TMVals = arrayfun(@(x) str2double(get(x,'String')),hMTs(tmpInd+1));
        fcnSetts = struct('ImType',convertValue(hIms(2)),'ObjCh',get(hIms(14),'Value'),'Resize',str2double(get(hIms(16),'String')),...
            'SegAlg',convertValue(hOAs(2)),'SegAlgSett',SAS,'BkgdCorr',convertValue(hOAs(17)),...
            'ObjMets',[OMs;OMMins;OMMaxs],'MetCost',str2double(get(hMTs(2),'String')),...
            'GapClose',str2double(get(hMTs(4),'String')),'Greedy',get(hMTs(5),'Value'),...
            'TrackMets',[TMs;TMs.*TMVals]);
        
        fileSetts = struct('FileType','Base','FilePath','','NFrames',str2double(get(hIms(12),'String')),'NFields',str2double(get(hIms(10),'String')));
        saveSetts = struct('YN',get(hDOs(3),'Value'),'FileName',get(hDOs(4),'String'),'FilePath',pwd);
        
        f = getFig(Parent);
        app = get(f,'UserData');
        if strcmp(fcnSetts.ImType,'Split')
            app.FileNames = {get(hIms(4),'String'),get(hIms(6),'String'),get(hIms(8),'String')};
        else
            app.FileNames = get(hIms(4),'String');
        end
        app.FileSettings = fileSetts;
        app.FcnSettings = fcnSetts;
        app.SaveSettings = saveSetts;
        set(f,'UserData',app)
    end

    function switchUI(h,e)
        % Function to handle display of certain dependent components on the UI
        switch h
            case hIms(2)
                if get(h,'Value')==2
                    set(hIms(3),'Title','Ch1 Base Name')
                    set(hIms(5),'Visible','on')
                    set(hIms(7),'Visible','on')
                    Setts.File.FileNames = cell(3,1);
                else
                    set(hIms(3),'Title','Base Name')
                    set(hIms(5),'Visible','off')
                    set(hIms(7),'Visible','off')
                    Setts.File.FileNames = {};
                end
            otherwise
        end
    end

    function metEnable(h,e)
        % Function to enable and disable value boxes during metric
        % selection for GUI
        tmpEnable = {'off','on'};
        val = get(h,'Value');
        
        i = find(hOAs==h);
        if ~isempty(i)
            set(hOAs(i+1),'Enable',tmpEnable{val+1})
            set(hOAs(i+2),'Enable',tmpEnable{val+1})
            return
        end
        
        i = find(hMTs==h);
        if ~isempty(i)
            set(hMTs(i+1),'Enable',tmpEnable{val+1})
            return
        end
        
    end

    function chooseFile(h,e)
        % Function to choose file for UI components
        switch h
            case hDOs(5)
                [names,path] = uiputfile({'*.mat','MAT Files';'*.*','All Files'},...
                    'Choose MAT file to save...',Setts.File.Path);
                if ~isequal(names,0)
                    Setts.Save.Path = path;
                    Setts.Save.FileName = names;
                    set(hDOs(4),'String',names)
                else
                    h = errordlg('No images were entered.');
                end
        end
    end

    function out = convertValue(h)
        % Function to convert correct settings value from UI component
        switch h
            case hIms(2)
                switch get(h,'Value')
                    case 1
                        out = 'RGB';
                    case 2
                        out = 'Split';
                    case 3
                        out = 'Gray';
                end
            case hOAs(2)
                switch get(h,'Value')
                    case 1
                        out = 'EdgeWater';
                    case 2
                        out = 'ThreshWater';
                end
            case hOAs(17)
                switch get(h,'Value')
                    case 1
                        out = 'None';
                    case 2
                        out = 'Gauss';
                    case 3
                        out = 'SKIZ';
                end
        end
        
    end
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