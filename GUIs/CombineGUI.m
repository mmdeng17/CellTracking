f = figure('name','Cell Tracking','Visible','off');

hTypeTabs = uitabgroup('Parent',f);
hTypeTab(1) = uitab(hTypeTabs,'Title','Run New...');
hTypeTab(2) = uitab(hTypeTabs,'Title','Run Existing...');
hTypeTab(3) = uitab(hTypeTabs,'Title','Run Multiple...');
hTypeTab(4) = uitab(hTypeTabs,'Title','Start Analysis');

H = UploadImages();
while ~isempty(H.Children)
    H.Children(1).Parent = hTypeTab(1);
end
close(H);


f.Visible = 'on';
f.UserData = CellTracker();