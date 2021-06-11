function varargout = untitled(varargin)
% UNTITLED MATLAB code for untitled.fig
%      UNTITLED, by itself, creates a new UNTITLED or raises the existing
%      singleton*.
%
%      H = UNTITLED returns the handle to a new UNTITLED or the handle to
%      the existing singleton*.
%
%      UNTITLED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED.M with the given input arguments.
%
%      UNTITLED('Property','Value',...) creates a new UNTITLED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled

% Last Modified by GUIDE v2.5 22-May-2021 23:20:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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


% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled (see VARARGIN)

% Choose default command line output for untitled
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Select_an_MRI_Image.
function Select_an_MRI_Image_Callback(hObject, eventdata, handles)

global I1
[I,path]=uigetfile({'*.jpg'; '*.jpeg'},'select an image');
I1 = imread([path,I]);

axes(handles.axes1);
imshow(I1);

title('\fontsize{15}\color[rgb]{1,1,0.5} Brain MRI Image')



function Apply_Median_Filter_Callback(hObject, eventdata, handles)

global I1 result

[result]=Pre_Processing(I1);
axes(handles.axes2);

imshow(result); title('\fontsize{15}\color[rgb]{1,1,0.5} Filtered Image');



% --- Executes on button press in Segment_the_Tumor.
function Segment_the_Tumor_Callback(hObject, eventdata, handles)

global result tumor tumor_label max_area stats

inp = im2double(result) ; 

num_of_clusters = 4;    %Number of clusters
[clustered_img]=k_means_clustering(inp,num_of_clusters);

% Applying Morphological Operation
binarized_img=imbinarize(double(clustered_img),0.5);
label = bwlabel(binarized_img);
stats = regionprops(logical(label),'Solidity','Area','BoundingBox');
area = [stats.Area];
density = [stats.Solidity];
high_dense_area = density>0.55;
max_area = max(area(high_dense_area));
tumor_label = find(area==max_area);
tumor = ismember(label,tumor_label);

tumor= imfill(tumor,'holes');
se1 = strel('diamond',3);   %creates diamond shape structure
tumor = imerode(tumor,se1);

se2 =strel('square',5);
tumor=imdilate(tumor,se2); 

axes(handles.axes3);
imshow(tumor); title('\fontsize{15}\color[rgb]{1,1,0.5} Segmented Image');



% --- Executes on button press in Extract_the_Features.
function Extract_the_Features_Callback(hObject, eventdata, handles)

global feat tumor

[feat]=Feature_extraction(tumor);
colnames = {'Value'};
featnames = {feat(1),feat(2),feat(3),feat(4),feat(5),feat(6),feat(7),feat(8),feat(9),feat(10)};

set(handles.uitable2,'data',[featnames'],'ColumnName',colnames);


% --- Executes on button press in Apply_SVM.
function Apply_SVM_Callback(hObject, eventdata, handles)
% hObject    handle to Apply_SVM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tumor_label max_area feat stats result

load Trainsetfinal.mat
xdata = data;
group = label;
svmStruct1 = fitcsvm(xdata,group,'KernelFunction','rbf');
type = predict(svmStruct1,feat);

 if (strcmpi(type,'Abnormal') && max_area > 300) 
     warndlg(' Tumor Detected !! ');
     
     box = stats(tumor_label);
     wantedBox = box.BoundingBox;
     
     axes(handles.axes4);
     imshow(result);title('\fontsize{15}\color[rgb]{1,1,0.5} Detected Tumor');
     hold on; rectangle('Position',wantedBox,'EdgeColor','g','LineWidth',3);
 else
     helpdlg(' No Tumor ');
     disp(' No Tumor ');
 end

 % --- Executes on button press in Optimization.
function Optimization_Callback(hObject, eventdata, handles)
% hObject    handle to Optimization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load Trainsetfinal.mat
classes = grp2idx(label);
X=data;
y=classes;
[test_accuracy,m] = optimization(X,y);

Precision=m(1)/(m(1)+m(3));
Recall=m(1)/(m(1)+m(2));
F1_Score=2*((Precision*Recall)/(Precision+Recall));

string15 = sprintf('Accuracy = %.3f', test_accuracy);
string16 = sprintf('Precision = %.3f', Precision);
string17 = sprintf('Recall = %.3f', Recall);
string18 = sprintf('F1_Score = %.3f', F1_Score);

set(handles.edit2,'string',string15);
set(handles.edit3,'string',string16);
set(handles.edit4,'string',string17);
set(handles.edit5,'string',string18);

axes(handles.axes5);
chart = confusionchart(m,{'Normal','Abnormal'});
chart.Title = '\fontsize{15}\color[rgb]{1,1,0.5} Confusion Matrix';

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


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


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
