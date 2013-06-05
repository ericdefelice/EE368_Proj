%% ReadEmotion
%cleaned up version of detecting emotions of happiness, sadness, anger, and
%surprise using a neutral calibration stage

%inputs: frameCorners (two corners of the frame of the face used to detect
%top of face and chin: [topleft; bottomright]),
%keyPointsIn (keypoints needed for detection of emotion: [
%left lip corner
%right lip corner
%bottom of lip
%nose
%left eye left corner
%left eye right corner
%right eye left corner
%right eye right corner
%middle of left eyebrow
%middle of right eyebrow
%]),
%calibration (flag to state if we are calibrating- if so then neutral
%points are set for a new cycle: [1/0]),
%pastMB (if inputed is used to either continue calibration or to see if
%emotion has changed),
%nMouthsBrowsIn (if inputed is used to continue calibration or as neutral
%values)
%pastEmotion (string inputed from past calculation if quick non movement
%skipping will be used

%outputs: emotion (string stating happy, sad, angry, surprise, or neutral
%or confused),
%eMap (percentage of confidence in the estimation)
%outMB (angles outputed which can be inputed to next cycle),
%nMouthsBrows (calibrated neutral angles only outputed if in calibration)


function [emotion, eMap, outMB, nMouthsBrows]=readEmotionI(bbox, keyPointsIn, calibration, nMouthsBrowsIn, pastMB, pastEmotion, eMapIn)
top=[mean(keyPointsIn(9:10,1)), bbox(4)];
chin=[mean(keyPointsIn(1:2,1)), bbox(2)];
keyPoints=zeros(12,2);
keyPoints(1:3,:)=keyPointsIn(1:3,:);
keyPoints(4,:)=chin;
keyPoints(5:11,:)=keyPointsIn(4:end,:);
keyPoints(12,:)=top;
changeThresh=5;
emString={'Happy', 'Sad', 'Angry', 'Surprised'};
[Mouths, Brows]=getImAngles2(keyPoints);
%first check if there is pastkeys
if (exist('pastMB','var')&(~calibration))
    nMouthsBrows=nMouthsBrowsIn;
    if (sum(abs([Mouths Brows]-pastMB))<changeThresh)
        emotion=pastEmotion;
        eMap=eMapIn;
        outMB=pastMB;
        past=1;
    else
        past=0;
    end
else
    past=0;
end
if (calibration)
    [nMouths, nBrows]=getImAngles2(keyPoints);
    if(exist('nMouthsBrowsIn','var'))
        nMouthsBrows=[(nMouths+nMouthsBrowsIn(1:6))/2 (nBrows+nMouthsBrowsIn(7:12))/2];
    else
        nMouthsBrows=[nMouths nBrows];
    end
    emotion='Neutral';
    eMap=[0 0 0 0];
    outMB=nMouthsBrows;
elseif (~past&(nargin>3))
    outMB=[Mouths Brows];
    nMouthsBrows=nMouthsBrowsIn;
    innerE=[0 0 0 0];%emotions in order happy,sad,angry,surprise
    %anger/sad if outer eye angle difference is positive by 8 or more
    if (max(nMouthsBrowsIn([7,10])-Brows([1,4]))>8)
        innerE=[0 1 2 0];
        if (max(nMouthsBrowsIn([7,10])-Brows([1,4]))>12)
            innerE=innerE+[0 0 2 0];
        end
        %surprise/happy if outer eye angle difference is negative by 6 or more
    elseif(min(nMouthsBrowsIn([7,10])-Brows([1,4]))<-6)
        innerE=[1 0 0 2];
    end
    %sad if bottom lip to corners negative by 6.5 or more
    if (min(nMouthsBrowsIn([1,2])-Mouths([1,2]))<-6.5)
        innerE=innerE+[0 2 0 0];
        %surprise if bottom lip to corners positive by 7 or more
    elseif (max(nMouthsBrowsIn([1,2])-Mouths([1,2]))>7)
        innerE=innerE+[0 0 0 1];
    end
    %happy if corners rise relative to nose by 7.2 or more
    if (max(nMouthsBrowsIn([5,6])-Mouths([5,6]))>7.2)
        innerE=innerE+[3.5 0 0 0];
    end
    %surprised if all negative brows
    if(sum(nMouthsBrowsIn(7:10)-Brows(1:4))<0)
        innerE=innerE+[0 0 0 1];
    end
    %anger if all positive brows
    if(sum(nMouthsBrowsIn(7:10)-Brows(1:4))>0)
        innerE=innerE+[0 0 1 0];
    end
    %sad if mouth mostly negative
    if (sum(nMouthsBrowsIn(1:6)-Mouths(1:6))<0)
        innerE=innerE+[0 1 0 0];
    end
    
    %check if we are ready
    if (max(innerE)<2)
        emotion='Neutral';
        eMap=[0 0 0 0];
    elseif(length(find(innerE==max(innerE)))>1)
        if((innerE(3)==innerE(4))|(innerE(1)==innerE(2))|(innerE(2)==innerE(4)))
            emotion='Confused';
        else
            if((innerE(1)==innerE(4))&(innerE(1)>1))
                if(max(nMouthsBrowsIn([1,2])-Mouths([1,2]))>min(nMouthsBrowsIn([5,6])-Mouths([5,6])))
                    emotion='Surprised';
                    innerE=innerE+[0 0 0 0.5];
                else
                    emotion='Happy';
                    innerE=innerE+[0.5 0 0 0];
                end
            elseif ((innerE(1)==innerE(3))&(innerE(1)>1))
                if (max(nMouthsBrowsIn([5,6])-Mouths([5,6]))>12)
                    emotion='Happy';
                    innerE=innerE+[0.5 0 0 0];
                else
                    emotion='Angry';
                    innerE=innerE+[0 0 0.5 0];
                end
            elseif  ((innerE(2)==innerE(3))&(innerE(2)>1))
                if(min(nMouthsBrowsIn([3,4])-Mouths([3,4]))<-2)
                    emotion='Sad';
                    innerE=innerE+[0 0.5 0 0];
                else
                    emotion='Angry';
                    innerE=innerE+[0 0 0.5 0];
                end
            end
        end
        eMap=innerE/sum(innerE);
    else
        emotion=emString{find(innerE==max(innerE))};
        eMap=innerE/sum(innerE);
    end 
    eMap(3:4)=[eMap(4) eMap(3)];
    
end

end