function d = cv_dist_pt_pt(point1, point2)
%
% cv_dist_pt_pt - distance between 2 points
% Call: d = cv_dist_pt_pt(point1,point2);
% On input:
%     point1: point (vector; any dimension)
%     point2: point (vector; any dimension)
% On output:
%     d: Euclidean distance between the 2 points
% Author:
%     Tom Henderson
%     7 January 2000
% Custom Functions Used:
%     none
% Method:
%     calculate norm
% Testing:
% > cv_dist_pt_pt([0 0 0], [1 1 0])
%
% ans =
%
%    1.4142
%
% >  = cv_()
%
d = sqrt(sum((point2-point1).^2));