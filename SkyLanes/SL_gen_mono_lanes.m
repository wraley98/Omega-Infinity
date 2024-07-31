function airways_out = SL_gen_mono_lanes(airways)
% SL_gen_mono_lanes - generate lanes for given single-level network
% On input:
%     airways (primitive airways struct): initial network info
%       .vertexes (nx3 array): road network vertexes
%       .edges (mx2 array): vertex index pair for edges
%       .launch_vertexes (1xp vector): vertex indexes of launch sites
%       .land_vertexes (1xq vector): vertex indexes of land sites
% On output:
%     airways_out (airways struct): airway lane info
%       .vertexes (nx3 array); road intersections or endpoints
%       .edges (mx2 array): edges between road vertexes
%       .launch_vertexes (1xp vector): road vertexes for launching
%       .land_vertexes (1xq vector): road vertexes for landing
%       .min_lane_len (flioat): minimum lane length
%       .g_z_upper (float): altitude for lanes
%       .g_z_lower (float): altitude for lanes (same as upper)
%       .roundabouts_up (roundabouts struct): empty
%       .roundabouts_dn (roundabouts struct): roundabouts for lanes
%       .lanes (kx6 array): lanes (entry point, exit point)
%       .lane_vertexes (wx3 array): lane vertexes
%       .lane_edges (zx2 array): vertex indexes for edges
%       .G (digraph): graph of airways
%       .launch_lane_vertexes (1xs vector): lane vertexes for launching
%       .land_lane_vertexes (1xt vector): lane vertexes for landing
% Call:
%     airways = SL_gen_mono_lanes(airways);
% Author:
%     T. Henderson
%     UU
%     Spring 2024
%

LAUNCH_CODE = -1;
LAND_CODE = -2;

vertexes = airways.vertexes;
num_vertexes = length(vertexes(:,1));
edges = airways.edges;
num_edges = length(edges(:,1));
num_rows = airways.roads.num_rows;
num_cols = airways.roads.num_cols;
all_lanes = [];

% Create roundabouts
for v = 1:num_vertexes
    [r_up,r_dn]= SL_roundabout(airways,v);
    r_up = [];
    all_lanes = [all_lanes;r_dn.lanes];
    airways.roundabouts_up(v).info = r_up;
    airways.roundabouts_dn(v).info = r_dn;
end

% Create launch lanes
launch_vertexes = airways.launch_vertexes;
launch_lanes = [];
for v = 1:num_vertexes
    if find(launch_vertexes==v)
        angles_nei = airways.roundabouts_dn(v).info.angles_nei;
        v_lanes = airways.roundabouts_dn(v).info.lanes;
        index = find(angles_nei==LAUNCH_CODE);
        launch_lanes = [launch_lanes;[v_lanes(index,1:2),vertexes(v,3),...
            v_lanes(index,1:3)]];
    end
end
all_lanes = [all_lanes;launch_lanes];

% Create land lanes
land_vertexes = airways.land_vertexes;
land_lanes = [];
for v = 1:num_vertexes
    if find(land_vertexes==v)
        angles_nei = airways.roundabouts_dn(v).info.angles_nei;
        v_lanes = airways.roundabouts_dn(v).info.lanes;
        index = find(angles_nei==LAND_CODE);
        land_lanes = [land_lanes;[v_lanes(index,1:3),...
            v_lanes(index,1:2),vertexes(v,3)]];
    end
end
all_lanes = [all_lanes; land_lanes];

% Create lanes between connected vertexes
e_lanes = [];
% Column 1
c = 1;
for r = num_rows:-1:2
    v1 = SL_rc2index(r,c,num_rows,num_cols);
    v2 = SL_rc2index(r-1,c,num_rows,num_cols);
    [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
    e_lanes = [e_lanes; pt1,pt2];
end
% row 1
r = 1;
for c = 1:num_cols-1
    v1 = SL_rc2index(r,c,num_rows,num_cols);
    v2 = SL_rc2index(r,c+1,num_rows,num_cols);
    [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
    e_lanes = [e_lanes; pt1,pt2];
end
% Column n
c = num_cols;
for r = 1:num_rows-1
    v1 = SL_rc2index(r,c,num_rows,num_cols);
    v2 = SL_rc2index(r+1,c,num_rows,num_cols);
    [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
    e_lanes = [e_lanes; pt1,pt2];
end
% row m
r = num_rows;
for c = num_cols:-1:2
    v1 = SL_rc2index(r,c,num_rows,num_cols);
    v2 = SL_rc2index(r,c-1,num_rows,num_cols);
    [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
    e_lanes = [e_lanes; pt1,pt2];
end
% rows 2 to m-1
dir = 1;
for r = 2:num_rows-1
    dir = 1 - dir;
    if dir==1  % go right
        for c = 1:num_cols-1
            v1 = SL_rc2index(r,c,num_rows,num_cols);
            v2 = SL_rc2index(r,c+1,num_rows,num_cols);
            [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
            e_lanes = [e_lanes; pt1,pt2];
        end
    else
        for c = num_cols:-1:2
            v1 = SL_rc2index(r,c,num_rows,num_cols);
            v2 = SL_rc2index(r,c-1,num_rows,num_cols);
            [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
            e_lanes = [e_lanes; pt1,pt2];
        end
    end
end
% cols 2:n-1
col_dir = 1;
for c = 2:num_cols-1
    col_dir = 1 - col_dir;
    row_dir = 1 - col_dir;
    for r = 1:num_rows-1
        row_dir = 1 - row_dir;
        if row_dir==1
            v1 = SL_rc2index(r+1,c,num_rows,num_cols);
            v2 = SL_rc2index(r,c,num_rows,num_cols);
            [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
            e_lanes = [e_lanes; pt1,pt2];
        else
            v1 = SL_rc2index(r,c,num_rows,num_cols);
            v2 = SL_rc2index(r+1,c,num_rows,num_cols);
            [pt1,pt2] = SL_connect_vertexes(v1,v2,vertexes,airways);
            e_lanes = [e_lanes; pt1,pt2];
        end
    end
end
all_lanes = [all_lanes; e_lanes];

airways.lanes = all_lanes;
num_all_lanes = length(all_lanes(:,1));
lane_vertexes = [all_lanes(:,1:3);all_lanes(:,4:6)];
lane_vertexes = SL_elim_redundant(lane_vertexes);
airways.lane_vertexes = lane_vertexes;
edges = zeros(num_all_lanes,2);
for e = 1:num_all_lanes
    pt1 = all_lanes(e,1:3);
    pt2 = all_lanes(e,4:6);
    index1 = find(pt1(1)==lane_vertexes(:,1)...
        &pt1(2)==lane_vertexes(:,2)&pt1(3)==lane_vertexes(:,3));
    index2 = find(pt2(1)==lane_vertexes(:,1)...
        &pt2(2)==lane_vertexes(:,2)&pt2(3)==lane_vertexes(:,3));
    edges(e,:) = [index1, index2];
end
airways.lane_edges = edges;
G = SL_airways2graph(airways);
airways.G = G;

% Set launch lane vertexes
[num_launch_lanes,dummy] = size(launch_lanes);
launch_lane_vertexes = zeros(1,num_launch_lanes);
for k = 1:num_launch_lanes
    launch_lane_vertexes(k) = find(launch_lanes(k,1)==lane_vertexes(:,1)...
        &launch_lanes(k,2)==lane_vertexes(:,2)...
        &launch_lanes(k,3)==lane_vertexes(:,3));
end
airways.launch_lane_vertexes = launch_lane_vertexes;

% Set land lane vertexes
[num_land_lanes,dummy] = size(land_lanes);
land_lane_vertexes = zeros(1,num_land_lanes);
for k = 1:num_land_lanes
    land_lane_vertexes(k) = find(land_lanes(k,4)==lane_vertexes(:,1)...
        &land_lanes(k,5)==lane_vertexes(:,2)...
        &land_lanes(k,6)==lane_vertexes(:,3));
end
airways.land_lane_vertexes = land_lane_vertexes;

num_lanes = length(airways.lanes(:,1));
lane_lengths = zeros(num_lanes,1);
for s = 1:num_lanes
    lane_lengths(s) = norm(airways.lanes(s,4:6)-airways.lanes(s,1:3));
end
airways.lane_lengths = lane_lengths;

airways_out = airways;

tch = 0;
