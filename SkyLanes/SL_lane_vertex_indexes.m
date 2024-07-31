function airways = SL_lane_vertex_indexes(airways_in)
% SL_lane_vertex_indexes - add lane vertex indexes to airways
% On input:
%     airways_in (airways struct): airways info
% On output:
%     airways (airways struct): airways info with lane vertex indexes
% Call:
%     airways = SL_lane_vertex_indexes(airways);
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

airways = airways_in;
lanes = airways.lanes;
V = airways.lane_vertexes;

[num_lanes,~] = size(lanes);
for k = 1:num_lanes
    airways.lane_vertex_indexes = [0,0];
end

for k = 1:num_lanes
    x1 = lanes(k,1);
    y1 = lanes(k,2);
    z1 = lanes(k,3);
    index1 = find(V(:,1)==x1&V(:,2)==y1&V(:,3)==z1);
    x2 = lanes(k,4);
    y2 = lanes(k,5);
    z2 = lanes(k,6);
    airways.lane_vertex_indexes(k,1) = index1;
    index2 = find(V(:,1)==x2&V(:,2)==y2&V(:,3)==z2);
    airways.lane_vertex_indexes(k,2) = index2;
end
