function facedetect
%FACEDETECT  face detection demo
%
% Before start, addpath('/path/to/mexopencv');
%
%clc;
%clear all;
%close all;
addpath('./include');

% Load flandmark_model into MATLAB memory
model = flandmark_load_model('./include/flandmark_model.dat');

disp('Face detection demo. Press any key when done.');

% Load cascade file
xml_file = fullfile('./include','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

% Set up camera
camera = cv.VideoCapture;
pause(3); % Necessary in some environment. See help cv.VideoCapture

% Set up display window
window = figure('KeyPressFcn',@(obj,evt)setappdata(obj,'flag',true));
setappdata(window,'flag',false);

% Start main loop
%while true
while true
    % Grab and preprocess an image
    im = camera.read;
    im = cv.resize(im,0.5);
    gr = cv.cvtColor(im,'RGB2GRAY');
    gr = cv.equalizeHist(gr);
    % Detect
    boxes = classifier.detect(gr,'ScaleFactor',1.2,...
                                 'MinNeighbors',2,...
                                 'MinSize',[30,30]);
    % Draw results
    imshow(im);
    for i = 1:numel(boxes)
        rectangle('Position',boxes{i},'EdgeColor','g','LineWidth',2);
        
        bbox = [boxes{i}(1) boxes{i}(2) boxes{i}(1)+boxes{i}(3) boxes{i}(2)+boxes{i}(4)];
        % detect keypoints and display
        for j = 1 : size(boxes{i}, 1)
          tic
          P = flandmark_detector(gr, int32(bbox(j, :)),  model);
          % find eye-brows
          if (P(1,2) > 0)
            fh_box = [bbox(1) bbox(2) boxes{i}(3) P(1,2)-bbox(1)];
            f_im = gr(fh_box(1):fh_box(4)+fh_box(1),fh_box(2):fh_box(3)+fh_box(2),:);
            %f_im = rgb2hsv(f_im);
            %im_bw = edge(f_im,'sobel');
            %imshow(im_bw,[]);
            rectangle('Position',fh_box,'EdgeColor','y','LineWidth',2);
          end
          
          % elapsed time
          t1 = toc;
          fprintf('MEX:    Elapsed time %f ms\n', t1*1000);
          
          hold on;  
          % show landmarks
          %comps = ['S0'; 'S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'];
          plot(P(1, 1), P(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
          %text(P(1, 1)+1, P(2, 1)+1, comps(1,:), 'color', 'b', 'FontSize', 12);
          plot(P(1, 2:end), P(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          %text(P(1, 2:end)+1, P(2, 2:end)+1, comps(2:end,:), 'color', 'r', 'FontSize', 12);
          hold off;
        end;
    end    
    
    % Terminate if any user input
    flag = getappdata(window,'flag');
    if isempty(flag)||flag, break; end
    pause(0.1);
end

pause(0.1);
% Close
close(window);

end

