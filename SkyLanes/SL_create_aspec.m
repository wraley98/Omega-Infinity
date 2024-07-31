function aspec = SL_create_aspec
% SL_create_aspec - create airway specifications
% On input:
%     N/A
% On output:
%     aspec (aspec struct): airways info
% Call:
%      aspec1 = SL_create_aspec;
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

display('Create airway specification');
xmin = 0;
xmax = 0;
ymin = 0;
ymax = 0;
lat_min = 39.015715881037330;  % Colorado GPS lat origin in degrees
lon_min = -104.8962519661514;  % Colorado GPS lon origin in degrees
origin_alt = 2173.7;           % Colorado meters above sea level
crs = 2232;                    % CRS map index for Colorado
%lat_min = 39.0157161;
lat_max = 39.0168580;
lon_max = -104.8951167;
%lon_min = -104.8962942;
offset_x = 0;
offset_y = 0;
shift_x = 0;
shift_y = 0;
cmd = 1;
while cmd>0
    display(' ');
    display('roads (1), levels (2), launch_vertexes (3)');
    display('land_vertexes (4), min_lane_length (5)');
    display('min_altitude (6), max_altitude (7)');
    display('lat_min (8), lon_min (9)');
    display('Origin altitude (meters above sea level (10)');
    display('CRS Map Index (11)');
    display('shift x origin (12), shift y origin (13),');
    display('Reset airway creator (99)');
    display('Use test Airway (88)')
    display(' ');
    cmd = input('Choose Field (1 to 11 or 99/88; 0 to quit): ');
    display(' ');
    switch cmd
        case 1  % roads
            r_type = input("Road Type ('grid'): ");
            xyz = input('If x,y enter 1; if lat/lon enter 2: ');
            if isempty(xyz)|xyz~=2
                xmin = input('xmin: ');
                xmax = input('xmax: ');
                ymin = input('ymin: ');
                ymax = input('ymax: ');
            else
                lat_min = input('lat min: ');
                lat_max = input('lat max: ');
                lon_min = input('lon min: ');
                lon_max = input('lon max: ');
            end
            z = input('z: ');
            delx = input('delx: ');
            dely = input('dely: ');
            x_vals = [xmin:delx:xmax];
            num_cols = length(x_vals);
            y_vals = [ymin:dely:ymax];
            num_rows = length(y_vals);
        case 2 % number of levels
            levels = input('Number of levels (1 or 2): ');
        case 3 % launch vertexes
            num_vertexes = input('Number launch vertexes: ');
            launch_vertexes = [];
            for k = 1:num_vertexes
                v = input('Vertex index: ');
                launch_vertexes = [launch_vertexes,v];
            end
        case 4 % land vertexes
            num_vertexes = input('Number land vertexes: ');
            land_vertexes = [];
            for k = 1:num_vertexes
                v = input('Vertex index: ');
                land_vertexes = [land_vertexes,v];
            end
        case 5 % min_lane_length
            min_lane_length = input('Min_lane_length: ');
        case 6 % min altitude
            min_altitude = input('Min altitude: ');
        case 7 % max altitude
            max_altitude = input('Max altitude: ');
        case 8 % min_lat
            lat_min = input('lat_min: ');
        case 9 % min_lon
            lon_min = input('lon_min: ');
        case 10 % Origin altitude above sea level (meters)
            origin_alt = input('Origin altitude above sea level (m): ');
        case 11 % CRS Map Index
            crs = input('CRS Map Index: ');
        case 12 % shift x origin
            shift_x = input('Enter x shift: ');
        case 13 % shift y origin
            shift_y = input('Enter y shift: ');
        case 99 % reset
            fprintf('\\Resetting Airway Creator\\ \n\n')
            aspec = SL_create_aspec();
            return 
        case 88
            
            r_type = 'grid';

            z = -0.643;
            xmin = 1.963;
            xmax = 3.074;
            delx = 1;
            dely = 0.5;
            ymin = 0.728;
            ymax = 1.539;

            x_vals = [xmin:delx:xmax];
            num_cols = length(x_vals);
            y_vals = [ymin:dely:ymax];
            num_rows = length(y_vals);

            min_lane_length = 0.2;
            levels = 1;
            
            launch_vertexes = [1 4];
            land_vertexes = [2 3];

            min_altitude = 0.1;
            max_altitude = 0.1;

        otherwise

            cmd = 0;
    end
end
roads.road_type = r_type;
roads.xmin = xmin;
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
