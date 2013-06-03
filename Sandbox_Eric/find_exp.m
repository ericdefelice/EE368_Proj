function exp_map = find_exp(bbox, KP, exp_models, neutral)
  % 1 - Happiness
  % 2 - Sadness
  % 3 - Surprise
  % 4 - Anger

  % initialize variables
  exp_map = zeros(4,1);
  cur_kps = zeros(2,15);
  cur_dist = zeros(2,15);
  
  % normalize the current keypoints to the bounding box size
  cur_kps(1,:) = (KP(1,:)-bbox(1))/bbox(3);
  cur_kps(2,:) = (KP(2,:)-bbox(2))/bbox(4);
  %cur_kps(1,2:end) = (KP(1,1)-KP(1,2:end))/bbox(3);
  %cur_kps(2,2:end) = (KP(2,1)-KP(2,2:end))/bbox(4);
  %cur_kps(:,1) = [KP(1,1)/bbox(3) KP(2,1)/bbox(4)];
  
  % find the distance of the keypoints in the current frame to the neutral
  for i=1:15
    cur_dist(:,i) = neutral(:,i)-cur_kps(:,i);
  end
  
  % find expressions if there is a neutral model
  if (nnz(neutral) > 0)
    % find correlation to happiness
    exp_map(1) = 2*(-1*(cur_dist(1,5))+(cur_dist(1,4)+cur_dist(2,4)+cur_dist(2,5)));
    % find correlation to sadness
    exp_map(2) = 2*(-1*(cur_dist(2,4)+cur_dist(2,5))-0.5*(sum(cur_dist(2,9:14))));
    % find correlation to suprise
    exp_map(3) = -1*(cur_dist(2,15)+cur_dist(1,4))+(sum(cur_dist(2,9:14))+cur_dist(1,5));
    % find correlation to anger
    exp_map(4) = 1*(-1*(sum(cur_dist(2,9:14))+cur_dist(1,11))+(cur_dist(1,13)));
    %{
    % find correlation to happiness
    if (cur_kps(1,4) > neutral(1,4))
      exp_map(1) = exp_map(1) + 0.25;
    end
    if (cur_kps(1,5) < neutral(1,5))
      exp_map(1) = exp_map(1) + 0.25;
    end
    if (cur_kps(2,4) > neutral(2,4))
      exp_map(1) = exp_map(1) + 0.25;
    end
    if (cur_kps(2,5) > neutral(2,5))
      exp_map(1) = exp_map(1) + 0.25;
    end
    % find correlation to sadness
    if (cur_kps(1,4) > neutral(1,4))
      exp_map(2) = exp_map(2) + 0.25;
    end
    if (cur_kps(1,5) < neutral(1,5))
      exp_map(2) = exp_map(2) + 0.25;
    end
    if (cur_kps(2,4) < neutral(2,4))
      exp_map(2) = exp_map(2) + 0.25;
    end
    if (cur_kps(2,5) < neutral(2,5))
      exp_map(2) = exp_map(2) + 0.25;
    end
    %}
  end
  
  %cur_dist = zeros(4,15);
  %neutral_dist = zeros(4,15);
  % apply weighting to the keypoints
  %kp_weight = [KP(:,4) KP(:,5) KP(:,9:15)];
  %exp_weight = [exp_models(:,4,:) exp_models(:,5,:) exp_models(:,9:15,:)];
  %neutral_weight = [neutral(:,4,:) neutral(:,5,:) neutral(:,9:15,:)];
  % normalize the current keypoints to the bounding box size
  %cur_kps(1,2:end) = (cur_kps(1,1)-cur_kps(1,2:end))/bbox(3);
  %cur_kps(2,2:end) = (kp_weight(2,1)-kp_weight(2,2:end))/bbox(4);
  %cur_kps(:,1) = [kp_weight(1,1)/bbox(3) kp_weight(2,1)/bbox(4)];
  % find the distance from the models to the keypoints
  %for i=1:15
  %  for j=1:4
  %    cur_dist(j,i) = sqrt((exp_models(1,i,j)-cur_kps(1,i))^2+(exp_models(2,i,j)-cur_kps(2,i))^2);
  %    neutral_dist(j,i) = sqrt((exp_models(1,i,j)-neutral(1,i))^2+(exp_models(2,i,j)-neutral(2,i))^2);
  %  end
  %end
  
  % compare the normalized keypoints to the models
  %for i=1:4
    %cur_dist(i,:) = cur_dist(i,:)./neutral_dist(i,:);
    %exp_map(i) = sqrt((1-mean2(cur_dist(i,:)))^2);
    %exp_map(i) = 1-(mean2(cur_dist(i,:))/mean2(neutral_dist(i,:)));
    
    %exp_map(i) = (exp_models(:,2:end,i) - cur_kps(:,2:end)).^2;
    %exp_map(i) = exp_map(i)-sum(sum((exp_models(:,2:end,i) - neutral(:,2:end)),1),2);
  %end
return