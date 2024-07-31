function SL_scenario2waypts(scenario)
% SL_scenario2waypts - produces waypoint files for flights in scenario
% On input:
%     scenario (scenario struct): has scenario info:
%       .airways (airways struct): airways info
%       .flights (flights struct): flights info
% On output:
%     a waypoints .txt file will be created for each flight
% Call:
%     SL_scenario2waypts(DD,'S2');
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

FT2M = 1/3.28;

if isempty(scenario)
    return
end

flights = scenario.flights;
if isempty(flights)
    return
end

num_flights = length(flights);
airways = scenario.airways;

fname = input('Enter base file name: ');

cmd0 = 'Type waypts desired \n';
cmd1 = '  1: local xyz (x,y,z,speed) \n';
cmd2 = '  2: UAS (t,lat,lon,speed) \n';
cmd3 = '  3: shifted (t,lat,lon,alt): ';
waypt_type = input([cmd0,cmd1,cmd2,cmd3]);

roads = airways.roads;
lat1 = roads.lat_min;
lon1 = roads.lon_min;
crs = roads.crs;
offset_x = roads.offset_x;
offset_y = roads.offset_y;
p_mercator_co = projcrs(crs);
[x1,y1] = projfwd(p_mercator_co,lat1,lon1);

if waypt_type==1
    for f = 1:num_flights
        speed = flights(f).speeds(1);
        r = [flights(f).route(1,1:3);flights(f).route(1,4:6);...
            flights(f).route(2:end,4:6)];
        [len_r,~] = size(r);
        % rm = r;
        % for k = 1:len_r
        %     rm(k,1) = rm(k,1) + x1 + offset_x;
        %     rm(k,2) = rm(k,2) + y1 + offset_y;
        % end
        % [lats,lons] = projinv(p_mercator_co,rm(:,1),rm(:,2));
        % alt = rm(:,3)*FT2M;
        % num_pts = length(lats);

        fnamef = [fname,'xyz',int2str(f),'.txt'];
        fid = fopen(fnamef,'w');
        for p = 1:len_r
            fprintf(fid,'%15.8f, %15.8f, %15.8f, %15.8f \n',r(p,1),...
                r(p,2),r(p,3),speed);
        end
        fclose(fid);
    end
elseif waypt_type==2
    roads = airways.roads;
    lat1 = roads.lat_min;
    lon1 = roads.lon_min;
    crs = roads.crs;
    offset_x = roads.offset_x;
    offset_y = roads.offset_y;
    p_mercator_co = projcrs(crs);
    [x1,y1] = projfwd(p_mercator_co,lat1,lon1);

    for f = 1:num_flights
        speed = flights(f).speeds(1)*FT2M;
        r = [flights(f).route(1,1:3);flights(f).route(1,4:6);...
            flights(f).route(2:end,4:6)];
        [len_r,~] = size(r);
        rm = r;
        for k = 1:len_r
            rm(k,1) = rm(k,1) + x1 + offset_x;
            rm(k,2) = rm(k,2) + y1 + offset_y;
        end
        [lats,lons] = projinv(p_mercator_co,rm(:,1),rm(:,2));
        alt = rm(:,3)*FT2M;
        num_pts = length(lats);

        fnamef = [fname,'UAS',int2str(f),'.txt'];
        fid = fopen(fnamef,'w');
        for p = 1:num_pts
            fprintf(fid,'%15.8f, %15.8f, %15.8f, %15.8f \n',lats(p),...
                lons(p),alt(p,1),speed);
        end
        fclose(fid);
    end
elseif waypt_type==3
    lat_new = input('Enter new lat (0 for no change): ');
    if lat_new==0
        lat_new = lat1;
    end
    lon_new = input('Enter new lon: (0 for no change): ');
    if lon_new==0
        lon_new = lon1;
    end
    alt_new = input('Enter new altitude in ft (0 for no change): ');
    if alt_new==0
        alt_new = roads.vertexes(1,3);
    end
    dx = input('Enter x shift (0 for no change): ');
    dy = input('Enter y shift (0 for no change): ');
    for f = 1:num_flights
        speed = flights(f).speeds(1)*FT2M;
        r = [flights(f).route(1,1:3);flights(f).route(1,4:6);...
            flights(f).route(2:end,4:6)];
        [len_r,~] = size(r);
        waypts2 = SL_trans_waypts(r,roads,lat_new,lon_new,alt_new,...
            dx,dy);
        [lats,lons] = projinv(p_mercator_co,waypts2(:,1),waypts2(:,2));
        alt = waypts2(:,3)*FT2M;

        fnamef = [fname,'UASs',int2str(f),'.txt'];
        fid = fopen(fnamef,'w');
        for p = 1:len_r
            fprintf(fid,'%15.8f, %15.8f, %15.8f, %15.8f \n',lats(p),...
                lons(p),alt(p),speed);
        end
        fclose(fid);
    end
end