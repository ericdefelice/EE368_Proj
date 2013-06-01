function KP = find_keypoints(img, cur_box, bbox, model, alg_num)
  % initialize variables
  eb_l = zeros(2,3);
  eb_r = zeros(2,3);
  lip_m = zeros(2,1);
  % find initial keypoints with flandmark
  KP(:,1:8) = flandmark_detector(img, int32(bbox),  model);
  % find eye-brows
  if (KP(2,2) > 0)
    % first find bounding box for forehead
    fh_bot = min([KP(2,2) KP(2,3) KP(2,6) KP(2,7)]);
    fh_box = [bbox(1) bbox(2) cur_box(3) fh_bot-bbox(2)];
    % crop forehead image
    f_im = img(fh_box(2)+fh_box(4)/4:fh_box(2)+fh_box(4),fh_box(1):fh_box(1)+fh_box(3),:);
    % perform adaptive histogram equalization to account for lighting
    f_im = adapthisteq(f_im,'NumTiles',[8 8],'ClipLimit',0.001);
    % perform median filtering for noise reduction
    f_im = medfilt2(f_im,[4 4]);
    % perform difference of box filtering in y-direction to find edges
    H_avg2 = fspecial('average',[4 2]);
    H_avg4 = fspecial('average',[8 2]);
    img2 = imfilter(f_im,H_avg2,'replicate','conv');
    img4 = imfilter(f_im,H_avg4,'replicate','conv');
    f_im = img4-img2;
    % adjust the resulting image to have a mean of zero
    f_im = f_im - mean2(f_im);
    % threshold image to bright values above a std dev from mean
    im_bw = (f_im>0.1*sqrt(var(var(double(f_im)))));
    % find regions in the thresholded image
    S=regionprops(im_bw,'PixelIdxList','Area','Centroid','Extrema');
    % filter out the small areas
    idx = ([S.Area] > mean([S.Area]));
    S = S(idx');
    % only keep the regions that have a centroid between the eye corners
    r_idx=1;
    l_idx=1;
    for k=1:size(S,1)
      k_x_pos = S(k).Centroid(1);
      if (k_x_pos > (KP(1,6)-fh_box(1)) && k_x_pos < (KP(1,2)-fh_box(1)))
        S_l(l_idx) = S(k);
        l_idx = l_idx+1;
      elseif (k_x_pos > (KP(1,3)-fh_box(1)) && k_x_pos < (KP(1,7)-fh_box(1)))
        S_r(r_idx) = S(k);
        r_idx = r_idx+1;
      end
    end
    % assume the largest region above each eye is the eyebrow
    if (exist('S_l','var') && exist('S_r','var'))
      idx = ([S_l.Area] == max([S_l.Area]));
      S_l = S_l(idx');
      idx = ([S_r.Area] == max([S_r.Area]));
      S_r = S_r(idx'); 
      % save eyebrow keypoints to variables
      y_adj = fh_box(2)+fh_box(4)/4;
      eb_l(:,1) = [S_l(1).Centroid(1)+fh_box(1) S_l(1).Centroid(2)+y_adj];
      eb_r(:,1) = [S_r(1).Centroid(1)+fh_box(1) S_r(1).Centroid(2)+y_adj];
      eb_l(:,2) = [S_l(1).Extrema(8,1)+fh_box(1) S_l(1).Extrema(8,2)+y_adj];
      eb_l(:,3) = [S_l(1).Extrema(3,1)+fh_box(1) S_l(1).Extrema(3,2)+y_adj];
      eb_r(:,2) = [S_r(1).Extrema(8,1)+fh_box(1) S_r(1).Extrema(8,2)+y_adj];
      eb_r(:,3) = [S_r(1).Extrema(3,1)+fh_box(1) S_r(1).Extrema(3,2)+y_adj];
      % map to KP output
      KP(:,9:14) = [eb_l eb_r];
      % plot keypoints
      %plot(eb_l(1,:),eb_l(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
      %plot(eb_r(1,:),eb_r(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    end
  end
          
  % find center of lower lip
  if (KP(1,4) > 0)
    % first find bounding box for mouth area
    lb_top = (max([KP(2,4) KP(2,5)])+KP(2,8))/2;
    lip_box = [KP(1,4) lb_top KP(1,5)-KP(1,4) (size(img,1)-lb_top)/2];
    l_im = img(lip_box(2):lip_box(2)+lip_box(4),lip_box(1):lip_box(1)+lip_box(3),:);
    % perform adaptive histogram equalization for lighting
    l_im = adapthisteq(l_im,'NumTiles',[2 2],'ClipLimit',0.001);
    % perform median filtering for noise reduction
    l_im = medfilt2(l_im,[2 2]);
    % perform a difference of 2 highpass filters in the y-direction
    % this is to catch dark to light transitions mor accurately
    % examples are upper lip to teeth or line between lips to lower lip
    kernel1 = [1 2 1; 0 0 0; -1 -2 -1];
    kernel2 = [-1 -1 -1; 0 0 0; 1 1 1];
    l_im1 = conv2(l_im,kernel1,'valid');
    l_im2 = conv2(l_im,kernel2,'valid');
    l_im = l_im1 - l_im2;
    % adjust the mean of the image to be zero
    l_im = l_im - mean2(l_im);
    % make an assumption that the center of the lip is exactly between
    % the two corners of the mouth in the x-direction
    % take the largest transition on that vertical line
    [~, ind] = max(l_im(:,round(size(l_im,2)/2)));
    % save that point as the lower lip keypoint
    lip_m(:,1) = [round(size(l_im,2)/2)+lip_box(1) ind+lip_box(2)];
    % map to KP output
    KP(:,15) = lip_m;
    % plot keypoints
    %plot(lip_m(1,:),lip_m(2,:), 'r*', 'LineWidth', 1, 'MarkerSize', 5, 'MarkerFaceColor', 'r');
  end
return