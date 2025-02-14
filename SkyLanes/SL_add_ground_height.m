function airways_out = SL_add_ground_height(airways)
% SL_add_ground_height - add ground heights to lanes heights
% On input:
%     airways (airways struct): airways info
% On output:
%     airways_out (airways struct): ground height added to lanes
% Call:
%     airways = SL_add_grund_height(airways);
% Author:
%     T. Henderson
%     UU
%     Fall 2020
%

airways_out = airways;
vertexes = airways.vertexes;
num_vertexes = length(vertexes(:,1));
lane_vertexes = airways.lane_vertexes;
num_lane_vertexes = length(lane_vertexes(:,1));

for v1 = 1:num_lane_vertexes
    dx = lane_vertexes(v1,1)-vertexes(:,1);
    dy = lane_vertexes(v1,2)-vertexes(:,2);
    d = dx.^2 + dy.^2;
    index = find(d==min(d));
    if length(index)>1
        index = index(1);
    end
    airways_out.lane_vertexes(v1,3) = airways_out.lane_vertexes(v1,3) ...
        + vertexes(index,3);
    indexes = find(airways.lane_edges(:,1)==v1);
    airways_out.lanes(indexes,3) = airways_out.lanes(indexes,3)...
        + vertexes(index,3);
    indexes = find(airways.lane_edges(:,2)==v1);
    airways_out.lanes(indexes,6) = airways_out.lanes(indexes,6)...
        + vertexes(index,3);
end
