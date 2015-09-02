function GUIRET(Parent)

SaveSetts = struct('YN',0,'FileName','','FilePath',pwd);

hRETs(1) = uibuttongroup('Parent',Parent,'Title','Existing Tracking File');
hRETs(2) = uicontrol('Parent',hRETs(1),'Style','edit','String','','HorizontalAlignment','left');
hRETs(3) = uicontrol('Parent',hRETs(1),'Style','pushbutton','String','Choose File...',...
    'Callback',{@chooseFile});

RETsPos = [.02 .85 .66 .11;.02 .02 .59 .96;...
    .63 .02 .35 .96];
for i=1:numel(hRETs)
    hRETs(i).Units = 'Normalized';
    hRETs(i).Position = RETsPos(i,:);
end

%% Callback functions
    function chooseFile(h,e)
        % Function to choose file for UI components
        app = get(getFig(Parent),'UserData');
        
        switch h
            case hRETs(3)
                [names,path] = uigetfile({'*.mat','MAT Files';'*.*','All Files'},...
                    'Choose tracking file to open:',app.FileSettings.FilePath,'MultiSelect','off');
                if ~isequal(names,0)
                    SaveSetts.FilePath = path;
                    SaveSetts.FileName = names;
                    hRETs(2).String = names;
                    app.SaveSettings = SaveSetts;
                else
                    h = errordlg('No images were entered.');
                end
        end
    end

end

function root = getFig(h)
% Function to get root figure of the GUI
if isprop(h,'Name')
    if strcmp(h.Name,'Cell Tracking')
        root = h;
        return
    end
end
root = getFig(h.Parent);
end