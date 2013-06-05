%%output mouth angles
%yasersoy
function [e1LB, e1RB, e2LB, e2RB, distBtop]= angleBrow(e1L, e1R, b1C, e2L, e2R, b2C, top)
%flip eL or eR to right side or bC on each step
if nargin>4
    e1Ll=[e1L(1)+2*(b1C(1)-e1L(1)) e1L(2)];
    e1LB=myAng(b1C,e1Ll);
    e1RB=myAng(b1C,e1R);
    e2Ll=[e2L(1)+2*(b2C(1)-e2L(1)) e2L(2)];
    e2LB=myAng(b2C,e2Ll);
    e2RB=myAng(b2C,e2R);
end
if nargin>5
    distBtop=top(2)-mean([b1C(2) b2C(2)]);
end

end