function varargout = HWS_GUI(varargin)
% HWS_GUI MATLAB code for HWS_GUI.fig
%      HWS_GUI, by itself, creates a new HWS_GUI or raises the existing
%      singleton*.
%
%      H = HWS_GUI returns the handle to a new HWS_GUI or the handle to
%      the existing singleton*.
%
%      HWS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HWS_GUI.M with the given input arguments.
%
%      HWS_GUI('Property','Value',...) creates a new HWS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HWS_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HWS_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HWS_GUI

% Last Modified by GUIDE v2.5 01-Dec-2020 22:03:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HWS_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @HWS_GUI_OutputFcn, ...
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


% --- Executes just before HWS_GUI is made visible.
function HWS_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HWS_GUI (see VARARGIN)

% Choose default command line output for HWS_GUI
handles.output = hObject;
handles.image=cell(0);
handles.fileImage=cell(0);
handles.imageIndex=1;
handles.tableData=cell(0);
handles.minBlockSize=50;
handles.threshold = 0;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HWS_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HWS_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in folderListBox.
function folderListBox_Callback(hObject, eventdata, handles)
% hObject    handle to folderListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns folderListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from folderListBox
% 获取当前选择的图片列表
contents=get(hObject,'Value');
imageName=get(handles.folderListBox,'String');
handles.fileImage=imageName(contents);
handles.imageIndex=1;
handles.tableData=cell(0);
handles.image=cell(0);
for i=1:length(handles.fileImage)
    image=imread([handles.imagePath,'\',cell2mat(handles.fileImage(i))]);
    if(size(image,3)>1)
        handles.image{i}=rgb2gray(image);
    else
        handles.image{i}=image;
    end
end
updateImageAndTable(hObject, eventdata, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function folderListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to folderListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openFolderBtn.
function openFolderBtn_Callback(hObject, eventdata, handles)
% hObject    handle to openFolderBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 读取文件,更改列表显示
handles.imagePath=uigetdir("","请选择图片所在文件夹");
% 更新列表
if ~handles.imagePath
    return
end
dirList=dir(handles.imagePath);
imageFileName={};
for i=1:length(dirList)
    if(~isempty(strfind(dirList(i).name,'.jpg')) || ~isempty(strfind(dirList(i).name,'.png')) || ~isempty(strfind(dirList(i).name,'.jpeg')))
        imageFileName=[imageFileName,dirList(i).name];
    end
end
handles.imageFileName=imageFileName;
set(handles.folderListBox,'String',imageFileName');
% Update handles structure
folderListBox_Callback(hObject, eventdata, handles);
set(handles.folderListBox,'Value',1);
set(handles.reverseBtn,'Enable','on');
set(handles.analysisBtn,'Enable','on');
guidata(hObject, handles);



% --- Executes on button press in analysisBtn.
function analysisBtn_Callback(hObject, eventdata, handles)
% hObject    handle to analysisBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 分析结果, 更新 table, 更新 axes
handles.tableData=cell(0);
tableData=cell(length(handles.image),1);
for i=1:length(handles.image)
    % 对图像进行分析
    image=handles.image{i};
    if(handles.threshold)
        level=handles.threshold/255;
    else
        level=graythresh(image);
        handles.threshold=floor(level*255);
    end
    bw=imbinarize(image,level);
    blockInfo=getBoxCount(bw,handles.minBlockSize);
    tableData{i}=blockInfo;
end
handles.tableData=tableData;
% update axes and table.
updateImageAndTable(hObject, eventdata, handles);
guidata(hObject,handles);

function curIndexEdit_Callback(hObject, eventdata, handles)
% hObject    handle to curIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of curIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of curIndexEdit as a double
% 检查输入是否合法

% 更新 index, 更新图像
index=str2num(get(hObject,'String'));
if(isempty(index) || ~ismember(index,1:length(handles.fileImage)))
    dialog("Error","This is a invaild input.");
else
    handles.imageIndex=index;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function curIndexEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to curIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% 更新显示的图片
function updateImageAndTable(hObject, eventdata, handles)
set(handles.mainTable,'Data',[]);
% 更新图片角标
set(handles.text3,'String',strcat('/ ',num2str(length(handles.fileImage))));
set(handles.curIndexEdit,'String',handles.imageIndex)
set(handles.thresholdEdit,'String',handles.threshold);
set(handles.slider3,'String',handles.threshold);
% 更新显示的图
axes(handles.mainAxes);
cla reset;
% image=imread([handles.imagePath,'\',cell2mat(handles.fileImage(handles.imageIndex))]);
imshow(handles.image{handles.imageIndex});
hold on;
if(~isempty(handles.tableData))
    data=handles.tableData{handles.imageIndex};
    % 更新 table
    tData=[];
    for i=1:length(data)
       tData(i,:)=[data(i).Perimeter,data(i).Area,2*sqrt(pi.*data(i).Area)./data(i).Perimeter,abs(data(i).boxCount(1))]; 
    end
    set(handles.mainTable,'Data',tData);
    % 绘制标签和 box
    for i=1:length(data)
        text(data(i).Centroid(1),data(i).Centroid(2),string(i),'Color','r','FontSize',10);
        rectangle('Position',data(i).BoundingBox,'EdgeColor','r');
    end
end


% --- Executes on button press in forwardBtn.
function forwardBtn_Callback(hObject, eventdata, handles)
% hObject    handle to forwardBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageIndex+1<=length(handles.fileImage))
    handles.imageIndex=handles.imageIndex+1;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes on button press in backwardBtn.
function backwardBtn_Callback(hObject, eventdata, handles)
% hObject    handle to backwardBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(handles.imageIndex-1>=1)
    handles.imageIndex=handles.imageIndex-1;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);



function minBlockSizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to minBlockSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minBlockSizeEdit as text
%        str2double(get(hObject,'String')) returns contents of minBlockSizeEdit as a double
index=str2num(get(hObject,'String'));
if(isempty(index))
    dialog("Error","This is a invaild input.");
else
    handles.minBlockSize=index;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function minBlockSizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minBlockSizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reverseBtn.
function reverseBtn_Callback(hObject, eventdata, handles)
% hObject    handle to reverseBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 图像反转
if(~isempty(handles.fileImage))
    for i=1:length(handles.fileImage)
        handles.image{i}=abs(255-handles.image{i});
    end
end
updateImageAndTable(hObject, eventdata, handles);
guidata(hObject, handles);


% --- Executes on key press with focus on minBlockSizeEdit and none of its controls.
function minBlockSizeEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to minBlockSizeEdit (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
index=str2num(get(hObject,'String'));
if(isempty(index))
    dialog("Error","This is a invaild input.");
else
    handles.minBlockSize=index;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function cugAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cugAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cugAxes
backgroundImageUrl="./CUG.jpg";
backgroundImage=imread(backgroundImageUrl);
axes(hObject);
imshow(backgroundImage);


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.threshold=round(get(hObject,'Value'));
updateImageAndTable(hObject, eventdata, handles);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function thresholdEdit_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdEdit as text
%        str2double(get(hObject,'String')) returns contents of thresholdEdit as a double

index=str2num(get(hObject,'String'));
if(isempty(index))
    dialog("Error","This is a invaild input.");
else
    handles.threshold=index;
    updateImageAndTable(hObject, eventdata, handles);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function thresholdEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
