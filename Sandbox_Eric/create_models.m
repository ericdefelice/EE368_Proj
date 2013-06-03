% Create models for the 4 key expressions we are interested in
% 1 - Happiness
% 2 - Sadness
% 3 - Surprise
% 4 - Anger
% Store these models in a matlab file to be used during expression
% detection

clc;
clear all;
close all;

% Load flandmark_model into MATLAB memory
model = flandmark_load_model('./include/flandmark_model.dat');
% Load cascade file
xml_file = fullfile('./include','haarcascade_frontalface_alt2.xml');
classifier = cv.CascadeClassifier(xml_file);

% model variable
exp_models = zeros(2,15,4);

% loop for each expression
for exp_i = 1:4
  % first load all the model images for expression
  switch exp_i
    case 1,
      imgs = dir('model_images/happy*.gif');
    case 2,
      imgs = dir('model_images/sad*.gif');
    case 3,
      imgs = dir('model_images/surprise*.gif');
    case 4,
      imgs = dir('model_images/anger*.gif');
  end
  cur_model = zeros(2,15,size(imgs,1));
  for i = 1:size(imgs,1)
    img_name = imgs(i).name;
    [img,map] = imread(['model_images/' img_name]);
    img = ind2gray(img,map);
    % find bounding box for face
    img = cv.resize(img,0.4);
    %figure; imshow(img);
    boxes = classifier.detect(img,'ScaleFactor',1.3,...
                                   'MinNeighbors',2,...
                                   'MinSize',[40,40],'MaxSize',[200,200]);
    boxes{1}(4) = boxes{1}(4)+10;
    %rectangle('Position',boxes{1},'EdgeColor','g','LineWidth',2);
    % crop bounding box image from original image
    bbox = [boxes{1}(1) boxes{1}(2) boxes{1}(1)+boxes{1}(3) boxes{1}(2)+boxes{1}(4)];
    % find keypoints in iamge
    KP = find_keypoints(img, boxes{1}, bbox, model, 2);
    % show keypoints on the original grayscale image
    %hold on;
    %plot(KP(1, 1), KP(2, 1), 'b*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'b');
    %plot(KP(1, 2:end), KP(2, 2:end), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    %hold off;
    if (size(KP,2) == 15)
      cur_model(1,:,i) = (KP(1,:)-bbox(1))/bbox(3);
      cur_model(2,:,i) = (KP(2,:)-bbox(2))/bbox(4);
        
      %cur_model(1,2:end,i) = (KP(1,1)-KP(1,2:end))/bbox(3);
      %cur_model(2,2:end,i) = (KP(2,1)-KP(2,2:end))/bbox(4);
      %cur_model(:,1,i) = [KP(1,1)/bbox(3) KP(2,1)/bbox(4)];
    end
  end
  filt_model = zeros(2,15,nnz(cur_model(1,1,:)));
  j=1;
  for i = 1:size(cur_model,3)
    if (cur_model(1,1,i)~=0)
      filt_model(:,:,j)=cur_model(:,:,i);
      j = j + 1;
    end
  end
  model_sum = zeros(2,15);
  for f=1:size(filt_model,3)
    model_sum = filt_model(:,:,f)+model_sum;
  end
  % final model for happiness
  exp_models(:,:,exp_i) = model_sum./size(filt_model,3);
end
save('exp_models.mat','exp_models');

