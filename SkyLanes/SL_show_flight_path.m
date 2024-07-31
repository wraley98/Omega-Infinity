function SL_show_flight_path(airways,flights)
% SL_show_flight_path - shows overlay of flight path on lane network
% On input:
%     airways (airways struct): airways info
%     flights (flights struct): flights info
% On output:
%     N/A  produces figure with path overlayed on lane network
% Call:
%     SL_show_flight_path(airways,flights);
% Author:
%     T. Henderson
%     UU
%     Summer 2024
%

num_flights = length(flights);
flight_id = input('Flight ID: ');
flight_slot = input('Flight Slot: ');

for f = 1:num_flights
    if flights(f).flight_slot==flight_slot&flights(f).flight_id==flight_id
        path = flights(f).path;
        SL_show_airways3D(airways,path);
    end
end
