function airway = SL_Confrim_Airway(airway)

roads = airway.roads;

while ~strcmp(roads.road_type, 'grid')
   
    roads.road_type = input('Please input correct road type "grid": ');

end

while ~isempty(roads.xmin) || roads.xmin < 0
    
    roads.xmin = input('xmin incorrect, input correct xmin: ');

end

while ~isempty(roads.ymin) || roads.ymin < 0
    
    roads.ymin = input('ymin incorrect, input correct ymin: ');

end

while ~isempty(roads.z)
    
    roads.ymin = input('z not inputed, input z: ');

end

while ~isempty(roads.delx) || roads.delx < 0
    
    roads.delx = input('delx incorrect, input correct delx: ');

end

while ~isempty(roads.dely) || roads.dely < 0
    
    roads.dely = input('dely incorrect, input correct dely: ');

end

while ~isempty(roads.dely) || roads.dely < 0
    
    roads.dely = input('dely incorrect, input correct dely: ');

end


roads.x_vals = [roads.xmin:roads.delx:roads.xmax];
roads.num_cols = length(roads.x_vals);
roads.y_vals = [roads.ymin:roads.dely:roads.ymax];
roads.num_rows = length(roads.y_vals);

airway.roads = roads;

while ~isempty(airway.levels) || airway.levels < 1 || airway.levels > 2
    
    roads.levels = ...
        input('Number of levels incorrect, input correct level: ');

end

while ~isempty(airway.launch_vertexes) || airway.levels < 1 || airway.levels > 2
           
           num_vertexes = input('Launch vertex incorrect: ');
           launch_vertexes = [];

            for k = 1:num_vertexes
                v = input('Vertex index: ');
                launch_vertexes = [launch_vertexes,v];
            end
end

end

roads.road_type = r_type;

roads.xmax = xmax;
roads.ymin = ymin;
roads.ymax = ymax;
roads.lat_min = lat_min;
roads.lat_max = lat_max;
roads.lon_min = lon_min;
roads.lon_max = lon_max;
roads.crs = crs;
roads.origin_alt = origin_alt;
roads.offset_x = offset_x;
roads.offset_y = offset_y;
roads.z = z;
roads.delx = delx;
roads.dely = dely;
roads.num_cols = num_cols;
roads.num_rows = num_rows;
roads.shift_x = shift_x;
roads.shift_y = shift_y;
aspec.roads = roads;
aspec.levels = levels;
aspec.launch_vertexes = launch_vertexes;
aspec.land_vertexes = land_vertexes;
aspec.min_lane_length = min_lane_length;
aspec.min_altitude = min_altitude;
aspec.max_altitude = max_altitude;
