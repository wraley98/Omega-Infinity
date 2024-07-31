function airways = SL_aspec2airways(aspec)
% SL_aspec2airways - create airway from specification
% On input:
%     aspec (airway specification): airways spec info
% On output:
%     airways (airways struct): airways info
% Call:
%     airways = SL_aspec2airway(aspec);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

airways = [];

roads = SL_gen_grid_roads(aspec.roads.xmin,aspec.roads.xmax,...
    aspec.roads.ymin,aspec.roads.ymax,aspec.roads.delx,aspec.roads.dely);
airways = SL_gen_airways(roads,aspec.launch_vertexes,...
    aspec.land_vertexes,aspec.min_lane_length,aspec.min_altitude,...
    aspec.max_altitude);
airways.roads.lat_min = aspec.roads.lat_min;
airways.roads.lat_max = aspec.roads.lat_max;
airways.roads.lon_min = aspec.roads.lon_min;
airways.roads.lon_max = aspec.roads.lon_max;
airways.roads.crs = aspec.roads.crs;
airways.roads.origin_alt = aspec.roads.origin_alt;
airways.roads.offset_x = aspec.roads.offset_x;
airways.roads.offset_y = aspec.roads.offset_y;
airways.roads.shift_x = aspec.roads.shift_x;
airways.roads.shift_y = aspec.roads.shift_y;
