function varargout = UploadImages(varargin)
% UPLOADIMAGES MATLAB code for UploadImages.fig
%      UPLOADIMAGES, by itself, creates a new UPLOADIMAGES or raises the existing
%      singleton*.
%
%      H = UPLOADIMAGES returns the handle to a new UPLOADIMAGES or the handle to
%      the existing singleton*.
%
%      UPLOADIMAGES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UPLOADIMAGES.M with the given input arguments.
%
%      UPLOADIMAGES('Property','Value',...) creates a new UPLOADIMAGES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UploadImages_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UploadImages_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UploadImages

% Last Modified by GUIDE v2.5 14-Jan-2016 17:39:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UploadImages_OpeningFcn, ...
                   'gui_OutputFcn',  @UploadImages_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


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


%
function app = getApp(h)
f = getFig(h);
set(f,'UserData',app)


% --- Executes just before UploadImages is made visible.
function UploadImages_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UploadImages (see VARARGIN)

% Choose default command line output for UploadImages
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UploadImages wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = UploadImages_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ImageListbox.
function ImageListbox_Callback(hObject, eventdata, handles)
% hObject    handle to ImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageListbox


% --- Executes during object creation, after setting all properties.
function ImageListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ImageTypeMenu.
function ImageTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ImageTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ImageTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ImageTypeMenu
handles = guihandles(getFig(hObject));
switch hObject.Value
    case 1
        handles.SelectButton1.String = 'Select...';
        handles.SelectButton3.Visible = 'off';
        handles.SelectButton2.Visible = 'off';
        handles.FileNameEditPanel2.Visible = 'off';
        handles.FileNameEditPanel3.Visible = 'off';
        handles.MultiFileEditPanel1.Title  = 'File Name Format';
        handles.MultiFileEditPanel2.Visible = 'off';
        handles.MultiFileEditPanel3.Visible = 'off';
        handles.ImageListbox.UserData = {};
        handles.ImageListbox.String = [];
        handles.FileSelectPanel.UserData = {};
    case 2
        handles.SelectButton1.String = 'Select R...';
        handles.SelectButton3.Visible = 'on';
        handles.SelectButton2.Visible = 'on';
        handles.FileNameEditPanel2.Visible = 'on';
        handles.FileNameEditPanel3.Visible = 'on';
        handles.MultiFileEditPanel1.Title  = 'Ch1 File Name Format';
        handles.MultiFileEditPanel2.Visible = 'on';
        handles.MultiFileEditPanel3.Visible = 'on';
        handles.ImageListbox.UserData = {{},{},{}};
        handles.ImageListbox.String = [];
        handles.FileSelectPanel.UserData = {{},{},{}};
    case 3
        handles.SelectButton1.String = 'Select...';
        handles.SelectButton3.Visible = 'off';
        handles.SelectButton2.Visible = 'off';
        handles.FileNameEditPanel2.Visible = 'off';
        handles.FileNameEditPanel3.Visible = 'off';
        handles.MultiFileEditPanel1.Title  = 'File Name Format';
        handles.MultiFileEditPanel2.Visible = 'off';
        handles.MultiFileEditPanel3.Visible = 'off';
        handles.ImageListbox.UserData = {};
        handles.ImageListbox.String = [];
        handles.FileSelectPanel.UserData = {};
end


% --- Executes during object creation, after setting all properties.
function ImageTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectButton1.
function SelectButton1_Callback(hObject, eventdata, handles)
% hObject    handle to SelectButton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guihandles(getFig(hObject));

switch handles.ImageTypeMenu.Value
    case 2
        titleString = 'Choose Ch1 images...';
    case {1,3}
        titleString = 'Choose images...';
end

[names,path] = uigetfile({'*.jpg;*.tif;*.png;*.gif','Image Files';'*.*','All Files'},...
    titleString,'','MultiSelect','on');
handles.FileSelectPanel.UserData{1} = path;
if ~isequal(names,0)
    if ~iscell(names)
        names = {names};
    end
    
    handles.ImageListbox.UserData{1} = names;
    switch handles.ImageTypeMenu.Value
    case 2
        handles.ImageListbox.String = [handles.ImageListbox.UserData{1},...
            handles.ImageListbox.UserData{2},handles.ImageListbox.UserData{3}];
    case {1,3}
        handles.ImageListbox.String = handles.ImageListbox.UserData{1};
    end
    handles.ImageListbox.String
else
    % No images - do nothing
end


% --- Executes on button press in ClearButton.
function ClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guihandles(getFig(hObject));

handles.ImageListbox.String = '';
switch handles.ImageTypeMenu.Value
    case 2
        handles.ImageListbox.UserData = {{},{},{}};
    case {1,3}
        handles.ImageListbox.UserData = {};
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in UploadTypeMenu.
function UploadTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to UploadTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns UploadTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from UploadTypeMenu
handles = guihandles(getFig(hObject));
switch hObject.Value
    case 1
        handles.FileSelectPanel.Visible = 'on';
        handles.FileNamePanel.Visible   = 'off';
        handles.MultiFilePanel.Visible  = 'off';
    case 2
        handles.FileSelectPanel.Visible = 'off';
        handles.FileNamePanel.Visible   = 'on';
        handles.MultiFilePanel.Visible  = 'off';
    case 3
        handles.FileSelectPanel.Visible = 'off';
        handles.FileNamePanel.Visible   = 'off';
        handles.MultiFilePanel.Visible  = 'on';
end


% --- Executes during object creation, after setting all properties.
function UploadTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UploadTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SelectButton2.
function SelectButton2_Callback(hObject, eventdata, handles)
% hObject    handle to SelectButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guihandles(getFig(hObject));

[names,path] = uigetfile({'*.jpg;*.tif;*.png;*.gif','Image Files';'*.*','All Files'},...
    'Choose Ch2 images...','','MultiSelect','on');
handles.FileSelectPanel.UserData{2} = path;
if ~isequal(names,0)
    if ~iscell(names)
        names = {names};
    end
    
    handles.ImageListbox.UserData{2} = names;
    handles.ImageListbox.String = [handles.ImageListbox.UserData{1},...
            handles.ImageListbox.UserData{2},handles.ImageListbox.UserData{3}];
else
    % No images - do nothing
end


% --- Executes on button press in SelectButton3.
function SelectButton3_Callback(hObject, eventdata, handles)
% hObject    handle to SelectButton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guihandles(getFig(hObject));

[names,path] = uigetfile({'*.jpg;*.tif;*.png;*.gif','Image Files';'*.*','All Files'},...
    'Choose Ch3 images...','','MultiSelect','on');
handles.FileSelectPanel.UserData{3} = path;
if ~isequal(names,0)
    if ~iscell(names)
        names = {names};
    end
    
    handles.ImageListbox.UserData{3} = names;
    handles.ImageListbox.String = [handles.ImageListbox.UserData{1},...
            handles.ImageListbox.UserData{2},handles.ImageListbox.UserData{3}];
else
    % No images - do nothing
end

% --- Executes on selection change in FileNameStartMenu.
function FileNameStartMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameStartMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileNameStartMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileNameStartMenu


% --- Executes during object creation, after setting all properties.
function FileNameStartMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameStartMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileNameFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of FileNameFrameEdit as a double


% --- Executes during object creation, after setting all properties.
function FileNameFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileNameEdit1_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameEdit1 as text
%        str2double(get(hObject,'String')) returns contents of FileNameEdit1 as a double


% --- Executes during object creation, after setting all properties.
function FileNameEdit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiFileFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MultiFileFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiFileFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of MultiFileFrameEdit as a double


% --- Executes during object creation, after setting all properties.
function MultiFileFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiFileFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiFileFieldEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MultiFileFieldEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiFileFieldEdit as text
%        str2double(get(hObject,'String')) returns contents of MultiFileFieldEdit as a double


% --- Executes during object creation, after setting all properties.
function MultiFileFieldEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiFileFieldEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiFileEdit1_Callback(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiFileEdit1 as text
%        str2double(get(hObject,'String')) returns contents of MultiFileEdit1 as a double


% --- Executes during object creation, after setting all properties.
function MultiFileEdit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FileNameEdit3_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameEdit3 as text
%        str2double(get(hObject,'String')) returns contents of FileNameEdit3 as a double


% --- Executes during object creation, after setting all properties.
function FileNameEdit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileNameEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to FileNameEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNameEdit2 as text
%        str2double(get(hObject,'String')) returns contents of FileNameEdit2 as a double


% --- Executes during object creation, after setting all properties.
function FileNameEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNameEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiFileEdit3_Callback(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiFileEdit3 as text
%        str2double(get(hObject,'String')) returns contents of MultiFileEdit3 as a double


% --- Executes during object creation, after setting all properties.
function MultiFileEdit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MultiFileEdit2_Callback(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MultiFileEdit2 as text
%        str2double(get(hObject,'String')) returns contents of MultiFileEdit2 as a double


% --- Executes during object creation, after setting all properties.
function MultiFileEdit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MultiFileEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
