%%output mouth angles
%yasersoy
function [mBR, mBL, cR, cL, nR, nL]= angleMouth(mR, mL, mB, c, n)
%flip mL to right side on each step
if nargin>2
    mBR=myAng(mB,mR);
    mLl=[mL(1)+2*(mB(1)-mL(1)) mL(2)];
    mBL=myAng(mB,mLl);
end
if nargin>3
    cR=myAng(c,mR);
    mLl=[mL(1)+2*(c(1)-mL(1)) mL(2)];
    cL=myAng(c,mLl);
end
if nargin>4
    nR=myAng(n,mR);
    mLl=[mL(1)+2*(n(1)-mL(1)) mL(2)];
    nL=myAng(n,mLl);
end

end
