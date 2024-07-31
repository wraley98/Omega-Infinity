function airways = SL_gen_airways(roads,launch_sites,land_sites,...
    min_lane_len,altitude1,altitude2)
% SL_gen_airways - generate airway lanes from a road network
% On input:
%     roads (road struct): road info
%     launch_site (1xm vector): vertex indexes of launch locations
%     land_sites (1xn vector): vertex indexes of lan locations
%     min_lane_len (float): minimum length of any lane
%     altitude1 (float): lower altitude for 2-level airway
%     altitude2 (float): upper altitude for 2-level airway
% On output:
%     airways (airway struct): lane information
% Call:
%     lanes_SLC = SL_gen_airways(roads,launch, land, min_lane_len,40,50);
% Author:
%     T. Henderson
%     UU
%     Fall 2020
%

airways.vertexes = roads.vertexes;
airways.edges = roads.edges;
airways.vertexes(:,3) = 0;

num_vertexes = length(airways.vertexes(:,1));

airways.launch_vertexes = launch_sites;
airways.land_vertexes = land_sites;
airways.min_lane_len = min_lane_len;
airways.g_z_upper = altitude2; %534
airways.g_z_lower = altitude1; %467
airways.roads = roads;

if altitude1~=altitude2
    airways = SL_gen_lanes(airways);
else
    airways = SL_gen_mono_lanes(airways);
end

airways.vertexes = roads.vertexes;
airways = SL_add_ground_height(airways);
airways = SL_node_degrees(airways);
airways = SL_lane_vertex_indexes(airways);
airways.smallest_angle = SL_smallest_angle(airways);
