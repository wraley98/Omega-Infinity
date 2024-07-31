function [zoomLevel,player,lat0,lon0,lats,lons] = SL_show_path_on_map(...
    airways,flights)
% SL_show_path_on_map - uses GIS functons to overlay path on map
% On input:
%     airways (airways struct): airways info
%     flights (flights struct): flights info
% On output:
%     zoomLevel (int): used in GIS display (can use +/- to zoom in window)
%     player (player struct): GIS variable
%     lat0 (float): latitude of lane network origin
%     lon0 (float): longitude of lane network origin
%     lats (nx1 vector): latitudes of path
%     lons (nx1 vector): longitudes of path
%     displays path overlayed on map (closed upon function exit)
% Call:
%      [zoomLevel,player,lat0,lon0,lats,lons] = ...
%               SL_show_path_on_map(airways,flights);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

zoomLevel = 18;
player = [];
lats = [];
lons = [];

lat0 = airways.roads.lat_min;
lon0 = airways.roads.lon_min;
num_flight_ID = 0;
num_flights = length(flights);
for k = 1:num_flights
    num_flight_ID = max(num_flight_ID,flights(k).flight_id);
end
num_slots = zeros(num_flight_ID,1);
for k = 1:num_flights
    f_ID = flights(k).flight_id;
    num_slots(f_ID) = max(num_slots(f_ID),flights(k).flight_slot);
end

cmd = 1;  % get flight
while ~isempty(cmd)&cmd~-0
    flight_ID = input('Enter flight ID: ');
    if flight_ID<1|flight_ID>num_flight_ID
        display('Flight ID out of range');
        return
    end
    slot = input('Enter flight slot: ');
    if slot<1|slot>num_slots;
        display('Slot out of range');
        return
    end
    cmd = input('Enter 0 or <RET> to quit loop: ');
end

for f = 1:num_flights
    if flights(f).flight_id==flight_ID&flights(f).flight_slot==slot
        route = flights(f).route;
    end
end

if isempty(route)
    return
end
path = [route(1,1:3);route(1:end,4:6)];
[len_path,~] = size(path);
lats = zeros(len_path,1);
lons = zeros(len_path,1);
for k = 1:len_path
    [lat,lon] = local2latlon(path(k,1),path(k,2),path(k,3),[lat0,lon0,...
        path(1,3)]);
    lats(k) = lat;
    lons(k) = lon;
end

cmd = 1;
while ~isempty(cmd)&cmd~=0
    zoomLevel = input('Enter zoomLevel (e.g., 18): ');
    player = geoplayer(lat0,lon0,zoomLevel);
    plotRoute(player,lats,lons);
    cmd = input('Enter 0 or <RET> to quit loop: ');
end
