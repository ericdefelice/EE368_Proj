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
            f_im = gr(fh_box(2):fh_box(2)+fh_box(4),fh_box(1):fh_box(1)+fh_box(3),:);
            f_im = f_im(2:end,:)-f_im(1:end-1,:);
            %imshow(f_im,[]);
            im_bw = (f_im>mean2(f_im));
            %imshow(im_bw);
            S=regionprops(im_bw,'PixelIdxList','Area','Solidity','Centroid','Orientation');
            % filter regions with small areas
            idx = ([S.Area] > mean([S.Area]));
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
            idx = ([S_l.Area] == max([S_l.Area]));
            S_l = S_l(idx');
            idx = ([S_r.Area] == max([S_r.Area]));
            S_r = S_r(idx'); 
            %new_img(S_l(1).PixelIdxList)=1;
            %new_img(S_r(1).PixelIdxList)=1;
            %imshow(new_img,[]);
            eb_l = [S_l(1).Centroid(1)+fh_box(1) S_l(1).Centroid(2)+fh_box(2)];
            eb_r = [S_r(1).Centroid(1)+fh_box(1) S_r(1).Centroid(2)+fh_box(2)];
            %rectangle('Position',fh_box,'EdgeColor','y','LineWidth',2);
          end
          
          % elapsed time
          t1 = toc;
          fprintf('MEX:    Elapsed time %f ms\n', t1*1000);
          
          hold on;
          
          % average the keypoints over a couple frames to smooth them
          
          
          % show landmarks
          %comps = ['S0'; 'S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'];
          plot(P(1, 1), P(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
          %text(P(1, 1)+1, P(2, 1)+1, comps(1,:), 'color', 'b', 'FontSize', 12);
          plot(P(1, 2:end), P(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          %text(P(1, 2:end)+1, P(2, 2:end)+1, comps(2:end,:), 'color', 'r', 'FontSize', 12);
          plot(eb_l(1),eb_l(2), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          plot(eb_r(1),eb_r(2), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
          hold off;
          
          % average the keypoints over a couple frames to smooth them
          
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

