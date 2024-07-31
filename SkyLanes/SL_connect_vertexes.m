function [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways)
% SL_connect_vertexes - find corresponding air ane roundabout vertexes
%                       that connect two given ground vertexes
% On input:
%     v1 (int): index of start ground vertex
%     v2 (int): index of goal ground vertex
%     vertexes (nx3 array): all ground vertexes
%     airways (airways struct): airways info
% On output:
%     pt1 (1x3 vector): roundabout vertex above v1
%     pt2 (1x3 vector): roundabout vertex above v2
% Call:
%     [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

pt1 = vertexes(v1,:);
pt2 = vertexes(v2,:);
dir = pt2 - pt1;
dir = dir/norm(dir);
theta = SL_posori(atan2(dir(2),dir(1)));
angles_nei1 = airways.roundabouts_dn(v1).info.angles_nei;
angles_nei2 = airways.roundabouts_dn(v2).info.angles_nei;
index12 = find(angles_nei1==v2);
index21 = find(angles_nei2==v1);
pt1 = airways.roundabouts_dn(v1).info.lanes(index12,1:3);
pt2 = airways.roundabouts_dn(v2).info.lanes(index21,1:3);
