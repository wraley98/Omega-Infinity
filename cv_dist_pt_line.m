function d = cv_dist_pt_line(point,line)
%
% cv_dist_pt_line - distance between a point and a line
% Call: d = cv_dist_pt_line(point,line);
% On input:
%     point: 3D point
%     line:  2x3 matrix of 2 points
% On output:
%     d: Euclidean distance between point and line
% Author:
%     Tom Henderson
%     7 January 2000
% Custom Functions Used:
%     none
% Method:
%     find point on line so that distance to point is minimized
% Testing:
% > d(1,1) = cv_dist_pt_line([0 0 0],[0 0 0; 1 0 0]);
% > d(1,2) = cv_dist_pt_line([0 0 0],[1 1 0; 1 0 0]);
% > d(1,3) = cv_dist_pt_line([1 0 0],[0 0 0; 1 1 0]);
% > d(1,4) = cv_dist_pt_line([2 0 0],[0 0 0; 1 1 0]);
% > d
%
% d =
%
%         0    1.0000    0.7071    1.4142
%
pt1 = line(1,:);
pt2 = line(2,:);
numer = (point(1)-pt1(1))*(pt2(1)-pt1(1)) ...
   + (point(2)-pt1(2))*(pt2(2)-pt1(2)) ...
   + (point(3)-pt1(3))*(pt2(3)-pt1(3));
denom = cv_dist_pt_pt(pt1,pt2)^2;
t = numer/denom;
closest_pt = pt1 + t*(pt2-pt1);
d = cv_dist_pt_pt(closest_pt,point);