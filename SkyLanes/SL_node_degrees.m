function airwayso = SL_node_degrees(airways)
% SL_node_degrees - add node in and out degrees
% On input:
%     airways (airways struct): airways info
% On output:
%     airwayso (airways struct): airways info with node degrees
% Call:
%     ni = SL_node_degrees(i1,i2);
% Author:
%     T. Henderson
%     UU
%     Fall 2020
%

airwayso = airways;
lane_edges = airways.lane_edges;
lane_vertexes = airways.lane_vertexes;
[num_lane_vertexes,~] = size(lane_vertexes);

for k = 1:num_lane_vertexes
    airwayso.vertex_out_degree(k) = length(find(lane_edges(:,1)==k));
    airwayso.vertex_in_degree(k) = length(find(lane_edges(:,2)==k));
end
