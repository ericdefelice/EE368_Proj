function [Mouths, Brows]=getImAngles2(neutral)
%orderofkeys=['mL' 'mR' 'mB' 'c' 'n' 'e1L' 'e1R' 'e2L' 'e2R' 'b1C' 'b2C' 'top'];

%mouth angles
%orderofmouths=['mBR', 'mBL', 'cR', 'cL', 'nR', 'nL'];
Mouths=zeros(1,6);
[Mouths(1), Mouths(2), Mouths(3), Mouths(4), Mouths(5), Mouths(6)]= angleMouth(neutral(2,:), neutral(1,:), neutral(3,:), neutral(4,:), neutral(5,:));
%brow angels
%orderofbrows=['e1LB', 'e1RB', 'e2LB', 'e2RB', 'distBtop'];
Brows=zeros(1,6);
[Brows(1), Brows(2), Brows(3), Brows(4), Brows(5),  Brows(6)]= angleBrow2(neutral(6,:), neutral(7,:), neutral(10,:), neutral(8,:), neutral(9,:), neutral(11,:), neutral(12,:));

