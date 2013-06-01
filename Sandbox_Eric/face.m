function varargout = face(varargin)
% FACE MATLAB code for face.fig
%      FACE, by itself, creates a new FACE or raises the existing
%      singleton*.
%
%      H = FACE returns the handle to a new FACE or the handle to
%      the existing singleton*.
%
%      FACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACE.M with the given input arguments.
%
%      FACE('Property','Value',...) creates a new FACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before face_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to face_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help face

% Last Modified by GUIDE v2.5 29-May-2013 23:02:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @face_OpeningFcn, ...
                   'gui_OutputFcn',  @face_OutputFcn, ...
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


% --- Executes just before face is made visible.
function face_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to face (see VARARGIN)

% Choose default command line output for face
handles.output = hObject;

%add mex here 
% addpath('/Users/kzhou/Desktop/trunk/mexopencv-master/');
addpath('./include');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes face wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = face_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable warning messages
warning('off');

% Load flandmark_model into MATLAB memory
model = flandmark_load_model('./include/flandmark_model.dat');

% Load cascade file
xml_file = fullfile('./include','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

%Camera
cap = cv.VideoCapture;
pause(3); % intialization...
%flag_stop = get(handles.pushbutton3,'Value');
flag_stop = false;
cal_cnt=1;
KP_prev = zeros(4,15);
kp_prev_i = 1;
% model to set for calibration
neutral_model = zeros(2,15,100);
neutral_avg = zeros(2,15);
% enter processing loop
while 1
    im = cap.read;
    im = cv.resize(im,0.5);
    gr = cv.cvtColor(im,'RGB2GRAY');
    gr = cv.equalizeHist(gr);
    
    %bounding box here
    boxes = classifier.detect(gr,'ScaleFactor',1.3,...
                                 'MinNeighbors',2,...
                                 'MinSize',[40,40],'MaxSize',[200,200]);
    if (length(boxes)==1)
      % Draw results
      imshow(gr,'Parent', handles.axes1);

      % Draw bounding box around detected face
      rectangle('Position',boxes{1},'EdgeColor','g','LineWidth',2);
        
      % crop bounding box image from original image
      bbox = [boxes{1}(1) boxes{1}(2) boxes{1}(1)+boxes{1}(3) boxes{1}(2)+boxes{1}(4)];
      
      % start timer for speed evaluation
      tic
      % detect keypoints in the bounding box
      KP = find_keypoints(gr, boxes{1}, bbox, model, 2);
      % elapsed time for keypoint detection
      t1 = toc;
      fprintf('Keypoint Detection:    Elapsed time %f ms\n', t1*1000);
      
      %if (nnz(KP) == 15)
        % if KP_prev is full, average the keypoints over a few frames to smooth them
        if (kp_prev_i == 5)
          if (nnz(KP) < 15)
            kp_prev_i = 1;
          else
            KP_avg = (KP_prev(1:2,:)+KP_prev(3:4,:)+KP)./3;
            % save the keypoints into the previous keypoint matrix for averaging
            KP_prev = [KP_prev(3:end,:);KP];
          end
        else
          % KP_prev is not full yet, so use current keypoints until then  
          KP_avg = KP;
          % fill the KP_prev matrix with keypoint values
          KP_prev(kp_prev_i:kp_prev_i+1,:) = KP;
          kp_prev_i = kp_prev_i + 2;
        end
      %else
        % reset the average if no keypoints are detected for current bbox
      %  KP_avg = KP;
      %  KP_prev = zeros(6,15);
      %end
          
      % show keypoints on the original grayscale image
      hold on;
      %comps = ['S0'; 'S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'];
      plot(KP_avg(1, 1), KP_avg(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
      %text(P(1, 1)+1, P(2, 1)+1, comps(1,:), 'color', 'b', 'FontSize', 12);
      plot(KP_avg(1, 2:end), KP_avg(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
      %text(P(1, 2:end)+1, P(2, 2:end)+1, comps(2:end,:), 'color', 'r', 'FontSize', 12);
      %plot(eb_l(1,:),eb_l(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
      %plot(eb_r(1,:),eb_r(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
      hold off;
          
      % Check to perform calibration
      Cal_flag   = get(handles.togglebutton1,'Value');
      if Cal_flag
         cal_cnt = 1+cal_cnt;
         % store keypoints to neutral model
         neutral_model(:,:,cal_cnt) = KP_avg;
         if(cal_cnt>100)
             model_sum = zeros(2,15);
             for f=1:100
               model_sum = neutral_model(:,:,f)+model_sum;
             end
             neutral_avg = model_sum./100;
             set(handles.togglebutton1,'Value',0);
             figure; imshow(gr,[]);
             hold on;
             plot(neutral_avg(1, 1), neutral_avg(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
             plot(neutral_avg(1, 2:end), neutral_avg(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
             hold off;
             % normalize neutral model to the center 
             pause(15);
         end   
      else   
         cal_cnt = 1;
      end
      
      % If the 'Cease' button is pressed, stop loop
      if flag_stop
        break;
      end
      pause(0.01);
    end


end
