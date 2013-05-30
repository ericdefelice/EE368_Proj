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
               
               
global neutral_model; 
neutral_model = zeros(2,15,100);

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

% Hint: get(hObject,'Value') returns toggle state of togglebutton1






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






% Load flandmark_model into MATLAB memory
model = flandmark_load_model('./include/flandmark_model.dat');


% Load cascade file
xml_file = fullfile('./include','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

%Camera
cap = cv.VideoCapture;
pause(3); % intialization...
flag_stop = false;
cal_cnt=0;
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

    %     for i = 1:numel(boxes)
    %         rectangle('Position',boxes{},'EdgeColor','r','LineWidth',2);
    %         pause(0.5);
    %         figure(50);imshow(rgb2gray(im(boxes{i}(2):boxes{i}(2)+boxes{i}(4),boxes{i}(1):boxes{i}(1)+boxes{i}(3),:)));
    %     end
       rectangle('Position',boxes{1},'EdgeColor','g','LineWidth',2);
        
        bbox = [boxes{1}(1) boxes{1}(2) boxes{1}(1)+boxes{1}(3) boxes{1}(2)+boxes{1}(4)];
        % detect keypoints and display
        for j = 1 : size(boxes{1}, 1)
          tic
          P = flandmark_detector(gr, int32(bbox(j, :)),  model);
          eb_l = zeros(2,3);
          eb_r = zeros(2,3);
          lip_m = zeros(2,1);
          % find eye-brows
          if (P(1,2) > 0)
            fh_box = [bbox(1) bbox(2) boxes{1}(3) P(1,2)-bbox(1)];
            f_im = gr(fh_box(2)+(fh_box(4)/2):fh_box(2)+fh_box(4),fh_box(1):fh_box(1)+fh_box(3),:);
            f_im = f_im(2:end,:)-f_im(1:end-1,:);
            %imshow(f_im,[]);
            im_bw = (f_im>mean2(f_im));
            %imshow(im_bw);
            S=regionprops(im_bw,'PixelIdxList','Area','Solidity','Centroid','Orientation','Extrema');
            % filter regions with small areas
            %idx = ([S.Area] > mean([S.Area]));
            idx = ([S.Area] > 10);
            S = S(idx');
            idx = ([S.Orientation] < 10 & [S.Orientation] > -10 & [S.Solidity] > 0.4);
            S = S(idx');
            %new_img = zeros(size(im_bw,1),size(im_bw,2));
            r_idx=1;
            l_idx=1;
            for k=1:size(S,1)
              k_x_pos = S(k).Centroid(1);
              if (k_x_pos > (P(1,6)-fh_box(1)) && k_x_pos < (P(1,2)-fh_box(1)))
                S_l(l_idx) = S(k);
                l_idx = l_idx+1;
              elseif (k_x_pos > (P(1,3)-fh_box(1)) && k_x_pos < (P(1,7)-fh_box(1)))
                S_r(r_idx) = S(k);
                r_idx = r_idx+1;
                %new_img(S(k).PixelIdxList) = 1;
              end
            end
            if (exist('S_l','var') && exist('S_r','var'))
              idx = ([S_l.Area] == max([S_l.Area]));
              S_l = S_l(idx');
              idx = ([S_r.Area] == max([S_r.Area]));
              S_r = S_r(idx'); 
              % save eyebrow keypoints to variables
              hold on;
              
              y_adj = fh_box(2)+(fh_box(4)/2);
              eb_l(:,1) = [S_l(1).Centroid(1)+fh_box(1) S_l(1).Centroid(2)+y_adj];
              eb_r(:,1) = [S_r(1).Centroid(1)+fh_box(1) S_r(1).Centroid(2)+y_adj];
              eb_l(:,2) = [S_l(1).Extrema(8,1)+fh_box(1) S_l(1).Extrema(8,2)+y_adj];
              eb_l(:,3) = [S_l(1).Extrema(3,1)+fh_box(1) S_l(1).Extrema(3,2)+y_adj];
              eb_r(:,2) = [S_r(1).Extrema(8,1)+fh_box(1) S_r(1).Extrema(8,2)+y_adj];
              eb_r(:,3) = [S_r(1).Extrema(3,1)+fh_box(1) S_r(1).Extrema(3,2)+y_adj];
              % plot keypoints
              plot(eb_l(1,:),eb_l(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
              plot(eb_r(1,:),eb_r(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
            end
          end
          
          % find center of lower lip
          if (P(1,4) > 0)
            %fh_box = [bbox(1) bbox(2) boxes{i}(3) P(1,2)-bbox(1)];
            %f_im = gr(fh_box(2)+(fh_box(4)/2):fh_box(2)+fh_box(4),fh_box(1):fh_box(1)+fh_box(3),:);
            
            lip_box = [P(1,4) P(2,8) P(1,5)-P(1,4) bbox(4)-P(2,8)];
            l_im = gr(lip_box(2):lip_box(2)+lip_box(4)+10,lip_box(1):lip_box(1)+lip_box(3),:);
            hold off;
            l_im = l_im(2:end,:)-l_im(1:end-1,:);
            %imshow(l_im);
            im_bw = (l_im>10);
            im_bw = imclose(im_bw,ones(size(im_bw,2)/8));
            %imshow(im_bw);
            S=regionprops(im_bw,'PixelIdxList','Area','Centroid');
            % filter regions with small areas
            idx = ([S.Area]==max([S.Area]));
            S = S(idx');
            %im_bw = zeros(size(im_bw,1),size(im_bw,2));
            %im_bw(S(1).PixelIdxList) = 1;
            %imshow(im_bw);
            hold on;
            lip_m(:,1) = [S(1).Centroid(1)+lip_box(1) S(1).Centroid(2)+lip_box(2)];
            % plot keypoints
            plot(lip_m(1,:),lip_m(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');           
          end
          % elapsed time
          t1 = toc;
          fprintf('MEX:    Elapsed time %f ms\n', t1*1000);
          
          % average the keypoints over a couple frames to smooth them
          
          hold on;
          % show landmarks
          %comps = ['S0'; 'S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'];
          plot(P(1, 1), P(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
          %text(P(1, 1)+1, P(2, 1)+1, comps(1,:), 'color', 'b', 'FontSize', 12);
          plot(P(1, 2:end), P(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          %text(P(1, 2:end)+1, P(2, 2:end)+1, comps(2:end,:), 'color', 'r', 'FontSize', 12);
          %plot(eb_l(1,:),eb_l(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          %plot(eb_r(1,:),eb_r(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          hold off;
          
          % average the keypoints over a couple frames to smooth them
          
        end; 
    
      
      Cal_flag   = get(handles.togglebutton1,'Value');
      if Cal_flag
         cal_cnt = 1+cal_cnt;
         % store keypoints (P, eb_l, eb_r, lip_m) to neutral model
         %
         %
         if(cal_cnt>100)
             set(handles.togglebutton1,'Value',0);
         end   
      else   
         cal_cnt = 0;
          
      end
      
      
        if flag_stop
            
            break;
        end
        pause(0.01);
    end


end
