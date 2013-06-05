%calcualte angle
%yasersoy
function out = myAng(p1, p2)
out = atan2(p2(2)-p1(2),p2(1)-p1(1))*180/pi;
end