function waypts2 = SL_trans_waypts(waypts1,roads,lat,lon,alt,dx,dy)
% SL_trans_waypts - translate waypoints to another location
% On input:
%     waypts1 (nx4 array): waypoints
%     roads (roads struct): roads info
%     lat (float): latitude in degrees
%     lon (float): longitude in degrees
%     alt (float): altitude in meters
%     dx (float): offset in local CRS coords in x
%     dy (float): offset in local CRS coords in y
% On output:
%     waypts2 (nx4 array): waypoints translated
% Call:
%     w2 = SL_trans_waypts(w1,roads,lat,lon,alt,dx,dy);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

crs = roads.crs;
lat1 = roads.lat_min;
lon1 = roads.lon_min;
offset_x = roads.offset_x;
offset_y = roads.offset_y;
p_mercator_co = projcrs(crs);
[x_new,y_new] = projfwd(p_mercator_co,lat,lon);

waypts2 = waypts1;
waypts2(:,1) = waypts1(:,1) + x_new + dx;
waypts2(:,2) = waypts1(:,2) + y_new + dy;
